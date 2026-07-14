import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/staff/cafe_booking.dart'; // Đường dẫn tới file model của bạn

class StaffBookingStorage {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'bookings';

  /// Tìm kiếm đơn đặt bàn bằng số điện thoại
  static Future<CafeBooking?> searchBookingByPhone(String phone) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('phone', isEqualTo: phone)
      // Lấy đơn hàng mới nhất hoặc chưa hoàn thành
          .where('status', isNotEqualTo: 'Đã hoàn thành')
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        return CafeBooking.fromJson(doc.data(), doc.id);
      }
      return null;
    } catch (e) {
      print("Lỗi khi tra cứu đặt bàn: $e");
      return null;
    }
  }

  /// Cập nhật trạng thái đặt bàn (ví dụ: 'Khách đã nhận bàn')
  static Future<bool> updateBookingStatus(String bookingId, String newStatus) async {
    try {
      await _firestore.collection(_collectionName).doc(bookingId).update({
        'status': newStatus,
      });
      return true;
    } catch (e) {
      print("Lỗi khi cập nhật trạng thái đặt bàn: $e");
      return false;
    }
  }
  /// Lắng nghe các yêu cầu đặt bàn mới theo THỜI GIAN THỰC (Real-time)
  static Stream<List<CafeBooking>> streamPendingBookings() {
    return _firestore
        .collection(_collectionName)
        .where('status', isEqualTo: 'Chờ xác nhận') // Chỉ lấy các đơn chờ duyệt
    // .orderBy('createdAt', descending: true) // Có thể thêm dòng này nếu có trường thời gian tạo
        .snapshots() // Lệnh này giúp Firebase tự động bắn data mới về app
        .map((snapshot) => snapshot.docs
        .map((doc) => CafeBooking.fromJson(doc.data(), doc.id))
        .toList());
  }
}