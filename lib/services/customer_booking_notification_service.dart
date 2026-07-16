import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Customer-facing status for a table-booking request.
class CustomerBookingNotification {
  final String id;
  final String bookingId;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isConfirmed;

  const CustomerBookingNotification({
    required this.id,
    required this.bookingId,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.isConfirmed,
  });

  factory CustomerBookingNotification.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    final timestamp = data['createdAt'];
    return CustomerBookingNotification(
      id: document.id,
      bookingId: data['bookingId'] as String? ?? '',
      title: data['title'] as String? ?? 'Cập nhật đặt bàn',
      message: data['message'] as String? ?? '',
      createdAt: timestamp is Timestamp ? timestamp.toDate() : DateTime.now(),
      isConfirmed: data['isConfirmed'] as bool? ?? false,
    );
  }
}

class CustomerBookingNotificationService {
  CustomerBookingNotificationService._();

  static final _items = FirebaseFirestore.instance.collection(
    'customer_booking_notifications',
  );
  static final _localChanges = StreamController<void>.broadcast();

  static Stream<void> get localChanges => _localChanges.stream;

  static Future<void> createPending({
    required String bookingId,
    required String tableName,
  }) async {
    try {
      await _items.doc(bookingId).set({
        'bookingId': bookingId,
        'title': 'Yêu cầu đặt bàn đang chờ xác nhận',
        'message': '$tableName đang chờ PetHub xác nhận.',
        'createdAt': FieldValue.serverTimestamp(),
        'isConfirmed': false,
      });
    } on FirebaseException {
      // The booking is still retained locally when the device is offline.
    }
  }

  static Future<void> confirmBooking(String bookingId) async {
    await _markLocalBookingConfirmed(bookingId);
    _localChanges.add(null);
    try {
      await _items.doc(bookingId).set({
        'bookingId': bookingId,
        'title': 'Đặt bàn thành công',
        'message': 'PetHub đã xác nhận yêu cầu đặt bàn của bạn.',
        'createdAt': FieldValue.serverTimestamp(),
        'isConfirmed': true,
      }, SetOptions(merge: true));
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({'status': 'confirmed'});
    } on FirebaseException {
      // Firestore will retry when a connection is available.
    }
  }

  static Future<void> _markLocalBookingConfirmed(String bookingId) async {
    const storageKey = 'booking_history_items';
    final preferences = await SharedPreferences.getInstance();
    final bookings = preferences.getStringList(storageKey) ?? const [];
    var changed = false;
    final updated = bookings.map((encoded) {
      try {
        final booking = jsonDecode(encoded) as Map<String, dynamic>;
        if (booking['id'] == bookingId && booking['status'] != 'confirmed') {
          booking['status'] = 'confirmed';
          changed = true;
          return jsonEncode(booking);
        }
      } catch (_) {
        // Keep invalid legacy data untouched.
      }
      return encoded;
    }).toList();

    if (changed) await preferences.setStringList(storageKey, updated);
  }

  static Stream<List<CustomerBookingNotification>> watch() => _items
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(CustomerBookingNotification.fromFirestore)
            .toList(),
      );
}
