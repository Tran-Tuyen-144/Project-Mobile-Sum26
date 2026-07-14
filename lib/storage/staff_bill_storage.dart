import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/staff/cafe_bill.dart'; // Đường dẫn tới file model của bạn

class StaffBillStorage {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'bills';

  /// Tạo hóa đơn mới (Xuất Bill) và đẩy lên Firebase
  static Future<bool> createBill(CafeBill bill) async {
    try {
      // Sử dụng toJson() để convert Object thành Map cho Firebase
      await _firestore.collection(_collectionName).doc(bill.id).set(bill.toJson());
      return true;
    } catch (e) {
      print("Lỗi khi tạo hóa đơn (Bill): $e");
      return false;
    }
  }

  /// (Tùy chọn) Lấy danh sách các Bill đã xuất trong ca làm việc hôm nay
  static Future<List<CafeBill>> getTodayBills(String staffName) async {
    try {
      // Tính toán thời điểm bắt đầu của ngày hôm nay
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      final snapshot = await _firestore
          .collection(_collectionName)
          .where('staffName', isEqualTo: staffName)
          .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => CafeBill.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print("Lỗi khi lấy danh sách Bill: $e");
      return [];
    }
  }
}