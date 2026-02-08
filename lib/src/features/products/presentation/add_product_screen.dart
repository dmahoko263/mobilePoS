import 'package:flutter/material.dart';
import 'package:pos_tablet_app/src/core/services/isar_service.dart';
import 'package:pos_tablet_app/src/features/auth/models/shop.dart';
import 'package:pos_tablet_app/src/features/products/models/product.dart';
import 'package:pos_tablet_app/src/features/products/models/product_unit.dart';

class AddProductScreen extends StatefulWidget {
  final Product? productToEdit;

  const AddProductScreen({super.key, this.productToEdit});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _isarService = IsarService();

  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _priceController = TextEditingController();
  final _costController = TextEditingController();
  final _quantityController = TextEditingController();
  final _baseUnitController = TextEditingController(text: 'piece');
  final _categoryController = TextEditingController();
  final _supplierController = TextEditingController();

  // Sell units (Single/Pack/Carton) with their own prices
  final List<_UnitRow> _unitRows = [
    _UnitRow(unitName: 'Single', multiplierToBase: '1', sellPrice: ''),
  ];

  bool _isGlobal = false;
  int? _selectedShopId;
  List<Shop> _availableShops = [];

  @override
  void initState() {
    super.initState();
    _loadShopsAndData();
  }

  Future<void> _loadShopsAndData() async {
    final shops = await _isarService.getAllShops();
    if (!mounted) return;

    setState(() {
      _availableShops = shops;
    });

    final p = widget.productToEdit;

    // EDIT MODE
    if (p != null) {
      _nameController.text = p.name;
      _skuController.text = p.sku ?? '';
      _priceController.text = p.price.toString();
      _costController.text = p.costPrice.toString();
      _quantityController.text = p.quantity.toString();
      _categoryController.text = p.category;
      _supplierController.text = p.supplierName ?? '';
      _isGlobal = p.shopId == null;
      _selectedShopId = p.shopId;
      _baseUnitController.text = p.baseUnit.isEmpty ? 'piece' : p.baseUnit;

      final units = await _isarService.getUnitsForProduct(p.id);
      if (!mounted) return;

      setState(() {
        _unitRows.clear();

        if (units.isEmpty) {
          _unitRows.add(
            _UnitRow(
              unitName: 'Single',
              multiplierToBase: '1',
              sellPrice: p.price.toString(),
              barcode: p.sku ?? '',
            ),
          );
        } else {
          for (final u in units) {
            _unitRows.add(
              _UnitRow(
                unitName: u.unitName,
                multiplierToBase: u.multiplierToBase.toString(),
                sellPrice: u.sellPrice.toString(),
                barcode: u.barcode ?? '',
              ),
            );
          }
        }
      });

      return;
    }

    // NEW PRODUCT DEFAULTS
    setState(() {
      _selectedShopId = IsarService.currentShopId;
      _baseUnitController.text = 'piece';
      if (_unitRows.isEmpty) {
        _unitRows.add(
          _UnitRow(unitName: 'Single', multiplierToBase: '1', sellPrice: ''),
        );
      }
    });
  }

  Future<void> _saveToDb() async {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill in Name, Price and Quantity')),
      );
      return;
    }

    if (!_isGlobal && _selectedShopId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Select a Shop or mark as Global.')),
      );
      return;
    }

    final sku = _skuController.text.isEmpty
        ? 'SKU-${DateTime.now().millisecondsSinceEpoch}'
        : _skuController.text;

    final product = widget.productToEdit ?? Product();
    final currentQty = int.tryParse(_quantityController.text) ?? 0;

    product
      ..name = _nameController.text.trim()
      ..sku = sku.trim()
      ..price = double.tryParse(_priceController.text.trim()) ?? 0.0
      ..costPrice = double.tryParse(_costController.text.trim()) ?? 0.0
      ..quantity = currentQty
      ..baseUnit = _baseUnitController.text.trim().isEmpty
          ? 'piece'
          : _baseUnitController.text.trim()
      ..category = _categoryController.text.trim().isEmpty
          ? 'General'
          : _categoryController.text.trim()
      ..supplierName = _supplierController.text.trim().isEmpty
          ? null
          : _supplierController.text.trim()
      ..shopId = _isGlobal ? null : _selectedShopId;

    if (widget.productToEdit == null) {
      product.initialQuantity = currentQty;
    }

    await _isarService.saveProduct(product);

    // Save sell units
    final unitsToSave = <ProductUnit>[];
    for (final r in _unitRows) {
      final name = r.unitName.text.trim();
      if (name.isEmpty) continue;

      final mult = int.tryParse(r.multiplierToBase.text.trim()) ?? 1;
      final price = double.tryParse(r.sellPrice.text.trim()) ?? product.price;
      final barcode = r.barcode.text.trim();

      unitsToSave.add(
        ProductUnit()
          ..productId = product.id
          ..unitName = name
          ..multiplierToBase = mult <= 0 ? 1 : mult
          ..sellPrice = price
          ..barcode = barcode.isEmpty ? null : barcode,
      );
    }

    // Ensure Single exists
    if (!unitsToSave.any((u) => u.unitName.toLowerCase() == 'single')) {
      unitsToSave.insert(
        0,
        ProductUnit()
          ..productId = product.id
          ..unitName = 'Single'
          ..multiplierToBase = 1
          ..sellPrice = product.price
          ..barcode = (product.sku?.isNotEmpty == true) ? product.sku : null,
      );
    }

    await _isarService.upsertUnitsForProduct(product.id, unitsToSave);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          widget.productToEdit == null ? 'Product Created!' : 'Product Updated!',
        ),
      ),
    );
    Navigator.pop(context);
  }

  Widget _sectionTitle(String text, {IconData? icon}) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: Colors.blueGrey),
          const SizedBox(width: 8),
        ],
        Text(text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.productToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Product' : 'Add Inventory'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SHOP SELECTION ---
              Card(
                elevation: 0,
                color: Colors.grey.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text("Global Product",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(_isGlobal
                          ? "Visible in ALL Shops"
                          : "Visible only in specific Shop"),
                      value: _isGlobal,
                      activeColor: Colors.orange,
                      secondary: Icon(Icons.public,
                          color: _isGlobal ? Colors.orange : Colors.grey),
                      onChanged: (val) {
                        setState(() {
                          _isGlobal = val;
                          if (_isGlobal) _selectedShopId = null;
                        });
                      },
                    ),
                    if (!_isGlobal)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: DropdownButtonFormField<int>(
                          value: _selectedShopId,
                          decoration: const InputDecoration(
                            labelText: 'Assign to Shop',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: _availableShops
                              .map((shop) => DropdownMenuItem<int>(
                                    value: shop.id,
                                    child: Text(shop.name),
                                  ))
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _selectedShopId = val),
                          hint: const Text("Select Shop"),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              _sectionTitle('Product Details', icon: Icons.inventory_2_outlined),
              const SizedBox(height: 16),

              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shopping_bag),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _skuController,
                decoration: const InputDecoration(
                  labelText: 'Barcode / SKU',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.qr_code),
                ),
              ),
              const SizedBox(height: 16),

              // Price + Cost (ROW OK)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _priceController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Selling Price (Single)',
                        border: OutlineInputBorder(),
                        prefixText: '\$ ',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _costController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Cost Price',
                        border: OutlineInputBorder(),
                        prefixText: '\$ ',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Quantity + Base Unit + Category (ROW FIXED!)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Quantity (in base units)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.numbers),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _baseUnitController,
                      decoration: const InputDecoration(
                        labelText: 'Base Unit (e.g. piece, ml, gram)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.straighten),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _categoryController,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _supplierController,
                decoration: const InputDecoration(
                  labelText: 'Supplier Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_shipping),
                ),
              ),

              const SizedBox(height: 24),

              // --- SELL UNITS SECTION ---
              Row(
                children: [
                  Expanded(
                    child: _sectionTitle('Sell Units (Single / Pack / Carton)',
                        icon: Icons.sell_outlined),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _unitRows.add(
                          _UnitRow(
                            unitName: 'Carton',
                            multiplierToBase: '24',
                            sellPrice: '',
                          ),
                        );
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add unit'),
                  )
                ],
              ),
              const SizedBox(height: 8),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _unitRows.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final row = _unitRows[i];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: row.unitName,
                                decoration: const InputDecoration(
                                  labelText: 'Unit name',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: row.multiplierToBase,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Multiplier to base',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: row.sellPrice,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Sell price for this unit',
                                  border: OutlineInputBorder(),
                                  prefixText: '\$ ',
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: row.barcode,
                                decoration: const InputDecoration(
                                  labelText: 'Barcode (optional)',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_unitRows.length > 1)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () =>
                                  setState(() => _unitRows.removeAt(i)),
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red),
                              label: const Text('Remove',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _saveToDb,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    isEdit ? 'UPDATE PRODUCT' : 'SAVE TO INVENTORY',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnitRow {
  final TextEditingController unitName;
  final TextEditingController multiplierToBase;
  final TextEditingController sellPrice;
  final TextEditingController barcode;

  _UnitRow({
    required String unitName,
    required String multiplierToBase,
    required String sellPrice,
    String barcode = '',
  })  : unitName = TextEditingController(text: unitName),
        multiplierToBase = TextEditingController(text: multiplierToBase),
        sellPrice = TextEditingController(text: sellPrice),
        barcode = TextEditingController(text: barcode);
}
