import 'package:flutter/material.dart';

enum MenuItemSource {
  seed,
  admin,
}

class MenuItemData {
  final String id;
  final String name;
  final String description;
  final String category;
  final int price;
  final String imageUrl;
  final String iconKey;
  final int colorValue;
  final MenuItemSource source;
  final bool isActive;
  final int sortOrder;

  const MenuItemData({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.iconKey,
    required this.colorValue,
    required this.source,
    required this.isActive,
    required this.sortOrder,
  });

  factory MenuItemData.fromMap(
      String id,
      Map<String, dynamic> data,
      ) {
    final category = _readString(
      data['category'],
      fallback: 'Khác',
    );

    return MenuItemData(
      id: id,
      name: _readString(
        data['name'],
        fallback: 'Món chưa đặt tên',
      ),
      description: _readString(data['description']),
      category: category,
      price: _readInt(data['price']),
      imageUrl: _readString(
        data['image'] ?? data['imageUrl'],
      ),
      iconKey: _readString(
        data['iconKey'],
        fallback: defaultIconKeyForCategory(category),
      ),
      colorValue: _readInt(
        data['colorValue'],
        fallback: defaultColorValueForCategory(category),
      ),
      source: data['source'] == 'seed'
          ? MenuItemSource.seed
          : MenuItemSource.admin,
      isActive: data['isActive'] is bool
          ? data['isActive'] as bool
          : true,
      sortOrder: _readInt(
        data['sortOrder'],
        fallback: 2147483647,
      ),
    );
  }

  IconData get icon {
    switch (iconKey) {
      case 'coffee':
        return Icons.coffee_rounded;

      case 'tea':
        return Icons.emoji_food_beverage_rounded;

      case 'drink':
        return Icons.local_drink_rounded;

      case 'blender':
        return Icons.blender_rounded;

      case 'eco':
        return Icons.eco_rounded;

      case 'cake':
        return Icons.cake_rounded;

      case 'cookie':
        return Icons.cookie_rounded;

      case 'water':
        return Icons.water_drop_rounded;

      case 'cafe':
      default:
        return Icons.local_cafe_rounded;
    }
  }

  Color get color => Color(colorValue);

  String get sourceLabel {
    return source == MenuItemSource.seed
        ? 'Món mặc định'
        : 'Món Admin thêm';
  }

  static String defaultIconKeyForCategory(String category) {
    switch (category.trim().toLowerCase()) {
      case 'cafe':
      case 'cà phê':
        return 'cafe';

      case 'trà':
        return 'tea';

      case 'sinh tố':
        return 'blender';

      case 'bánh ngọt':
        return 'cake';

      default:
        return 'drink';
    }
  }

  static int defaultColorValueForCategory(String category) {
    switch (category.trim().toLowerCase()) {
      case 'cafe':
      case 'cà phê':
        return 0xFFDDF6FF;

      case 'trà':
        return 0xFFFFF0D9;

      case 'sinh tố':
        return 0xFFE0F7E9;

      case 'bánh ngọt':
        return 0xFFF0E8FF;

      default:
        return 0xFFE8F7FF;
    }
  }

  static String _readString(
      dynamic value, {
        String fallback = '',
      }) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }

    return fallback;
  }

  static int _readInt(
      dynamic value, {
        int fallback = 0,
      }) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      final normalized = value.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );

      return int.tryParse(normalized) ?? fallback;
    }

    return fallback;
  }
}