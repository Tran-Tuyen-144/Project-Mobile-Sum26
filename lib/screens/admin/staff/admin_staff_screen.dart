import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import 'admin_staff_detail_screen.dart';
import 'admin_staff_form_screen.dart';

class AdminStaffScreen extends StatefulWidget {
  const AdminStaffScreen({super.key});

  @override
  State<AdminStaffScreen> createState() => _AdminStaffScreenState();
}

class _AdminStaffScreenState extends State<AdminStaffScreen> {
  // Dữ liệu giả lập
  final List<Map<String, dynamic>> _staffList = [
    {
      "id": "NV001",
      "name": "Nguyễn Hải Yến",
      "role": "Phục vụ bàn",
      "dob": "16/07/2004",
      "contact": "0901234567",
      "notes": "Ca sáng",
    },
    {
      "id": "NV002",
      "name": "Trần Mộng Tuyền",
      "role": "Pha chế chính",
      "dob": "10/05/2004",
      "contact": "0912345678",
      "notes": "Ca chiều",
    },
    {
      "id": "NV003",
      "name": "Nguyễn Hoàng Ngọc Trân",
      "role": "Chăm sóc thú cưng",
      "dob": "22/11/2004",
      "contact": "0987654321",
      "notes": "Ca tối",
    },
  ];

  // Hàm hiển thị hộp thoại Xóa
  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc chắn muốn xóa nhân viên ${_staffList[index]['name']} không?',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context), // Đóng dialog, không làm gì
            child: const Text(
              'Hủy bỏ',
              style: TextStyle(color: AppColors.textSoft),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _staffList.removeAt(index); // Xóa khỏi danh sách
              });
              Navigator.pop(context); // Đóng dialog
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text(
              'Xác nhận',
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
          'Danh sách nhân sự',
          style: TextStyle(color: AppColors.textSoft, fontSize: 16),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_circle,
              color: AppColors.primary,
              size: 28,
            ),
            onPressed: () async {
              // Mở màn hình thêm mới
              final newStaff = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminStaffFormScreen()),
              );
              if (newStaff != null) {
                setState(() => _staffList.add(newStaff));
              }
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _staffList.length,
        itemBuilder: (context, index) {
          final staff = _staffList[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.mint.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: AppColors.mint),
              ),
              title: Text(
                staff['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(staff['role']),
              // Vùng chứa 2 icon Sửa / Xóa (Trailing)
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.edit_rounded,
                      color: AppColors.primary,
                    ),
                    onPressed: () async {
                      // Mở màn hình sửa và chờ nhận lại data
                      final updatedStaff = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdminStaffFormScreen(staff: staff),
                        ),
                      );
                      if (updatedStaff != null) {
                        setState(() => _staffList[index] = updatedStaff);
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_rounded,
                      color: Colors.redAccent,
                    ),
                    onPressed: () => _showDeleteDialog(index),
                  ),
                ],
              ),
              onTap: () {
                // Nhảy sang màn hình chi tiết
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdminStaffDetailScreen(staff: staff),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
