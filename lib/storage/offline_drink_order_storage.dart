import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/default_menu_items.dart';

class OfflineDrinkOrderItemSnapshot {
  final String itemId;
  final String name;
  final String category;
  final int unitPrice;
  final int quantity;
  final String imageUrl;

  const OfflineDrinkOrderItemSnapshot({
    required this.itemId,
    required this.name,
    required this.category,
    required this.unitPrice,
    required this.quantity,
    required this.imageUrl,
  });

  OfflineDrinkOrderItemSnapshot copyWith({
    String? itemId,
    String? name,
    String? category,
    int? unitPrice,
    int? quantity,
    String? imageUrl,
  }) {
    return OfflineDrinkOrderItemSnapshot(
      itemId: itemId ?? this.itemId,
      name: name ?? this.name,
      category: category ?? this.category,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'name': name,
      'category': category,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'imageUrl': imageUrl,
    };
  }

  factory OfflineDrinkOrderItemSnapshot.fromJson(
      Map<String, dynamic> json,
      ) {
    return OfflineDrinkOrderItemSnapshot(
      itemId: json['itemId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      unitPrice: _readInt(json['unitPrice']),
      quantity: _readInt(json['quantity']),
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }
}

class OfflineDrinkOrder {
  final DateTime createdAt;
  final Map<String, int> items;
  final Map<String, OfflineDrinkOrderItemSnapshot>
  itemDetails;
  final int totalPrice;
  final String paymentMethod;

  const OfflineDrinkOrder({
    required this.createdAt,
    required this.items,
    required this.itemDetails,
    required this.totalPrice,
    required this.paymentMethod,
  });

  String itemName(String itemId) {
    return itemDetails[itemId]?.name ??
        _legacyItemName(itemId);
  }

  Map<String, dynamic> toJson() {
    return {
      'createdAt': createdAt.toIso8601String(),
      'items': items,
      'itemDetails': itemDetails.map(
            (key, value) => MapEntry(
          key,
          value.toJson(),
        ),
      ),
      'totalPrice': totalPrice,
      'paymentMethod': paymentMethod,
    };
  }

  factory OfflineDrinkOrder.fromJson(
      Map<String, dynamic> json,
      ) {
    final items = _readItems(json['items']);
    final details = _readItemDetails(
      json['itemDetails'],
      items,
    );

    return OfflineDrinkOrder(
      createdAt:
      DateTime.tryParse(
        json['createdAt'] as String? ?? '',
      ) ??
          DateTime.now(),
      items: items,
      itemDetails: details,
      totalPrice: _readInt(json['totalPrice']),
      paymentMethod:
      json['paymentMethod'] as String? ?? '',
    );
  }

  static Map<String, int> _readItems(dynamic rawItems) {
    final items = <String, int>{};

    if (rawItems is! Map) {
      return items;
    }

    rawItems.forEach((rawKey, rawValue) {
      final itemId = normalizeItemId(
        rawKey.toString(),
      );

      final quantity = _readInt(rawValue);

      if (itemId.isNotEmpty && quantity > 0) {
        items[itemId] = quantity;
      }
    });

    return items;
  }

  static Map<String, OfflineDrinkOrderItemSnapshot>
  _readItemDetails(
      dynamic rawDetails,
      Map<String, int> items,
      ) {
    final details =
    <String, OfflineDrinkOrderItemSnapshot>{};

    if (rawDetails is Map) {
      rawDetails.forEach((rawKey, rawValue) {
        if (rawValue is! Map) {
          return;
        }

        final itemId = normalizeItemId(
          rawKey.toString(),
        );

        final parsed =
        OfflineDrinkOrderItemSnapshot.fromJson(
          Map<String, dynamic>.from(rawValue),
        );

        details[itemId] = parsed.copyWith(
          itemId: itemId,
          quantity:
          items[itemId] ?? parsed.quantity,
        );
      });
    }

    for (final entry in items.entries) {
      if (details.containsKey(entry.key)) {
        continue;
      }

      details[entry.key] =
          _legacySnapshot(
            entry.key,
            entry.value,
          );
    }

    return details;
  }
}

class OfflineDrinkOrderStorage {
  static const String _cartKey =
      'drink_order_cart';

  static const String _historyKey =
      'drink_order_history';

  static Future<Map<String, int>> loadCart() async {
    final preferences =
    await SharedPreferences.getInstance();

    final encoded =
    preferences.getString(_cartKey);

    if (encoded == null) {
      return {};
    }

    try {
      final decoded = jsonDecode(encoded);

      if (decoded is! Map) {
        return {};
      }

      final cart = <String, int>{};

      decoded.forEach((rawKey, rawValue) {
        final itemId = normalizeItemId(
          rawKey.toString(),
        );

        final quantity = _readInt(rawValue);

        if (itemId.isNotEmpty && quantity > 0) {
          cart[itemId] = quantity;
        }
      });

      return cart;
    } catch (_) {
      return {};
    }
  }

  static Future<void> saveCart(
      Map<String, int> cart,
      ) async {
    final preferences =
    await SharedPreferences.getInstance();

    await preferences.setString(
      _cartKey,
      jsonEncode(cart),
    );
  }

  static Future<void> clearCart() async {
    final preferences =
    await SharedPreferences.getInstance();

    await preferences.remove(_cartKey);
  }

  static Future<List<OfflineDrinkOrder>>
  loadOrderHistory() async {
    final preferences =
    await SharedPreferences.getInstance();

    final encodedOrders =
        preferences.getStringList(_historyKey) ?? [];

    final orders = <OfflineDrinkOrder>[];

    for (final encoded in encodedOrders) {
      try {
        final decoded = jsonDecode(encoded);

        if (decoded is Map<String, dynamic>) {
          orders.add(
            OfflineDrinkOrder.fromJson(decoded),
          );
        } else if (decoded is Map) {
          orders.add(
            OfflineDrinkOrder.fromJson(
              Map<String, dynamic>.from(decoded),
            ),
          );
        }
      } catch (_) {
        // Bỏ qua bản ghi hỏng, giữ các bản ghi còn lại.
      }
    }

    orders.sort(
          (first, second) =>
          first.createdAt.compareTo(
            second.createdAt,
          ),
    );

    return orders;
  }

  static Future<void> saveOfflineOrder(
      OfflineDrinkOrder order,
      ) async {
    final orders = await loadOrderHistory();
    orders.add(order);

    final preferences =
    await SharedPreferences.getInstance();

    await preferences.setStringList(
      _historyKey,
      orders
          .map((item) => jsonEncode(item.toJson()))
          .toList(),
    );
  }
}

String normalizeItemId(String rawId) {
  final id = rawId.trim();

  if (id.isEmpty) {
    return '';
  }

  if (id.startsWith('default_')) {
    return id;
  }

  if (id.startsWith('mock:')) {
    return 'default_${id.substring(5)}';
  }

  if (id.startsWith('firebase:')) {
    return id.substring('firebase:'.length);
  }

  if (RegExp(r'^\d+$').hasMatch(id)) {
    return 'default_$id';
  }

  return id;
}

OfflineDrinkOrderItemSnapshot _legacySnapshot(
    String itemId,
    int quantity,
    ) {
  for (final item in defaultMenuItems) {
    if (item.id == itemId) {
      return OfflineDrinkOrderItemSnapshot(
        itemId: itemId,
        name: item.name,
        category: item.category,
        unitPrice: item.price,
        quantity: quantity,
        imageUrl: item.imageUrl,
      );
    }
  }

  return OfflineDrinkOrderItemSnapshot(
    itemId: itemId,
    name: 'Món đã xóa',
    category: 'Khác',
    unitPrice: 0,
    quantity: quantity,
    imageUrl: '',
  );
}

String _legacyItemName(String itemId) {
  return _legacySnapshot(itemId, 1).name;
}

int _readInt(dynamic value) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  if (value is String) {
    return int.tryParse(value) ?? 0;
  }

  return 0;
}