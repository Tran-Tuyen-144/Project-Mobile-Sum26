import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Local menu catalog used by the admin.  It starts with a usable menu instead
/// of a blank screen and stays available without Firestore.
class MenuCatalogStorage {
  static const _key = 'admin_menu_catalog_v1';

  static Future<List<Map<String, dynamic>>> load() async {
    final raw = (await SharedPreferences.getInstance()).getString(_key);
    if (raw == null) return _defaults();
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    } catch (_) {
      return _defaults();
    }
  }

  static Future<void> save(List<Map<String, dynamic>> items) async {
    await (await SharedPreferences.getInstance()).setString(
      _key,
      jsonEncode(items),
    );
  }

  static List<Map<String, dynamic>> _defaults() => [
    _item('Cà phê sữa', 'Cafe', '35.000', 'Đậm vị, ít ngọt'),
    _item('Bạc xỉu', 'Cafe', '38.000', 'Nhiều sữa, thơm dịu'),
    _item('Trà đào cam sả', 'Trà', '45.000', 'Trà đào mát lạnh'),
    _item('Trà tắc', 'Trà', '30.000', 'Chua ngọt dễ uống'),
    _item('Sinh tố bơ', 'Sinh tố', '49.000', 'Bơ tươi, sánh mịn'),
    _item('Sinh tố xoài', 'Sinh tố', '45.000', 'Xoài chín tự nhiên'),
    _item('Bánh tiramisu', 'Bánh ngọt', '55.000', 'Mềm, thơm cà phê'),
  ];

  static Map<String, dynamic> _item(
    String name,
    String category,
    String price,
    String note,
  ) => {
    'name': name,
    'category': category,
    'price': price,
    'note': note,
    'image': 'assets/image/cat1.jpg',
  };
}
