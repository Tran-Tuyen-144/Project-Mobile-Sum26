import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class OfflineDrinkOrder {
  final DateTime createdAt;
  final Map<int, int> items;
  final int totalPrice;
  final String paymentMethod;

  const OfflineDrinkOrder({
    required this.createdAt,
    required this.items,
    required this.totalPrice,
    required this.paymentMethod,
  });

  Map<String, dynamic> toJson() {
    return {
      'createdAt': createdAt.toIso8601String(),
      'items': items.map((key, value) => MapEntry(key.toString(), value)),
      'totalPrice': totalPrice,
      'paymentMethod': paymentMethod,
    };
  }

  factory OfflineDrinkOrder.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as Map<String, dynamic>? ?? {};

    return OfflineDrinkOrder(
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      items: rawItems.map(
        (key, value) => MapEntry(int.tryParse(key) ?? 0, value as int? ?? 0),
      )..removeWhere((key, value) => key == 0 || value <= 0),
      totalPrice: json['totalPrice'] as int? ?? 0,
      paymentMethod: json['paymentMethod'] as String? ?? '',
    );
  }
}

class OfflineDrinkOrderStorage {
  static const String _cartKey = 'drink_order_cart';
  static const String _historyKey = 'drink_order_history';

  static Future<Map<int, int>> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_cartKey);
    if (encoded == null) return {};

    try {
      final decoded = jsonDecode(encoded) as Map<String, dynamic>;
      return decoded.map(
        (key, value) => MapEntry(int.tryParse(key) ?? 0, value as int? ?? 0),
      )..removeWhere((key, value) => key == 0 || value <= 0);
    } catch (_) {
      return {};
    }
  }

  static Future<void> saveCart(Map<int, int> cart) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = cart.map((key, value) => MapEntry(key.toString(), value));
    await prefs.setString(_cartKey, jsonEncode(encoded));
  }

  static Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }

  static Future<List<OfflineDrinkOrder>> loadOrderHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedOrders = prefs.getStringList(_historyKey) ?? [];
    final orders = <OfflineDrinkOrder>[];

    for (final encoded in encodedOrders) {
      try {
        final decoded = jsonDecode(encoded) as Map<String, dynamic>;
        orders.add(OfflineDrinkOrder.fromJson(decoded));
      } catch (_) {}
    }

    orders.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return orders;
  }

  static Future<void> saveOfflineOrder(OfflineDrinkOrder order) async {
    final orders = await loadOrderHistory();
    orders.add(order);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _historyKey,
      orders.map((item) => jsonEncode(item.toJson())).toList(),
    );
  }
}
