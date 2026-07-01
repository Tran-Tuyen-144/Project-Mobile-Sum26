import 'package:cloud_firestore/cloud_firestore.dart';

import '../screens/customer/booking_confirm/booking_confirm_data.dart';
class FirebaseBookingService {
  FirebaseBookingService._();

  static final CollectionReference<Map<String, dynamic>> _bookings =
  FirebaseFirestore.instance.collection('bookings');

  static Future<void> createBooking(BookingConfirmData data) async {
    await _bookings.add({
      'branch': data.branch,
      'day': data.day,
      'time': data.time,
      'guests': data.guests,
      'tableName': data.tableName,
      'status': 'confirmed',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}