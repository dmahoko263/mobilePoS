import 'package:isar/isar.dart';

part 'outbox_item.g.dart';

enum OutboxType {
  statsDaily,
  statsHourly,
  stats30Min,
  statsOnDemand,
  backupAll,
}

@collection
class OutboxItem {
  Id id = Isar.autoIncrement;

  late String shopId;
  late String type; // enum name
  late String idempotencyKey;
  late String payloadJson;

  String status = "QUEUED"; // QUEUED | SENDING | DONE | FAILED
  int retryCount = 0;
  DateTime createdAt = DateTime.now();
  DateTime? nextRetryAt;
  String? lastError;
}
