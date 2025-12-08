import 'package:isar/isar.dart';

part 'user.g.dart';

@collection
class User {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String username;

  late String password; // In a real app, hash this!

  @enumerated
  late UserRole role; // admin, assistant, cashier
  // NEW: Link to Shop (Nullable for Super Admin who sees all)
  int? shopId;
}

enum UserRole { superAdmin, assistant, admin, cashier }
