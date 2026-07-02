import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';

class AdminTableFormScreen extends StatefulWidget {
  final Map<String, dynamic>? tableData;

  const AdminTableFormScreen({super.key, this.tableData});

  @override
  State<AdminTableFormScreen> createState() => _AdminTableFormScreenState();
}

class _AdminTableFormScreenState extends State<AdminTableFormScreen> {
  final _nameController = TextEditingController();
  final _seatsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.tableData != null) {
      _nameController.text = widget.tableData!['name'] ?? '';
      _seatsController.text = widget.tableData!['seats'] ?? '';
    }
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận hủy'),
        content: const Text('Các thay đổi sẽ không được lưu. Hủy bỏ?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Không')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Đồng ý', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.tableData != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isEditing ? 'Sửa thông tin bàn' : 'Thêm bàn mới', style: const TextStyle(color: AppColors.textDark, fontSize: 18)),
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textDark), onPressed: _showCancelDialog),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.table_restaurant_rounded, size: 80, color: AppColors.peach),
            const SizedBox(height: 24),
            TextField(controller: _nameController, decoration: InputDecoration(labelText: 'Tên/Số bàn (VD: Bàn 01)', filled: true, fillColor: Colors.grey.shade50, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
            const SizedBox(height: 16),
            TextField(controller: _seatsController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Số ghế', filled: true, fillColor: Colors.grey.shade50, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: _showCancelDialog, style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)), child: const Text('Hủy bỏ', style: TextStyle(color: AppColors.textDark)))),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, {
                        'name': _nameController.text.trim().isEmpty ? "Bàn Mới" : _nameController.text.trim(),
                        'seats': _seatsController.text.trim().isEmpty ? "2" : _seatsController.text.trim(),
                      });
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: Text(isEditing ? 'Lưu' : 'Thêm', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}