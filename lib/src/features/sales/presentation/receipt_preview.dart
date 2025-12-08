import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_tablet_app/src/core/services/settings_service.dart';
import 'package:pos_tablet_app/src/features/orders/models/order.dart';

class ReceiptPreview extends StatefulWidget {
  final Order order;
  const ReceiptPreview({super.key, required this.order});

  @override
  State<ReceiptPreview> createState() => _ReceiptPreviewState();
}

class _ReceiptPreviewState extends State<ReceiptPreview> {
  final _settingsService = SettingsService();
  Map<String, String> _shopDetails = {};
  String? _logoPath;
  double _zigRate = 1.0; // Default to 1 if USD

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final details = await _settingsService.getShopDetails();
    final logo = await _settingsService.getShopLogo();
    final rate = await _settingsService.getZigRate();
    setState(() {
      _shopDetails = details;
      _logoPath = logo;
      _zigRate = rate;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine Currency & Multiplier
    // Note: If order was paid in ZiG, we convert the Base USD Amount to ZiG using current rate
    // (Ideally we would use historic rate saved in order, but current rate is a fallback)
    String currencyCode = widget.order.paymentCurrency ?? 'USD';
    double multiplier = (currencyCode == 'ZiG') ? _zigRate : 1.0;

    // Formatting
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final numFormat = NumberFormat("#,##0.00", "en_US");

    const receiptStyle =
        TextStyle(fontFamily: 'Courier', fontSize: 14, color: Colors.black);
    const boldStyle = TextStyle(
        fontFamily: 'Courier',
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.black);

    double totalDisplay = widget.order.totalAmount * multiplier;
    double tenderedDisplay = (widget.order.tenderedAmount ?? 0) *
        multiplier; // Assuming tendered was entered in pay currency
    // If tendered was saved raw, we use it directly. If it was saved as USD equivalent, we multiply.
    // Based on POS Screen logic, tendered is saved AS ENTERED (in selected currency).
    // So we DON'T multiply tendered/change if they are already in the correct currency.
    // Wait... POS Screen logic saved `tendered` directly.
    // Let's assume tendered/change are already in the payment currency.
    double finalTendered = widget.order.tenderedAmount ?? 0;
    double finalChange = widget.order.changeAmount ?? 0;

    // BUT totalAmount in Order model is ALWAYS BASE USD. So we MUST multiply it.

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: Container(
        width: 380,
        padding: const EdgeInsets.all(20),
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // HEADER
              if (_logoPath != null && File(_logoPath!).existsSync())
                Image.file(File(_logoPath!),
                    height: 80, width: 80, fit: BoxFit.contain)
              else
                const Icon(Icons.store, size: 50, color: Colors.black87),

              const SizedBox(height: 10),
              Text(_shopDetails['name'] ?? 'Loading...',
                  style: boldStyle.copyWith(fontSize: 18),
                  textAlign: TextAlign.center),
              Text(_shopDetails['address'] ?? '',
                  style: receiptStyle, textAlign: TextAlign.center),
              Text('Tel: ${_shopDetails['phone'] ?? ''}',
                  style: receiptStyle, textAlign: TextAlign.center),
              const SizedBox(height: 15),
              _buildDashedLine(),
              const SizedBox(height: 10),

              // METADATA
              _buildRow('Receipt No:', '#${widget.order.id}',
                  style: receiptStyle),
              _buildRow('Date:', dateFormat.format(widget.order.orderDate),
                  style: receiptStyle),
              _buildRow('Cashier:', widget.order.cashierName ?? 'Admin',
                  style: receiptStyle),

              const SizedBox(height: 10),
              _buildDashedLine(),
              const SizedBox(height: 10),

              // ITEMS
              Row(
                children: [
                  Expanded(flex: 2, child: Text('Item', style: boldStyle)),
                  Expanded(
                      flex: 1,
                      child: Text('Qty',
                          style: boldStyle, textAlign: TextAlign.center)),
                  Expanded(
                      flex: 1,
                      child: Text('Total',
                          style: boldStyle, textAlign: TextAlign.right)),
                ],
              ),
              const SizedBox(height: 5),

              if (widget.order.items != null)
                ...widget.order.items!.map((item) {
                  // Item Price is in USD Base. Convert to Payment Currency.
                  final itemTotalUSD =
                      (item.priceAtSale ?? 0) * (item.quantity ?? 1);
                  final itemDisplay = itemTotalUSD * multiplier;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      children: [
                        Expanded(
                            flex: 2,
                            child: Text(item.productName ?? 'Unknown',
                                style: receiptStyle)),
                        Expanded(
                            flex: 1,
                            child: Text('${item.quantity}',
                                style: receiptStyle,
                                textAlign: TextAlign.center)),
                        Expanded(
                            flex: 1,
                            child: Text(numFormat.format(itemDisplay),
                                style: receiptStyle,
                                textAlign: TextAlign.right)),
                      ],
                    ),
                  );
                }),

              const SizedBox(height: 10),
              _buildDashedLine(),
              const SizedBox(height: 10),

              // TOTALS
              _buildRow('TOTAL $currencyCode:', numFormat.format(totalDisplay),
                  style: boldStyle.copyWith(fontSize: 16)),

              if (widget.order.tenderedAmount != null) ...[
                const SizedBox(height: 5),
                _buildRow('Tendered:', numFormat.format(finalTendered),
                    style: receiptStyle),
                _buildRow('Change:', numFormat.format(finalChange),
                    style: boldStyle),
              ],

              const SizedBox(height: 20),
              Text('Thank you for your support!',
                  style: receiptStyle, textAlign: TextAlign.center),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                color: Colors.black,
                child: const Text('Powered by Lifetime Images',
                    style: TextStyle(
                        fontFamily: 'Courier',
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.print),
                  label: const Text('Close / Print'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {required TextStyle style}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: style), Text(value, style: style)],
      ),
    );
  }

  Widget _buildDashedLine() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          children: List.generate(
              dashCount,
              (_) => SizedBox(
                  width: dashWidth,
                  height: 1,
                  child: DecoratedBox(
                      decoration: BoxDecoration(color: Colors.black)))),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
        );
      },
    );
  }
}
