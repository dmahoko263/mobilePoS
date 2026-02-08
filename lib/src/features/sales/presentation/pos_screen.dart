import 'dart:io';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:pos_tablet_app/src/core/payments/pesepay_api.dart';

import 'package:pos_tablet_app/src/core/services/isar_service.dart';
import 'package:pos_tablet_app/src/core/services/printer_service.dart';
import 'package:pos_tablet_app/src/core/services/ZimraService.dart';
import 'package:pos_tablet_app/src/core/services/settings_service.dart';
import 'package:pos_tablet_app/src/features/orders/models/order.dart';
import 'package:pos_tablet_app/src/features/orders/models/order_item.dart';
import 'package:pos_tablet_app/src/features/products/models/product.dart';
import 'package:pos_tablet_app/src/features/products/models/product_unit.dart';
import 'package:pos_tablet_app/src/core/services/whatsapp_service.dart';
import 'package:url_launcher/url_launcher.dart';

class CartItem {
  final Product product;

  /// What sell unit is being used for this cart line (Single / Pack / Carton)
  final String unitName;

  /// How many base units this represents (Single=1, Carton=24, etc)
  final int multiplierToBase;

  /// Price for THIS unit (can be different from multiplier * single price)
  final double unitPrice;

  /// Optional: unitId (Isar ProductUnit.id) if it exists
  final int? unitId;

  int quantity;

  CartItem({
    required this.product,
    required this.unitName,
    required this.multiplierToBase,
    required this.unitPrice,
    this.unitId,
    this.quantity = 1,
  });

  int get baseQtyDeducted => quantity * multiplierToBase;

  double get total => unitPrice * quantity;
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

  // =========================
  // PESEPAY BACKEND URL
  // =========================
  // TODO: replace with your backend url (LAN IP / domain)
  static const String _apiBaseUrl = "http://YOUR_BACKEND_IP:3000";
  PesepayApi get _pesepayApi => PesepayApi(_apiBaseUrl);

  // Cache product units (single/pack/carton) by productId
  final Map<int, List<ProductUnit>> _unitsCache = {};

  // Controllers
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _customerAddressController = TextEditingController();
  final _searchController = TextEditingController();
  final _tenderedController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // State
  final List<CartItem> _cart = [];
  String _shopName = "POS Terminal";
  BluetoothDevice? _selectedPrinter;
  double _zigRate = 0;
  double _taxRate = 0;
  double _discountAmount = 0;
  String _searchQuery = "";
  final bool _isNavSidebarOpen = false; // Start closed
  bool _isProductGridVisible = true;

  @override
  void initState() {
    super.initState();
    _loadRates();
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
    if (shop != null && shop.name.isNotEmpty) {
      _shopName = shop.name;
    }
  }

  // --- CART LOGIC ---
  Future<void> _addToCart(Product product, {CartItem? forcedCartItem}) async {
    final cartItem = forcedCartItem ?? await _pickUnitAndBuildCartItem(product);
    if (cartItem == null) return;

    // Stock check for +1 unit
    final baseNeededForOne = cartItem.multiplierToBase;
    if (!await _hasEnoughStockForBaseQty(product, baseNeededForOne)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Out of Stock!')),
        );
      }
      return;
    }

    setState(() {
      final index = _cart.indexWhere((item) =>
          item.product.id == cartItem.product.id &&
          item.unitName == cartItem.unitName);
      if (index >= 0) {
        final nextBaseNeeded =
            (_cart[index].quantity + 1) * _cart[index].multiplierToBase;
        if (product.quantity >= nextBaseNeeded) {
          _cart[index].quantity++;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Not enough stock for that quantity')),
          );
        }
      } else {
        _cart.add(cartItem);
      }
    });

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

  Future<List<ProductUnit>> _getUnitsForProduct(Product product) async {
    final pid = product.id;
    if (_unitsCache.containsKey(pid)) return _unitsCache[pid]!;
    final units = await _isarService.getUnitsForProduct(pid);
    _unitsCache[pid] = units;
    return units;
  }

  Future<CartItem?> _pickUnitAndBuildCartItem(Product product) async {
    final units = await _getUnitsForProduct(product);

    // Fallback: no units configured => treat Product.price as "Single"
    if (units.isEmpty) {
      return CartItem(
        product: product,
        unitName: 'Single',
        multiplierToBase: 1,
        unitPrice: product.price,
        unitId: null,
      );
    }

    // Only one unit => just use it
    if (units.length == 1) {
      final u = units.first;
      return CartItem(
        product: product,
        unitName: u.unitName,
        multiplierToBase: u.multiplierToBase,
        unitPrice: u.sellPrice,
        unitId: u.id,
      );
    }

    // Multiple units => let cashier choose
    if (!mounted) return null;
    final selected = await showModalBottomSheet<ProductUnit>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const ListTile(
              title: Text('Select unit',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Choose how you want to sell this item'),
            ),
            const Divider(height: 0),
            ...units.map(
              (u) => ListTile(
                leading: const Icon(Icons.inventory_2_outlined),
                title: Text(u.unitName),
                subtitle: Text(
                    '1 ${u.unitName} = ${u.multiplierToBase} ${product.baseUnit}(s)'),
                trailing: Text('\$${u.sellPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                onTap: () => Navigator.pop(context, u),
              ),
            ),
          ],
        ),
      ),
    );

    if (selected == null) return null;

    return CartItem(
      product: product,
      unitName: selected.unitName,
      multiplierToBase: selected.multiplierToBase,
      unitPrice: selected.sellPrice,
      unitId: selected.id,
    );
  }

  Future<bool> _hasEnoughStockForBaseQty(
      Product product, int baseQtyNeeded) async {
    return product.quantity >= baseQtyNeeded;
  }

  @override
  void dispose() {
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
    bool fiscalize = true;

    _tenderedController.clear();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            double currentTotal =
                selectedCurrency == 'USD' ? _totalUSD : _totalZiG;
            double tenderedInput =
                double.tryParse(_tenderedController.text) ?? 0.0;
            double changeDue = tenderedInput - currentTotal;

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
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const SizedBox.shrink();
                            }

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
                            if (!snapshot.hasData) {
                              return const Text('Searching for printers...');
                            }
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

                      // --- FISCALIZATION TOGGLE ---
                      CheckboxListTile(
                        value: fiscalize,
                        onChanged: (v) => setDialogState(() => fiscalize = v!),
                        title: const Text('Fiscalize (ZIMRA)'),
                        subtitle: const Text('Uploads sale to tax authority'),
                        secondary:
                            const Icon(Icons.cloud_upload, color: Colors.blue),
                        activeColor: Colors.blue,
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
                    if (selectedMethod == 'Cash' &&
                        tenderedInput < currentTotal) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content:
                              Text('Tendered amount is less than Total!')));
                      return;
                    }

                    Navigator.pop(context);

                    _finalizeSale(selectedMethod, selectedCurrency, isPrinting,
                        sendWhatsApp, fiscalize, tenderedInput, changeDue > 0 ? changeDue : 0.0);
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
      bool sendWhatsApp, bool fiscalize, double tendered, double change) async {
    double finalAmount = currency == 'USD' ? _totalUSD : _totalZiG;

    // ==========================================
    // 1) ONLINE PAYMENT (PESEPAY via BACKEND)
    // ==========================================
    if (method == 'Pesepay') {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final apiCurrency = currency == 'ZiG' ? 'ZWL' : currency;

        final shop = await _isarService.getCurrentShop();
       final shopId = (shop?.id ?? "LOCAL").toString();


        final phone = _customerPhoneController.text.trim();
        if (phone.isEmpty) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Customer phone is required for online payment')));
          return;
        }

        // Use a temporary order id for gateway initiation (real order saved after payment confirmed)
        final tempOrderId = "TMP-${DateTime.now().millisecondsSinceEpoch}";

        final result = await _pesepayApi.initiateEcocash(
          shopId: shopId,
          orderId: tempOrderId,
          amount: finalAmount,
          currencyCode: apiCurrency,
          phone: phone,
          email: "",
          methodCode: "PZW201",
        );

        Navigator.pop(context);

        final redirectUrl = result["redirectUrl"] ?? result["redirect_url"];
        if (redirectUrl != null && redirectUrl.toString().isNotEmpty) {
          final Uri url = Uri.parse(redirectUrl.toString());
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }
        }

        final ref = (result['referenceNumber'] ??
                result['reference_number'] ??
                result['referenceCode'] ??
                result['reference_code'] ??
                '')
            .toString();

        if (ref.isNotEmpty) {
          final paid = await _showPaymentConfirmationDialog(ref);
          if (!paid) return;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Payment reference missing. Payment not confirmed.')));
          return;
        }
      } catch (e) {
        Navigator.pop(context);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Online Payment Failed: $e')));
        }
        return;
      }
    }

    // ==========================================
    // 2) UPDATE INVENTORY (deduct stock in base units)
    // ==========================================
    for (final c in _cart) {
      final baseDeduct = c.baseQtyDeducted;
      await _isarService.adjustProductStockBaseQty(c.product.id, -baseDeduct);
      c.product.quantity = (c.product.quantity - baseDeduct);
      if (c.product.quantity < 0) c.product.quantity = 0;
    }

    // ==========================================
    // 3) CREATE ORDER OBJECT
    // ==========================================
    final orderItems = _cart
        .map((c) => OrderItem()
          ..productName = c.product.name
          ..quantity = c.quantity
          ..unitName = c.unitName
          ..baseQtyDeducted = c.baseQtyDeducted
          ..priceAtSale = c.unitPrice
          ..costAtSale = c.product.costPrice)
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

    // ==========================================
    // 4) SAVE LOCALLY (get ID for fiscalization)
    // ==========================================
    final orderId = await _isarService.saveOrderLocal(newOrder);
    newOrder.id = orderId;

    // ==========================================
    // 5) ZIMRA FISCALIZATION (OPTIONAL)
    // ==========================================
    String fiscalMessage = "";
    if (fiscalize) {
      try {
        final zimraService = ZimraService(_isarService);
        await zimraService.fiscalizeOrder(newOrder);
        fiscalMessage = " & Fiscalized";
      } catch (e) {
        // Keep sale saved locally; mark retry inside ZimraService if you do that
        // ignore: avoid_print
        print("ZIMRA Fiscalization Skipped/Failed: $e");
      }
    }

    // ==========================================
    // 6) PRINT RECEIPT
    // ==========================================
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

    // ==========================================
    // 7) WHATSAPP RECEIPT
    // ==========================================
    if (sendWhatsApp) {
      final phone = _customerPhoneController.text;
      if (phone.isNotEmpty) {
        try {
          await WhatsAppService().sendTextReceipt(
              phone, newOrder, currency, finalAmount,
              tendered: tendered, change: change);
        } catch (e) {
          // ignore
        }
      }
    }

    // ==========================================
    // 8) RESET UI
    // ==========================================
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
        SnackBar(
            content: Text('Transaction Completed$fiscalMessage!'),
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
              try {
                final statusResp = await _pesepayApi.checkStatus(reference);
                final statusStr = (statusResp["status"] ??
                        statusResp["paymentStatus"] ??
                        statusResp["message"] ??
                        "")
                    .toString()
                    .toUpperCase();

                final paid =
                    statusStr.contains("PAID") || statusStr.contains("SUCCESS");

                if (paid) {
                  Navigator.pop(context, true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Status: $statusStr. Try again.')));
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Status check failed: $e')));
              }
            },
            child: const Text('Check Status'),
          ),
        ],
      ),
    ).then((val) => val ?? false);
  }

  Widget _buildProductCard(Product product) {
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isOutOfStock
                      ? Icons.production_quantity_limits
                      : Icons.fastfood,
                  size: 40,
                  color: isOutOfStock ? Colors.grey : Colors.blue,
                ),
                const SizedBox(height: 10),
                Text(
                  product.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.black87),
                ),
                const SizedBox(height: 6),
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
                        textAlign: TextAlign.center,
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
                                "Find",
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

  // --- BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
            if (_shopName != "POS Terminal")
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
          if (_isProductGridVisible)
            Expanded(
              flex: 6,
              child: Column(
                children: [
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

                        final unit =
                            await _isarService.getUnitByBarcode(value);
                        if (unit != null) {
                          final product = await _isarService
                              .getProductById(unit.productId);
                          if (product != null) {
                            final baseNeeded = unit.multiplierToBase;
                            if (product.quantity >= baseNeeded) {
                              await _addToCart(
                                product,
                                forcedCartItem: CartItem(
                                  product: product,
                                  unitName: unit.unitName,
                                  multiplierToBase: unit.multiplierToBase,
                                  unitPrice: unit.sellPrice,
                                  unitId: unit.id,
                                ),
                              );
                              _searchController.clear();
                              _searchFocusNode.requestFocus();
                              setState(() => _searchQuery = "");
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Out of Stock!')));
                            }
                          }
                          return;
                        }

                        final results =
                            await _isarService.searchProducts(value);
                        try {
                          final exactMatch =
                              results.firstWhere((p) => p.sku == value);
                          if (exactMatch.quantity > 0) {
                            await _addToCart(exactMatch);
                            _searchController.clear();
                            _searchFocusNode.requestFocus();
                            setState(() => _searchQuery = "");
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Out of Stock!')));
                          }
                        } catch (e) {
                          // ignore
                        }
                      },
                    ),
                  ),

                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _searchFocusNode.requestFocus();
                      },
                      behavior: HitTestBehavior.translucent,
                      child: Container(
                        color: Colors.grey[100],
                        padding: const EdgeInsets.all(8.0),
                        child: FutureBuilder<List<Product>>(
                          future: _searchQuery.isEmpty
                              ? _isarService.getAllProducts()
                              : _isarService.searchProducts(_searchQuery),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const Center(child: Text('No Items Found'));
                            }
                            return GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
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
    if (_cart.isEmpty) {
      return const Center(
          child: Text('Cart is empty', style: TextStyle(color: Colors.grey)));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: _cart.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final item = _cart[index];
        return ListTile(
          title: Text('${item.product.name} (${item.unitName})',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(
              '${item.quantity} x \$${item.unitPrice.toStringAsFixed(2)}'),
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
    super.key,
    required this.productName,
    required this.productSku,
    required this.service,
  });

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
                const Text("Branch Availability", style: TextStyle(fontSize: 16)),
                Text(productName,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 450,
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
