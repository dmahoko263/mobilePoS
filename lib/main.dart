import 'package:flutter/material.dart';
import 'package:pos_tablet_app/src/features/auth/models/user.dart';
import 'package:pos_tablet_app/src/features/auth/presentation/login_screen.dart';
import 'package:pos_tablet_app/src/features/auth/presentation/user_management_screen.dart';
import 'package:pos_tablet_app/src/features/auth/presentation/shop_management_screen.dart';
import 'package:pos_tablet_app/src/features/products/presentation/inventory_list_screen.dart';
import 'package:pos_tablet_app/src/features/sales/presentation/dashboard_screen.dart';
import 'package:pos_tablet_app/src/features/sales/presentation/pos_screen.dart';
import 'package:pos_tablet_app/src/features/sales/presentation/sales_history_screen.dart';
import 'package:pos_tablet_app/src/features/settings/presentation/settings_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tablet POS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  final User currentUser;

  const MainNavigationShell({super.key, required this.currentUser});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [];
  final List<NavigationRailDestination> _destinations = [];

  @override
  void initState() {
    super.initState();
    _setupMenu();
  }

  void _setupMenu() {
    final role = widget.currentUser.role;

    // 1. TERMINAL (Everyone sees this)
    _screens.add(PosScreen(cashierName: widget.currentUser.username));
    _destinations.add(const NavigationRailDestination(
      icon: Icon(Icons.point_of_sale),
      label: Text('Terminal'),
    ));

    // 2. MANAGEMENT SCREENS
    if (role == UserRole.admin ||
        role == UserRole.superAdmin ||
        role == UserRole.assistant) {
      _screens.add(const SalesHistoryScreen());
      _destinations.add(const NavigationRailDestination(
        icon: Icon(Icons.receipt),
        label: Text('History'),
      ));

      _screens.add(const InventoryDashboardScreen());
      _destinations.add(const NavigationRailDestination(
        icon: Icon(Icons.inventory_2),
        label: Text('Inventory'),
      ));

      _screens.add(const DashboardScreen());
      _destinations.add(const NavigationRailDestination(
        icon: Icon(Icons.dashboard),
        label: Text('Dashboard'),
      ));
    }

    // 3. SENSITIVE SCREENS
    if (role == UserRole.admin || role == UserRole.superAdmin) {
      _screens.add(const UserManagementScreen());
      _destinations.add(const NavigationRailDestination(
        icon: Icon(Icons.people),
        label: Text('Users'),
      ));

      _screens.add(const SettingsScreen());
      _destinations.add(const NavigationRailDestination(
        icon: Icon(Icons.settings),
        label: Text('Settings'),
      ));
    }

    // 4. SHOPS (Super Admin Only)
    if (role == UserRole.superAdmin) {
      _screens.add(const ShopManagementScreen());
      _destinations.add(const NavigationRailDestination(
        icon: Icon(Icons.store),
        label: Text('Shops'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            extended: true,
            minExtendedWidth: 200,
            leading: Column(
              children: [
                const Icon(Icons.account_circle, size: 40, color: Colors.blue),
                const SizedBox(height: 8),
                Text(widget.currentUser.username.toUpperCase(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12)),
                Text(widget.currentUser.role.name,
                    style: const TextStyle(fontSize: 10, color: Colors.grey)),
                const SizedBox(height: 20),
              ],
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: TextButton.icon(
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text('Logout',
                        style: TextStyle(color: Colors.red)),
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()));
                    },
                  ),
                ),
              ),
            ),
            destinations: _destinations,
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
    );
  }
}
