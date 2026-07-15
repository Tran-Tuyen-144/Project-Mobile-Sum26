import 'package:flutter/material.dart';

import '../../../../storage/table_booking_service.dart';
import '../../../../theme/app_colors.dart';
import 'admin_table_form_screen.dart';

class AdminTableListScreen extends StatefulWidget {
  const AdminTableListScreen({super.key});

  @override
  State<AdminTableListScreen> createState() => _AdminTableListScreenState();
}

class _AdminTableListScreenState extends State<AdminTableListScreen> {
  String _branch = TableBookingService.branches.first;

  Future<void> _addTable() async {
    final data = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const AdminTableFormScreen()),
    );
    if (data == null) return;
    await TableBookingService.addTable(
      branch: _branch,
      name: data['name'] as String? ?? '',
      seats: int.tryParse('${data['seats']}') ?? 2,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sơ đồ bàn')),
    floatingActionButton: FloatingActionButton(
      backgroundColor: AppColors.primary,
      onPressed: _addTable,
      child: const Icon(Icons.add, color: Colors.white),
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: DropdownButtonFormField<String>(
            value: _branch,
            decoration: const InputDecoration(labelText: 'Chi nhánh'),
            items: TableBookingService.branches
                .map(
                  (branch) =>
                      DropdownMenuItem(value: branch, child: Text(branch)),
                )
                .toList(),
            onChanged: (value) => setState(() => _branch = value!),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<TableBookingItem>>(
            stream: TableBookingService.tableStream(_branch),
            builder: (context, snapshot) {
              final tables =
                  snapshot.data ?? TableBookingService.tablesFor(_branch);
              if (tables.isEmpty)
                return const Center(child: Text('Chưa có bàn nào.'));
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: tables.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final table = tables[index];
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        Icons.table_restaurant_rounded,
                        color: table.isBooked ? Colors.orange : Colors.green,
                      ),
                      title: Text(table.name),
                      subtitle: Text(
                        '${table.seats} ghế • ${table.isBooked ? 'Đã đặt' : 'Còn trống'}',
                      ),
                      trailing: IconButton(
                        tooltip: 'Xóa bàn',
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.red,
                        ),
                        onPressed: () => TableBookingService.deleteTable(
                          _branch,
                          table.tableId,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    ),
  );
}
