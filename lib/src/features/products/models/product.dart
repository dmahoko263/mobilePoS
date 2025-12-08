import 'package:isar/isar.dart';

part 'product.g.dart'; // This file is generated automatically

@collection
class Product {
  Id id = Isar.autoIncrement;

  late String name;

  late double price; // Selling Price
  late double costPrice; // Cost Price

  late int quantity; // Current Stock Level
  int initialQuantity =
      0; // NEW: To track sales performance (Initial - Current)

  late String category;
  String? sku; // Barcode

  // NEW: Link to Shop & Supplier
  @Index()
  int? shopId; // Null means "Global" (All shops)
  String? shopName; // Snapshot of shop name for display
  String? supplierName; // NEW: Track who supplied this

  String? imageUrl; // NEW: For the dashboard icon

  // --- HELPER CALCULATIONS (Not stored in DB, calculated on the fly) ---

  // Total value of stock at selling price
  @ignore
  double get totalStockValue => price * quantity;

  // Total value of stock at cost price
  @ignore
  double get totalCostValue => costPrice * quantity;

  // Items sold since last full restock
  @ignore
  int get soldCount => (initialQuantity - quantity).clamp(0, 999999);

  // Sales performance (0.0 to 1.0)
  @ignore
  double get performance =>
      initialQuantity == 0 ? 0 : soldCount / initialQuantity;
}

// NEW: Class to track Write-offs and Restocks history
@collection
class StockAdjustment {
  Id id = Isar.autoIncrement;

  int productId;
  int quantityChange; // Positive = Restock, Negative = Write-off
  String reason; // "Damaged", "Expired", "Theft", "Restock"
  DateTime date;

  StockAdjustment(
      {required this.productId,
      required this.quantityChange,
      required this.reason,
      required this.date});
}
