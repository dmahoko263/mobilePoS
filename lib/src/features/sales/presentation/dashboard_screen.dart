import 'package:flutter/material.dart';
import 'package:pos_tablet_app/src/core/services/isar_service.dart';
import 'package:pos_tablet_app/src/features/orders/models/order.dart';
import 'package:pos_tablet_app/src/core/services/settings_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final IsarService _isarService = IsarService();
  final SettingsService _settingsService = SettingsService();
  double _zigRate = 13.5;

  @override
  void initState() {
    super.initState();
    _loadRate();
  }

  void _loadRate() async {
    final rate = await _settingsService.getZigRate();
    setState(() => _zigRate = rate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Business Dashboard')),
      body: FutureBuilder<List<Order>>(
        // Note: For "Performing Shops" to work globally, we need to fetch ALL orders from ALL shops.
        // However, IsarService.getAllOrders() currently filters by 'currentShopId'.
        // If this is the Super Admin Dashboard, we might want a special method 'getAllOrdersGlobal()'.
        // For now, this shows data for the CURRENT shop.
        future: _isarService.getAllOrders(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final orders = snapshot.data!;

          // --- CALCULATE STATS ---
          double totalUSDCollected = 0;
          double totalZiGCollected = 0;

          Map<String, double> cashierPerformance = {};
          Map<String, int> productPerformance = {};
          Map<String, double> customerPerformance = {};

          // NEW: Shop Performance (This will only show current shop unless we change query)
          // But assuming we enhance IsarService later, here is the logic:
          Map<String, double> shopPerformance = {};

          for (var o in orders) {
            // Revenue Split
            if (o.paymentCurrency == 'ZiG') {
              totalZiGCollected += (o.totalAmount * _zigRate);
            } else {
              totalUSDCollected += o.totalAmount;
            }

            // 1. Cashier
            final cashier = o.cashierName ?? 'Unknown';
            cashierPerformance[cashier] =
                (cashierPerformance[cashier] ?? 0) + o.totalAmount;

            // 2. Customer
            final customer = (o.customerName == null || o.customerName!.isEmpty)
                ? 'Walk-in'
                : o.customerName!;
            if (customer != 'Walk-in') {
              customerPerformance[customer] =
                  (customerPerformance[customer] ?? 0) + o.totalAmount;
            }

            // 3. Shop (Using Shop ID for now, ideally join with Shop Name)
            // In single shop mode, this just shows one entry.
            final shopKey = 'Shop #${o.shopId ?? 0}';
            shopPerformance[shopKey] =
                (shopPerformance[shopKey] ?? 0) + o.totalAmount;

            // 4. Products
            if (o.items != null) {
              for (var item in o.items!) {
                final prodName = item.productName ?? 'Unknown';
                productPerformance[prodName] =
                    (productPerformance[prodName] ?? 0) + (item.quantity ?? 0);
              }
            }
          }

          // Sort Lists
          var sortedCashiers = cashierPerformance.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          var sortedProducts = productPerformance.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          var sortedCustomers = customerPerformance.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          var sortedShops = shopPerformance.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value)); // NEW

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Cash Flow Today',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                Row(
                  children: [
                    _buildStatCard(
                        'USD Sales',
                        '\$${totalUSDCollected.toStringAsFixed(2)}',
                        Colors.green,
                        Icons.attach_money),
                    const SizedBox(width: 24),
                    _buildStatCard(
                        'ZiG Sales',
                        'ZiG ${totalZiGCollected.toStringAsFixed(2)}',
                        Colors.orange,
                        Icons.currency_exchange),
                    const SizedBox(width: 24),
                    _buildStatCard('Total Orders', '${orders.length}',
                        Colors.blue, Icons.shopping_bag),
                  ],
                ),

                const SizedBox(height: 40),

                // 4-COLUMN LAYOUT (Added Performing Shops)
                // Note: On smaller screens, this might need to be a GridView or two Rows.
                // For Tablet landscape, a Row works.
                SizedBox(
                  height: 300, // Fixed height for lists
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: _buildListSection(
                              'Top Cashiers',
                              sortedCashiers,
                              (e) => '\$${e.value.toStringAsFixed(2)}',
                              Colors.blue)),
                      const SizedBox(width: 16),
                      Expanded(
                          child: _buildListSection(
                              'Top Shops',
                              sortedShops,
                              (e) => '\$${e.value.toStringAsFixed(2)}',
                              Colors.teal)), // NEW SECTION
                      const SizedBox(width: 16),
                      Expanded(
                          child: _buildListSection('Top Items', sortedProducts,
                              (e) => '${e.value} sold', Colors.orange)),
                      const SizedBox(width: 16),
                      Expanded(
                          child: _buildListSection(
                              'Loyal Customers',
                              sortedCustomers,
                              (e) => '\$${e.value.toStringAsFixed(2)}',
                              Colors.purple)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildListSection(String title, List<MapEntry> data,
      String Function(MapEntry) trailing, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Expanded(
          child: Card(
            elevation: 2,
            child: data.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(20), child: Text('No data'))
                : ListView.separated(
                    itemCount: data.take(5).length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final entry = data[index];
                      return ListTile(
                        leading: CircleAvatar(
                            backgroundColor: color.withOpacity(0.1),
                            child: Text('${index + 1}',
                                style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.bold))),
                        title: Text(entry.key,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13),
                            overflow: TextOverflow.ellipsis),
                        trailing: Text(trailing(entry),
                            style: const TextStyle(fontSize: 12)),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12),
                      );
                    },
                  ),
          ),
        )
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        height: 200,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 32),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(value,
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: color)),
                ),
                Text(title,
                    style: const TextStyle(fontSize: 16, color: Colors.grey)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
