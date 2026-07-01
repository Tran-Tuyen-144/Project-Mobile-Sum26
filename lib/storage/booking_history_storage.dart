import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

enum BookingStatus {
  confirmed('Đã xác nhận'),
  pendingSync('Chờ đồng bộ'),
  cancelled('Đã hủy');

  final String label;

  const BookingStatus(this.label);

  static BookingStatus fromName(String value) {
    return BookingStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => BookingStatus.confirmed,
    );
  }
}

class BookingHistoryItem {
  final String id;
  final DateTime createdAt;
  final String branch;
  final String day;
  final String time;
  final int guests;
  final int tableId;
  final String tableName;
  final String customerName;
  final String phone;
  final String note;
  final BookingStatus status;

  const BookingHistoryItem({
    required this.id,
    required this.createdAt,
    required this.branch,
    required this.day,
    required this.time,
    required this.guests,
    required this.tableId,
    required this.tableName,
    required this.customerName,
    required this.phone,
    required this.note,
    required this.status,
  });

  BookingHistoryItem copyWith({BookingStatus? status}) {
    return BookingHistoryItem(
      id: id,
      createdAt: createdAt,
      branch: branch,
      day: day,
      time: time,
      guests: guests,
      tableId: tableId,
      tableName: tableName,
      customerName: customerName,
      phone: phone,
      note: note,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'branch': branch,
      'day': day,
      'time': time,
      'guests': guests,
      'tableId': tableId,
      'tableName': tableName,
      'customerName': customerName,
      'phone': phone,
      'note': note,
      'status': status.name,
    };
  }

  factory BookingHistoryItem.fromJson(Map<String, dynamic> json) {
    return BookingHistoryItem(
      id: json['id'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      branch: json['branch'] as String? ?? '',
      day: json['day'] as String? ?? '',
      time: json['time'] as String? ?? '',
      guests: json['guests'] as int? ?? 1,
      tableId: json['tableId'] as int? ?? 0,
      tableName: json['tableName'] as String? ?? '',
      customerName: json['customerName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      note: json['note'] as String? ?? '',
      status: BookingStatus.fromName(json['status'] as String? ?? ''),
    );
  }
}

class BookingHistoryStorage {
  static const String _key = 'booking_history_items';

  static Future<List<BookingHistoryItem>> loadBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedItems = prefs.getStringList(_key) ?? [];
    final bookings = <BookingHistoryItem>[];

    for (final encoded in encodedItems) {
      try {
        final decoded = jsonDecode(encoded) as Map<String, dynamic>;
        bookings.add(BookingHistoryItem.fromJson(decoded));
      } catch (_) {}
    }

    bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return bookings;
  }

  static Future<void> saveBooking(BookingHistoryItem booking) async {
    final bookings = await loadBookings();
    bookings.removeWhere((item) => item.id == booking.id);
    bookings.insert(0, booking);
    await _saveBookings(bookings);
  }

  static Future<void> updateStatus(String id, BookingStatus status) async {
    final bookings = await loadBookings();
    final updated = bookings
        .map(
          (booking) =>
              booking.id == id ? booking.copyWith(status: status) : booking,
        )
        .toList();
    await _saveBookings(updated);
  }

  static Future<void> _saveBookings(List<BookingHistoryItem> bookings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      bookings.map((booking) => jsonEncode(booking.toJson())).toList(),
    );
  }
}
