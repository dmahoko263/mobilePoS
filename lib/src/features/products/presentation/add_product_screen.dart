import 'package:flutter/material.dart';
import 'package:pos_tablet_app/src/features/products/models/product.dart';
import 'package:pos_tablet_app/src/core/services/isar_service.dart';
import 'package:pos_tablet_app/src/features/auth/models/shop.dart';

class AddProductScreen extends StatefulWidget {
  final Product? productToEdit;

  const AddProductScreen({super.key, this.productToEdit});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _priceController = TextEditingController();
  final _costController = TextEditingController();
  final _quantityController = TextEditingController();
  final _categoryController = TextEditingController();
  final _supplierController = TextEditingController(); // NEW: Controller

  final _isarService = IsarService();

  bool _isGlobal = false;
  int? _selectedShopId; // The shop we are adding this to
  List<Shop> _availableShops = []; // List for dropdown

  @override
  void initState() {
    super.initState();
    _loadShopsAndData();
  }

  void _loadShopsAndData() async {
    // 1. Load Shops List
    final shops = await _isarService.getAllShops();

    setState(() {
      _availableShops = shops;

      // 2. Pre-fill Data if Editing
      if (widget.productToEdit != null) {
        final p = widget.productToEdit!;
        _nameController.text = p.name;
        _skuController.text = p.sku ?? '';
        _priceController.text = p.price.toString();
        _costController.text = p.costPrice.toString();
        _quantityController.text = p.quantity.toString();
        _categoryController.text = p.category;
        _supplierController.text = p.supplierName ?? ''; // Pre-fill Supplier
        _isGlobal = p.shopId == null;
        _selectedShopId = p.shopId;
      } else {
        // 3. Default for New Product
        // If not global, default to current logged-in shop
        _selectedShopId = IsarService.currentShopId;
      }
    });
  }

  void _saveToDb() async {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill in Name, Price and Quantity')),
      );
      return;
    }

    // Validation: If not global, must have a shop selected
    if (!_isGlobal && _selectedShopId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error: Select a Shop or mark as Global.')),
      );
      return;
    }

    String sku = _skuController.text.isEmpty
        ? 'SKU-${DateTime.now().millisecondsSinceEpoch}'
        : _skuController.text;

    final product = widget.productToEdit ?? Product();
    int currentQty = int.tryParse(_quantityController.text) ?? 0;

    product
      ..name = _nameController.text
      ..sku = sku
      ..price = double.tryParse(_priceController.text) ?? 0.0
      ..costPrice = double.tryParse(_costController.text) ?? 0.0
      ..quantity = currentQty
      ..category = _categoryController.text.isEmpty
          ? 'General'
          : _categoryController.text
      ..supplierName = _supplierController.text // Save Supplier

      // LOGIC: Global = null, Specific = selected ID
      ..shopId = _isGlobal ? null : _selectedShopId;

    // IMPORTANT: Set initialQuantity for Dashboard Performance calculation
    if (widget.productToEdit == null) {
      // For new products, initial is what we start with
      product.initialQuantity = currentQty;
    }
    // If editing, we generally don't override initialQuantity unless you specifically want to reset stats

    await _isarService.saveProduct(product);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.green,
            content: Text(widget.productToEdit == null
                ? 'Product Created!'
                : 'Product Updated!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.productToEdit == null ? 'Add Inventory' : 'Edit Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SHOP SELECTION SECTION ---
              Card(
                elevation: 0,
                color: Colors.grey.shade50,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey.shade300)),
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
                          if (_isGlobal)
                            _selectedShopId = null; // Clear shop if global
                        });
                      },
                    ),

                    // Only show Dropdown if NOT Global
                    if (!_isGlobal)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: DropdownButtonFormField<int>(
                          value: _selectedShopId,
                          decoration: const InputDecoration(
                              labelText: 'Assign to Shop',
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white),
                          items: _availableShops.map((shop) {
                            return DropdownMenuItem<int>(
                              value: shop.id,
                              child: Text(shop.name),
                            );
                          }).toList(),
                          onChanged: (val) =>
                              setState(() => _selectedShopId = val),
                          hint: const Text("Select Shop"),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // ------------------------------

              const Text('Product Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                    labelText: 'Product Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.shopping_bag)),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _skuController,
                decoration: const InputDecoration(
                    labelText: 'Barcode / SKU',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.qr_code)),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Selling Price',
                          border: OutlineInputBorder(),
                          prefixText: '\$ '),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _costController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Cost Price',
                          border: OutlineInputBorder(),
                          prefixText: '\$ '),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Quantity',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.numbers)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _categoryController,
                      decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // NEW: Supplier Field
              TextField(
                controller: _supplierController,
                decoration: const InputDecoration(
                    labelText: 'Supplier Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.local_shipping)),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _saveToDb,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[900],
                      foregroundColor: Colors.white),
                  child: Text(
                      widget.productToEdit == null
                          ? 'SAVE TO INVENTORY'
                          : 'UPDATE PRODUCT',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
