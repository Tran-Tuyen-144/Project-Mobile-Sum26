import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';

class AdminMenuFormScreen extends StatefulWidget {
  final Map<String, dynamic>? menuItem;

  const AdminMenuFormScreen({super.key, this.menuItem});

  @override
  State<AdminMenuFormScreen> createState() => _AdminMenuFormScreenState();
}

class _AdminMenuFormScreenState extends State<AdminMenuFormScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _noteController = TextEditingController();

  // Biến lưu phân loại
  String _selectedCategory = 'Cafe';
  final List<String> _categories = ['Cafe', 'Sinh tố', 'Trà', 'Bánh ngọt'];

  @override
  void initState() {
    super.initState();
    if (widget.menuItem != null) {
      _nameController.text = widget.menuItem!['name'] ?? '';
      _priceController.text = widget.menuItem!['price'] ?? '';
      _noteController.text = widget.menuItem!['note'] ?? '';
      _selectedCategory = widget.menuItem!['category'] ?? 'Cafe';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(widget.menuItem == null ? 'Thêm món mới' : 'Sửa món')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(label: 'Tên món', controller: _nameController),

            const Text("Phân loại:", style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: _categories.map((cat) => ChoiceChip(
                label: Text(cat),
                selected: _selectedCategory == cat,
                onSelected: (selected) => setState(() => _selectedCategory = cat),
                selectedColor: AppColors.primary.withOpacity(0.3),
              )).toList(),
            ),
            const SizedBox(height: 16),

            _buildTextField(label: 'Giá tiền', controller: _priceController, isNumber: true),
            _buildTextField(label: 'Ghi chú', controller: _noteController, maxLines: 2),

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy'))),
                const SizedBox(width: 16),
                Expanded(child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () {
                    Navigator.pop(context, {
                      'name': _nameController.text,
                      'category': _selectedCategory,
                      'price': _priceController.text,
                      'note': _noteController.text,
                      'image': 'assets/image/cat1.jpg' // Giả lập ảnh
                    });
                  },
                  child: const Text('Xác nhận', style: TextStyle(color: Colors.white)),
                )),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, required TextEditingController controller, bool isNumber = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label, filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
      ),
    );
  }
}