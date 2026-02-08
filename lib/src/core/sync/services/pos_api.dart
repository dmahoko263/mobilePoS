import 'dart:convert';
import 'package:http/http.dart' as http;


class PosApi {
  final String baseUrl;
  PosApi(this.baseUrl);

  Future<void> syncShopStats(
      Map payload, String idempotencyKey) async {
    await http.post(
      Uri.parse("$baseUrl/api/pos/shop-stats"),
      headers: {
        "Content-Type": "application/json",
        "x-idempotency-key": idempotencyKey,
      },
      body: jsonEncode(payload),
    );
  }

  Future<void> uploadBackup(
      Map payload, String idempotencyKey) async {
    await http.post(
      Uri.parse("$baseUrl/api/pos/backups"),
      headers: {
        "Content-Type": "application/json",
        "x-idempotency-key": idempotencyKey,
      },
      body: jsonEncode(payload),
    );
  }
}
