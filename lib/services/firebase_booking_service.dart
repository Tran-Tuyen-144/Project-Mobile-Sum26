import 'package:cloud_firestore/cloud_firestore.dart';

import '../screens/customer/booking_confirm/booking_confirm_data.dart';

class FirebaseBookingService {
  FirebaseBookingService._();

  static final CollectionReference<Map<String, dynamic>> _bookings =
      FirebaseFirestore.instance.collection('bookings');

  /// Remote sync is optional here: the customer booking flow has already
  /// recorded the reservation locally before this confirmation page opens.
  static Future<bool> createBooking(BookingConfirmData data) async {
    try {
      await _bookings.add({
        'branch': data.branch,
        'day': data.day,
        'time': data.time,
        'guests': data.guests,
        'tableName': data.tableName,
        'status': 'confirmed',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } on FirebaseException {
      // Permission/network issues must not make a locally saved booking fail.
      return false;
    }
  }
}
