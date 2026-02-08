import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart';

class CloudSyncService {
  // Replace with your DEPLOYED backend URL
  static const String _baseUrl = 'https://your-backend-url.com/api';

  // Singleton
  static final CloudSyncService _instance = CloudSyncService._internal();
  factory CloudSyncService() => _instance;
  CloudSyncService._internal();

  String? _shopId;

  // 1. INIT: Call this on app start
  Future<void> initialize(String shopId) async {
    _shopId = shopId;
    await checkLicenseStatus();
  }

  // 2. CHECK LICENSE (The Kill Switch)
  // Returns: 'active', 'expired', 'blocked'
  Future<String> checkLicenseStatus() async {
    if (_shopId == null) {
      return 'active'; // Default to active if offline/setup mode
    }

    try {
      final response =
          await http.get(Uri.parse('$_baseUrl/check-license/$_shopId'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final status = data['status']; // 'active', 'blocked', 'expired'

        // Save status locally so we remember even if offline next time
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('license_status', status);

        if (status == 'blocked') {
          // TODO: TRIGGER APP LOCK SCREEN NAVIGATOR HERE
          print("ACCESS BLOCKED BY ADMIN");
        }
        return status;
      }
    } catch (e) {
      print("Offline or Server Error: $e");
    }

    // If offline, fallback to last known status
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('license_status') ?? 'active';
  }

  // 3. UPLOAD BACKUP
  Future<bool> uploadBackup(File backupFile) async {
    if (_shopId == null) return false;

    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('$_baseUrl/upload-backup/$_shopId'));

      request.files.add(await http.MultipartFile.fromPath(
          'backup', backupFile.path,
          filename: basename(backupFile.path)));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        print("Backup Uploaded Successfully");
        return true;
      } else {
        print("Upload Failed: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Backup Error: $e");
      return false;
    }
  }

  // 4. SYNC PERFORMANCE (Daily Stats)
  Future<void> syncDailyStats(
      {required double salesUSD,
      required double salesZiG,
      required int txCount}) async {
    if (_shopId == null) return;

    try {
      await http.post(Uri.parse('$_baseUrl/sync-stats'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'shopId': _shopId,
            'totalSalesUSD': salesUSD,
            'totalSalesZiG': salesZiG,
            'transactionCount': txCount,
            'date': DateTime.now().toIso8601String()
          }));
    } catch (e) {
      print("Sync Error: $e");
    }
  }
}
