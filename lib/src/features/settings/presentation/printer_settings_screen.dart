import 'dart:io';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:pos_tablet_app/src/core/services/settings_service.dart';

class PrinterSettingsScreen extends StatefulWidget {
  const PrinterSettingsScreen({super.key});

  @override
  State<PrinterSettingsScreen> createState() => _PrinterSettingsScreenState();
}

class _PrinterSettingsScreenState extends State<PrinterSettingsScreen> {
  final BlueThermalPrinter _bluetooth = BlueThermalPrinter.instance;
  final SettingsService _settingsService = SettingsService();

  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _selectedDevice;
  bool _isConnected = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      _initPrinter();
    }
  }

  void _initPrinter() async {
    setState(() => _isLoading = true);

    // 1. Get List of Paired Devices
    List<BluetoothDevice> devices = [];
    try {
      devices = await _bluetooth.getBondedDevices();
    } catch (e) {
      print("Error getting devices: $e");
    }

    // 2. Get Saved Printer Address
    final savedAddress = await _settingsService.getPrinterAddress();

    // 3. Find Saved Device in List
    BluetoothDevice? savedDevice;
    if (savedAddress != null && devices.isNotEmpty) {
      try {
        savedDevice = devices.firstWhere((d) => d.address == savedAddress);
      } catch (e) {
        // Saved device not found in paired list
      }
    }

    // 4. Check Connection Status (if saved device exists)
    bool connected = false;
    if (savedDevice != null) {
      connected = (await _bluetooth.isConnected) ?? false;
    }

    setState(() {
      _devices = devices;
      _selectedDevice = savedDevice;
      _isConnected = connected;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    // If we are on Android, disconnect to free up the printer for the POS screen
    if (Platform.isAndroid && _isConnected) {
      _bluetooth.disconnect();
    }
    super.dispose();
  }

  void _connectToDevice(BluetoothDevice device) async {
    setState(() => _isLoading = true);

    // If already connected to something else, disconnect first
    if (_isConnected) {
      await _bluetooth.disconnect();
    }

    try {
      // Connect
      await _bluetooth.connect(device);

      // Save Preference
      if (device.address != null) {
        await _settingsService.savePrinterAddress(device.address!);
      }

      setState(() {
        _selectedDevice = device;
        _isConnected = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Connected to ${device.name}"),
            backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Connection Failed: $e"),
            backgroundColor: Colors.red));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _disconnect() async {
    await _bluetooth.disconnect();
    setState(() => _isConnected = false);
  }

  void _testPrint() async {
    if ((await _bluetooth.isConnected) == true) {
      _bluetooth.printNewLine();
      _bluetooth.printCustom("TEST PRINT SUCCESS", 1, 1);
      _bluetooth.printNewLine();
      _bluetooth.printNewLine();
      _bluetooth.paperCut();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!Platform.isAndroid) {
      return Scaffold(
        appBar: AppBar(title: const Text('Printer Setup')),
        body: const Center(
          child: Text(
              'Bluetooth Printing is only available on Android.\nWindows uses system print dialogs.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Printer Configuration'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initPrinter,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // STATUS HEADER
                Container(
                  padding: const EdgeInsets.all(16),
                  color: _isConnected
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  child: Row(
                    children: [
                      Icon(
                        _isConnected ? Icons.check_circle : Icons.warning,
                        color: _isConnected ? Colors.green : Colors.orange,
                        size: 30,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isConnected
                                ? "Printer Connected"
                                : "No Printer Connected",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          if (_selectedDevice != null)
                            Text("Active Device: ${_selectedDevice?.name}",
                                style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                      const Spacer(),
                      if (_isConnected)
                        TextButton.icon(
                            onPressed: _testPrint,
                            icon: const Icon(Icons.print),
                            label: const Text("Test"))
                    ],
                  ),
                ),

                const Divider(height: 1),

                // DEVICES LIST
                Expanded(
                  child: ListView.separated(
                    itemCount: _devices.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final device = _devices[index];
                      final isSelected =
                          _selectedDevice?.address == device.address;

                      return ListTile(
                        leading: const Icon(Icons.print),
                        title: Text(device.name ?? "Unknown Device"),
                        subtitle: Text(device.address ?? ""),
                        trailing: isSelected && _isConnected
                            ? ElevatedButton(
                                onPressed: _disconnect,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white),
                                child: const Text("Disconnect"),
                              )
                            : ElevatedButton(
                                onPressed: () => _connectToDevice(device),
                                child: const Text("Connect"),
                              ),
                      );
                    },
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Note: Ensure your Bluetooth printer is paired in Android Settings first.",
                    style: TextStyle(
                        color: Colors.grey, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
    );
  }
}
