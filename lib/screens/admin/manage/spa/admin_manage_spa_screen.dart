import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../theme/app_colors.dart';
import '../../../../services/cloudinary_upload_service.dart'; // Đảm bảo đường dẫn này đúng

class AdminManageSpaScreen extends StatefulWidget {
  const AdminManageSpaScreen({super.key});

  @override
  State<AdminManageSpaScreen> createState() => _AdminManageSpaScreenState();
}

class _AdminManageSpaScreenState extends State<AdminManageSpaScreen> {
  // Kết nối đến bảng spa_services trên Firebase
  final CollectionReference _spaCollection = FirebaseFirestore.instance.collection('spa_services');

  // Danh mục dịch vụ mặc định
  final List<String> _defaultCategories = ['Tắm sấy', 'Cắt tỉa lông', 'Vệ sinh (Tai, Móng)', 'Massage thư giãn', 'Khác'];

  // Dữ liệu giả định để test UI
  final List<Map<String, dynamic>> _mockServices = [
    {"id": "S1", "name": "Tắm sấy cơ bản (Dưới 5kg)", "price": 100000, "category": "Tắm sấy", "image": "", "isFirebase": false},
    {"id": "S2", "name": "Cắt tỉa lông tạo kiểu", "price": 250000, "category": "Cắt tỉa lông", "image": "", "isFirebase": false},
    {"id": "S3", "name": "Cắt móng & Vệ sinh tai", "price": 50000, "category": "Vệ sinh (Tai, Móng)", "image": "", "isFirebase": false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Quản lý Dịch vụ Spa', style: TextStyle(fontWeight: FontWeight.bold))),
      body: StreamBuilder<QuerySnapshot>(
        stream: _spaCollection.snapshots(),
        builder: (context, snapshot) {
          List<Map<String, dynamic>> combined = [];

          if (snapshot.hasData) {
            combined.addAll(snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id;
              data['isFirebase'] = true;
              return data;
            }));
          }
          combined.addAll(_mockServices);

          return Column(
            children: [
              // 1. BẢNG TỔNG HỢP SỐ LƯỢNG DỊCH VỤ
              Container(
                margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Tổng dịch vụ hiện có:",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      "${combined.length}",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ],
                ),
              ),

              // 2. DANH SÁCH DỊCH VỤ
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: combined.length,
                  itemBuilder: (context, index) {
                    final item = combined[index];
                    final isFirebase = item['isFirebase'] == true;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              image: (item['image'] != null && item['image'] != "")
                                  ? DecorationImage(image: NetworkImage(item['image']), fit: BoxFit.cover)
                                  : null
                          ),
                          child: (item['image'] == null || item['image'] == "")
                              ? const Icon(Icons.spa, color: AppColors.primary) // Icon mặc định nếu không có ảnh
                              : null,
                        ),
                        title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("${item['price']}đ • ${item['category']}"),
                        trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              if (isFirebase) {
                                _spaCollection.doc(item['id']).delete();
                              } else {
                                setState(() => _mockServices.removeWhere((s) => s['id'] == item['id']));
                              }
                            }
                        ),
                        onTap: () => _showSpaForm(item: item),
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
        onPressed: () => _showSpaForm(),
        label: const Text("Thêm dịch vụ"),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  // 3. FORM THÊM / SỬA DỊCH VỤ
  void _showSpaForm({Map<String, dynamic>? item}) {
    final nameCtrl = TextEditingController(text: item?['name'] ?? '');
    final priceCtrl = TextEditingController(text: item?['price']?.toString() ?? '');

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
          title: Text(item == null ? 'Thêm dịch vụ Spa' : 'Chỉnh sửa dịch vụ'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Khung upload ảnh
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
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Tên dịch vụ (Bắt buộc)', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Giá tiền', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                // Dropdown danh mục
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
                final newName = nameCtrl.text.trim();

                if (newName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập tên dịch vụ!'), backgroundColor: Colors.orange));
                  return;
                }
                if (cat.isEmpty) return;

                final data = {
                  'name': newName,
                  'price': int.tryParse(priceCtrl.text) ?? 0,
                  'category': cat,
                  'image': currentImageUrl
                };

                try {
                  if (item != null) {
                    if (item['isFirebase'] == true) {
                      await _spaCollection.doc(item['id']).update(data);
                    } else {
                      setState(() {
                        final index = _mockServices.indexWhere((s) => s['id'] == item['id']);
                        if (index != -1) {
                          _mockServices[index] = {..._mockServices[index], ...data};
                        }
                      });
                    }
                  } else {
                    await _spaCollection.add(data);
                  }
                  if (mounted) Navigator.pop(dialogContext);
                } catch (e) {
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi lưu: $e'), backgroundColor: Colors.red));
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }
}