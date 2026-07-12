import 'package:flutter/material.dart';
// Đã tạm thời gỡ bỏ import image_picker để bạn không bị lỗi khi chưa cài thư viện
import '../../../../theme/app_colors.dart';

class AdminPetFormScreen extends StatefulWidget {
  final Map<String, dynamic>? pet; // Nếu null là Thêm mới, có dữ liệu là Sửa

  const AdminPetFormScreen({super.key, this.pet});

  @override
  State<AdminPetFormScreen> createState() => _AdminPetFormScreenState();
}

class _AdminPetFormScreenState extends State<AdminPetFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _characteristicsController = TextEditingController();
  final _hobbiesController = TextEditingController();

  String?
  _existingImagePath; // Chỉ dùng String (đường dẫn asset) cho giai đoạn dữ liệu giả

  @override
  void initState() {
    super.initState();
    if (widget.pet != null) {
      _nameController.text = widget.pet!['name'] ?? '';
      _ageController.text = widget.pet!['age'] ?? '';
      _characteristicsController.text = widget.pet!['characteristics'] ?? '';
      _hobbiesController.text = widget.pet!['hobbies'] ?? '';
      _existingImagePath = widget.pet!['image'];
    }
  }

  // Hàm giả lập chọn ảnh (Không cần thư viện)
  void _pickMockImage() {
    setState(() {
      // Tạm thời gán cứng 1 ảnh trong assets của bạn khi bấm chọn ảnh
      _existingImagePath = 'assets/image/cat1.jpg';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã giả lập chọn ảnh thành công!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // Hàm hiển thị Dialog xác nhận khi bấm Hủy
  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận hủy'),
        content: const Text(
          'Những thông tin bạn vừa nhập sẽ không được lưu. Bạn có chắc chắn muốn hủy?',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Không',
              style: TextStyle(color: AppColors.textSoft),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Đóng dialog
              Navigator.pop(context); // Đóng form, quay về trang trước
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text(
              'Đồng ý hủy',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.pet != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Sửa thông tin thú cưng' : 'Thêm thú cưng mới',
          style: const TextStyle(color: AppColors.textDark, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: _showCancelDialog,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Khung chọn ảnh (Giả lập)
              GestureDetector(
                onTap: _pickMockImage,
                child: Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.peach, width: 2),
                    image: _existingImagePath != null
                        ? DecorationImage(
                            image: AssetImage(
                              _existingImagePath!,
                            ), // Dùng AssetImage cho dữ liệu giả
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _existingImagePath == null
                      ? const Icon(
                          Icons.add_a_photo_rounded,
                          color: AppColors.textSoft,
                          size: 32,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Chọn ảnh (Tùy chọn)",
                style: TextStyle(color: AppColors.textSoft, fontSize: 12),
              ),
              const SizedBox(height: 24),

              // Tất cả các trường đều gán isRequired: false
              _buildTextField(
                label: 'Tên thú cưng',
                controller: _nameController,
                isRequired: false,
              ),
              _buildTextField(
                label: 'Tuổi',
                controller: _ageController,
                isRequired: false,
              ),
              _buildTextField(
                label: 'Đặc điểm nhận dạng',
                controller: _characteristicsController,
                maxLines: 2,
                isRequired: false,
              ),
              _buildTextField(
                label: 'Sở thích',
                controller: _hobbiesController,
                isRequired: false,
              ),

              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _showCancelDialog,
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
                        // BỎ QUA KIỂM TRA LỖI (Validate)
                        // Lấy dữ liệu hoặc gán giá trị mặc định nếu bỏ trống để ListView không bị sập
                        String finalName = _nameController.text.trim().isEmpty
                            ? "Bé Pet Mới"
                            : _nameController.text.trim();
                        String finalAge = _ageController.text.trim().isEmpty
                            ? "1 tuổi"
                            : _ageController.text.trim();
                        String finalChar =
                            _characteristicsController.text.trim().isEmpty
                            ? "Đang cập nhật..."
                            : _characteristicsController.text.trim();
                        String finalHob = _hobbiesController.text.trim().isEmpty
                            ? "Chưa rõ"
                            : _hobbiesController.text.trim();
                        String finalImage =
                            _existingImagePath ??
                            'assets/image/dog1.jpg'; // Ảnh mặc định nếu quên chọn

                        Navigator.pop(context, {
                          'name': finalName,
                          'age': finalAge,
                          'characteristics': finalChar,
                          'hobbies': finalHob,
                          'image': finalImage,
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        isEditing ? 'Lưu thay đổi' : 'Thêm mới',
                        style: const TextStyle(
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
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
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
        // Đã tắt chế độ bắt buộc, luôn trả về null (không có lỗi)
        validator: isRequired
            ? (value) => (value == null || value.trim().isEmpty)
                  ? 'Trường này không được bỏ trống'
                  : null
            : null,
      ),
    );
  }
}
