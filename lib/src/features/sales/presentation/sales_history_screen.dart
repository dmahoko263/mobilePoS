import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_tablet_app/src/core/services/isar_service.dart';
import 'package:pos_tablet_app/src/core/services/report_service.dart';
import 'package:pos_tablet_app/src/features/orders/models/order.dart';
import 'package:pos_tablet_app/src/features/sales/presentation/receipt_preview.dart';

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  final IsarService _isarService = IsarService();
  final ReportService _reportService = ReportService();

  // Helper to format date nicely (e.g., "Oct 24, 14:30")
  String _formatDate(DateTime date) {
    return DateFormat('MMM d, y • HH:mm').format(date);
  }

  // Generate and Print PDF Report
  void _printReport(List<Order> orders) async {
    if (orders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data to report')),
      );
      return;
    }

    // FIX: Use named arguments 'orders:' and 'title:'
    await _reportService.printBalanceSheet(
        orders: orders, title: 'Sales Report');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        actions: [
          // PDF EXPORT BUTTON
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Print Daily Report',
            onPressed: () async {
              final orders = await _isarService.getAllOrders();
              _printReport(orders);
            },
          )
        ],
      ),
      body: FutureBuilder<List<Order>>(
        future: _isarService.getAllOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No sales yet', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final orders = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final order = orders[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: order.status == OrderStatus.paid
                      ? Colors.green.shade100
                      : Colors.orange.shade100,
                  child: Icon(
                    order.status == OrderStatus.paid ? Icons.check : Icons.sync,
                    color: order.status == OrderStatus.paid
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
                title: Text(
                  '\$${order.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                // UPDATED SUBTITLE: Shows Date AND Cashier Name
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_formatDate(order.orderDate)),
                    const SizedBox(height: 2),
                    Text(
                      'Sold by: ${order.cashierName ?? 'Unknown'}',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.blueGrey[700],
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                trailing: const Icon(Icons.chevron_right),

                // OPEN RECEIPT PREVIEW ON TAP
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => ReceiptPreview(order: order),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
