import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class AdminShiftAssignScreen extends StatefulWidget {
  const AdminShiftAssignScreen({super.key});

  @override
  State<AdminShiftAssignScreen> createState() => _AdminShiftAssignScreenState();
}

class _AdminShiftAssignScreenState extends State<AdminShiftAssignScreen> {
  final List<String> _allStaff = ["Nguyễn Hải Yến", "Trần Mộng Tuyền", "Nguyễn Hoàng Ngọc Trân", "Nguyễn Xuân Hiếu"];

  // Dữ liệu mẫu: Map<Tên nhân viên, Tên ca>
  Map<String, String> _shiftAssignment = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Xếp ca làm việc"),
        actions: [
          // Nút Lưu để xác nhận hoàn tất xếp ca
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              print("Kết quả xếp ca: $_shiftAssignment");
              Navigator.pop(context, _shiftAssignment);
            },
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildShiftSection("Ca Sáng (07:00 - 12:00)"),
          _buildShiftSection("Ca Chiều (12:00 - 17:00)"),
          _buildShiftSection("Ca Tối (17:00 - 22:00)"),
        ],
      ),
    );
  }

  Widget _buildShiftSection(String shiftName) {
    // Đếm số lượng nhân viên trong ca này để hiển thị tiêu đề cho sinh động
    int count = _shiftAssignment.values.where((s) => s == shiftName).length;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(shiftName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("$count nhân viên đã chọn"),
        children: _allStaff.map((staff) {
          return CheckboxListTile(
            dense: true,
            title: Text(staff),
            value: _shiftAssignment[staff] == shiftName,
            onChanged: (val) {
              setState(() {
                if (val == true) {
                  // Xếp nhân viên vào ca này (tự động xóa khỏi ca cũ nếu có)
                  _shiftAssignment[staff] = shiftName;
                } else {
                  _shiftAssignment.remove(staff);
                }
              });
            },
          );
        }).toList(),
      ),
    );
  }
}