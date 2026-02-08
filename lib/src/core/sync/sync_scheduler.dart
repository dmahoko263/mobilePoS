import 'dart:convert';
import 'dart:math';

import 'package:isar/isar.dart';
import 'package:pos_tablet_app/src/core/sync/models/outbox_item.dart';
import 'package:pos_tablet_app/src/core/sync/services/pos_api.dart';

class SyncEngine {
  final Isar isar;
  final PosApi api;
  final String shopId;

  SyncEngine({
    required this.isar,
    required this.api,
    required this.shopId,
  });

  Future<void> enqueue(
    OutboxType type,
    Map<String, dynamic> payload,
    String key,
  ) async {
    final item = OutboxItem()
      ..shopId = shopId
      ..type = type.name
      ..payloadJson = jsonEncode(payload)
      ..idempotencyKey = key
      ..status = "QUEUED"
      ..retryCount = 0
      ..createdAt = DateTime.now()
      ..nextRetryAt = null
      ..lastError = null;

    await isar.writeTxn(() => isar.outboxItems.put(item));
  }

  Future<void> trySync({bool auto = true}) async {
    final now = DateTime.now();

    // Fetch queued items first (simple + avoids Isar QueryBuilder grouping issues)
    final queued = await isar.outboxItems
        .filter()
        .shopIdEqualTo(shopId)
        .statusEqualTo("QUEUED")
        .sortByCreatedAt()
        .findAll();

    final items = auto
        ? queued.where((i) => i.nextRetryAt == null || i.nextRetryAt!.isBefore(now))
        : queued;

    for (final item in items) {
      await _process(item);
    }
  }

  Future<void> _process(OutboxItem item) async {
    await isar.writeTxn(() async {
      item.status = "SENDING";
      await isar.outboxItems.put(item);
    });

    try {
      final payload = jsonDecode(item.payloadJson);

      switch (item.type) {
        case "statsDaily":
        case "statsHourly":
        case "stats30Min":
        case "statsOnDemand":
          await api.syncShopStats(payload as Map, item.idempotencyKey);
          break;

        case "backupAll":
          await api.uploadBackup(payload as Map, item.idempotencyKey);
          break;

        default:
          throw Exception("Unknown outbox type: ${item.type}");
      }

      await isar.writeTxn(() async {
        item.status = "DONE";
        item.lastError = null;
        item.nextRetryAt = null;
        await isar.outboxItems.put(item);
      });
    } catch (e) {
      final retry = item.retryCount + 1;
      final delaySeconds = min(retry * retry * 15, 600);

      await isar.writeTxn(() async {
        item.retryCount = retry;
        item.status = "QUEUED";
        item.lastError = e.toString();
        item.nextRetryAt = DateTime.now().add(Duration(seconds: delaySeconds));
        await isar.outboxItems.put(item);
      });
    }
  }
}
