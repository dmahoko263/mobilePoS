import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_tablet_app/src/core/services/isar_service.dart';
import 'package:pos_tablet_app/src/features/orders/models/order.dart';

class SoldItemsScreen extends StatefulWidget {
  const SoldItemsScreen({super.key});

  @override
  State<SoldItemsScreen> createState() => _SoldItemsScreenState();
}

class _SoldItemsScreenState extends State<SoldItemsScreen> {
  final IsarService _isarService = IsarService();
  final NumberFormat _currency = NumberFormat.simpleCurrency();
  final DateFormat _date = DateFormat('dd MMM HH:mm');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Items Sold Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Add Date Filter logic here later
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
            return const Center(child: Text("No items sold yet."));
          }

          // FLATTEN ORDERS INTO A LIST OF ITEMS
          // We combine the Order info (Date, Cashier) with the Item info (Name, Qty)
          final List<Map<String, dynamic>> flatItems = [];

          for (var order in snapshot.data!) {
            if (order.items != null) {
              for (var item in order.items!) {
                flatItems.add({
                  'name': item.productName ?? 'Unknown',
                  'qty': item.quantity ?? 0,
                  'price': item.priceAtSale ?? 0.0,
                  'total': (item.priceAtSale ?? 0) * (item.quantity ?? 1),
                  'date': order.orderDate,
                  'cashier': order.cashierName,
                  'orderId': order.id,
                });
              }
            }
          }

          // Sort by date (newest first)
          flatItems.sort((a, b) => b['date'].compareTo(a['date']));

          return ListView.separated(
            itemCount: flatItems.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = flatItems[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade50,
                  child: Text(
                    "${item['qty']}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ),
                title: Text(item['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  "${_date.format(item['date'])} • ${item['cashier']} • Order #${item['orderId']}",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                trailing: Text(
                  _currency.format(item['total']),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
