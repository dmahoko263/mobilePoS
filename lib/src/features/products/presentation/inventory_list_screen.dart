import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_tablet_app/src/core/services/isar_service.dart';
import 'package:pos_tablet_app/src/features/products/models/product.dart';
import 'package:pos_tablet_app/src/features/auth/models/shop.dart'; // Import Shop
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
  List<Shop> _shops = [];
  bool _isLoadingShops = true;

  @override
  void initState() {
    super.initState();
    _loadShops();
  }

  Future<void> _loadShops() async {
    final shops = await _isarService.getAllShops();
    if (mounted) {
      setState(() {
        _shops = shops;
        _isLoadingShops = false;
      });
    }
  }

  // --- ACTIONS ---
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

                  if (isWriteOff) {
                    product.quantity -= qty;
                  } else {
                    product.quantity += qty;
                  }

                  await _isarService.saveProduct(product);
                  Navigator.pop(context);
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
        title: const Text('Inventory by Shop',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddProductScreen()));
        },
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Product", style: TextStyle(color: Colors.white)),
      ),
      body: StreamBuilder<List<Product>>(
        stream: _isarService.streamAllProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              _isLoadingShops) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No Inventory Data"));
          }

          final allProducts = snapshot.data!;

          // 1. Filter Logic
          final filteredProducts = _searchQuery.isEmpty
              ? allProducts
              : allProducts
                  .where((p) =>
                      p.name
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()) ||
                      (p.sku != null && p.sku!.contains(_searchQuery)))
                  .toList();

          // 2. Global Calculations (Grand Totals)
          double globalCost = filteredProducts.fold(
              0, (sum, item) => sum + (item.quantity * item.costPrice));
          double globalRetail = filteredProducts.fold(
              0, (sum, item) => sum + (item.quantity * item.price));

          // 3. Grouping Logic
          Map<int, List<Product>> groupedProducts = {};
          List<Product> unassignedProducts = [];

          // Initialize groups for known shops
          for (var shop in _shops) {
            groupedProducts[shop.id] = [];
          }

          // Distribute products
          for (var p in filteredProducts) {
            if (p.shopId == null) {
              unassignedProducts.add(p);
            } else if (groupedProducts.containsKey(p.shopId)) {
              groupedProducts[p.shopId]!.add(p);
            } else {
              unassignedProducts.add(p); // Fallback
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. GLOBAL KPIs
                const Text("Global Overview",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                        child: _StatCard(
                      title: "Total Expenses (Cost)",
                      value: "\$${NumberFormat('#,##0.00').format(globalCost)}",
                      icon: Icons.money_off,
                      color: Colors.orange,
                    )),
                    const SizedBox(width: 15),
                    Expanded(
                        child: _StatCard(
                      title: "Total Stock Value (Retail)",
                      value:
                          "\$${NumberFormat('#,##0.00').format(globalRetail)}",
                      icon: Icons.monetization_on,
                      color: Colors.green,
                    )),
                    const SizedBox(width: 15),
                    Expanded(
                        child: _StatCard(
                      title: "Total SKUs",
                      value: "${filteredProducts.length}",
                      icon: Icons.inventory_2,
                      color: Colors.blue,
                    )),
                  ],
                ),

                const SizedBox(height: 25),

                // 2. SEARCH
                TextField(
                  decoration: InputDecoration(
                    hintText: "Search Product by Name or SKU...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),

                const SizedBox(height: 20),

                // 3. SHOP SECTIONS
                if (unassignedProducts.isNotEmpty)
                  _buildShopSection(
                      "Unassigned / Warehouse", unassignedProducts),

                ..._shops.map((shop) {
                  final products = groupedProducts[shop.id] ?? [];
                  // If search is active, hide empty shops. If search is empty, show all shops.
                  if (products.isEmpty && _searchQuery.isNotEmpty)
                    return const SizedBox.shrink();

                  return _buildShopSection(shop.name, products);
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildShopSection(String shopName, List<Product> products) {
    // Shop Specific Totals
    double totalCost =
        products.fold(0, (sum, item) => sum + (item.quantity * item.costPrice));
    double totalRetail =
        products.fold(0, (sum, item) => sum + (item.quantity * item.price));

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        initiallyExpanded: true,
        shape: const Border(),
        title: Text(shopName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: [
              _MiniMetric(
                  label: "Expenses/Cost",
                  value: "\$${NumberFormat('#,##0').format(totalCost)}",
                  color: Colors.orange),
              const SizedBox(width: 20),
              _MiniMetric(
                  label: "Stock Value",
                  value: "\$${NumberFormat('#,##0').format(totalRetail)}",
                  color: Colors.green),
              const SizedBox(width: 20),
              Text("${products.length} Items",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
        ),
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Theme(
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
                columns: const [
                  DataColumn(label: Text("Product")),
                  DataColumn(label: Text("Category")),
                  DataColumn(label: Text("Cost")),
                  DataColumn(label: Text("Price")),
                  DataColumn(label: Text("Stock")),
                  DataColumn(label: Text("Actions")),
                ],
                rows: products.map((product) {
                  return DataRow(cells: [
                    DataCell(Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(product.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        if (product.sku != null)
                          Text(product.sku!,
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.grey)),
                      ],
                    )),
                    DataCell(Text(product.category)),
                    DataCell(Text("\$${product.costPrice.toStringAsFixed(2)}")),
                    DataCell(Text("\$${product.price.toStringAsFixed(2)}")),
                    DataCell(Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: product.quantity < 5
                              ? Colors.red.withOpacity(0.1)
                              : Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4)),
                      child: Text("${product.quantity}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: product.quantity < 5
                                  ? Colors.red
                                  : Colors.green)),
                    )),
                    DataCell(Row(
                      children: [
                        IconButton(
                            icon: const Icon(Icons.edit,
                                size: 18, color: Colors.blue),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => AddProductScreen(
                                          productToEdit: product)));
                            }),
                        IconButton(
                            icon: const Icon(Icons.settings_backup_restore,
                                size: 18, color: Colors.orange),
                            onPressed: () => _handleStockAdjustment(product)),
                      ],
                    )),
                  ]);
                }).toList(),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// --- HELPER WIDGETS ---

class _MiniMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MiniMetric(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 10, color: Colors.grey)),
            Text(value,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        )
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard(
      {required this.title,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
              Icon(icon, color: color, size: 24),
            ],
          ),
          const SizedBox(height: 10),
          Text(value,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
