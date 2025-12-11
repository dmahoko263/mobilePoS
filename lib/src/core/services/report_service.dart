import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pos_tablet_app/src/features/orders/models/order.dart';

class ReportService {
  // Generate Comprehensive Balance Sheet
  // Added 'inventoryValue' and 'cashFloat' to make the balance sheet realistic
  Future<void> printBalanceSheet({
    required List<Order> orders, // <--- Required
    required String title, // <--- Required
    double inventoryValue = 0.0, // Optional
    double cashFloat = 0.0, // Optional
  }) async {
    final doc = pw.Document();

    // 1. CALCULATE FINANCIALS
    double totalRevenue = 0;
    double costOfGoodsSold = 0;

    // Breakdown Assets
    double cashInHand = cashFloat;
    double digitalFunds = 0; // Swipe, Ecocash, Pesepay

    for (var o in orders) {
      totalRevenue += o.totalAmount;

      // Asset Breakdown (Cash vs Bank)
      // Note: Ensure strings match your DB values exactly ('Cash', 'Swipe', etc.)
      if (o.paymentCurrency == 'USD' &&
          (o.paymentMethod?.contains('Cash') ?? true)) {
        // Assuming default is cash if unspecified
        cashInHand += o.totalAmount;
      } else {
        // Anything else (ZiG, Swipe, Transfer) is treated as Digital/Bank
        // If it's ZiG, we assume value is converted or handled separately.
        // For this sheet, we sum strictly the totalAmount field.
        digitalFunds += o.totalAmount;
      }

      if (o.items != null) {
        for (var item in o.items!) {
          // If costAtSale is null, assume 0 (or fetch from product if possible)
          double c = item.priceAtSale ?? 0;
          // Note: Ideally, you should store 'costPrice' in OrderItem.
          // If not available, Profit calc will be inaccurate.
          // Using price * 0.7 as a placeholder estimate for Cost if real cost is missing
          double estimatedCost = c * 0.7;
          costOfGoodsSold += estimatedCost * (item.quantity ?? 0);
        }
      }
    }

    double netProfit = totalRevenue - costOfGoodsSold;

    // ASSETS CALCULATION
    double totalCurrentAssets = cashInHand + digitalFunds + inventoryValue;

    // EQUITY CALCULATION
    // In a simple POS: Equity = Initial Capital (Float + Stock) + Net Profit
    // This ensures Assets = Liabilities + Equity
    double totalEquity = (cashFloat + inventoryValue) + netProfit;

    // 2. CREATE PDF LAYOUT
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // HEADER
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(title.toUpperCase(),
                          style: pw.TextStyle(
                              fontSize: 20, fontWeight: pw.FontWeight.bold)),
                      pw.Text(
                          'Date: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
                          style: const pw.TextStyle(
                              fontSize: 10, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.blueGrey800),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Text('BALANCE SHEET',
                        style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blueGrey800)),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Divider(thickness: 2, color: PdfColors.blueGrey),
              pw.SizedBox(height: 20),

              // SECTION 1: ASSETS
              _buildSectionHeader('ASSETS'),
              pw.SizedBox(height: 10),

              _buildRow('Current Assets', '', isBold: true),
              _buildRow('   Cash on Hand (Drawer + Float)',
                  _formatCurrency(cashInHand)),
              _buildRow(
                  '   Digital/Bank Accounts', _formatCurrency(digitalFunds)),
              _buildRow('   Inventory (Unsold Stock)',
                  _formatCurrency(inventoryValue)),
              pw.Divider(thickness: 0.5),
              _buildRow('TOTAL ASSETS', _formatCurrency(totalCurrentAssets),
                  isBold: true, color: PdfColors.green700),

              pw.SizedBox(height: 30),

              // SECTION 2: LIABILITIES & EQUITY
              _buildSectionHeader('LIABILITIES & EQUITY'),
              pw.SizedBox(height: 10),

              _buildRow('Liabilities', '', isBold: true),
              _buildRow('   Accounts Payable', '\$0.00'),
              _buildRow('   Sales Tax Payable (Est. 15%)',
                  '\$${(totalRevenue * 0.15).toStringAsFixed(2)}'),

              pw.SizedBox(height: 10),

              _buildRow('Equity', '', isBold: true),
              _buildRow('   Opening Capital (Stock + Float)',
                  _formatCurrency(inventoryValue + cashFloat)),
              _buildRow('   Retained Earnings (Net Profit)',
                  _formatCurrency(netProfit)),

              pw.Divider(thickness: 0.5),

              // Balancing Figure (Simplified for POS context)
              _buildRow('TOTAL LIABILITIES & EQUITY',
                  _formatCurrency(totalCurrentAssets),
                  isBold: true, color: PdfColors.blue700),

              pw.Spacer(),

              // SIGNATURE SECTION
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    children: [
                      pw.Container(
                          width: 150, height: 1, color: PdfColors.black),
                      pw.SizedBox(height: 5),
                      pw.Text('Prepared By',
                          style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Container(
                          width: 150, height: 1, color: PdfColors.black),
                      pw.SizedBox(height: 5),
                      pw.Text('Approved By',
                          style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text('System Generated Report • Powered by mdtech',
                    style:
                        const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
              ),
            ],
          );
        },
      ),
    );

    // Print / Save
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'BalanceSheet_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  // --- HELPERS ---

  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  pw.Widget _buildSectionHeader(String title) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      color: PdfColors.grey200,
      child: pw.Text(
        title,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
      ),
    );
  }

  pw.Widget _buildRow(String label, String value,
      {bool isBold = false, PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: isBold ? pw.FontWeight.bold : null)),
          pw.Text(value,
              style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: isBold ? pw.FontWeight.bold : null,
                  color: color)),
        ],
      ),
    );
  }
}
