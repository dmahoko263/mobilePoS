import 'package:isar/isar.dart';

part 'shop.g.dart';

@collection
class Shop {
  Id id = Isar.autoIncrement;

  late String name;
  String? address;
  String? city; // NEW FIELD
  String? phone;
  String? logoPath;
  String? currency;
}
