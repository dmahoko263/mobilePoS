import 'package:isar/isar.dart';
import 'order_item.dart';

part 'order.g.dart';

@collection
class Order {
  Id id = Isar.autoIncrement;

  late DateTime orderDate;

  late double totalAmount;

  @enumerated
  late OrderStatus status;

  List<OrderItem>? items;

  String? cashierName;

  // --- NEW FIELDS ---
  String? customerName;
  String? customerPhone;

  double? tenderedAmount;
  double? changeAmount;

  String? paymentCurrency; // Stores "USD" or "ZiG"

  // *** ADD THIS MISSING FIELD ***
  String? paymentMethod; // Stores "Cash", "Swipe", "Ecocash", etc.

  @Index()
  int? shopId;
}

enum OrderStatus { pending, paid, synced }
