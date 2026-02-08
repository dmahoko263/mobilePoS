import 'package:isar/isar.dart';

part 'order_item.g.dart';

@embedded
class OrderItem {
  String? productName;
  int? quantity;
  double? priceAtSale;
  double? costAtSale; // New: To calculate profit later
  String? unitName;        // "Single", "Carton", etc
int? baseQtyDeducted;    // how many base units were removed from stock

}
