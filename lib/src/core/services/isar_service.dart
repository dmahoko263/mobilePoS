import 'dart:convert';
import 'dart:io';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pos_tablet_app/src/features/products/models/product.dart';
import 'package:pos_tablet_app/src/features/orders/models/order.dart';
import 'package:pos_tablet_app/src/features/auth/models/user.dart';
import 'package:pos_tablet_app/src/features/auth/models/shop.dart';

class IsarService {
  late Future<Isar> db;

  // GLOBAL STATE
  static int? currentShopId;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [ProductSchema, OrderSchema, UserSchema, ShopSchema],
        directory: dir.path,
        inspector: true,
      );
    }
    return Future.value(Isar.getInstance());
  }

  // -------------------------
  // SHOP MANAGEMENT
  // -------------------------
  Future<void> createShop(Shop shop) async {
    final isar = await db;
    await isar.writeTxn(() async => await isar.shops.put(shop));
  }

  Future<List<Shop>> getAllShops() async {
    final isar = await db;
    return await isar.shops.where().findAll();
  }

  Future<Shop?> getCurrentShop() async {
    if (currentShopId == null) return null;
    final isar = await db;
    return await isar.shops.get(currentShopId!);
  }

  // -------------------------
  // PRODUCT MANAGEMENT
  // -------------------------
  Future<void> saveProduct(Product newProduct) async {
    final isar = await db;
    if (currentShopId != null) newProduct.shopId = currentShopId;
    isar.writeTxnSync<int>(() => isar.products.putSync(newProduct));
  }

  // --- NEW: Needed for Sales Tracking ---
  Future<Product?> getProductById(Id id) async {
    final isar = await db;
    return await isar.products.get(id);
  }

  Future<List<Product>> getAllProducts() async {
    final isar = await db;
    // Super Admin sees all
    if (currentShopId == null) return await isar.products.where().findAll();

    // Shop Admin sees Shop + Global
    return await isar.products
        .filter()
        .shopIdEqualTo(currentShopId)
        // .or()
        // .shopIdIsNull()
        .findAll();
  }

  Future<List<Product>> searchProducts(String query) async {
    final isar = await db;
    if (query.isEmpty) return [];

    // SUPER ADMIN: Searches everything
    if (currentShopId == null) {
      return await isar.products
          .filter()
          .nameContains(query, caseSensitive: false)
          .or()
          .skuEqualTo(query)
          .findAll();
    }

    // SHOP ADMIN: Searches ONLY their shop
    return await isar.products
        .filter()
        .shopIdEqualTo(currentShopId) // Strict Scope
        .and()
        .group((q) =>
            q.nameContains(query, caseSensitive: false).or().skuEqualTo(query))
        .findAll();
  }

  Future<List<Product>> getProductsUnderPrice(double maxPrice) async {
    final isar = await db;

    // SUPER ADMIN
    if (currentShopId == null) {
      return await isar.products
          .filter()
          .priceLessThan(maxPrice + 0.001)
          .and()
          .priceGreaterThan(0)
          .findAll();
    }

    // SHOP ADMIN: Only their shop's inventory
    return await isar.products
        .filter()
        .shopIdEqualTo(currentShopId) // Strict Scope
        .and()
        .priceLessThan(maxPrice + 0.001)
        .and()
        .priceGreaterThan(0)
        .findAll();
  }

  Future<void> deleteProduct(Id id) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.products.delete(id);
    });
  }

  // -------------------------
  // INTER-BRANCH STOCK CHECK
  // -------------------------
  Future<List<Map<String, dynamic>>> checkOtherBranches(
      String productName, String sku) async {
    final isar = await db;

    // If we don't know who is asking, we can't exclude them.
    // But assuming a Shop Admin is logged in:
    final myShopId = currentShopId;

    // 1. Get ALL shops except the current one
    var otherShopsQuery = isar.shops.filter().not().idEqualTo(myShopId ?? -1);

    final otherShops = await otherShopsQuery.findAll();

    List<Map<String, dynamic>> results = [];

    // 2. Iterate through other shops to find the match
    for (var shop in otherShops) {
      final match = await isar.products
          .filter()
          .shopIdEqualTo(shop.id) // Look inside that specific shop
          .and()
          .group((q) => q
              .skuEqualTo(sku) // Match SKU (Best match)
              .or()
              .nameEqualTo(productName, caseSensitive: false)) // Or Name
          .findFirst();

      // 3. If found and has stock, add to report
      if (match != null && match.quantity > 0) {
        results.add({
          "shopName": shop.name,
          "city": shop.city,
          "address": shop.address,
          "quantity": match.quantity,
          "phone": shop.phone,
        });
      }
    }

    // Sort by highest stock first
    results
        .sort((a, b) => (b['quantity'] as int).compareTo(a['quantity'] as int));

    return results;
  }

  // -------------------------
  // ORDER MANAGEMENT
  // -------------------------
  Future<void> saveOrder(Order newOrder) async {
    final isar = await db;
    if (currentShopId != null) newOrder.shopId = currentShopId;

    await isar.writeTxn(() async {
      await isar.orders.put(newOrder);

      // Note: We handle Stock Decrement in the UI logic or here.
      // If logic is moved here fully, ensure it doesn't double count.
    });
  }

  Future<List<Order>> getAllOrders() async {
    final isar = await db;
    if (currentShopId == null) {
      return await isar.orders.where().findAll();
    }
    final orders =
        await isar.orders.filter().shopIdEqualTo(currentShopId).findAll();
    return orders.reversed.toList();
  }

  // -------------------------
  // USER MANAGEMENT
  // -------------------------
  Future<bool> isUserDbEmpty() async {
    final isar = await db;
    return await isar.users.count() == 0;
  }

  Future<void> createUser(
      String username, String password, UserRole role, int? shopId) async {
    final isar = await db;
    final newUser = User()
      ..username = username
      ..password = password
      ..role = role
      ..shopId = shopId;
    await isar.writeTxn(() async => await isar.users.put(newUser));
  }

  Future<User?> loginUser(String username, String password) async {
    final isar = await db;
    final user = await isar.users
        .filter()
        .usernameEqualTo(username)
        .passwordEqualTo(password)
        .findFirst();
    if (user != null) currentShopId = user.shopId;
    return user;
  }

  Future<List<User>> getAllUsers() async {
    final isar = await db;
    return await isar.users.where().findAll();
  }

  Future<void> deleteUser(Id id) async {
    final isar = await db;
    await isar.writeTxn(() async => await isar.users.delete(id));
  }

  // -------------------------
  // BACKUP & RESTORE
  // -------------------------
  Future<File> createBackup() async {
    final isar = await db;
    final shops = await isar.shops.where().exportJson();
    final users = await isar.users.where().exportJson();
    final products = await isar.products.where().exportJson();
    final orders = await isar.orders.where().exportJson();

    final backupData = {
      "version": 1,
      "timestamp": DateTime.now().toIso8601String(),
      "shops": shops,
      "users": users,
      "products": products,
      "orders": orders,
    };

    final directory = await getTemporaryDirectory();
    final fileName = 'pos_backup_${DateTime.now().millisecondsSinceEpoch}.json';
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(jsonEncode(backupData));
    return file;
  }

  Future<void> restoreBackup(File backupFile) async {
    final isar = await db;
    try {
      final jsonString = await backupFile.readAsString();
      final Map<String, dynamic> data = jsonDecode(jsonString);

      await isar.writeTxn(() async {
        if (data['shops'] != null)
          await isar.shops
              .importJson(List<Map<String, dynamic>>.from(data['shops']));
        if (data['users'] != null)
          await isar.users
              .importJson(List<Map<String, dynamic>>.from(data['users']));
        if (data['products'] != null)
          await isar.products
              .importJson(List<Map<String, dynamic>>.from(data['products']));
        if (data['orders'] != null)
          await isar.orders
              .importJson(List<Map<String, dynamic>>.from(data['orders']));
      });
    } catch (e) {
      print("Restore Error: $e");
      throw "Invalid Backup File";
    }
  }

  // -------------------------
  // REAL-TIME STREAMS
  // -------------------------

  // FIXED: Using async* and yield* to handle the Future<Isar>
  Stream<List<Product>> streamAllProducts() async* {
    final isar = await db;

    // Logic: If Super Admin, stream all. If Shop Admin, stream only shop items.
    if (currentShopId == null) {
      yield* isar.products.where().watch(fireImmediately: true);
    } else {
      yield* isar.products
          .filter()
          .shopIdEqualTo(currentShopId)
          .watch(fireImmediately: true);
    }
  }
}
