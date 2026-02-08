import 'dart:convert';
import 'package:http/http.dart' as http;

class PesepayApi {
  final String baseUrl;
  PesepayApi(this.baseUrl);

  Future<Map<String, dynamic>> initiateEcocash({
    required String shopId,
    required String orderId,
    required double amount,
    required String currencyCode,
    required String phone,
    String? email,
    String methodCode = "PZW201", // EcoCash method code
  }) async {
    final res = await http.post(
      Uri.parse("$baseUrl/api/pos/payments/pesepay/initiate"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "shopid": shopId,
        "orderid": orderId,
        "amount": amount,
        "currencyCode": currencyCode,
        "phone": phone,
        "email": email ?? "",
        "paymentMethodCode": methodCode,
      }),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("PesePay init failed: ${res.statusCode} ${res.body}");
    }

    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> checkStatus(String referenceNumber) async {
    final res = await http.get(
      Uri.parse("$baseUrl/api/pos/payments/pesepay/status/$referenceNumber"),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("PesePay status failed: ${res.statusCode} ${res.body}");
    }

    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}
