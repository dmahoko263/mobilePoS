import 'package:fl_chart/fl_chart.dart'; // Add fl_chart to pubspec.yaml
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_tablet_app/src/core/services/isar_service.dart';
import 'package:pos_tablet_app/src/features/products/models/product.dart';
import 'package:pos_tablet_app/src/features/products/presentation/add_product_screen.dart';

class InventoryDashboardScreen extends StatefulWidget {
  const InventoryDashboardScreen({super.key});

  @override
  State<InventoryDashboardScreen> createState() =>
      _InventoryDashboardScreenState();
}

class _InventoryDashboardScreenState extends State<InventoryDashboardScreen> {
  final _isarService = IsarService();
  String _searchQuery = "";

  // --- ACTIONS ---

  void _refresh() => setState(() {});

  Future<void> _handleStockAdjustment(Product product) async {
    final qtyController = TextEditingController();
    String reason = "Damaged";
    bool isWriteOff = true;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("Manage Stock Adjustment"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text("Write-Off / Down"),
                        selected: isWriteOff,
                        onSelected: (v) =>
                            setDialogState(() => isWriteOff = true),
                        selectedColor: Colors.red.shade100,
                        labelStyle: TextStyle(
                            color: isWriteOff ? Colors.red : Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text("Restock"),
                        selected: !isWriteOff,
                        onSelected: (v) =>
                            setDialogState(() => isWriteOff = false),
                        selectedColor: Colors.green.shade100,
                        labelStyle: TextStyle(
                            color: !isWriteOff ? Colors.green : Colors.grey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: qtyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Quantity",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                if (isWriteOff)
                  DropdownButtonFormField<String>(
                    value: reason,
                    items: const [
                      DropdownMenuItem(
                          value: "Damaged", child: Text("Damaged")),
                      DropdownMenuItem(
                          value: "Expired", child: Text("Expired")),
                      DropdownMenuItem(
                          value: "Theft", child: Text("Theft/Loss")),
                      DropdownMenuItem(
                          value: "Internal Use", child: Text("Internal Use")),
                    ],
                    onChanged: (v) => setDialogState(() => reason = v!),
                    decoration: const InputDecoration(labelText: "Reason"),
                  ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel")),
              ElevatedButton(
                onPressed: () async {
                  int qty = int.tryParse(qtyController.text) ?? 0;
                  if (qty <= 0) return;

                  // Logic Update
                  if (isWriteOff) {
                    product.quantity -= qty;
                    // Save Log (Implementation needed in service)
                    // await _isarService.logAdjustment(product.id, -qty, reason);
                  } else {
                    product.quantity += qty;
                    product.initialQuantity +=
                        qty; // Increase baseline for restock
                    // await _isarService.logAdjustment(product.id, qty, "Restock");
                  }

                  await _isarService.saveProduct(product);
                  Navigator.pop(context);
                  _refresh();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: isWriteOff ? Colors.red : Colors.green,
                    foregroundColor: Colors.white),
                child:
                    Text(isWriteOff ? "Confirm Write-Off" : "Confirm Restock"),
              )
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Inventory Dashboard',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddProductScreen()));
          _refresh();
        },
        backgroundColor: Colors.black,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("New Product", style: TextStyle(color: Colors.white)),
      ),
      body: FutureBuilder<List<Product>>(
        future: _isarService.getAllProducts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final allProducts = snapshot.data!;
          final products = _searchQuery.isEmpty
              ? allProducts
              : allProducts
                  .where((p) =>
                      p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
                  .toList();

          // --- CALCULATIONS ---
          double totalStockValue =
              products.fold(0, (sum, item) => sum + item.totalStockValue);
          int totalItems = products.fold(0, (sum, item) => sum + item.quantity);
          int itemsSold = products.fold(0, (sum, item) => sum + item.soldCount);
          int lowStockCount = products.where((i) => i.quantity < 5).length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. STATS CARDS
                Row(
                  children: [
                    Expanded(
                        child: _StatCard(
                      title: "Total Stock Value",
                      value:
                          "\$${NumberFormat('#,##0').format(totalStockValue)}",
                      icon: Icons.monetization_on,
                      color: Colors.green,
                      trend: "+12% vs last month", // Mock trend
                    )),
                    const SizedBox(width: 15),
                    Expanded(
                        child: _StatCard(
                      title: "Active Products",
                      value: "$totalItems",
                      icon: Icons.inventory_2,
                      color: Colors.blue,
                      trend: "${products.length} Types",
                    )),
                    const SizedBox(width: 15),
                    Expanded(
                        child: _StatCard(
                      title: "Items Sold",
                      value: NumberFormat('#,##0').format(itemsSold),
                      icon: Icons.shopping_bag_outlined,
                      color: Colors.orange,
                      trend: "Lifetime Sales",
                    )),
                    const SizedBox(width: 15),
                    Expanded(
                        child: _StatCard(
                      title: "Low Stock Alert",
                      value: "$lowStockCount",
                      icon: Icons.warning_amber_rounded,
                      color: Colors.red,
                      trend: "Needs Action",
                    )),
                  ],
                ),

                const SizedBox(height: 25),

                // 2. SEARCH & HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("All Product List",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    SizedBox(
                      width: 300,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Search Product...",
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 10),
                        ),
                        onChanged: (v) => setState(() => _searchQuery = v),
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 15),

                // 3. MAIN TABLE
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.grey.shade200, blurRadius: 10)
                      ]),
                  child: Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: DataTable(
                      headingRowHeight: 60,
                      dataRowMinHeight: 70,
                      dataRowMaxHeight: 70,
                      columnSpacing: 20,
                      columns: const [
                        DataColumn(label: Text("Product Name")),
                        DataColumn(label: Text("Shop/Supplier")),
                        DataColumn(
                            label: Text("Performance")), // The Progress Bar
                        DataColumn(label: Text("Stock")),
                        DataColumn(label: Text("Value")),
                        DataColumn(label: Text("Action")),
                      ],
                      rows: products.map((product) {
                        return DataRow(cells: [
                          // 1. Name & Image
                          DataCell(Row(
                            children: [
                              Container(
                                width: 45,
                                height: 45,
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8)),
                                child:
                                    const Icon(Icons.image, color: Colors.grey),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(product.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text(product.sku ?? "-",
                                      style: const TextStyle(
                                          fontSize: 11, color: Colors.grey)),
                                ],
                              )
                            ],
                          )),

                          // 2. Shop/Supplier
                          DataCell(Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                    color: product.shopId == null
                                        ? Colors.purple.shade50
                                        : Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(4)),
                                child: Text(
                                    product.shopId == null
                                        ? "Global"
                                        : (product.shopName ?? "Local"),
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: product.shopId == null
                                            ? Colors.purple
                                            : Colors.blue)),
                              ),
                              const SizedBox(height: 4),
                              Text(product.supplierName ?? "No Supplier",
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                            ],
                          )),

                          // 3. Performance (Arc Chart style)
                          DataCell(_PerformanceIndicator(product: product)),

                          // 4. Stock
                          DataCell(Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${product.quantity} units",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: product.quantity < 5
                                          ? Colors.red
                                          : Colors.black)),
                              Text(
                                  product.quantity < 5
                                      ? "Restock Now"
                                      : "In Stock",
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: product.quantity < 5
                                          ? Colors.red
                                          : Colors.green)),
                            ],
                          )),

                          // 5. Value
                          DataCell(Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("\$${product.price.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              Text(
                                  "Cost: \$${product.costPrice.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.grey)),
                            ],
                          )),

                          // 6. Action
                          DataCell(PopupMenuButton(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (val) {
                              if (val == 'edit') {
                                Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => AddProductScreen(
                                                productToEdit: product)))
                                    .then((_) => _refresh());
                              } else if (val == 'adjust') {
                                _handleStockAdjustment(product);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                  value: 'edit', child: Text("Edit Details")),
                              const PopupMenuItem(
                                  value: 'adjust',
                                  child: Text(
                                      "Stock Adjustment (Write-off/Restock)")),
                            ],
                          )),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // 4. TRENDS CHART (Mock Data for Visual)
                const Text("Stock Valuation Trend",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                Container(
                  height: 300,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12)),
                  child: LineChart(LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (val, meta) {
                                  return Text("M${val.toInt()}",
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 10));
                                })),
                        leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: const [
                            FlSpot(1, 3000),
                            FlSpot(2, 3500),
                            FlSpot(3, 4000),
                            FlSpot(4, 3800),
                            FlSpot(5, 5200),
                            FlSpot(6, 6000)
                          ],
                          isCurved: true,
                          color: Colors.blueAccent,
                          barWidth: 3,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                              show: true,
                              color: Colors.blueAccent.withOpacity(0.1)),
                        )
                      ])),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

// --- WIDGET HELPERS ---

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String trend;

  const _StatCard(
      {required this.title,
      required this.value,
      required this.icon,
      required this.color,
      required this.trend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 10),
          Text(value,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(trend, style: TextStyle(fontSize: 10, color: color)),
        ],
      ),
    );
  }
}

class _PerformanceIndicator extends StatelessWidget {
  final Product product;
  const _PerformanceIndicator({required this.product});

  @override
  Widget build(BuildContext context) {
    // Avoid division by zero
    double progress = product.initialQuantity > 0
        ? (product.soldCount / product.initialQuantity)
        : 0.0;

    // Cap at 1.0
    if (progress > 1.0) progress = 1.0;

    Color color = Colors.green;
    String label = "Excellent";
    if (progress < 0.2) {
      color = Colors.grey;
      label = "Slow";
    } else if (progress < 0.5) {
      color = Colors.orange;
      label = "Good";
    }

    return Row(
      children: [
        SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            color: color,
            strokeWidth: 4,
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            Text("${product.soldCount} Sold",
                style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        )
      ],
    );
  }
}
