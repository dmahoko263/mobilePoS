# pos_tablet_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
urgent promotes
in the inventory and quantity and cost price so that the admin can see profits and losese also on the end of day prepare a printable balance sheet which can be printed to pdf
allow admin login
with admin dashboard and all settings
let admin create cashier accounts and assistant admin accounts
if cashier logs in they will be directed to pos terminal
the super-admin sees all the activities by all the usres
allow barcode scan and manual entry search by barcode or by name in terminal
after 30 days or monthend auto prepare a balance sheet
allow to work for windows and if no printer print to pdf

2. Windows Configuration
   Unlike Android, Windows does not automatically register custom links during development. You must manually add a Registry Key to tell Windows that mdtechpos:// belongs to your app.

Step A: Locate your Debug Executable

Run your app once on Windows (F5 or flutter run -d windows).

Go to your project folder: build\windows\x64\runner\Debug\.

Find pos_tablet_app.exe.

Copy the full path (e.g., C:\Users\You\Projects\pos_tablet_app\build\windows\x64\runner\Debug\pos_tablet_app.exe).

Step B: Create a Registry Script

Create a new text file on your desktop named register_pos.reg.

Paste the code below into it.

Crucial: Replace PATH_TO_YOUR_EXE with the double-slashed path you copied (e.g., C:\\Users\\You\\...\\pos_tablet_app.exe).

Code snippet

Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\Software\Classes\mdtechpos]
"URL Protocol"=""
@="URL:MDTechPOS Protocol"

[HKEY_CURRENT_USER\Software\Classes\mdtechpos\shell]

[HKEY_CURRENT_USER\Software\Classes\mdtechpos\shell\open]

[HKEY_CURRENT_USER\Software\Classes\mdtechpos\shell\open\command]
@="\"PATH_TO_YOUR_EXE\" \"%1\""
Step C: Run the Script

Double-click register_pos.reg.

Click Yes to add it to the registry.

Note for Production: When you eventually build the final installer (using Inno Setup or MSIX), you will configure the installer to add these registry keys automatically on the user's computer. The manual step above is only for your development machine.

3. How to Test
   Android: Run the app. Open Chrome on the device/emulator and type mdtechpos://payment-return. It should instantly switch to your app.

Windows: Run the app. Open Edge/Chrome and type mdtechpos://payment-return. A popup will ask "Open Tablet POS?". Click Open.

Your payment flow will now automatically return to the app when completed!
Example
{
"amountDetails": {
"amount": 10,
"currencyCode": "ZWL"
},
"reasonForPayment": "Online payment for Camera",
"resultUrl": "https://my.resulturl.com",
"returnUrl": "https://my.return.url.com"
}
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:printer/printer.dart';

void main() {
runApp(const MyApp());
}

class MyApp extends StatefulWidget {
const MyApp({Key? key}) : super(key: key);

@override
State<MyApp> createState() => \_MyAppState();
}

class \_MyAppState extends State<MyApp> {
String \_platformVersion = 'Unknown';
String \_printResult = 'Unknown';

@override
void initState() {
super.initState();
initPlatformState();
}

// Platform messages are asynchronous, so we initialize in an async method.
Future<void> initPlatformState() async {
String platformVersion;
// Platform messages may fail, so we use a try/catch PlatformException.
// We also handle the message potentially returning null.
try {
platformVersion =
await Printer.platformVersion ?? 'Unknown platform version';
String content = " _NEPAL TOURISM_ \n" +
"Date : 04/05/2022 \n" +
"Date : 04/05/2022\n" +
"Time : 05:32 PM\n" +
"Bus No: UP-14AZ1512\n" +
" Delhi to Ghazibad \n" +
"Adult (2 X 100) = 200.00\n" +
"Child (1 X 50) = 50.00\n" +
" Total 250.00 \n" +
" _SHUB YATRA_ ";

      _printResult = await Printer.printContent(content: content) ?? 'Unknown platform version';
      //_printResult = await Printer.printImage(imageBitmap) ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });

}

@override
Widget build(BuildContext context) {
return MaterialApp(
home: Scaffold(
appBar: AppBar(
title: const Text('Plugin example app'),
),
body: Center(
child: Text('Running on: $\_platformVersion\nPrint Result: $\_printResult'),
),
),
);
}
}
import 'package:blue_thermal_printer_example/testprint.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/services.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
@override
\_MyAppState createState() => new \_MyAppState();
}

class \_MyAppState extends State<MyApp> {
BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

List<BluetoothDevice> \_devices = [];
BluetoothDevice? \_device;
bool \_connected = false;
TestPrint testPrint = TestPrint();

@override
void initState() {
super.initState();
initPlatformState();
}

Future<void> initPlatformState() async {
bool? isConnected = await bluetooth.isConnected;
List<BluetoothDevice> devices = [];
try {
devices = await bluetooth.getBondedDevices();
} on PlatformException {}

    bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          setState(() {
            _connected = true;
            print("bluetooth device state: connected");
          });
          break;
        case BlueThermalPrinter.DISCONNECTED:
          setState(() {
            _connected = false;
            print("bluetooth device state: disconnected");
          });
          break;
        case BlueThermalPrinter.DISCONNECT_REQUESTED:
          setState(() {
            _connected = false;
            print("bluetooth device state: disconnect requested");
          });
          break;
        case BlueThermalPrinter.STATE_TURNING_OFF:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth turning off");
          });
          break;
        case BlueThermalPrinter.STATE_OFF:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth off");
          });
          break;
        case BlueThermalPrinter.STATE_ON:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth on");
          });
          break;
        case BlueThermalPrinter.STATE_TURNING_ON:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth turning on");
          });
          break;
        case BlueThermalPrinter.ERROR:
          setState(() {
            _connected = false;
            print("bluetooth device state: error");
          });
          break;
        default:
          print(state);
          break;
      }
    });

    if (!mounted) return;
    setState(() {
      _devices = devices;
    });

    if (isConnected == true) {
      setState(() {
        _connected = true;
      });
    }

}

@override
Widget build(BuildContext context) {
return MaterialApp(
home: Scaffold(
appBar: AppBar(
title: Text('Blue Thermal Printer'),
),
body: Container(
child: Padding(
padding: const EdgeInsets.all(8.0),
child: ListView(
children: <Widget>[
Row(
crossAxisAlignment: CrossAxisAlignment.center,
mainAxisAlignment: MainAxisAlignment.start,
children: <Widget>[
SizedBox(
width: 10,
),
Text(
'Device:',
style: TextStyle(
fontWeight: FontWeight.bold,
),
),
SizedBox(
width: 30,
),
Expanded(
child: DropdownButton(
items: _getDeviceItems(),
onChanged: (BluetoothDevice? value) =>
setState(() => _device = value),
value: _device,
),
),
],
),
SizedBox(
height: 10,
),
Row(
crossAxisAlignment: CrossAxisAlignment.center,
mainAxisAlignment: MainAxisAlignment.end,
children: <Widget>[
ElevatedButton(
style: ElevatedButton.styleFrom(primary: Colors.brown),
onPressed: () {
initPlatformState();
},
child: Text(
'Refresh',
style: TextStyle(color: Colors.white),
),
),
SizedBox(
width: 20,
),
ElevatedButton(
style: ElevatedButton.styleFrom(
primary: _connected ? Colors.red : Colors.green),
onPressed: _connected ? _disconnect : _connect,
child: Text(
_connected ? 'Disconnect' : 'Connect',
style: TextStyle(color: Colors.white),
),
),
],
),
Padding(
padding:
const EdgeInsets.only(left: 10.0, right: 10.0, top: 50),
child: ElevatedButton(
style: ElevatedButton.styleFrom(primary: Colors.brown),
onPressed: () {
testPrint.sample();
},
child: Text('PRINT TEST',
style: TextStyle(color: Colors.white)),
),
),
],
),
),
),
),
);
}

List<DropdownMenuItem<BluetoothDevice>> \_getDeviceItems() {
List<DropdownMenuItem<BluetoothDevice>> items = [];
if (\_devices.isEmpty) {
items.add(DropdownMenuItem(
child: Text('NONE'),
));
} else {
\_devices.forEach((device) {
items.add(DropdownMenuItem(
child: Text(device.name ?? ""),
value: device,
));
});
}
return items;
}

void \_connect() {
if (\_device != null) {
bluetooth.isConnected.then((isConnected) {
if (isConnected == true) {
bluetooth.connect(\_device!).catchError((error) {
setState(() => \_connected = false);
});
setState(() => \_connected = true);
}
});
} else {
show('No device selected.');
}
}

void \_disconnect() {
bluetooth.disconnect();
setState(() => \_connected = false);
}

Future show(
String message, {
Duration duration: const Duration(seconds: 3),
}) async {
await new Future.delayed(new Duration(milliseconds: 100));
ScaffoldMessenger.of(context).showSnackBar(
new SnackBar(
content: new Text(
message,
style: new TextStyle(
color: Colors.white,
),
),
duration: duration,
),
);
}
}// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';

void main() {
runApp(const MyApp());
}

class MyApp extends StatefulWidget {
const MyApp({super.key});

@override
State<MyApp> createState() => \_MyAppState();
}

class \_MyAppState extends State<MyApp> {
final \_flutterThermalPrinterPlugin = FlutterThermalPrinter.instance;

String \_ip = '192.168.0.100';
String \_port = '9100';

List<Printer> printers = [];

StreamSubscription<List<Printer>>? \_devicesStreamSubscription;

// Get Printer List
void startScan() async {
\_devicesStreamSubscription?.cancel();
await \_flutterThermalPrinterPlugin.getPrinters(connectionTypes: [
ConnectionType.USB,
ConnectionType.BLE,
]);
\_devicesStreamSubscription = \_flutterThermalPrinterPlugin.devicesStream
.listen((List<Printer> event) {
setState(() {
printers = event;
printers.removeWhere((element) =>
element.name == null ||
element.name == '' ||
element.name!.toLowerCase().contains("print") == false);
});
});
}

@override
void initState() {
super.initState();
WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
startScan();
});
}

stopScan() {
\_flutterThermalPrinterPlugin.stopScan();
}

@override
Widget build(BuildContext context) {
return MaterialApp(
home: Scaffold(
appBar: AppBar(
title: const Text('Plugin example app'),
systemOverlayStyle: const SystemUiOverlayStyle(
statusBarColor: Colors.transparent,
),
),
body: Padding(
padding: const EdgeInsets.all(20),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Text(
'NETWORK',
style: Theme.of(context).textTheme.titleLarge,
),
const SizedBox(height: 12),
TextFormField(
initialValue: \_ip,
decoration: const InputDecoration(
labelText: 'Enter IP Address',
),
onChanged: (value) {
\_ip = value;
},
),
const SizedBox(height: 12),
TextFormField(
initialValue: \_port,
decoration: const InputDecoration(
labelText: 'Enter Port',
),
onChanged: (value) {
\_port = value;
},
),
const SizedBox(height: 12),
Row(
mainAxisAlignment: MainAxisAlignment.spaceEvenly,
children: [
Expanded(
child: ElevatedButton(
onPressed: () async {
final service = FlutterThermalPrinterNetwork(
\_ip,
port: int.parse(\_port),
);
await service.connect();
final profile = await CapabilityProfile.load();
final generator = Generator(PaperSize.mm80, profile);
List<int> bytes = [];
if (context.mounted) {
bytes = await FlutterThermalPrinter.instance
.screenShotWidget(
context,
generator: generator,
widget: receiptWidget("Network"),
);
bytes += generator.cut();
await service.printTicket(bytes);
}
await service.disconnect();
},
child: const Text('Test network printer'),
),
),
const SizedBox(width: 22),
Expanded(
child: ElevatedButton(
onPressed: () async {
final service = FlutterThermalPrinterNetwork(\_ip,
port: int.parse(\_port));
await service.connect();
final bytes = await \_generateReceipt();
await service.printTicket(bytes);
await service.disconnect();
},
child: const Text('Test network printer widget'),
),
),
],
),
const SizedBox(height: 12),
const Divider(),
const SizedBox(height: 22),
Text(
'USB/BLE',
style: Theme.of(context).textTheme.titleLarge,
),
const SizedBox(height: 22),
Row(
children: [
Expanded(
child: ElevatedButton(
onPressed: () {
// startScan();
startScan();
},
child: const Text('Get Printers'),
),
),
const SizedBox(width: 22),
Expanded(
child: ElevatedButton(
onPressed: () {
// startScan();
stopScan();
},
child: const Text('Stop Scan'),
),
),
],
),
const SizedBox(height: 12),
Expanded(
child: ListView.builder(
itemCount: printers.length,
itemBuilder: (context, index) {
return ListTile(
onTap: () async {
if (printers[index].isConnected ?? false) {
await \_flutterThermalPrinterPlugin
.disconnect(printers[index]);
} else {
await \_flutterThermalPrinterPlugin
.connect(printers[index]);
}
},
title: Text(printers[index].name ?? 'No Name'),
subtitle:
Text("Connected: ${printers[index].isConnected}"),
trailing: IconButton(
icon: const Icon(Icons.connect_without_contact),
onPressed: () async {
// final data = await \_generateReceipt(
// type: printers[index].connectionTypeString,
// );
// await \_flutterThermalPrinterPlugin.printData(
// printers[index],
// data,
// longData: true,
// );

                          await _flutterThermalPrinterPlugin.printWidget(
                            context,
                            printOnBle: true,
                            cutAfterPrinted: true,
                            printer: printers[index],
                            widget: receiptWidget(
                              printers[index].connectionTypeString,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );

}

Future<List<int>> \_generateReceipt({String? type}) async {
final profile = await CapabilityProfile.load();
final generator = Generator(PaperSize.mm80, profile);
List<int> bytes = [];
bytes += generator.text(
'FLUTTER THERMAL PRINTER',
styles: const PosStyles(
align: PosAlign.center,
bold: true,
height: PosTextSize.size2,
width: PosTextSize.size2,
),
);
bytes += generator.hr();
bytes += generator.row([
PosColumn(
text: 'Item',
width: 6,
styles: const PosStyles(bold: true),
),
PosColumn(
text: 'Price',
width: 6,
styles: const PosStyles(align: PosAlign.right, bold: true),
),
]);
bytes += generator.hr();
bytes += generator.row([
PosColumn(text: 'Apple', width: 6),
PosColumn(
text: '\$1.00',
width: 6,
styles: const PosStyles(align: PosAlign.right)),
]);
bytes += generator.row([
PosColumn(text: 'Banana', width: 6),
PosColumn(
text: '\$0.50',
width: 6,
styles: const PosStyles(align: PosAlign.right)),
]);
bytes += generator.row([
PosColumn(text: 'Orange', width: 6),
PosColumn(
text: '\$0.75',
width: 6,
styles: const PosStyles(align: PosAlign.right)),
]);
bytes += generator.hr();
bytes += generator.row([
PosColumn(
text: 'Total',
width: 6,
styles: const PosStyles(bold: true),
),
PosColumn(
text: '\$2.25',
width: 6,
styles: const PosStyles(align: PosAlign.right, bold: true),
),
]);
bytes += generator.feed(1);
bytes += generator.text(
'Printer Type: ${type ?? "Unknown"}',
styles: const PosStyles(align: PosAlign.left),
);
bytes += generator.feed(2);
bytes += generator.text(
'Thank you for your purchase!',
styles: const PosStyles(
align: PosAlign.center,
),
);

    bytes += generator.cut();
    return bytes;

}

Widget receiptWidget(String printerType) {
log("Date1: ${DateTime.now()}");
final widget = SizedBox(
width: 550,
child: Material(
child: Padding(
padding: const EdgeInsets.all(16.0),
child: Column(
mainAxisSize: MainAxisSize.min,
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Center(
child: Text(
'FLUTTER THERMAL PRINTER',
style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
),
),
const Divider(thickness: 2),
const SizedBox(height: 10),
_buildReceiptRow('Item', 'Price'),
const Divider(),
_buildReceiptRow('Apple', '\$1.00'),
_buildReceiptRow('Banana', '\$0.50'),
_buildReceiptRow('Orange', '\$0.75'),
const Divider(thickness: 2),
_buildReceiptRow('Total', '\$2.25', isBold: true),
const SizedBox(height: 20),
_buildReceiptRow('Printer Type', printerType),
const SizedBox(height: 50),
const Center(
child: Text(
'Thank you for your purchase!',
style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
),
),
],
),
),
),
);

    log("Date1: ${DateTime.now()}");
    return widget;

}
}

Widget \_buildReceiptRow(String leftText, String rightText,
{bool isBold = false}) {
return Padding(
padding: const EdgeInsets.symmetric(vertical: 4.0),
child: Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Text(
leftText,
style: TextStyle(
fontSize: 16,
fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
),
Text(
rightText,
style: TextStyle(
fontSize: 16,
fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
),
],
),
);
}
