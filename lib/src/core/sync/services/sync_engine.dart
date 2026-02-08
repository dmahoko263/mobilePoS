import 'dart:convert';
import 'dart:math';
import 'package:pos_tablet_app/src/core/sync/models/outbox_item.dart';
import 'package:pos_tablet_app/src/core/sync/services/pos_api.dart';
import 'package:isar/isar.dart';

class SyncEngine {
  final Isar isar;
  final PosApi api;
  final String shopId;

  SyncEngine({required this.isar, required this.api, required this.shopId});

  Future<void> enqueue(
    OutboxType type,
    Map<String, dynamic> payload,
    String key,
  ) async {
    final item = OutboxItem()
      ..shopId = shopId
      ..type = type.name
      ..payloadJson = jsonEncode(payload)
      ..idempotencyKey = key;

    await isar.writeTxn(() => isar.outboxItems.put(item));
  }

Future<void> trySync({bool auto = true}) async {
  final now = DateTime.now();

  final items = await isar.outboxItems
      .filter()
      .shopIdEqualTo(shopId)
      .statusEqualTo("QUEUED")
      .sortByCreatedAt()
      .findAll();

  final ready = auto
      ? items.where((i) => i.nextRetryAt == null || i.nextRetryAt!.isBefore(now))
      : items;

  for (final item in ready) {
    await _process(item);
  }
}


  Future<void> _process(OutboxItem item) async {
    await isar.writeTxn(() {
      item.status = "SENDING";
      return isar.outboxItems.put(item);
    });

    try {
      final payload = jsonDecode(item.payloadJson);

      switch (item.type) {
        case "statsDaily":
        case "statsHourly":
        case "stats30Min":
        case "statsOnDemand":
          await api.syncShopStats(payload, item.idempotencyKey);
          break;

        case "backupAll":
          await api.uploadBackup(payload, item.idempotencyKey);
          break;
      }

      await isar.writeTxn(() {
        item.status = "DONE";
        item.lastError = null;
        return isar.outboxItems.put(item);
      });
    } catch (e) {
      final retry = item.retryCount + 1;
      final delay = min(retry * retry * 15, 600);

      await isar.writeTxn(() {
        item.retryCount = retry;
        item.status = "QUEUED";
        item.lastError = e.toString();
        item.nextRetryAt =
            DateTime.now().add(Duration(seconds: delay));
        return isar.outboxItems.put(item);
      });
    }
  }
}
