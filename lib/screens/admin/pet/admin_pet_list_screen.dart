import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import 'admin_pet_form_screen.dart'; // Import màn hình Form vừa tạo

class AdminPetListScreen extends StatefulWidget {
  const AdminPetListScreen({super.key});

  @override
  State<AdminPetListScreen> createState() => _AdminPetListScreenState();
}

class _AdminPetListScreenState extends State<AdminPetListScreen> {
  // Danh sách dữ liệu mẫu
  final List<Map<String, dynamic>> _pets = [
    {
      "name": "Mailisa",
      "age": "2 tuổi",
      "characteristics": "Lông trắng, mắt xanh",
      "hobbies": "Thích ngủ nướng",
      "image": "assets/image/cat1.jpg",
    },
    {
      "name": "Corgi Lucky",
      "age": "3 tuổi",
      "characteristics": "Chân ngắn, mông to",
      "hobbies": "Thích bóng tennis",
      "image": "assets/image/dog1.jpg",
    },
  ];

  // Hàm hiển thị Dialog xác nhận Xóa
  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc chắn muốn xóa bé "${_pets[index]['name']}" khỏi hệ thống không?',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Hủy',
              style: TextStyle(color: AppColors.textSoft),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _pets.removeAt(index);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text(
              'Xác nhận xóa',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Hồ sơ thú cưng",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          // Nút Thêm mới trên AppBar
          IconButton(
            icon: const Icon(
              Icons.add_circle_rounded,
              color: AppColors.primary,
              size: 28,
            ),
            onPressed: () async {
              // Mở form thêm mới và chờ dữ liệu trả về
              final newPet = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminPetFormScreen()),
              );
              // Nếu nhận được dữ liệu (bấm Xác nhận), thì cập nhật danh sách
              if (newPet != null) {
                setState(() {
                  _pets.add(newPet);
                });
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _pets.isEmpty
          ? const Center(
              child: Text(
                "Chưa có thú cưng nào",
                style: TextStyle(color: AppColors.textSoft),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _pets.length,
              itemBuilder: (context, index) {
                final pet = _pets[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF4EE), // Màu pastel nhẹ
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white,
                      // Xử lý hiển thị ảnh: Từ máy (File) hoặc mặc định (Asset)
                      backgroundImage:
                          pet["image"].toString().startsWith('assets/')
                          ? AssetImage(pet["image"]) as ImageProvider
                          : FileImage(File(pet["image"])),
                    ),
                    title: Text(
                      pet["name"],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      pet["age"],
                      style: const TextStyle(color: Colors.black54),
                    ),

                    // Nút Sửa và Xóa
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit_rounded,
                            color: Colors.blue,
                            size: 22,
                          ),
                          onPressed: () async {
                            // Mở form và truyền dữ liệu pet hiện tại vào để sửa
                            final updatedPet = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AdminPetFormScreen(pet: pet),
                              ),
                            );
                            // Cập nhật lại danh sách nếu có thay đổi
                            if (updatedPet != null) {
                              setState(() {
                                _pets[index] = updatedPet;
                              });
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_rounded,
                            color: Colors.redAccent,
                            size: 22,
                          ),
                          onPressed: () => _showDeleteDialog(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
