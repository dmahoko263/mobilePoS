import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _zigRateKey = 'zig_rate';
  static const String _taxRateKey = 'tax_rate';
  static const String _shopLogoKey = 'shop_logo_path';
  static const String _printerAddressKey = 'printer_address';
  // Get ZiG Rate (Default to 13.5 if not set)
  Future<double> getZigRate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_zigRateKey) ?? 13.5;
  }

  // Save ZiG Rate
  Future<void> setZigRate(double rate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_zigRateKey, rate);
  }

  // Get Tax % (Default to 0%)
  Future<double> getTaxRate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_taxRateKey) ?? 0.0;
  }

  // Save Tax %
  Future<void> setTaxRate(double rate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_taxRateKey, rate);
  }

  // SHOP DETAILS
  Future<void> saveShopDetails(
      String name, String address, String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('shop_name', name);
    await prefs.setString('shop_address', address);
    await prefs.setString('shop_phone', phone);
  }

  Future<Map<String, String>> getShopDetails() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('shop_name') ?? 'My Shop',
      'address': prefs.getString('shop_address') ?? 'Harare, Zimbabwe',
      'phone': prefs.getString('shop_phone') ?? '+263 77 000 0000',
    };
  }

  // Save Logo Path
  Future<void> saveShopLogo(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_shopLogoKey, path);
  }

  // Get Logo Path
  Future<String?> getShopLogo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_shopLogoKey);
  }

  Future<void> savePrinterAddress(String address) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_printerAddressKey, address);
  }

//printer settings
  Future<String?> getPrinterAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_printerAddressKey);
  }
}
