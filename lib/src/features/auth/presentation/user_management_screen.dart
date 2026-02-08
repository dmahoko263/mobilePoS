import 'package:flutter/material.dart';
import 'package:pos_tablet_app/src/core/services/isar_service.dart';
import 'package:pos_tablet_app/src/features/auth/models/user.dart';
import 'package:pos_tablet_app/src/features/auth/models/shop.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final _isarService = IsarService();
  List<Shop> _availableShops = [];

  @override
  void initState() {
    super.initState();
    _loadShops();
  }

  void _loadShops() async {
    final shops = await _isarService.getAllShops();
    setState(() {
      _availableShops = shops;
    });
  }

  void _refresh() {
    setState(() {});
  }

  // --- ADD / EDIT USER DIALOG ---
  void _showUserDialog({User? userToEdit}) {
    final usernameController =
        TextEditingController(text: userToEdit?.username ?? '');
    final passwordController =
        TextEditingController(text: userToEdit?.password ?? '');

    UserRole selectedRole = userToEdit?.role ?? UserRole.cashier;
    int? selectedShopId = userToEdit?.shopId; // Default to existing or null

    // If creating new and only 1 shop exists, auto-select it
    if (userToEdit == null && _availableShops.length == 1) {
      selectedShopId = _availableShops.first.id;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(userToEdit == null ? 'Create New User' : 'Edit User'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: usernameController,
                      decoration: const InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),

                    // ROLE DROPDOWN
                    DropdownButtonFormField<UserRole>(
                      value: selectedRole,
                      decoration: const InputDecoration(
                          labelText: 'Role', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(
                            value: UserRole.cashier,
                            child: Text('Cashier (POS Only)')),
                        DropdownMenuItem(
                            value: UserRole.assistant,
                            child: Text('Assistant')),
                        DropdownMenuItem(
                            value: UserRole.admin, child: Text('Admin')),
                        DropdownMenuItem(
                            value: UserRole.superAdmin,
                            child: Text('Super Admin')),
                      ],
                      onChanged: (val) {
                        setDialogState(() {
                          selectedRole = val!;
                          // Super Admins don't belong to a specific shop usually
                          if (selectedRole == UserRole.superAdmin) {
                            selectedShopId = null;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // SHOP DROPDOWN (Hide if Super Admin)
                    if (selectedRole != UserRole.superAdmin)
                      DropdownButtonFormField<int>(
                        value: selectedShopId,
                        decoration: const InputDecoration(
                            labelText: 'Assign to Shop',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.store)),
                        hint: const Text('Select a Shop'),
                        items: _availableShops.map((shop) {
                          return DropdownMenuItem<int>(
                            value: shop.id,
                            child: Text(shop.name),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setDialogState(() => selectedShopId = val),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    if (usernameController.text.isNotEmpty &&
                        passwordController.text.isNotEmpty) {
                      if (selectedRole != UserRole.superAdmin &&
                          selectedShopId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Please select a shop for this user')));
                        return;
                      }

                      // We reuse 'createUser' for both create and update because Isar 'put' handles both based on ID logic.
                      // Ideally we'd have an 'updateUser' method, but we can delete/re-create or update fields.
                      // For simplicity here, we delete old and create new to ensure ID consistency or just use a custom update logic.
                      // BETTER WAY:
                      if (userToEdit != null) {
                        // Update existing
                        await _isarService
                            .deleteUser(userToEdit.id); // Remove old
                      }

                      await _isarService.createUser(
                          usernameController.text,
                          passwordController.text,
                          selectedRole,
                          selectedShopId);

                      Navigator.pop(context);
                      _refresh();

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(userToEdit == null
                                ? 'User Created'
                                : 'User Updated')));
                      }
                    }
                  },
                  child: Text(userToEdit == null ? 'Create' : 'Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteUser(User user) async {
    if (user.role == UserRole.superAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot delete Super Admin')));
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove User?'),
        content: Text('Remove "${user.username}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Remove', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await _isarService.deleteUser(user.id);
      _refresh();
    }
  }

  // Helper to find shop name by ID
  String _getShopName(int? shopId) {
    if (shopId == null) return 'Global / None';
    final shop = _availableShops.where((s) => s.id == shopId).firstOrNull;
    return shop?.name ?? 'Unknown Shop';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Staff Management')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUserDialog(),
        label: const Text('Add Staff'),
        icon: const Icon(Icons.person_add),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<User>>(
        future: _isarService.getAllUsers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final users = snapshot.data!;
          if (users.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: Card(
                elevation: 2,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(Colors.blue.shade50),
                  columns: const [
                    DataColumn(
                        label: Text('Username',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Role',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Assigned Shop',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Actions',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: users.map((user) {
                    return DataRow(cells: [
                      DataCell(Text(user.username,
                          style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text(user.role.name.toUpperCase())),
                      DataCell(Text(_getShopName(user.shopId),
                          style: TextStyle(
                              color: user.shopId == null
                                  ? Colors.grey
                                  : Colors.black))),
                      DataCell(Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showUserDialog(userToEdit: user),
                          ),
                          if (user.role != UserRole.superAdmin)
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteUser(user),
                            ),
                        ],
                      )),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
