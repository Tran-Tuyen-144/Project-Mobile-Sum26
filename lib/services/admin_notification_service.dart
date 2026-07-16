import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'customer_booking_notification_service.dart';

class AdminNotification {
  final String id;
  final String title;
  final String body;
  final String type;
  final DateTime createdAt;
  final bool isRead;
  final bool isApproved;
  final String? bookingId;

  const AdminNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    required this.isRead,
    required this.isApproved,
    this.bookingId,
  });

  AdminNotification copyWith({bool? isRead, bool? isApproved}) =>
      AdminNotification(
        id: id,
        title: title,
        body: body,
        type: type,
        createdAt: createdAt,
        isRead: isRead ?? this.isRead,
        isApproved: isApproved ?? this.isApproved,
        bookingId: bookingId,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'type': type,
    'createdAt': createdAt.toIso8601String(),
    'isRead': isRead,
    'isApproved': isApproved,
    'bookingId': bookingId,
  };

  factory AdminNotification.fromJson(Map<String, dynamic> data) =>
      AdminNotification(
        id: data['id'] as String? ?? '',
        title: data['title'] as String? ?? 'Thông báo mới',
        body: data['body'] as String? ?? '',
        type: data['type'] as String? ?? 'general',
        createdAt:
            DateTime.tryParse(data['createdAt'] as String? ?? '') ??
            DateTime.now(),
        isRead: data['isRead'] as bool? ?? false,
        isApproved: data['isApproved'] as bool? ?? false,
        bookingId: data['bookingId'] as String?,
      );
}

/// Notifications are first saved on this device. Firestore is a best-effort
/// sync layer, so a denied rule never leaves the admin page blank.
class AdminNotificationService {
  AdminNotificationService._();
  static const _storageKey = 'admin_notifications_v1';
  static final _items = FirebaseFirestore.instance.collection(
    'admin_notifications',
  );
  static final _controller =
      StreamController<List<AdminNotification>>.broadcast();
  static final List<AdminNotification> _local = [];
  static bool _loaded = false;

  static Future<void> create({
    required String title,
    required String body,
    required String type,
    String? bookingId,
  }) async {
    await _ensureLoaded();
    final item = AdminNotification(
      id: 'local_${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      body: body,
      type: type,
      createdAt: DateTime.now(),
      isRead: false,
      isApproved: false,
      bookingId: bookingId,
    );
    _local.insert(0, item);
    await _saveAndEmit();
    try {
      await _items.doc(item.id).set({
        ...item.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException {
      // The locally stored notification is still available.
    }
  }

  static Stream<List<AdminNotification>> watch() async* {
    await _ensureLoaded();
    yield List.unmodifiable(_local);
    yield* _controller.stream;
  }

  static Future<void> markRead(String id) async {
    await _ensureLoaded();
    final index = _local.indexWhere((item) => item.id == id);
    if (index < 0) return;
    _local[index] = _local[index].copyWith(isRead: true);
    await _saveAndEmit();
    try {
      await _items.doc(id).update({'isRead': true});
    } on FirebaseException {
      return;
    }
  }

  static Future<void> approveBooking(String id) async {
    await _ensureLoaded();
    final index = _local.indexWhere((item) => item.id == id);
    if (index < 0) return;
    _local[index] = _local[index].copyWith(isRead: true, isApproved: true);
    await _saveAndEmit();
    final bookingId = _local[index].bookingId;
    if (bookingId != null && bookingId.isNotEmpty) {
      await CustomerBookingNotificationService.confirmBooking(bookingId);
    }
    try {
      await _items.doc(id).update({'isRead': true, 'isApproved': true});
    } on FirebaseException {
      return;
    }
  }

  static Future<void> _ensureLoaded() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final raw = (await SharedPreferences.getInstance()).getString(
        _storageKey,
      );
      if (raw != null) {
        final data = jsonDecode(raw) as List<dynamic>;
        _local.addAll(
          data.map(
            (item) => AdminNotification.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          ),
        );
        _local.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
    } catch (_) {}
  }

  static Future<void> _saveAndEmit() async {
    await (await SharedPreferences.getInstance()).setString(
      _storageKey,
      jsonEncode(_local.map((item) => item.toJson()).toList()),
    );
    _controller.add(List.unmodifiable(_local));
  }
}
