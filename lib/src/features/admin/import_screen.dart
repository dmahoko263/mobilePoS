import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ImportScreen extends StatelessWidget {
  final String baseUrl;
  const ImportScreen({super.key, required this.baseUrl});

  Future<void> _pickAndUpload(BuildContext context, String type) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result == null) return;

    final file = result.files.first;
    final req = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/api/admin/import/$type"),
    );

    req.files.add(
      await http.MultipartFile.fromPath("file", file.path!),
    );

    final res = await req.send();
    final body = await res.stream.bytesToString();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Import Results"),
        content: Text(body),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Excel Import")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.people),
              label: const Text("Import Users"),
              onPressed: () => _pickAndUpload(context, "users"),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.inventory),
              label: const Text("Import Products"),
              onPressed: () => _pickAndUpload(context, "products"),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.sell),
              label: const Text("Import Units"),
              onPressed: () => _pickAndUpload(context, "units"),
            ),
          ],
        ),
      ),
    );
  }
}
