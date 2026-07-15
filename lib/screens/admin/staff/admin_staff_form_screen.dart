import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';

class AdminStaffFormScreen extends StatefulWidget {
  final Map<String, dynamic>?
  staff; // Nếu truyền vào null -> Thêm mới, có data -> Sửa

  const AdminStaffFormScreen({super.key, this.staff});

  @override
  State<AdminStaffFormScreen> createState() => _AdminStaffFormScreenState();
}

class _AdminStaffFormScreenState extends State<AdminStaffFormScreen> {
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _roleController = TextEditingController();
  final _dobController = TextEditingController();
  final _contactController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Đổ dữ liệu cũ vào ô nhập liệu nếu đang ở chế độ Sửa
    if (widget.staff != null) {
      _nameController.text = widget.staff!['name'];
      _idController.text = widget.staff!['id'];
      _roleController.text = widget.staff!['role'];
      _dobController.text = widget.staff!['dob'];
      _contactController.text = widget.staff!['contact'];
      _notesController.text = widget.staff!['notes'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.staff != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isEditing ? 'Sửa thông tin' : 'Thêm nhân viên'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Ô tải ảnh (Giả lập)
            GestureDetector(
              onTap: () {
                // TODO: Gọi thư viện image_picker để chọn ảnh
              },
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: AppColors.textSoft,
                ),
              ),
            ),
            const SizedBox(height: 24),

            _buildTextField(label: 'Họ và tên', controller: _nameController),
            _buildTextField(label: 'Mã nhân viên', controller: _idController),
            _buildTextField(label: 'Chức vụ', controller: _roleController),
            _buildTextField(label: 'Ngày sinh', controller: _dobController),
            _buildTextField(label: 'Liên lạc', controller: _contactController),
            _buildTextField(
              label: 'Ghi chú',
              controller: _notesController,
              maxLines: 3,
            ),

            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Hủy bỏ',
                      style: TextStyle(color: AppColors.textDark),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Trả về dữ liệu mới để màn hình chính cập nhật
                      Navigator.pop(context, {
                        'id': _idController.text,
                        'name': _nameController.text,
                        'role': _roleController.text,
                        'dob': _dobController.text,
                        'contact': _contactController.text,
                        'notes': _notesController.text,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Xác nhận',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
