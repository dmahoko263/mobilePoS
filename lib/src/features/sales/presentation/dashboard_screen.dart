import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_tablet_app/src/core/services/isar_service.dart';
import 'package:pos_tablet_app/src/features/orders/models/order.dart';
import 'package:pos_tablet_app/src/features/auth/models/shop.dart';
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

  // --- FILTER STATE ---
  // FIX 1: Use ID (int) instead of Shop Object to prevent Dropdown crash
  int? _selectedShopId;

  String _selectedTimeRange = 'Today';
  final List<String> _timeRanges = [
    'Today',
    'Yesterday',
    'This Week',
    'This Month',
    'All Time'
  ];

  @override
  void initState() {
    super.initState();
    _loadRate();
  }

  void _loadRate() async {
    final rate = await _settingsService.getZigRate();
    setState(() => _zigRate = rate);
  }

  // --- DATE FILTER LOGIC ---
  bool _isOrderInTimeRange(DateTime orderDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (_selectedTimeRange) {
      case 'Today':
        return orderDate.isAfter(today);
      case 'Yesterday':
        final yesterday = today.subtract(const Duration(days: 1));
        return orderDate.isAfter(yesterday) && orderDate.isBefore(today);
      case 'This Week':
        final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
        return orderDate.isAfter(startOfWeek);
      case 'This Month':
        final startOfMonth = DateTime(now.year, now.month, 1);
        return orderDate.isAfter(startOfMonth);
      case 'All Time':
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Analytics',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50],
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          _isarService.getAllOrders(),
          _isarService.getAllShops(),
        ]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allOrders = snapshot.data![0] as List<Order>;
          final allShops = snapshot.data![1] as List<Shop>;

          // 1. FILTER ORDERS
          final filteredOrders = allOrders.where((o) {
            // FIX 2: Filter by ID
            if (_selectedShopId != null && o.shopId != _selectedShopId) {
              return false;
            }
            return _isOrderInTimeRange(o.orderDate);
          }).toList();

          // 2. CREATE SHOP LOOKUP MAP
          final Map<int, String> shopNames = {
            for (var s in allShops) s.id: s.name
          };

          // --- 3. CALCULATE STATS ---
          double totalUSDCollected = 0;
          double totalZiGCollected = 0;

          Map<String, double> cashierPerformance = {};
          Map<String, int> productPerformance = {};
          Map<String, double> customerPerformance = {};
          Map<String, double> shopPerformance = {};

          Map<String, double> salesHistory = {};
          final now = DateTime.now();
          final DateFormat dateFormatter = DateFormat('MM/dd');
          final DateFormat keyFormatter = DateFormat('yyyy-MM-dd');

          for (int i = 6; i >= 0; i--) {
            String dateKey =
                keyFormatter.format(now.subtract(Duration(days: i)));
            salesHistory[dateKey] = 0.0;
          }

          Map<String, double> shopDailyPerformance = {};

          for (var o in filteredOrders) {
            // Revenue
            if (o.paymentCurrency == 'ZiG') {
              totalZiGCollected += (o.totalAmount * _zigRate);
            } else {
              totalUSDCollected += o.totalAmount;
            }

            final String realShopName =
                (o.shopId != null && shopNames.containsKey(o.shopId))
                    ? shopNames[o.shopId]!
                    : "Shop #${o.shopId ?? '?'}";

            // Cashier
            final cashier = o.cashierName ?? 'Unknown';
            cashierPerformance[cashier] =
                (cashierPerformance[cashier] ?? 0) + o.totalAmount;

            // Shop Performance
            shopPerformance[realShopName] =
                (shopPerformance[realShopName] ?? 0) + o.totalAmount;

            // Products
            if (o.items != null) {
              for (var item in o.items!) {
                final prodName = item.productName ?? 'Unknown';
                productPerformance[prodName] =
                    (productPerformance[prodName] ?? 0) + (item.quantity ?? 0);
              }
            }

            // Customer
            final customer = (o.customerName == null || o.customerName!.isEmpty)
                ? 'Walk-in'
                : o.customerName!;
            if (customer != 'Walk-in') {
              customerPerformance[customer] =
                  (customerPerformance[customer] ?? 0) + o.totalAmount;
            }

            // Chart Data
            String orderDateKey = keyFormatter.format(o.orderDate);
            if (salesHistory.containsKey(orderDateKey)) {
              double amountInUSD = o.paymentCurrency == 'ZiG'
                  ? o.totalAmount / _zigRate
                  : o.totalAmount;
              salesHistory[orderDateKey] =
                  (salesHistory[orderDateKey] ?? 0) + amountInUSD;
            }

            double amountInUSD = o.paymentCurrency == 'ZiG'
                ? o.totalAmount / _zigRate
                : o.totalAmount;
            shopDailyPerformance[realShopName] =
                (shopDailyPerformance[realShopName] ?? 0) + amountInUSD;
          }

          // Sort Lists
          var sortedCashiers = cashierPerformance.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          var sortedProducts = productPerformance.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          var sortedCustomers = customerPerformance.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          var sortedShops = shopPerformance.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          var sortedChartShops = shopDailyPerformance.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          List<FlSpot> trendSpots = [];
          int index = 0;
          salesHistory.forEach((date, value) {
            trendSpots.add(FlSpot(index.toDouble(), value));
            index++;
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ----------------------------------------------------
                // FILTER BAR
                // ----------------------------------------------------
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.filter_list, color: Colors.grey),
                      const SizedBox(width: 10),
                      const Text("Filters:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(width: 20),

                      // FIX 3: DROPDOWN USES INT ID
                      DropdownButton<int?>(
                        value: _selectedShopId,
                        hint: const Text("All Shops"),
                        underline: const SizedBox(),
                        items: [
                          const DropdownMenuItem<int?>(
                              value: null, child: Text("All Shops")),
                          ...allShops.map((shop) => DropdownMenuItem<int?>(
                                value: shop.id, // Use ID here
                                child: Text(shop.name),
                              )),
                        ],
                        onChanged: (int? newShopId) {
                          setState(() => _selectedShopId = newShopId);
                        },
                      ),

                      const VerticalDivider(
                          width: 30, thickness: 1, indent: 10, endIndent: 10),

                      // TIME RANGE SELECTOR
                      DropdownButton<String>(
                        value: _selectedTimeRange,
                        underline: const SizedBox(),
                        items: _timeRanges.map((String range) {
                          return DropdownMenuItem<String>(
                            value: range,
                            child: Text(range),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() => _selectedTimeRange = newValue);
                          }
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // KPI CARDS
                const Text('Performance Overview',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                Row(
                  children: [
                    _buildStatCard(
                        'Revenue (USD)',
                        '\$${totalUSDCollected.toStringAsFixed(2)}',
                        Colors.green,
                        Icons.attach_money),
                    const SizedBox(width: 24),
                    _buildStatCard(
                        'Revenue (ZiG)',
                        'ZiG ${totalZiGCollected.toStringAsFixed(2)}',
                        Colors.orange,
                        Icons.currency_exchange),
                    const SizedBox(width: 24),
                    _buildStatCard('Transactions', '${filteredOrders.length}',
                        Colors.blue, Icons.receipt_long),
                  ],
                ),

                const SizedBox(height: 40),

                // LISTS
                SizedBox(
                  height: 300,
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
                      if (_selectedShopId == null) ...[
                        Expanded(
                            child: _buildListSection(
                                'Performing Shops',
                                sortedShops,
                                (e) => '\$${e.value.toStringAsFixed(2)}',
                                Colors.teal)),
                        const SizedBox(width: 16),
                      ],
                      Expanded(
                          child: _buildListSection(
                              'Top Products',
                              sortedProducts,
                              (e) => '${e.value} sold',
                              Colors.orange)),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
                const Divider(thickness: 2),
                const SizedBox(height: 20),

                // CHARTS
                const Text('Visual Analytics',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                SizedBox(
                  height: 350,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildChartContainer(
                          title: "Sales Trend (Last 7 Days)",
                          child: LineChart(
                            LineChartData(
                              gridData: const FlGridData(
                                  show: true, drawVerticalLine: false),
                              titlesData: FlTitlesData(
                                topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 1,
                                    getTitlesWidget: (val, meta) {
                                      int i = val.toInt();
                                      if (i >= 0 && i < salesHistory.length) {
                                        DateTime date =
                                            now.subtract(Duration(days: 6 - i));
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                              dateFormatter.format(date),
                                              style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold)),
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: trendSpots,
                                  isCurved: true,
                                  color: Colors.blue,
                                  barWidth: 3,
                                  dotData: const FlDotData(show: true),
                                  belowBarData: BarAreaData(
                                      show: true,
                                      color: Colors.blue.withOpacity(0.1)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 1,
                        child: _buildChartContainer(
                          title: "Revenue Share ($_selectedTimeRange)",
                          child: sortedChartShops.isEmpty
                              ? const Center(
                                  child: Text("No Data for selected period"))
                              : BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceAround,
                                    barTouchData: BarTouchData(
                                      enabled: true,
                                      touchTooltipData: BarTouchTooltipData(
                                        getTooltipColor: (_) => Colors.blueGrey,
                                        getTooltipItem:
                                            (group, groupIndex, rod, rodIndex) {
                                          String shopName =
                                              sortedChartShops[groupIndex].key;
                                          return BarTooltipItem(
                                            '$shopName\n',
                                            const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                            children: <TextSpan>[
                                              TextSpan(
                                                text:
                                                    '\$${rod.toY.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                    color: Colors.yellow),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                    titlesData: FlTitlesData(
                                      show: true,
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget:
                                              (double value, TitleMeta meta) {
                                            int i = value.toInt();
                                            if (i >= 0 &&
                                                i < sortedChartShops.length) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8),
                                                child: Text(
                                                  sortedChartShops[i]
                                                      .key
                                                      .split(' ')
                                                      .first,
                                                  style: const TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              );
                                            }
                                            return const Text('');
                                          },
                                        ),
                                      ),
                                      leftTitles: const AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false)),
                                      topTitles: const AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false)),
                                      rightTitles: const AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false)),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    gridData: const FlGridData(show: false),
                                    barGroups: sortedChartShops
                                        .asMap()
                                        .entries
                                        .map((e) {
                                      return BarChartGroupData(
                                        x: e.key,
                                        barRods: [
                                          BarChartRodData(
                                            toY: e.value.value,
                                            color: Colors.teal,
                                            width: 20,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            backDrawRodData:
                                                BackgroundBarChartRodData(
                                                    show: true,
                                                    toY: (sortedChartShops
                                                            .first.value *
                                                        1.1),
                                                    color: Colors.grey[100]),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- HELPER WIDGETS ---

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

  Widget _buildChartContainer({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 20),
          Expanded(child: child),
        ],
      ),
    );
  }
}
