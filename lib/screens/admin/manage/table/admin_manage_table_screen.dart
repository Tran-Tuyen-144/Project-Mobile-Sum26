import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../theme/app_colors.dart';

class AdminManageTableScreen extends StatefulWidget {
  const AdminManageTableScreen({super.key});

  @override
  State<AdminManageTableScreen> createState() => _AdminManageTableScreenState();
}

class _AdminManageTableScreenState extends State<AdminManageTableScreen> {
  final CollectionReference _tablesCollection = FirebaseFirestore.instance.collection('tables');

  final List<Map<String, dynamic>> _mockTables = [
    {"id": "T1", "name": "Bàn A1", "seats": 2, "isFirebase": false},
    {"id": "T2", "name": "Bàn A2", "seats": 2, "isFirebase": false},
    {"id": "T3", "name": "Bàn B1", "seats": 4, "isFirebase": false},
    {"id": "T4", "name": "Bàn B2", "seats": 4, "isFirebase": false},
    {"id": "T5", "name": "Bàn C1", "seats": 6, "isFirebase": false},
    {"id": "T6", "name": "Bàn C2", "seats": 6, "isFirebase": false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Quản lý bàn')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _tablesCollection.snapshots(),
        builder: (context, snapshot) {
          List<Map<String, dynamic>> combined = [];

          if (snapshot.hasData) {
            combined.addAll(snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id;
              data['isFirebase'] = true;
              return data;
            }).toList());
          }
          combined.addAll(_mockTables);

          return ListView.builder(
            itemCount: combined.length,
            itemBuilder: (context, index) {
              final table = combined[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(table['name']),
                  subtitle: Text("Số chỗ: ${table['seats']}"),
                  leading: Icon(table['isFirebase'] == true ? Icons.edit : Icons.lock),
                  trailing: table['isFirebase'] == true
                      ? IconButton(icon: const Icon(Icons.delete), onPressed: () => _tablesCollection.doc(table['id']).delete())
                      : null,
                  onTap: table['isFirebase'] == true ? () => _showTableForm(table: table) : null,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTableForm(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showTableForm({Map<String, dynamic>? table}) {
    final nameCtrl = TextEditingController(text: table?['name'] ?? '');
    final seatsCtrl = TextEditingController(text: table?['seats']?.toString() ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Tên bàn')),
            TextField(controller: seatsCtrl, decoration: const InputDecoration(labelText: 'Số chỗ')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final data = {'name': nameCtrl.text, 'seats': int.tryParse(seatsCtrl.text) ?? 0};
                if (table != null && table['isFirebase'] == true) {
                  await _tablesCollection.doc(table['id']).update(data);
                } else {
                  await _tablesCollection.add(data);
                }
                if (mounted) Navigator.pop(context);
              },
              child: const Text('LƯU DỮ LIỆU'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}