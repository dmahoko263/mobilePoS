import 'package:isar/isar.dart';

part 'order_item.g.dart';

@embedded
class OrderItem {
  String? productName;
  int? quantity;
  double? priceAtSale;
  double? costAtSale; // New: To calculate profit later
}
