import 'package:flutter/material.dart'; // Needed for Colors in logic
import 'package:isar/isar.dart';

part 'product.g.dart';

@collection
class Product {
  Id id = Isar.autoIncrement;

  late String name;
  late double price;
  late double costPrice;

  // --- NEW: Inventory base unit (smallest unit) ---
  // e.g. piece, ml, gram
  String baseUnit = 'piece';

    // Quantity is stored in BASE units (e.g. pieces).
  late int quantity;
  int initialQuantity = 0;

  late String category;
  String? sku;

  @Index()
  int? shopId;
  String? shopName;
  String? supplierName;
  String? imageUrl;

  // --- NEW: STRATEGY CONFIGURATION FIELDS ---

  // The specific level where this item enters the "Yellow" zone
  int reorderPoint = 10;

  // How many days it takes for a supplier to deliver this item
  int leadTimeDays = 7;

  // Calculated average sales per day (velocity).
  // Update this field whenever you close a "Day" or run a report.
  double averageDailySales = 1.0;

  // --- STRATEGY CALCULATIONS (Getters) ---

  // 1. TRAFFIC LIGHT STRATEGY
  @ignore
  String get stockStatus {
    if (quantity == 0) return 'Out of Stock'; // RED
    if (quantity <= reorderPoint) return 'Critical'; // RED
    if (quantity <= (reorderPoint * 1.5)) return 'Warning'; // YELLOW
    return 'Healthy'; // GREEN
  }

  // 2. PREDICTIVE ORDERING (Days Sales of Inventory - DSI)
  @ignore
  int get daysUntilStockout {
    if (averageDailySales <= 0) return 999; // Moving too slow to measure
    return (quantity / averageDailySales).floor();
  }

  // Helper for UI Colors
  @ignore
  Color get statusColor {
    switch (stockStatus) {
      case 'Out of Stock':
      case 'Critical':
        return Colors.red;
      case 'Warning':
        return Colors.orange;
      case 'Healthy':
      default:
        return Colors.green;
    }
  }

  // 3. ABC ANALYSIS HELPER (Calculated via usage value)
  // Note: True ABC requires comparing against all products,
  // but this is a helper for the sort value.
  @ignore
  double get usageValue => costPrice * soldCount;

  // EXISTING HELPERS
  @ignore
  double get totalStockValue => price * quantity;
  @ignore
  double get totalCostValue => costPrice * quantity;
  @ignore
  int get soldCount => (initialQuantity - quantity).clamp(0, 999999);
}

@collection
class StockAdjustment {
  Id id = Isar.autoIncrement;
  int productId;
  int quantityChange;
  String reason;
  DateTime date;

  StockAdjustment(
      {required this.productId,
      required this.quantityChange,
      required this.reason,
      required this.date});
}
