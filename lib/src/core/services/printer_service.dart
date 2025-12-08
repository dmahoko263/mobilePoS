import 'dart:io';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw; // Windows PDF
import 'package:printing/printing.dart'; // Windows Printing
import 'package:pos_tablet_app/src/core/services/settings_service.dart';
import 'package:pos_tablet_app/src/features/orders/models/order.dart';
import 'package:pos_tablet_app/src/features/orders/models/order_item.dart';
import 'package:pos_tablet_app/src/features/auth/models/shop.dart'; // Import Shop Model

class PrinterService {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  // --- 1. GET DEVICES (Android Only) ---
  Future<List<BluetoothDevice>> getBondedDevices() async {
    if (Platform.isAndroid) {
      return await bluetooth.getBondedDevices();
    }
    return [];
  }

  // --- 2. CONNECT (Android Only) ---
  Future<bool> connect(BluetoothDevice? device) async {
    if (Platform.isAndroid) {
      if (device == null) return false;
      try {
        return (await bluetooth.connect(device)) ?? false;
      } catch (e) {
        print("Connection Error: $e");
        return false;
      }
    }
    return true; // Windows is always "ready"
  }

  Future<bool> get isConnected async {
    return await BlueThermalPrinter.instance.isConnected ?? false;
  }

  // --- 3. MAIN PRINT FUNCTION ---
  Future<void> printReceipt({
    required Order order,
    required List<OrderItem> items,
    required Map<String, String> shopDetails,
    required Map<String, String> customerDetails,
    required String paymentMethod,
    required String currency,
    required double totalPaid,
    required String cashierName,
    double? tendered,
    double? change,
    Shop? branchShop, // <--- NEW PARAMETER
  }) async {
    // WINDOWS: PDF Printing
    if (Platform.isWindows) {
      await _printWindowsPdf(
          order,
          items,
          shopDetails,
          customerDetails,
          paymentMethod,
          currency,
          totalPaid,
          cashierName,
          tendered,
          change,
          branchShop);
      return;
    }

    // ANDROID: Bluetooth ESC/POS
    if (Platform.isAndroid) {
      if ((await bluetooth.isConnected) != true) {
        bool success = await autoConnect();
        if (!success) return;
      }
      ;
      await _printAndroidBluetooth(
          order,
          items,
          shopDetails,
          customerDetails,
          paymentMethod,
          currency,
          totalPaid,
          cashierName,
          tendered,
          change,
          branchShop);
    }
  }

// --- AUTO CONNECT ---
  Future<bool> autoConnect() async {
    if (!Platform.isAndroid) return true; // Windows always true

    // 1. Check if already connected
    if ((await bluetooth.isConnected) == true) return true;

    // 2. Get Saved Address
    final SettingsService settings = SettingsService();
    final String? savedAddress = await settings.getPrinterAddress();

    if (savedAddress == null) return false; // No printer configured

    // 3. Find Device
    List<BluetoothDevice> devices = await bluetooth.getBondedDevices();
    try {
      final device = devices.firstWhere((d) => d.address == savedAddress);
      return (await bluetooth.connect(device)) ?? false;
    } catch (e) {
      return false; // Saved device not found or connection failed
    }
  }

  // ============================================================
  // LOGIC A: WINDOWS PDF PRINTING
  // ============================================================
  Future<void> _printWindowsPdf(
      Order order,
      List<OrderItem> items,
      Map<String, String> shopDetails,
      Map<String, String> customerDetails,
      String paymentMethod,
      String currency,
      double totalPaid,
      String cashierName,
      double? tendered,
      double? change,
      Shop? branchShop // <--- Added here
      ) async {
    final doc = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final numFormat = NumberFormat("#,##0.00", "en_US");

    final SettingsService settings = SettingsService();
    final String? customLogoPath = await settings.getShopLogo();
    pw.MemoryImage? pdfLogo;

    if (customLogoPath != null && File(customLogoPath).existsSync()) {
      pdfLogo = pw.MemoryImage(File(customLogoPath).readAsBytesSync());
    }

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.all(5),
        build: (pw.Context context) {
          return pw.Column(
            children: [
              if (pdfLogo != null) pw.Image(pdfLogo, width: 60, height: 60),

              // 1. HEAD OFFICE DETAILS
              pw.Text(shopDetails['name'] ?? 'Head Office',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 16)),
              if (shopDetails['address']?.isNotEmpty ?? false)
                pw.Text(shopDetails['address']!,
                    style: const pw.TextStyle(fontSize: 10)),
              if (shopDetails['phone']?.isNotEmpty ?? false)
                pw.Text('Tel: ${shopDetails['phone']!}',
                    style: const pw.TextStyle(fontSize: 10)),

              // 2. BRANCH DETAILS
              if (branchShop != null) ...[
                pw.SizedBox(height: 5),
                pw.Text('Branch: ${branchShop.name}',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 12)),
                if (branchShop.address != null)
                  pw.Text(branchShop.address!,
                      style: const pw.TextStyle(fontSize: 10)),
                if (branchShop.phone != null)
                  pw.Text('Branch Tel: ${branchShop.phone!}',
                      style: const pw.TextStyle(fontSize: 10)),
              ],

              pw.Divider(borderStyle: pw.BorderStyle.dashed),

              _pwRow('Receipt:', '#${order.id}'),
              _pwRow('Date:', dateFormat.format(order.orderDate)),
              _pwRow('Cashier:', cashierName),

              pw.Divider(borderStyle: pw.BorderStyle.dashed),

              ...items.map((item) {
                final total = (item.priceAtSale ?? 0) * (item.quantity ?? 1);
                return pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                        child: pw.Text('${item.quantity}x ${item.productName}',
                            style: const pw.TextStyle(fontSize: 10))),
                    pw.Text(numFormat.format(total),
                        style: const pw.TextStyle(fontSize: 10)),
                  ],
                );
              }),

              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              _pwRow('TOTAL ($currency):', numFormat.format(totalPaid),
                  isBold: true, fontSize: 14),
              if (tendered != null)
                _pwRow('Tendered:', numFormat.format(tendered)),
              if (change != null) _pwRow('Change:', numFormat.format(change)),

              pw.SizedBox(height: 5),
              _pwRow('Paid via:', paymentMethod),
              pw.SizedBox(height: 10),
              pw.Text('Thank you for your support!',
                  style: const pw.TextStyle(fontSize: 10)),
              pw.Text('Powered by Lifetime Images',
                  style: pw.TextStyle(
                      fontSize: 8, fontWeight: pw.FontWeight.bold)),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
        onLayout: (format) async => doc.save(), name: 'Receipt_${order.id}');
  }

  pw.Widget _pwRow(String label, String value,
      {bool isBold = false, double fontSize = 10}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label,
            style: pw.TextStyle(
                fontSize: fontSize,
                fontWeight: isBold ? pw.FontWeight.bold : null)),
        pw.Text(value,
            style: pw.TextStyle(
                fontSize: fontSize,
                fontWeight: isBold ? pw.FontWeight.bold : null)),
      ],
    );
  }

  // ============================================================
  // LOGIC B: ANDROID BLUETOOTH PRINTING
  // ============================================================
// ============================================================
  // LOGIC B: ANDROID BLUETOOTH PRINTING (INK SAVER MODE)
  // ============================================================
  Future<void> _printAndroidBluetooth(
      Order order,
      List<OrderItem> items,
      Map<String, String> shopDetails,
      Map<String, String> customerDetails,
      String paymentMethod,
      String currency,
      double totalPaid,
      String cashierName,
      double? tendered,
      double? change,
      Shop? branchShop) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    // HELPER: Create a light dashed line instead of a solid block line
    // 32 dashes fits well on 58mm paper with normal font
    final String dashedLine = '--------------------------------';

    try {
      final SettingsService settings = SettingsService();
      final String? customLogoPath = await settings.getShopLogo();

      // OPTIONAL: If the logo is too dark, comment this block out to save more ink
      if (customLogoPath != null && File(customLogoPath).existsSync()) {
        final Uint8List imgBytes = await File(customLogoPath).readAsBytes();
        final image = img.decodeImage(imgBytes);
        if (image != null) {
          // Resize to smaller width to save ink
          final resized = img.copyResize(image, width: 250);
          bytes += generator.image(resized);
        }
      }
    } catch (e) {
      print(e);
    }

    // 1. HEADER (Reduced from size2 to size1)
    bytes += generator.text(shopDetails['name'] ?? '',
        styles: const PosStyles(
            align: PosAlign.center,
            bold: true, // Keep bold, but remove size2
            height: PosTextSize.size1,
            width: PosTextSize.size1));

    if (shopDetails['address']?.isNotEmpty ?? false) {
      bytes += generator.text(shopDetails['address']!,
          styles: const PosStyles(align: PosAlign.center));
    }
    if (shopDetails['phone']?.isNotEmpty ?? false) {
      bytes += generator.text('Tel: ${shopDetails['phone']}',
          styles: const PosStyles(align: PosAlign.center));
    }

    // 2. BRANCH (Standard text, no bold unless necessary)
    if (branchShop != null) {
      bytes += generator.feed(1);
      bytes += generator.text('Branch: ${branchShop.name}',
          styles: const PosStyles(align: PosAlign.center, bold: false));
      if (branchShop.phone != null) {
        bytes += generator.text('Tel: ${branchShop.phone}',
            styles: const PosStyles(align: PosAlign.center));
      }
    }

    // Light separator
    bytes += generator.text(dashedLine,
        styles: const PosStyles(align: PosAlign.center));

    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    // Receipt Info (Plain text)
    bytes += generator.row([
      PosColumn(text: 'Rcpt: #${order.id}', width: 6),
      PosColumn(
          text: dateFormat.format(order.orderDate),
          width: 6,
          styles: const PosStyles(align: PosAlign.right)),
    ]);
    bytes += generator.text('Cashier: $cashierName');

    // Light separator
    bytes += generator.text(dashedLine,
        styles: const PosStyles(align: PosAlign.center));

    // Column Headers (Removed Bold)
    bytes += generator.row([
      PosColumn(text: 'Item', width: 6),
      PosColumn(text: 'Qty', width: 2),
      PosColumn(
          text: 'Tot',
          width: 4,
          styles: const PosStyles(align: PosAlign.right)),
    ]);

    // Items
    for (var item in items) {
      double itemTotal = (item.priceAtSale ?? 0) * (item.quantity ?? 1);
      bytes += generator.row([
        PosColumn(text: item.productName ?? 'Item', width: 6),
        PosColumn(text: '${item.quantity}', width: 2),
        PosColumn(
            text: itemTotal.toStringAsFixed(2),
            width: 4,
            styles: const PosStyles(align: PosAlign.right)),
      ]);
    }

    // Light separator
    bytes += generator.text(dashedLine,
        styles: const PosStyles(align: PosAlign.center));

    // TOTAL (Keep Bold, but size1)
    bytes += generator.row([
      PosColumn(
          text: 'TOTAL $currency:',
          width: 6,
          styles: const PosStyles(bold: true)), // Removed size2
      PosColumn(
          text: totalPaid.toStringAsFixed(2),
          width: 6,
          styles: const PosStyles(
              bold: true, align: PosAlign.right)), // Removed size2
    ]);

    if (tendered != null && change != null) {
      bytes += generator.row([
        PosColumn(text: 'Paid:', width: 6),
        PosColumn(
            text: tendered.toStringAsFixed(2),
            width: 6,
            styles: const PosStyles(align: PosAlign.right)),
      ]);
      bytes += generator.row([
        PosColumn(text: 'Change:', width: 6),
        PosColumn(
            text: change.toStringAsFixed(2),
            width: 6,
            styles: const PosStyles(align: PosAlign.right)),
      ]);
    }

    bytes += generator.text('Method: $paymentMethod',
        styles: const PosStyles(align: PosAlign.right));

    bytes += generator.feed(1);

    // Footer (Removed Bold, Removed Background)
    bytes += generator.text('Thank you for your support!',
        styles: const PosStyles(align: PosAlign.center));

    bytes += generator.text('Powered by Lifetime Images',
        styles: const PosStyles(
            align: PosAlign.center,
            bold: false, // Turn off bold
            reverse: false // Ensure no black background
            ));

    bytes += generator.feed(2);
    bytes += generator.cut();

    try {
      await bluetooth.writeBytes(Uint8List.fromList(bytes));
    } catch (e) {
      print(e);
    }
  }
}
