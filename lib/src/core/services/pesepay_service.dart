import 'dart:convert';
import 'package:http/http.dart' as http;

class PesepayService {
  // KEYS
  static const String _integrationKey = 'cda06c6f-6446-441c-bb61-913d8b1071da';
  // static const String _encryptionKey = '5cbc81453a6546d6a209f574d966c15f';

  // URL (Payments Engine)
  static const String _baseUrl =
      'https://api.pesepay.com/api/payments-engine/v1';

  Future<Map<String, dynamic>> initiatePayment({
    required double amount,
    required String currency,
    required String reason,
    // Customer details removed to match the working JSON example
  }) async {
    final url = Uri.parse('$_baseUrl/payments/initiate');

    // PAYLOAD EXACTLY MATCHING YOUR JSON EXAMPLE
    final body = {
      "amountDetails": {
        "amount": amount,
        "currencyCode": currency // "ZWL" or "USD"
      },
      "reasonForPayment": reason,
      "merchantReference": "POS-${DateTime.now().millisecondsSinceEpoch}",
      "resultUrl": "https://google.com",
      "returnUrl": "mdtechpos://payment-return"
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'authorization': _integrationKey // Key goes in Header
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw 'Pesepay Error (${response.statusCode}): ${response.body}';
      }
    } catch (e) {
      throw 'Connection Error: $e';
    }
  }

  Future<String> checkTransactionStatus(String referenceCode) async {
    // Note: Node.js example uses pollUrl, but checking by reference is also standard
    final url = Uri.parse(
        '$_baseUrl/payments/check-payment?referenceCode=$referenceCode');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'authorization': _integrationKey
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Check for paid status (Nodejs example says 'paid': true/false inside response)
        if (data['paid'] == true) return 'PAID';
        return data['transactionStatus'] ?? data['status'] ?? "UNKNOWN";
      }
      return "UNKNOWN";
    } catch (e) {
      return "ERROR";
    }
  }
}
