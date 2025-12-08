import 'package:flutter/material.dart';
import 'package:pos_tablet_app/src/core/services/isar_service.dart';
import 'package:pos_tablet_app/src/features/auth/models/shop.dart';

class ShopManagementScreen extends StatefulWidget {
  const ShopManagementScreen({super.key});

  @override
  State<ShopManagementScreen> createState() => _ShopManagementScreenState();
}

class _ShopManagementScreenState extends State<ShopManagementScreen> {
  final _isarService = IsarService();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController(); // NEW
  final _phoneController = TextEditingController();

  void _showAddShopDialog() {
    _nameController.clear();
    _addressController.clear();
    _cityController.clear();
    _phoneController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Shop'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                      labelText: 'Shop Name', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                      labelText: 'Address', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                      labelText: 'City', border: OutlineInputBorder())), // NEW
              const SizedBox(height: 10),
              TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                      labelText: 'Phone', border: OutlineInputBorder())),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (_nameController.text.isEmpty) return;

              final newShop = Shop()
                ..name = _nameController.text
                ..address = _addressController.text
                ..city = _cityController.text // SAVE CITY
                ..phone = _phoneController.text;

              await _isarService.createShop(newShop);

              if (mounted) {
                Navigator.pop(context);
                setState(() {}); // Refresh list
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shop Management')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddShopDialog,
        icon: const Icon(Icons.add_business),
        label: const Text('Add Shop'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Shop>>(
        future: _isarService.getAllShops(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.isEmpty) {
            return const Center(child: Text('No shops created yet.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final shop = snapshot.data![index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: const Icon(Icons.store, color: Colors.blue),
                ),
                title: Text(shop.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (shop.address != null) Text(shop.address!),
                    if (shop.city != null)
                      Text(shop.city!,
                          style: TextStyle(
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic)),
                  ],
                ),
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4)),
                  child: Text('ID: ${shop.id}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
