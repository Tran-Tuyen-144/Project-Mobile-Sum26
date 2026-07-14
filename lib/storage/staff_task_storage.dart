import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/staff/staff_task.dart'; // Đường dẫn tới file model của bạn

class StaffTaskStorage {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'staff_tasks';

  /// Lấy danh sách công việc trong ngày theo bộ phận (ví dụ: 'cafe', 'spa')
  static Future<List<StaffTask>> getTodayTasks(String department) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('department', isEqualTo: department)
      // Có thể thêm filter theo ngày nếu dữ liệu trên Firebase của bạn có trường 'date'
      // .where('date', isEqualTo: DateTime.now().toString().substring(0, 10))
          .get();

      return snapshot.docs
          .map((doc) => StaffTask.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print("Lỗi khi lấy danh sách công việc: $e");
      return [];
    }
  }

  /// Cập nhật trạng thái hoàn thành của công việc
  static Future<bool> updateTaskStatus(String taskId, bool isCompleted) async {
    try {
      await _firestore.collection(_collectionName).doc(taskId).update({
        'isCompleted': isCompleted,
      });
      return true;
    } catch (e) {
      print("Lỗi khi cập nhật trạng thái công việc: $e");
      return false;
    }
  }
}