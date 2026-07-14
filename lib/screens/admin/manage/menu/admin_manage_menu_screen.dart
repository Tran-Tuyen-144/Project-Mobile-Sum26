import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../theme/app_colors.dart';

class AdminManageMenuScreen extends StatefulWidget {
  const AdminManageMenuScreen({super.key});

  @override
  State<AdminManageMenuScreen> createState() => _AdminManageMenuScreenState();
}

class _AdminManageMenuScreenState extends State<AdminManageMenuScreen> {
  final CollectionReference _menuCollection = FirebaseFirestore.instance.collection('menu_items');

  // ĐÃ BỎ TỪ KHÓA 'const' Ở ĐÂY ĐỂ TRÁNH LỖI _Type
  final List<Map<String, dynamic>> _mockDrinks = [
    {"id": "M1", "name": "Latte Mây Xanh", "price": 45000, "category": "Cafe", "isFirebase": false},
    {"id": "M2", "name": "Trà Đào Cam Sả", "price": 42000, "category": "Trà", "isFirebase": false},
    {"id": "M3", "name": "Sinh Tố Dâu Mây", "price": 50000, "category": "Sinh tố", "isFirebase": false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Quản lý thực đơn')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _menuCollection.snapshots(),
        builder: (context, snapshot) {
          List<Map<String, dynamic>> menuItems = [];

          if (snapshot.hasData) {
            menuItems.addAll(snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id;
              data['isFirebase'] = true;
              return data;
            }).toList());
          }

          menuItems.addAll(_mockDrinks);

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: menuItems.length,
            itemBuilder: (context, index) {
              final item = menuItems[index];
              final isFirebase = item['isFirebase'] == true;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(isFirebase ? Icons.edit : Icons.lock, color: AppColors.primary),
                  title: Text(item['name']),
                  subtitle: Text("${item['price']}đ • ${item['category']}"),
                  trailing: isFirebase
                      ? IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _menuCollection.doc(item['id']).delete()
                  )
                      : null,
                  onTap: isFirebase ? () => _showMenuForm(item: item) : null,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showMenuForm(),
        label: const Text("Thêm món mới"),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _showMenuForm({Map<String, dynamic>? item}) {
    final nameCtrl = TextEditingController(text: item?['name'] ?? '');
    final priceCtrl = TextEditingController(text: item?['price']?.toString() ?? '');
    final catCtrl = TextEditingController(text: item?['category'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Tên món')),
              TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Giá tiền')),
              TextField(controller: catCtrl, decoration: const InputDecoration(labelText: 'Danh mục')),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final data = {'name': nameCtrl.text, 'price': int.tryParse(priceCtrl.text) ?? 0, 'category': catCtrl.text};
                  if (item != null && item['isFirebase'] == true) {
                    await _menuCollection.doc(item['id']).update(data);
                  } else {
                    await _menuCollection.add(data);
                  }
                  if (mounted) Navigator.pop(context);
                },
                child: const Text('LƯU DỮ LIỆU'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}