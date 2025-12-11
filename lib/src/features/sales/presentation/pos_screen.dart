import 'dart:io';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:pos_tablet_app/src/core/services/isar_service.dart';
import 'package:pos_tablet_app/src/core/services/printer_service.dart';
import 'package:pos_tablet_app/src/core/services/settings_service.dart';
import 'package:pos_tablet_app/src/features/orders/models/order.dart';
import 'package:pos_tablet_app/src/features/orders/models/order_item.dart';
import 'package:pos_tablet_app/src/features/products/models/product.dart';
import 'package:pos_tablet_app/src/core/services/whatsapp_service.dart';
import 'package:pos_tablet_app/src/core/services/pesepay_service.dart';
import 'package:url_launcher/url_launcher.dart';

class CartItem {
  final Product product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});
  double get total => product.price * quantity;
}

class PosScreen extends StatefulWidget {
  final String cashierName;
  const PosScreen({super.key, this.cashierName = 'Admin'});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final IsarService _isarService = IsarService();
  final SettingsService _settingsService = SettingsService();
  final PrinterService _printerService = PrinterService();

  // Controllers
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _customerAddressController = TextEditingController();
  final _searchController = TextEditingController();
  final _tenderedController = TextEditingController();
  // NEW: State for the Navigation Sidebar
  // bool _isNavSidebarOpen = false; // Start closed (or true if you prefer)
  // NEW: Add this FocusNode
  final FocusNode _searchFocusNode = FocusNode();

  // State
  List<CartItem> _cart = [];
  String _shopName = "POS Terminal";
  BluetoothDevice? _selectedPrinter;
  double _zigRate = 0;
  double _taxRate = 0;
  double _discountAmount = 0;
  String _searchQuery = "";
  bool _isNavSidebarOpen = false; // Start closed (or true if you prefer)

  // NEW: State for expanding/shrinking sidebar
  bool _isProductGridVisible = true;

  @override
  void initState() {
    super.initState();
    _loadRates();
    // NEW: Request focus after the frame builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

// --- NEW: Helper for Sidebar Buttons ---
  Widget _buildSidebarItem(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[800]),
      title: Text(label,
          style:
              TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w600)),
      onTap: onTap,
      hoverColor: Colors.blue.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  void _loadRates() async {
    final zig = await _settingsService.getZigRate();
    final tax = await _settingsService.getTaxRate();
    final shop = await _isarService.getCurrentShop();
    setState(() {
      _zigRate = zig;
      _taxRate = tax;
    });
    // NEW: Update title if shop exists
    if (shop != null && shop.name.isNotEmpty) {
      _shopName = shop.name;
    }
  }

  // --- CART LOGIC ---
  void _addToCart(Product product) {
    setState(() {
      final index = _cart.indexWhere((item) => item.product.id == product.id);
      if (index >= 0) {
        _cart[index].quantity++;
      } else {
        _cart.add(CartItem(product: product));
      }
    });
    // NEW: Refocus immediately so the next scan works
    _searchFocusNode.requestFocus();
  }

  void _removeFromCart(int index) {
    setState(() {
      if (_cart[index].quantity > 1) {
        _cart[index].quantity--;
      } else {
        _cart.removeAt(index);
      }
      if (_cart.isEmpty) _discountAmount = 0;
    });
  }

  @override
  void dispose() {
    // NEW: Dispose the focus node
    _searchFocusNode.dispose();
    super.dispose();
  }

  // --- MATH LOGIC ---
  double get _subtotal => _cart.fold(0, (sum, item) => sum + item.total);
  double get _taxAmount => (_subtotal - _discountAmount) * (_taxRate / 100);
  double get _totalUSD => (_subtotal - _discountAmount) + _taxAmount;
  double get _totalZiG => _totalUSD * _zigRate;

  // --- DISCOUNT DIALOG ---
  void _showDiscountDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apply Discount (USD)'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            prefixText: '- \$ ',
            border: OutlineInputBorder(),
            labelText: 'Amount off',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _discountAmount = double.tryParse(controller.text) ?? 0;
              });
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  // --- CHECKOUT DIALOG ---
  void _showCheckoutDialog() {
    String selectedMethod = 'Cash';
    String selectedCurrency = 'USD';
    bool isPrinting = true;
    bool sendWhatsApp = false;

    _tenderedController.clear();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // 1. Live Calculations
            double currentTotal =
                selectedCurrency == 'USD' ? _totalUSD : _totalZiG;
            double tenderedInput =
                double.tryParse(_tenderedController.text) ?? 0.0;
            double changeDue = tenderedInput - currentTotal;

            // 2. Decimal Logic for Suggestions
            double decimalPart = 0.0;
            if (changeDue > 0) {
              String changeStr = changeDue.toStringAsFixed(2);
              List<String> parts = changeStr.split('.');
              if (parts.length > 1) {
                decimalPart = double.tryParse("0.${parts[1]}") ?? 0.0;
              }
            }

            return AlertDialog(
              title: const Text('Checkout & Details'),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 450,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // --- PAYMENT CALCULATOR ---
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade100)),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('TOTAL DUE:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text(
                                    '$selectedCurrency ${currentTotal.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.blue)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _tenderedController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: InputDecoration(
                                  labelText: 'Amount Tendered',
                                  prefixText: '$selectedCurrency ',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: const OutlineInputBorder(),
                                  isDense: true),
                              onChanged: (val) => setDialogState(() {}),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('CHANGE:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text(
                                    '$selectedCurrency ${changeDue > 0 ? changeDue.toStringAsFixed(2) : "0.00"}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: changeDue >= 0
                                            ? Colors.green
                                            : Colors.red)),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // --- UPSELL SUGGESTIONS ---
                      if (changeDue > 0 &&
                          decimalPart > 0.05 &&
                          selectedCurrency == 'USD')
                        FutureBuilder<List<Product>>(
                          future:
                              _isarService.getProductsUnderPrice(decimalPart),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData || snapshot.data!.isEmpty)
                              return const SizedBox.shrink();

                            return Container(
                              margin: const EdgeInsets.only(top: 10),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.orange.shade300),
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(8)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.lightbulb,
                                          size: 16, color: Colors.orange),
                                      const SizedBox(width: 5),
                                      Text(
                                          "Cover the ${decimalPart.toStringAsFixed(2)} cents?",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.orange,
                                              fontSize: 13)),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Wrap(
                                    spacing: 8,
                                    children: snapshot.data!.map((prod) {
                                      return ActionChip(
                                        backgroundColor: Colors.white,
                                        label: Text(
                                            '${prod.name} (\$${prod.price.toStringAsFixed(2)})'),
                                        onPressed: () {
                                          _addToCart(prod);
                                          setDialogState(() {});
                                        },
                                      );
                                    }).toList(),
                                  )
                                ],
                              ),
                            );
                          },
                        ),

                      const Divider(height: 30),

                      TextField(
                          controller: _customerNameController,
                          decoration: const InputDecoration(
                              labelText: 'Name',
                              isDense: true,
                              border: OutlineInputBorder())),
                      const SizedBox(height: 8),
                      TextField(
                          controller: _customerPhoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                              labelText: 'Phone',
                              isDense: true,
                              border: OutlineInputBorder())),

                      const Divider(height: 30),

                      const Text('Payment Method',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Wrap(
                        spacing: 8,
                        children: ['Cash', 'Swipe', 'Ecocash', 'Pesepay']
                            .map((method) {
                          return ChoiceChip(
                            label: Text(method),
                            selected: selectedMethod == method,
                            onSelected: (selected) =>
                                setDialogState(() => selectedMethod = method),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 10),

                      const Text('Currency',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Radio(
                              value: 'USD',
                              groupValue: selectedCurrency,
                              onChanged: (v) {
                                setDialogState(() {
                                  selectedCurrency = v!;
                                  _tenderedController.clear();
                                });
                              }),
                          const Text('USD'),
                          Radio(
                              value: 'ZiG',
                              groupValue: selectedCurrency,
                              onChanged: (v) {
                                setDialogState(() {
                                  selectedCurrency = v!;
                                  _tenderedController.clear();
                                });
                              }),
                          const Text('ZiG'),
                        ],
                      ),

                      const Divider(height: 30),

                      // Printers (Android only)
                      if (Platform.isAndroid)
                        FutureBuilder<List<BluetoothDevice>>(
                          future: _printerService.getBondedDevices(),
                          builder: (c, snapshot) {
                            if (!snapshot.hasData)
                              return const Text('Searching for printers...');
                            return DropdownButton<BluetoothDevice>(
                              hint: const Text('Select Printer'),
                              value: _selectedPrinter,
                              isExpanded: true,
                              items: snapshot.data!
                                  .map((d) => DropdownMenuItem(
                                      value: d,
                                      child: Text(d.name ?? 'Unknown Device')))
                                  .toList(),
                              onChanged: (v) =>
                                  setDialogState(() => _selectedPrinter = v),
                            );
                          },
                        ),

                      CheckboxListTile(
                        value: isPrinting,
                        onChanged: (v) => setDialogState(() => isPrinting = v!),
                        title: const Text('Print Receipt'),
                        secondary: const Icon(Icons.print),
                      ),
                      CheckboxListTile(
                        value: sendWhatsApp,
                        onChanged: (v) =>
                            setDialogState(() => sendWhatsApp = v!),
                        title: const Text('Send WhatsApp'),
                        secondary: const Icon(Icons.chat),
                      )
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white),
                  onPressed: () {
                    // Validate Cash
                    if (selectedMethod == 'Cash' &&
                        tenderedInput < currentTotal) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content:
                              Text('Tendered amount is less than Total!')));
                      return;
                    }

                    Navigator.pop(context);

                    _finalizeSale(
                        selectedMethod,
                        selectedCurrency,
                        isPrinting,
                        sendWhatsApp,
                        tenderedInput,
                        changeDue > 0 ? changeDue : 0.0);
                  },
                  child: const Text('COMPLETE SALE'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- FINALIZE SALE ---
  void _finalizeSale(String method, String currency, bool printReceipt,
      bool sendWhatsApp, double tendered, double change) async {
    double finalAmount = currency == 'USD' ? _totalUSD : _totalZiG;

    // PESEPAY
    if (method == 'Pesepay') {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final pesepay = PesepayService();
        String apiCurrency = currency == 'ZiG' ? 'ZWL' : currency;

        final result = await pesepay.initiatePayment(
          amount: finalAmount,
          currency: apiCurrency,
          reason: "POS Sale by ${widget.cashierName}",
        );

        Navigator.pop(context);

        if (result['redirectUrl'] != null) {
          final Uri url = Uri.parse(result['redirectUrl']);
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }
          String ref =
              result['referenceNumber'] ?? result['referenceCode'] ?? '';
          if (ref.isNotEmpty) {
            bool paid = await _showPaymentConfirmationDialog(ref);
            if (!paid) return;
          }
        }
      } catch (e) {
        Navigator.pop(context);
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Online Payment Failed: $e')));
        return;
      }
    }

    // SAVE ORDER
    final orderItems = _cart
        .map((c) => OrderItem()
          ..productName = c.product.name
          ..quantity = c.quantity
          ..priceAtSale = c.product.price)
        .toList();

    final newOrder = Order()
      ..orderDate = DateTime.now()
      ..status = OrderStatus.paid
      ..items = orderItems
      ..cashierName = widget.cashierName
      ..totalAmount = _totalUSD
      ..tenderedAmount = tendered
      ..changeAmount = change
      ..paymentCurrency = currency
      ..paymentMethod = method
      ..customerName = _customerNameController.text.isEmpty
          ? 'Walk-in'
          : _customerNameController.text
      ..customerPhone = _customerPhoneController.text;

    await _isarService.saveOrder(newOrder);

    // PRINT RECEIPT
    if (printReceipt && (Platform.isWindows || _selectedPrinter != null)) {
      bool isConnected = await _printerService.connect(_selectedPrinter);
      if (isConnected) {
        final shopDetails = await _settingsService.getShopDetails();
        final branchShop = await _isarService.getCurrentShop();

        await _printerService.printReceipt(
          order: newOrder,
          items: orderItems,
          shopDetails: shopDetails,
          customerDetails: {
            'name': _customerNameController.text,
            'phone': _customerPhoneController.text,
            'address': _customerAddressController.text,
          },
          paymentMethod: method,
          currency: currency,
          totalPaid: finalAmount,
          cashierName: widget.cashierName,
          tendered: tendered,
          change: change,
          branchShop: branchShop,
        );
        await _printerService.disconnect();
      }
    }

    // WHATSAPP RECEIPT
    if (sendWhatsApp) {
      final phone = _customerPhoneController.text;
      if (phone.isNotEmpty) {
        try {
          await WhatsAppService().sendTextReceipt(
              phone, newOrder, currency, finalAmount,
              tendered: tendered, change: change);
        } catch (e) {}
      }
    }

    // RESET
    setState(() {
      _cart.clear();
      _customerNameController.clear();
      _customerPhoneController.clear();
      _customerAddressController.clear();
      _tenderedController.clear();
      _discountAmount = 0;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Transaction Completed!'),
            backgroundColor: Colors.green),
      );
    }
  }

  Future<bool> _showPaymentConfirmationDialog(String reference) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Waiting for Payment...'),
        content: const Text(
            'Please wait for payment completion.\n\nClick "Check Status" to confirm.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                const Text('Cancel Sale', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () async {
              final status =
                  await PesepayService().checkTransactionStatus(reference);
              if (status == 'SUCCESS' || status == 'PAID') {
                Navigator.pop(context, true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Status: $status. Try again.')));
              }
            },
            child: const Text('Check Status'),
          ),
        ],
      ),
    ).then((val) => val ?? false);
  }

  Widget _buildProductCard(Product product) {
    // 1. Determine State
    final bool isOutOfStock = product.quantity <= 0;
    final Color stockColor = isOutOfStock ? Colors.red : Colors.green;
    final String stockText =
        isOutOfStock ? 'Out of Stock' : '${product.quantity} in stock';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          // ... (Your existing onTap logic remains unchanged) ...
          if (!isOutOfStock) {
            _addToCart(product);
          } else {
            showDialog(
              context: context,
              builder: (_) => StockAvailabilityDialog(
                productName: product.name,
                productSku: product.sku ?? "NO_SKU",
                service: _isarService,
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          // FIX STARTS HERE: Wrap in LayoutBuilder or SingleChildScrollView
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min, // Important: shrink wrap content
              children: [
                Icon(
                  isOutOfStock
                      ? Icons.production_quantity_limits
                      : Icons.fastfood,
                  size: 40,
                  color: isOutOfStock ? Colors.grey : Colors.blue,
                ),
                const SizedBox(height: 10),

                // Product Name (Use Flexible/FittedBox if names are very long)
                Text(
                  product.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // Price
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.black87),
                ),

                const SizedBox(height: 6),

                // Stock Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: stockColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: stockColor.withOpacity(0.5)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        stockText,
                        textAlign: TextAlign.center, // Add alignment
                        style: TextStyle(
                          fontSize: 12,
                          color: stockColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isOutOfStock)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search, size: 10, color: stockColor),
                              const SizedBox(width: 4),
                              Text(
                                "Find", // Shortened text to save space
                                style:
                                    TextStyle(fontSize: 10, color: stockColor),
                              )
                            ],
                          ),
                        )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- BUILD METHOD (THE MISSING PIECE) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // NEW: Button to toggle left sidebar
        leading: IconButton(
          icon: Icon(_isProductGridVisible
              ? Icons.fullscreen_exit
              : Icons.view_sidebar),
          tooltip: _isProductGridVisible ? "Hide Products" : "Show Products",
          onPressed: () {
            setState(() {
              _isProductGridVisible = !_isProductGridVisible;
            });
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_shopName,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            if (_shopName !=
                "POS Terminal") // Optional: Show 'POS Terminal' as subtitle
              const Text("POS Terminal", style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Text('Rate: $_zigRate ZiG',
                  style: TextStyle(
                      color: Colors.grey[700], fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
      body: Row(
        children: [
          // LEFT SIDE: Product Grid (Expandable/Shrinkable)
          if (_isProductGridVisible)
            Expanded(
              flex: 6,
              child: Column(
                children: [
                  // Search
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Scan Barcode or Type Name...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = "");
                              _searchFocusNode.requestFocus();
                            }),
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                      onSubmitted: (value) async {
                        if (value.isEmpty) return;
                        final results =
                            await _isarService.searchProducts(value);
                        try {
                          final exactMatch =
                              results.firstWhere((p) => p.sku == value);
                          if (exactMatch.quantity > 0) {
                            _addToCart(exactMatch);
                            _searchController.clear();
                            _searchFocusNode.requestFocus();
                            setState(() => _searchQuery = "");
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Out of Stock!')));
                          }
                        } catch (e) {}
                      },
                    ),
                  ),

                  // Grid
                  // Grid
                  Expanded(
                    child: GestureDetector(
                      // NEW: Tapping the background refocuses the barcode scanner
                      onTap: () {
                        _searchFocusNode.requestFocus();
                      },
                      // Ensures taps on empty space are captured
                      behavior: HitTestBehavior.translucent,
                      child: Container(
                        color: Colors.grey[100],
                        padding: const EdgeInsets.all(8.0),
                        child: FutureBuilder<List<Product>>(
                          future: _searchQuery.isEmpty
                              ? _isarService.getAllProducts()
                              : _isarService.searchProducts(_searchQuery),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData || snapshot.data!.isEmpty)
                              return const Center(
                                  child: Text('No Items Found'));
                            return GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      // FIXED: Changed from 1.1 to 0.75 to make cards taller
                                      // and prevent 29 pixel overflow error
                                      childAspectRatio: 0.75,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10),
                              itemCount: snapshot.data!.length,
                              itemBuilder: (c, i) =>
                                  _buildProductCard(snapshot.data![i]),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if (_isProductGridVisible) const VerticalDivider(width: 1),

          // RIGHT SIDE: Cart
          // Logic: If left side is visible, this takes flex 4. If left side hidden, flex 1 (100%)
          Expanded(
            flex: _isProductGridVisible ? 4 : 1,
            child: Column(
              children: [
                _buildCartHeader(),
                Expanded(child: _buildCartList()),
                _buildCheckoutSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartHeader() => Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue.shade50,
      width: double.infinity,
      child: const Text('Current Order',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)));

  Widget _buildCartList() {
    if (_cart.isEmpty)
      return const Center(
          child: Text('Cart is empty', style: TextStyle(color: Colors.grey)));
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: _cart.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final item = _cart[index];
        return ListTile(
          title: Text(item.product.name,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(
              '${item.quantity} x \$${item.product.price.toStringAsFixed(2)}'),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            Text('\$${item.total.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () => _removeFromCart(index))
          ]),
        );
      },
    );
  }

  Widget _buildCheckoutSection() => Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.1))
      ]),
      child: Column(children: [
        _buildSummaryRow('Subtotal', _subtotal),

        // ... (Discount logic remains unchanged) ...
        InkWell(
            onTap: _showDiscountDialog,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Discount', style: TextStyle(color: Colors.blue)),
                  Text('- \$${_discountAmount.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.red))
                ])),

        const SizedBox(height: 5),
        _buildSummaryRow('Tax (${_taxRate.toStringAsFixed(1)}%)', _taxAmount),
        const Divider(),

        // FIX: Total USD Row
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Flexible(
            child: Text('TOTAL USD',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('\$${_totalUSD.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
            ),
          )
        ]),

        // FIX: Total ZiG Row
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Flexible(
            child: Text('TOTAL ZiG',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange)),
          ),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('ZiG ${_totalZiG.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange)),
            ),
          )
        ]),

        const SizedBox(height: 16),
        // ... (Button remains unchanged) ...
        SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
                onPressed: _cart.isEmpty ? null : _showCheckoutDialog,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white),
                child: const Text('CHARGE',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold))))
      ]));
  Widget _buildSummaryRow(String label, double amount) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Text('\$${amount.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
      ]));
}

// Place this at the bottom of your file, outside the _PosScreenState class
class StockAvailabilityDialog extends StatelessWidget {
  final String productName;
  final String productSku;
  final IsarService service;

  const StockAvailabilityDialog({
    Key? key,
    required this.productName,
    required this.productSku,
    required this.service,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.store_mall_directory, color: Colors.blue),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Branch Availability",
                    style: TextStyle(fontSize: 16)),
                Text(productName,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 450, // Fixed width for tablet dialogs
        height: 300,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: service.checkOtherBranches(productName, productSku),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.remove_shopping_cart,
                        size: 50, color: Colors.grey[300]),
                    const SizedBox(height: 10),
                    const Text(
                      "No stock found in other branches.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            final results = snapshot.data!;

            return ListView.separated(
              itemCount: results.length,
              separatorBuilder: (c, i) => const Divider(),
              itemBuilder: (context, index) {
                final item = results[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.shade50,
                    foregroundColor: Colors.green,
                    child: Text("${item['quantity']}",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  title: Text(item['shopName'],
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          "${item['city']} • ${item['address'] ?? 'No Address'}"),
                      if (item['phone'] != null)
                        Text("Tel: ${item['phone']}",
                            style: const TextStyle(
                                fontSize: 11, color: Colors.blueGrey)),
                    ],
                  ),
                  trailing: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade50,
                      foregroundColor: Colors.blue,
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.call, size: 16),
                    label: const Text("Call"),
                    onPressed: () async {
                      if (item['phone'] != null) {
                        final Uri launchUri = Uri(
                          scheme: 'tel',
                          path: item['phone'],
                        );
                        if (await canLaunchUrl(launchUri)) {
                          await launchUrl(launchUri);
                        }
                      }
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("CLOSE"),
        ),
      ],
    );
  }
}
