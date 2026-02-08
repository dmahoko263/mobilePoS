// lib/src/features/fiscal/models/fiscal_config.dart
import 'package:isar/isar.dart';

part 'fiscal_config.g.dart';

@collection
class FiscalConfig {
  Id id = Isar.autoIncrement;

  // Device Credentials from ZIMRA
  late int deviceId;
  late String activationKey;
  late String deviceSerialNo; // Your internal serial or hardware serial

  // Counters (CRITICAL for ZIMRA validation)
  int currentFiscalDayNo = 0;
  int lastReceiptGlobalNo = 0;

  // State
  bool isFiscalDayOpen = false;
  DateTime? fiscalDayOpenTime;

  // Token/Cert paths (In production, store sensitive keys in FlutterSecureStorage)
  String? certificatePath;
  String? privateKeyPath;
  // NEW REQUIRED FIELD
  String? previousReceiptHash;
}
