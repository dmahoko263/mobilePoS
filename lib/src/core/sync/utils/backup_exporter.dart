
class BackupExporter {
  static Map<String, dynamic> exportAll({
    required String shopId,
    required String deviceId,
    required Map<String, dynamic> data,
  }) {
    return {
      "shop_id": shopId,
      "device_id": deviceId,
      "created_at": DateTime.now().toIso8601String(),
      "data": data,
    };
  }
}
