import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pos_tablet_app/src/features/orders/models/order.dart';
import 'package:pos_tablet_app/src/core/services/settings_service.dart';

class WhatsAppService {
  final _settingsService = SettingsService();

  // 1. Send Text Receipt
  // Updated to accept currency, total, and optional tendered/change info
  Future<void> sendTextReceipt(
      String phone, Order order, String currency, double totalPaid,
      {double? tendered, double? change} // NEW Named Parameters
      ) async {
    if (phone.isEmpty) return;

    // Fetch Shop Details
    final shopDetails = await _settingsService.getShopDetails();
    final shopName = shopDetails['name'] ?? 'My Shop';
    final shopAddress = shopDetails['address'] ?? '';
    final shopPhone = shopDetails['phone'] ?? '';

    // Clean phone number
    String cleanedPhone = phone.replaceAll(RegExp(r'\D'), '');
    if (cleanedPhone.startsWith('0')) {
      cleanedPhone = '263${cleanedPhone.substring(1)}';
    }

    // Build the Receipt Text
    final StringBuffer message = StringBuffer();

    // Header
    message.writeln('*$shopName*');
    if (shopAddress.isNotEmpty) message.writeln(shopAddress);
    if (shopPhone.isNotEmpty) message.writeln('Tel: $shopPhone');
    message.writeln('----------------');

    // Metadata
    message.writeln('Receipt: #${order.id}');
    message.writeln('Date: ${order.orderDate.toString().substring(0, 16)}');
    message.writeln('Cashier: ${order.cashierName ?? "Admin"}');
    message.writeln('----------------');

    // Items
    if (order.items != null) {
      for (var item in order.items!) {
        // We list items. Note: Individual item prices are usually stored in USD (Base).
        // To avoid confusion, we just list quantity and name here,
        // or you can show the base USD price if preferred.
        message.writeln('${item.quantity}x ${item.productName}');
      }
    }

    // Footer
    message.writeln('----------------');
    message.writeln('*TOTAL PAID: $currency ${totalPaid.toStringAsFixed(2)}*');

    // NEW: Add Tendered & Change lines
    if (tendered != null && change != null) {
      message.writeln('Tendered: $currency ${tendered.toStringAsFixed(2)}');
      message.writeln('Change: $currency ${change.toStringAsFixed(2)}');
    }

    message.writeln('----------------');
    message.writeln('Thank you for your support!');
    message.writeln('_Powered by Lifetime Images');
    // Create WhatsApp URL
    final Uri url = Uri.parse(
        "whatsapp://send?phone=$cleanedPhone&text=${Uri.encodeComponent(message.toString())}");

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch WhatsApp. Make sure it is installed.';
    }
  }

  // 2. Share PDF Receipt
  Future<void> sharePdfReceipt(File pdfFile, String text) async {
    if (!await pdfFile.exists()) return;

    await Share.shareXFiles(
      [XFile(pdfFile.path)],
      text: text,
    );
  }
}
