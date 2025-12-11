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
        // Updated to match the Teal/Green theme from screenshots
        primaryColor: const Color(0xFF009688),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF009688)),
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
  bool _isSidebarExpanded = true; // Controls open/close state

  final List<Widget> _screens = [];
  final List<_MenuItem> _menuItems = [];

  @override
  void initState() {
    super.initState();
    _setupMenu();
  }

  void _setupMenu() {
    final role = widget.currentUser.role;

    // 1. TERMINAL (Everyone sees this)
    _screens.add(PosScreen(cashierName: widget.currentUser.username));
    _menuItems.add(_MenuItem(icon: Icons.point_of_sale, label: 'Terminal'));

    // 2. MANAGEMENT SCREENS
    if (role == UserRole.admin ||
        role == UserRole.superAdmin ||
        role == UserRole.assistant) {
      _screens.add(const SalesHistoryScreen());
      _menuItems.add(_MenuItem(icon: Icons.history, label: 'History'));

      _screens.add(const InventoryDashboardScreen());
      _menuItems
          .add(_MenuItem(icon: Icons.inventory_2_outlined, label: 'Inventory'));

      _screens.add(const DashboardScreen());
      _menuItems
          .add(_MenuItem(icon: Icons.dashboard_outlined, label: 'Dashboard'));
    }

    // 3. SENSITIVE SCREENS
    if (role == UserRole.admin || role == UserRole.superAdmin) {
      _screens.add(const UserManagementScreen());
      _menuItems.add(_MenuItem(icon: Icons.people_outline, label: 'Users'));

      _screens.add(const SettingsScreen());
      _menuItems
          .add(_MenuItem(icon: Icons.settings_outlined, label: 'Settings'));
    }

    // 4. SHOPS (Super Admin Only)
    if (role == UserRole.superAdmin) {
      _screens.add(const ShopManagementScreen());
      _menuItems.add(
          _MenuItem(icon: Icons.store_mall_directory_outlined, label: 'Shops'));
    }
  }

  void _onLogout() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // ---------------------------------------------
          // LEFT SIDEBAR (Collapsible)
          // ---------------------------------------------
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: _isSidebarExpanded ? 260 : 70,
            decoration: const BoxDecoration(
              color: Color(0xFF009688), // Teal sidebar color
            ),
            child: Column(
              children: [
                // 1. HEADER (Logo + Toggle)
                Container(
                  height: 80,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      // Toggle Button
                      IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _isSidebarExpanded = !_isSidebarExpanded;
                          });
                        },
                      ),
                      // App Name (Hidden if collapsed)
                      if (_isSidebarExpanded) ...[
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            "POS System",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ]
                    ],
                  ),
                ),

                const Divider(color: Colors.white24, height: 1),

                // 2. MENU ITEMS LIST
                Expanded(
                  child: ListView.builder(
                    itemCount: _menuItems.length,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemBuilder: (context, index) {
                      final item = _menuItems[index];
                      final isSelected = _selectedIndex == index;

                      return InkWell(
                        onTap: () => setState(() => _selectedIndex = index),
                        child: Container(
                          height: 50,
                          margin: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withOpacity(0.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 16),
                              Icon(
                                item.icon,
                                color:
                                    isSelected ? Colors.white : Colors.white70,
                                size: 24,
                              ),
                              if (_isSidebarExpanded) ...[
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    item.label,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.white70,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ]
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const Divider(color: Colors.white24, height: 1),

                // 3. USER PROFILE / LOGOUT (Bottom)
                Container(
                  padding: const EdgeInsets.all(16),
                  child: _isSidebarExpanded
                      ? Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 18,
                              child: Text(
                                widget.currentUser.username[0].toUpperCase(),
                                style: const TextStyle(
                                    color: Color(0xFF009688),
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.currentUser.username,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    widget.currentUser.role.name.toUpperCase(),
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon:
                                  const Icon(Icons.logout, color: Colors.white),
                              onPressed: _onLogout,
                              tooltip: "Logout",
                            )
                          ],
                        )
                      : IconButton(
                          icon: const Icon(Icons.logout, color: Colors.white),
                          onPressed: _onLogout,
                          tooltip: "Logout",
                        ),
                ),
              ],
            ),
          ),

          // ---------------------------------------------
          // RIGHT CONTENT AREA
          // ---------------------------------------------
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }
}

// Simple Helper Class for Menu Items
class _MenuItem {
  final IconData icon;
  final String label;

  _MenuItem({required this.icon, required this.label});
}
