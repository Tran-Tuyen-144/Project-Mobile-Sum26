import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RevenueOrder {
  final String id;
  final String category;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final String source;
  final String paymentMethod;
  final String status;
  final int totalAmount;
  final DateTime createdAt;
  final DateTime? completedAt;
  final List<Map<String, dynamic>> items;

  const RevenueOrder({
    required this.id,
    required this.category,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.source,
    required this.paymentMethod,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    required this.completedAt,
    required this.items,
  });

  bool get isCompleted => status == 'completed';

  bool get isPending => status == 'pending';

  String get itemSummary {
    if (items.isEmpty) {
      return 'Không có chi tiết món';
    }

    return items
        .map((item) {
          final name = item['name']?.toString() ?? 'Món';
          final quantity = _readInt(item['quantity'] ?? item['qty']);

          return '$name x$quantity';
        })
        .join(', ');
  }

  factory RevenueOrder.fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    return RevenueOrder(
      id: document.id,
      category: data['category']?.toString().toLowerCase() ?? '',
      customerId: data['customerId']?.toString() ?? '',
      customerName: data['customerName']?.toString() ?? '',
      customerEmail: data['customerEmail']?.toString() ?? '',
      source: data['source']?.toString() ?? 'admin',
      paymentMethod: data['paymentMethod']?.toString() ?? '',
      status: data['status']?.toString().toLowerCase() ?? '',
      totalAmount: _readInt(data['totalAmount']),
      createdAt: _readDate(data['createdAt']),
      completedAt: _readNullableDate(data['completedAt']),
      items: _readItems(data['items']),
    );
  }

  static int _readInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime _readDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate().toLocal();
    }

    if (value is DateTime) {
      return value.toLocal();
    }

    if (value is String) {
      return DateTime.tryParse(value)?.toLocal() ??
          DateTime.fromMillisecondsSinceEpoch(0);
    }

    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  static DateTime? _readNullableDate(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is Timestamp) {
      return value.toDate().toLocal();
    }

    if (value is DateTime) {
      return value.toLocal();
    }

    if (value is String) {
      return DateTime.tryParse(value)?.toLocal();
    }

    return null;
  }

  static List<Map<String, dynamic>> _readItems(dynamic value) {
    if (value is! List) {
      return const [];
    }

    return value
        .whereType<Map>()
        .map(
          (item) => item.map((key, value) => MapEntry(key.toString(), value)),
        )
        .toList();
  }
}

class OrderRevenueService {
  OrderRevenueService._();

  static final CollectionReference<Map<String, dynamic>> _orders =
      FirebaseFirestore.instance.collection('orders');

  static Stream<List<RevenueOrder>> watchOrders() {
    return _orders
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(RevenueOrder.fromDocument).toList(),
        );
  }

  static Stream<List<RevenueOrder>> watchPendingCustomerCafeOrders() {
    return watchOrders().map(
      (orders) => orders.where((order) {
        return order.category == 'cafe' &&
            order.source == 'customer' &&
            order.isPending;
      }).toList(),
    );
  }

  static Future<String> createCustomerCafeOrder({
    required List<Map<String, dynamic>> items,
    required int totalAmount,
    required String paymentMethod,
    required bool isPaid,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Bạn cần đăng nhập trước khi đặt hàng.');
    }

    if (items.isEmpty) {
      throw Exception('Giỏ hàng đang trống.');
    }

    if (totalAmount <= 0) {
      throw Exception('Tổng tiền đơn hàng không hợp lệ.');
    }

    final document = _orders.doc();

    await document.set({
      'orderId': document.id,
      'category': 'cafe',
      'customerId': user.uid,
      'customerName': user.displayName ?? '',
      'customerEmail': user.email ?? '',
      'source': 'customer',
      'orderType': 'Đặt từ ứng dụng khách hàng',
      'items': items,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'status': isPaid ? 'completed' : 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'completedAt': isPaid ? FieldValue.serverTimestamp() : null,
    });

    return document.id;
  }

  static Future<void> completeOrder(String orderId) async {
    await _orders.doc(orderId).update({
      'status': 'completed',
      'completedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> cancelOrder(String orderId) async {
    await _orders.doc(orderId).update({
      'status': 'cancelled',
      'cancelledAt': FieldValue.serverTimestamp(),
    });
  }
}
