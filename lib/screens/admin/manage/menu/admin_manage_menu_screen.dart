import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../theme/app_colors.dart';
import '../../../../services/cloudinary_upload_service.dart';

class AdminManageMenuScreen extends StatefulWidget {
  const AdminManageMenuScreen({super.key});

  @override
  State<AdminManageMenuScreen> createState() => _AdminManageMenuScreenState();
}

class _AdminManageMenuScreenState extends State<AdminManageMenuScreen> {
  final CollectionReference _menuCollection = FirebaseFirestore.instance.collection('menu_items');

  // ĐÃ SỬA: Xóa chữ 'Khác' ở đây để không bị trùng lặp ở Dropdown
  final List<String> _defaultCategories = ['Cafe', 'Trà', 'Sinh tố', 'Bánh ngọt'];

  final List<Map<String, dynamic>> _mockDrinks = [
    {"id": "M1", "name": "Latte Mây Xanh", "price": 45000, "category": "Cafe", "image": "", "isFirebase": false},
    {"id": "M2", "name": "Trà Đào Cam Sả", "price": 42000, "category": "Trà", "image": "", "isFirebase": false},
    {"id": "M3", "name": "Sinh Tố Dâu Mây", "price": 50000, "category": "Sinh tố", "image": "", "isFirebase": false},
  ];

  // Hàm định dạng tiền tệ có dấu chấm phân cách
  String formatCurrency(dynamic price) {
    if (price == null) return '0';
    String priceStr = price.toString();
    return priceStr.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Quản lý thực đơn', style: TextStyle(fontWeight: FontWeight.bold))),
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
            }));
          }
          menuItems.addAll(_mockDrinks);

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: menuItems.length,
            itemBuilder: (context, index) {
              final item = menuItems[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  leading: CircleAvatar(
                      backgroundImage: (item['image'] != null && item['image'] != "") ? NetworkImage(item['image']) : null,
                      child: (item['image'] == null || item['image'] == "") ? const Icon(Icons.restaurant_menu) : null
                  ),
                  title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  // ĐÃ SỬA: Hiển thị giá tiền có định dạng
                  subtitle: Text("${formatCurrency(item['price'])}đ • ${item['category']}"),
                  trailing: item['isFirebase'] == true
                      ? IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _menuCollection.doc(item['id']).delete())
                      : null,
                  onTap: () => _showMenuForm(item: item),
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
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showMenuForm({Map<String, dynamic>? item}) {
    final nameCtrl = TextEditingController(text: item?['name'] ?? '');
    // ĐÃ SỬA: Tự động định dạng giá tiền khi mở form sửa
    final priceCtrl = TextEditingController(text: item != null ? formatCurrency(item['price']) : '');

    // TỐI ƯU: Nếu danh mục cũ không có trong list mặc định, điền sẵn vào ô nhập "Khác"
    bool isCustomCategory = item != null && !_defaultCategories.contains(item['category']);
    final newCatCtrl = TextEditingController(text: isCustomCategory ? item['category'] : '');

    String? currentImageUrl = item?['image'] ?? '';
    String selectedCat = isCustomCategory ? 'Khác' : (item == null ? _defaultCategories.first : item['category']);
    bool isUploading = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(item == null ? 'Thêm món mới' : 'Sửa món'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    final image = await CloudinaryUploadService.pickImageFromGallery();
                    if (image != null) {
                      setDialogState(() => isUploading = true);
                      final result = await CloudinaryUploadService.uploadImageFile(image);
                      setDialogState(() {
                        currentImageUrl = CloudinaryUploadService.optimizedImageUrl(result.imageUrl);
                        isUploading = false;
                      });
                    }
                  },
                  child: Container(
                    height: 100, width: 100,
                    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
                    child: isUploading
                        ? const Center(child: CircularProgressIndicator())
                        : (currentImageUrl != null && currentImageUrl != ""
                        ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(currentImageUrl!, fit: BoxFit.cover))
                        : const Icon(Icons.add_a_photo, color: Colors.grey, size: 30)),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Tên món', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Giá tiền', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedCat,
                  items: [..._defaultCategories, 'Khác'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) => setDialogState(() => selectedCat = val!),
                  decoration: const InputDecoration(labelText: 'Danh mục', border: OutlineInputBorder()),
                ),
                if (selectedCat == 'Khác')
                  Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: TextField(controller: newCatCtrl, decoration: const InputDecoration(labelText: 'Nhập tên danh mục mới', border: OutlineInputBorder()))
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: isUploading ? null : () async {
                final cat = (selectedCat == 'Khác') ? newCatCtrl.text.trim() : selectedCat;
                if (cat.isEmpty) return; // Không cho lưu nếu để trống danh mục "Khác"

                // ĐÃ SỬA: Lọc bỏ các dấu chấm, ký tự lạ để lấy lại số nguyên gốc
                String rawPrice = priceCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
                int finalPrice = int.tryParse(rawPrice) ?? 0;

                final data = {
                  'name': nameCtrl.text,
                  'price': finalPrice, // Sử dụng giá đã được chuẩn hóa
                  'category': cat,
                  'image': currentImageUrl
                };

                if (item != null && item['isFirebase'] == true) {
                  await _menuCollection.doc(item['id']).update(data);
                } else if (item == null) {
                  await _menuCollection.add(data);
                }
                if (mounted) Navigator.pop(dialogContext);
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }
}