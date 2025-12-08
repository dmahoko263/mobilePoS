import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:pos_tablet_app/src/core/services/settings_service.dart';
import 'package:pos_tablet_app/src/core/services/isar_service.dart'; // Needed for Backup
import 'package:share_plus/share_plus.dart'; // Needed for Backup
import 'package:file_picker/file_picker.dart'; // Needed for Restore
import 'package:pos_tablet_app/src/features/settings/presentation/printer_settings_screen.dart'; // Import Printer Settings

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _settingsService = SettingsService();
  final _isarService = IsarService(); // Direct access for backup

  final _zigController = TextEditingController();
  final _taxController = TextEditingController();
  final _shopNameController = TextEditingController();
  final _shopAddressController = TextEditingController();
  final _shopPhoneController = TextEditingController();

  String? _logoPath;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    final zig = await _settingsService.getZigRate();
    final tax = await _settingsService.getTaxRate();
    final shopDetails = await _settingsService.getShopDetails();
    final logo = await _settingsService.getShopLogo();

    setState(() {
      _zigController.text = zig.toString();
      _taxController.text = tax.toString();
      _shopNameController.text = shopDetails['name'] ?? '';
      _shopAddressController.text = shopDetails['address'] ?? '';
      _shopPhoneController.text = shopDetails['phone'] ?? '';
      _logoPath = logo;
    });
  }

  // --- LOGO LOGIC ---
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final String fileName = path.basename(image.path);
      final String newPath = '${appDir.path}/$fileName';
      await File(image.path).copy(newPath);

      setState(() {
        _logoPath = newPath;
      });
    }
  }

  // --- BACKUP LOGIC ---
  void _handleBackup() async {
    try {
      final file = await _isarService.createBackup();
      await Share.shareXFiles([XFile(file.path)],
          text: 'POS Backup ${DateTime.now()}');
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Backup Failed: $e')));
    }
  }

  // --- RESTORE LOGIC ---
  void _handleRestore() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);

        final confirm = await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('Restore Database?'),
            content: const Text(
                'WARNING: This will delete all current data and replace it with the backup.\n\nAre you sure?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(c, false),
                  child: const Text('Cancel')),
              ElevatedButton(
                  onPressed: () => Navigator.pop(c, true),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white),
                  child: const Text('RESTORE')),
            ],
          ),
        );

        if (confirm == true) {
          await _isarService.restoreBackup(file);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Restore Successful! Please Restart App.'),
                backgroundColor: Colors.green));
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Restore Failed: $e')));
    }
  }

  void _saveSettings() async {
    final zig = double.tryParse(_zigController.text) ?? 13.5;
    final tax = double.tryParse(_taxController.text) ?? 0.0;

    await _settingsService.setZigRate(zig);
    await _settingsService.setTaxRate(tax);
    await _settingsService.saveShopDetails(
      _shopNameController.text,
      _shopAddressController.text,
      _shopPhoneController.text,
    );

    if (_logoPath != null) {
      await _settingsService.saveShopLogo(_logoPath!);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: Colors.green, content: Text('Settings Updated!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Store Configuration')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey),
                        image: _logoPath != null
                            ? DecorationImage(
                                image: FileImage(File(_logoPath!)),
                                fit: BoxFit.cover)
                            : null,
                      ),
                      child: _logoPath == null
                          ? const Icon(Icons.add_a_photo,
                              size: 40, color: Colors.grey)
                          : null,
                    ),
                    const SizedBox(height: 8),
                    const Text('Tap to set Shop Logo',
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const Divider(height: 40),

            const Text('Shop Details',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
                controller: _shopNameController,
                decoration: const InputDecoration(
                    labelText: 'Shop Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.store))),
            const SizedBox(height: 16),
            TextField(
                controller: _shopAddressController,
                decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on))),
            const SizedBox(height: 16),
            TextField(
                controller: _shopPhoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                    labelText: 'Shop Phone',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone))),

            const Divider(height: 40),

            const Text('Currency & Tax',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
                controller: _zigController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Daily ZiG Rate',
                    border: OutlineInputBorder(),
                    prefixText: 'ZiG ')),
            const SizedBox(height: 20),
            TextField(
                controller: _taxController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Sales Tax / VAT (%)',
                    border: OutlineInputBorder(),
                    suffixText: '%')),

            const Divider(height: 40),

            // --- HARDWARE SECTION ---
            const Text('Hardware',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300)),
              child: ListTile(
                leading: const Icon(Icons.print, color: Colors.blue, size: 30),
                title: const Text('Printer Configuration'),
                subtitle: const Text('Setup Bluetooth Thermal Printer'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PrinterSettingsScreen()),
                  );
                },
              ),
            ),

            const Divider(height: 40),

            // --- BACKUP & RESTORE BUTTONS ---
            const Text('Data Management',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _handleBackup,
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text('Backup Data'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _handleRestore,
                    icon: const Icon(Icons.cloud_download),
                    label: const Text('Restore Data'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _saveSettings,
                icon: const Icon(Icons.save),
                label: const Text('SAVE SETTINGS'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    foregroundColor: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
