import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../theme/app_colors.dart';

class AdminManageTableScreen extends StatefulWidget {
  const AdminManageTableScreen({super.key});

  @override
  State<AdminManageTableScreen> createState() => _AdminManageTableScreenState();
}

class _AdminManageTableScreenState extends State<AdminManageTableScreen> {
  final CollectionReference _tablesCollection = FirebaseFirestore.instance
      .collection('tables');

  // Danh sách dữ liệu giả định (có trường seri)
  final List<Map<String, dynamic>> _mockTables = [
    {
      "id": "T1",
      "name": "Bàn A1",
      "seats": 2,
      "seri": "SR-001",
      "isFirebase": false,
    },
    {
      "id": "T2",
      "name": "Bàn A2",
      "seats": 2,
      "seri": "SR-002",
      "isFirebase": false,
    },
    {
      "id": "T3",
      "name": "Bàn B1",
      "seats": 4,
      "seri": "SR-003",
      "isFirebase": false,
    },
    {
      "id": "T4",
      "name": "Bàn B2",
      "seats": 4,
      "seri": "SR-004",
      "isFirebase": false,
    },
    {
      "id": "T5",
      "name": "Bàn C1",
      "seats": 6,
      "seri": "SR-005",
      "isFirebase": false,
    },
    {
      "id": "T6",
      "name": "Bàn C2",
      "seats": 6,
      "seri": "SR-006",
      "isFirebase": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Quản lý bàn',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _tablesCollection.snapshots(),
        builder: (context, snapshot) {
          List<Map<String, dynamic>> combined = [];

          if (snapshot.hasData) {
            combined.addAll(
              snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                data['id'] = doc.id;
                data['isFirebase'] = true;
                return data;
              }).toList(),
            );
          }
          // Nối thêm danh sách bàn giả định
          combined.addAll(_mockTables);

          return Column(
            children: [
              // BẢNG TỔNG HỢP SỐ LƯỢNG BÀN
              Container(
                margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Tổng số bàn hiện có:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "${combined.length}",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              // DANH SÁCH BÀN
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: combined.length,
                  itemBuilder: (context, index) {
                    final table = combined[index];
                    final isFirebase = table['isFirebase'] == true;
                    final seri = table['seri'] ?? 'Chưa cập nhật';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        leading: Icon(
                          isFirebase ? Icons.table_restaurant : Icons.table_bar,
                          color: AppColors.primary,
                          size: 30,
                        ),
                        title: Text(
                          table['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            "Số chỗ: ${table['seats']}  •  Seri: $seri",
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            if (isFirebase) {
                              _tablesCollection.doc(table['id']).delete();
                            } else {
                              setState(
                                () => _mockTables.removeWhere(
                                  (t) => t['id'] == table['id'],
                                ),
                              );
                            }
                          },
                        ),
                        onTap: () => _showTableForm(table: table),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTableForm(),
        label: const Text("Thêm bàn mới"),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showTableForm({Map<String, dynamic>? table}) {
    final nameCtrl = TextEditingController(text: table?['name'] ?? '');
    final seatsCtrl = TextEditingController(
      text: table?['seats']?.toString() ?? '',
    );
    final seriCtrl = TextEditingController(text: table?['seri'] ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(table == null ? 'Thêm bàn mới' : 'Chỉnh sửa bàn'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tên bàn (Bắt buộc)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: seatsCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Số chỗ ngồi',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: seriCtrl,
                decoration: const InputDecoration(
                  labelText: 'Số Seri (Nội bộ)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = nameCtrl.text.trim();
              final newSeats = int.tryParse(seatsCtrl.text) ?? 0;
              final newSeri = seriCtrl.text.trim();

              if (newName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng nhập Tên bàn!'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              try {
                if (table != null) {
                  if (table['isFirebase'] == true) {
                    await _tablesCollection.doc(table['id']).update({
                      'name': newName,
                      'seats': newSeats,
                      'seri': newSeri,
                    });
                  } else {
                    setState(() {
                      final index = _mockTables.indexWhere(
                        (t) => t['id'] == table['id'],
                      );
                      if (index != -1) {
                        _mockTables[index]['name'] = newName;
                        _mockTables[index]['seats'] = newSeats;
                        _mockTables[index]['seri'] = newSeri;
                      }
                    });
                  }
                } else {
                  await _tablesCollection.add({
                    'name': newName,
                    'seats': newSeats,
                    'seri': newSeri,
                  });
                }

                if (mounted) Navigator.pop(dialogContext);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi khi lưu: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }
}
