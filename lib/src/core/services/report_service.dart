import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pos_tablet_app/src/features/orders/models/order.dart';

class ReportService {
  // Generate Balance Sheet for a specific day or month
  Future<void> printBalanceSheet(List<Order> orders, String title) async {
    final doc = pw.Document();

    // Calculate Totals
    double totalRevenue = 0;
    double totalCost = 0;

    for (var o in orders) {
      totalRevenue += o.totalAmount;
      if (o.items != null) {
        for (var item in o.items!) {
          // If we added costAtSale logic, use it. Otherwise 0.
          double c = item.costAtSale ?? 0;
          totalCost += c * (item.quantity ?? 0);
        }
      }
    }

    double grossProfit = totalRevenue - totalCost;

    // Create PDF Layout
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                  level: 0,
                  child: pw.Text(title,
                      style: pw.TextStyle(
                          fontSize: 24, fontWeight: pw.FontWeight.bold))),
              pw.SizedBox(height: 20),

              pw.Text(
                  'Generated: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}'),
              pw.Divider(),
              pw.SizedBox(height: 20),

              // Financial Summary Table
              pw.Table.fromTextArray(
                context: context,
                headers: ['Metric', 'Amount (USD)'],
                data: [
                  [
                    'Total Revenue (Sales)',
                    '\$${totalRevenue.toStringAsFixed(2)}'
                  ],
                  ['Cost of Goods Sold', '-\$${totalCost.toStringAsFixed(2)}'],
                  ['GROSS PROFIT', '\$${grossProfit.toStringAsFixed(2)}'],
                ],
                border: null,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.centerLeft,
              ),

              pw.SizedBox(height: 40),
              pw.Text('Transaction Breakdown',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),

              // Transaction List
              pw.Table.fromTextArray(
                context: context,
                headers: ['Time', 'Order ID', 'Items', 'Total'],
                data: orders.map((order) {
                  return [
                    DateFormat('HH:mm').format(order.orderDate),
                    '#${order.id}',
                    '${order.items?.length ?? 0}',
                    '\$${order.totalAmount.toStringAsFixed(2)}'
                  ];
                }).toList(),
              ),

              pw.Spacer(),
              pw.Footer(title: pw.Text('Powered by mdtech')),
            ],
          );
        },
      ),
    );

    // This works on Windows (Printers/PDF) and Android
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }
}
