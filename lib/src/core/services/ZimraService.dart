import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:isar/isar.dart';
import 'package:intl/intl.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:pointycastle/export.dart' as pc;
// FIX 1: Prefix crypto to avoid 'Digest' conflict with PointyCastle
import 'package:crypto/crypto.dart' as crypto;

import 'package:pos_tablet_app/src/core/services/isar_service.dart';
import 'package:pos_tablet_app/src/features/orders/models/order.dart';
import 'package:pos_tablet_app/src/features/fiscal/models/fiscal_config.dart';

class ZimraService {
  final Dio _dio = Dio();
  final IsarService _isarService;

  final String _baseUrl = 'https://fdmsapitest.zimra.co.zw';

  ZimraService(this._isarService) {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.headers = {
      'Content-Type': 'application/json',
    };
  }

  Future<void> fiscalizeOrder(Order order) async {
    final isar = await _isarService.db;

    // NOTE: If 'fiscalConfigs' is red, you MUST run: flutter pub run build_runner build
    final config = await isar.fiscalConfigs.where().findFirst();

    if (config == null || !config.isFiscalDayOpen) {
      throw Exception("Fiscal Day not open or device not configured");
    }

    // FIX 2: Assign variable FROM the result of the transaction
    final int thisReceiptGlobalNo = await isar.writeTxn(() async {
      config.lastReceiptGlobalNo += 1;
      await isar.fiscalConfigs.put(config);
      return config.lastReceiptGlobalNo; // Return value passes to variable
    });

    try {
      final receiptDate =
          DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(DateTime.now());
      final receiptTaxes = _calculateTaxes(order);

      // FIX 3: Added 'await' and passed 'isar' correctly matches new definition below
      final currentReceiptCounter = await _getDayReceiptCounter(isar, config);

      final receiptData = {
        "receiptType": "FISCALINVOICE",
        "receiptCurrency": (order.paymentCurrency ?? "USD").toUpperCase(),
        "receiptCounter": currentReceiptCounter,
        "receiptGlobalNo": thisReceiptGlobalNo,
        "invoiceNo": "INV-${order.id}",
        "receiptDate": receiptDate,
        "receiptLinesTaxInclusive": true,
        "receiptLines": _mapOrderItemsToLines(order),
        "receiptTaxes": receiptTaxes,
        "receiptPayments": [
          {
            "moneyTypeCode": _mapPaymentMethod(order.paymentMethod),
            "paymentAmount": order.totalAmount
          }
        ],
        "receiptTotal": order.totalAmount,
      };

      final signatureData = await _signData(receiptData, config.privateKeyPath!,
          config.deviceId, config.previousReceiptHash);

      final finalPayload = {
        "deviceID": config.deviceId,
        "receipt": {...receiptData, "receiptDeviceSignature": signatureData}
      };

      final response =
          await _dio.post('/Device/v1/submitReceipt', data: finalPayload);

      final serverSig = response.data['receiptServerSignature']['signature'];

      await isar.writeTxn(() async {
        order.isFiscalized = true;
        order.fiscalSignature = serverSig;
        order.fiscalDayNo = config.currentFiscalDayNo;
        order.receiptGlobalNo = thisReceiptGlobalNo;

        order.qrCodeData = _generateQRString(config.deviceId, receiptDate,
            thisReceiptGlobalNo, signatureData['hash']);

        config.previousReceiptHash = signatureData['hash'];
        await isar.fiscalConfigs.put(config);
        await isar.orders.put(order);
      });
    } catch (e) {
      print("Fiscalization Error: $e");
      await isar.writeTxn(() async {
        order.needsFiscalRetry = true;
        order.receiptGlobalNo = thisReceiptGlobalNo;
        order.fiscalDayNo = config.currentFiscalDayNo;
        await isar.orders.put(order);
      });
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // CRYPTOGRAPHY
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> _signData(Map<String, dynamic> data,
      String privateKeyPem, int deviceId, String? previousReceiptHash) async {
    final StringBuffer sb = StringBuffer();

    sb.write(deviceId.toString());
    sb.write(data['receiptType']);
    sb.write(data['receiptCurrency']);
    sb.write(data['receiptGlobalNo']);
    sb.write(data['receiptDate']);
    sb.write((data['receiptTotal'] * 100).round());

    final List<Map<String, dynamic>> taxes = data['receiptTaxes'];
    taxes.sort((a, b) => (a['taxCode'] as String).compareTo(b['taxCode']));

    for (var tax in taxes) {
      sb.write(tax['taxCode']);
      sb.write((tax['taxPercent'] as double).toStringAsFixed(2));
      sb.write(((tax['taxAmount'] as double) * 100).round());
      sb.write(((tax['salesAmountWithTax'] as double) * 100).round());
    }

    if (previousReceiptHash != null && previousReceiptHash.isNotEmpty) {
      sb.write(previousReceiptHash);
    }

    final String dataToSign = sb.toString();

    // FIX 1: Using the prefixed 'crypto' library to avoid Digest conflict
    final Uint8List dataBytes = utf8.encode(dataToSign);
    final crypto.Digest hashObj = crypto.sha256.convert(dataBytes);
    final String hashBase64 = base64.encode(hashObj.bytes);

    final RSAPrivateKey privateKey =
        CryptoUtils.rsaPrivateKeyFromPem(privateKeyPem);
    final signer = pc.Signer('SHA-256/RSA');
    signer.init(true, pc.PrivateKeyParameter<pc.RSAPrivateKey>(privateKey));

    final pc.RSASignature signature =
        signer.generateSignature(dataBytes) as pc.RSASignature;
    final String signatureBase64 = base64.encode(signature.bytes);

    return {"hash": hashBase64, "signature": signatureBase64};
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------

  // FIX 5: Updated definition to accept (Isar, FiscalConfig)
  Future<int> _getDayReceiptCounter(Isar isar, FiscalConfig config) async {
    if (config.fiscalDayOpenTime == null) return 1;

    final count = await isar.orders
        .filter()
        .orderDateGreaterThan(config.fiscalDayOpenTime!)
        .count();

    return count + 1;
  }

  List<Map<String, dynamic>> _mapOrderItemsToLines(Order order) {
    int index = 1;
    // FIX 3: Added (order.items ?? []) to prevent crash on null list
    return (order.items ?? []).map((item) {
      return {
        "receiptLineType": "Sale",
        "receiptLineNo": index++,
        "receiptLineHSCode": "",
        "receiptLineName": item.productName,
        "receiptLinePrice": item.priceAtSale,
        // FIX 4: Added null check (?? 0) for int math
        "receiptLineQuantity": item.quantity ?? 0,
        "receiptLineTotal": item.priceAtSale! * (item.quantity ?? 0),
        "taxCode": "A",
        "taxPercent": 15.00,
        "taxID": 1
      };
    }).toList();
  }

  List<Map<String, dynamic>> _calculateTaxes(Order order) {
    double totalTaxable = order.totalAmount;
    double taxRate = 0.15;
    double taxAmount = totalTaxable - (totalTaxable / (1 + taxRate));

    return [
      {
        "taxCode": "A",
        "taxID": 1,
        "taxPercent": 15.00,
        "taxAmount": double.parse(taxAmount.toStringAsFixed(2)),
        "salesAmountWithTax": totalTaxable
      }
    ];
  }

  String _mapPaymentMethod(String? method) {
    switch (method?.toLowerCase()) {
      case 'cash':
        return 'Cash';
      case 'swipe':
        return 'Card';
      case 'ecocash':
        return 'MobileWallet';
      default:
        return 'Other';
    }
  }

  String _generateQRString(
      int deviceId, String date, int globalNo, String hash) {
    final cleanDate = date.replaceAll(RegExp(r'[-T:]'), '');
    final cleanHash = hash.length > 20 ? hash.substring(0, 20) : hash;
    return "https://receipt.zimra.org/$deviceId/$cleanDate/$globalNo/$cleanHash";
  }
}
