import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/default_menu_items.dart';
import '../models/menu_item_data.dart';

class MenuRepository {
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static final CollectionReference<Map<String, dynamic>>
  _menuCollection = _firestore.collection('menu_items');

  static final DocumentReference<Map<String, dynamic>>
  _seedMarker = _firestore
      .collection('app_config')
      .doc('menu_seed_v1');

  static Stream<List<MenuItemData>> watchAllMenuItems() {
    return _menuCollection.snapshots().map((snapshot) {
      final items = snapshot.docs.map((document) {
        return MenuItemData.fromMap(
          document.id,
          document.data(),
        );
      }).toList();

      items.sort(_compareMenuItems);
      return items;
    });
  }

  static Stream<List<MenuItemData>> watchCustomerMenuItems() {
    return watchAllMenuItems().map((items) {
      return items
          .where((item) => item.isActive)
          .toList(growable: false);
    });
  }

  static List<String> categoriesFrom(
      List<MenuItemData> items, {
        bool includeAll = true,
      }) {
    final categories = LinkedHashSet<String>();

    for (final item in items) {
      final category = item.category.trim();

      if (category.isNotEmpty) {
        categories.add(category);
      }
    }

    return [
      if (includeAll) 'Tất cả',
      ...categories,
    ];
  }

  static Future<void> seedDefaultMenuIfNeeded() async {
    final references = defaultMenuItems
        .map((item) => _menuCollection.doc(item.id))
        .toList();

    await _firestore.runTransaction((transaction) async {
      final markerSnapshot =
      await transaction.get(_seedMarker);

      final markerData = markerSnapshot.data();

      if (markerSnapshot.exists &&
          markerData?['completed'] == true) {
        return;
      }

      final itemSnapshots =
      <DocumentSnapshot<Map<String, dynamic>>>[];

      for (final reference in references) {
        itemSnapshots.add(
          await transaction.get(reference),
        );
      }

      for (var index = 0;
      index < defaultMenuItems.length;
      index++) {
        final item = defaultMenuItems[index];
        final snapshot = itemSnapshots[index];

        // Không ghi đè món đã tồn tại.
        if (snapshot.exists) {
          continue;
        }

        transaction.set(
          references[index],
          _createData(
            item: item,
            source: MenuItemSource.seed,
          ),
        );
      }

      transaction.set(_seedMarker, {
        'completed': true,
        'version': 1,
        'completedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  static Future<String> addItem({
    required String name,
    required String description,
    required String category,
    required int price,
    required String imageUrl,
    required bool isActive,
  }) async {
    final reference = _menuCollection.doc();

    final normalizedCategory = category.trim();

    await reference.set({
      'name': name.trim(),
      'description': description.trim(),
      'category': normalizedCategory,
      'price': price,
      'image': imageUrl.trim(),
      'iconKey':
      MenuItemData.defaultIconKeyForCategory(
        normalizedCategory,
      ),
      'colorValue':
      MenuItemData.defaultColorValueForCategory(
        normalizedCategory,
      ),
      'source': MenuItemSource.admin.name,
      'isActive': isActive,
      'sortOrder': DateTime.now().millisecondsSinceEpoch,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return reference.id;
  }

  static Future<void> updateItem({
    required String itemId,
    required String name,
    required String description,
    required String category,
    required int price,
    required String imageUrl,
    required String iconKey,
    required int colorValue,
    required bool isActive,
  }) async {
    await _menuCollection.doc(itemId).update({
      'name': name.trim(),
      'description': description.trim(),
      'category': category.trim(),
      'price': price,
      'image': imageUrl.trim(),
      'iconKey': iconKey,
      'colorValue': colorValue,
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> deleteItem(String itemId) async {
    await _menuCollection.doc(itemId).delete();
  }

  static Future<void> setItemActive({
    required String itemId,
    required bool isActive,
  }) async {
    await _menuCollection.doc(itemId).update({
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Map<String, dynamic> _createData({
    required MenuItemData item,
    required MenuItemSource source,
  }) {
    return {
      'name': item.name,
      'description': item.description,
      'category': item.category,
      'price': item.price,
      'image': item.imageUrl,
      'iconKey': item.iconKey,
      'colorValue': item.colorValue,
      'source': source.name,
      'isActive': item.isActive,
      'sortOrder': item.sortOrder,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static int _compareMenuItems(
      MenuItemData first,
      MenuItemData second,
      ) {
    final orderComparison =
    first.sortOrder.compareTo(second.sortOrder);

    if (orderComparison != 0) {
      return orderComparison;
    }

    return first.name
        .toLowerCase()
        .compareTo(second.name.toLowerCase());
  }
}