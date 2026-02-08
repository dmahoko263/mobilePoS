import 'package:isar/isar.dart';

part 'product_unit.g.dart';

@collection
class ProductUnit {
  Id id = Isar.autoIncrement;

  /// FK -> Product.id
  late int productId;

  /// e.g. "Single", "Pack", "Carton"
  late String unitName;

  /// How many base units this sell unit represents.
  /// Example: base = piece, carton(24) => 24
  late int multiplierToBase;

  /// Selling price for THIS unit (can differ from multiplier * single price)
  late double sellPrice;

  /// Optional barcode per unit (useful for scanning cartons/packs)
  String? barcode;
}
