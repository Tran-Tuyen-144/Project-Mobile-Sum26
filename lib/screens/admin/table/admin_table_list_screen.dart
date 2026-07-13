import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import 'admin_table_form_screen.dart';

class AdminTableListScreen extends StatefulWidget {
  const AdminTableListScreen({super.key});
  @override
  State<AdminTableListScreen> createState() => _AdminTableListScreenState();
}

class _AdminTableListScreenState extends State<AdminTableListScreen> {
  final List<Map<String, dynamic>> _tables = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sơ đồ Bàn")),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () async {
          final newTable = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminTableFormScreen()),
          );
          if (newTable != null) setState(() => _tables.add(newTable));
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: ListView.builder(
        itemCount: _tables.length,
        itemBuilder: (context, index) {
          final table = _tables[index];
          return ListTile(
            leading: const Icon(Icons.table_restaurant),
            title: Text(table['name']),
            subtitle: Text("${table['seats']} ghế"),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => setState(() => _tables.removeAt(index)),
            ),
          );
        },
      ),
    );
  }
}
