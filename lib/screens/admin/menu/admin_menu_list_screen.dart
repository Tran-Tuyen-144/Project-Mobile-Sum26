import 'package:flutter/material.dart';

import '../../../../storage/menu_catalog_storage.dart';
import '../../../../theme/app_colors.dart';
import 'admin_menu_form_screen.dart';

class AdminMenuListScreen extends StatefulWidget {
  const AdminMenuListScreen({super.key});

  @override
  State<AdminMenuListScreen> createState() => _AdminMenuListScreenState();
}

class _AdminMenuListScreenState extends State<AdminMenuListScreen> {
  final List<Map<String, dynamic>> _menuItems = [];
  bool _loading = true;

  // Danh sách các tab
  final List<String> _tabs = ["Tất cả", "Cafe", "Sinh tố", "Trà", "Bánh ngọt"];

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    final items = await MenuCatalogStorage.load();
    if (!mounted) return;
    setState(() {
      _menuItems
        ..clear()
        ..addAll(items);
      _loading = false;
    });
  }

  Future<void> _saveMenu() => MenuCatalogStorage.save(_menuItems);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            "Quản lý thực đơn",
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black87),
          bottom: TabBar(
            isScrollable: true,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSoft,
            indicatorColor: AppColors.primary,
            tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primary,
          onPressed: () async {
            final newItem = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminMenuFormScreen()),
            );
            if (newItem != null) {
              setState(() => _menuItems.add(newItem));
              await _saveMenu();
            }
          },
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: _tabs.map((tab) => _buildFilteredList(tab)).toList(),
              ),
      ),
    );
  }

  // Hàm lọc danh sách hiển thị cho từng Tab
  Widget _buildFilteredList(String category) {
    final filtered = category == "Tất cả"
        ? _menuItems
        : _menuItems.where((item) => item['category'] == category).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          "Chưa có món nào trong mục $category",
          style: const TextStyle(color: AppColors.textSoft),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        // Tìm index gốc để xóa đúng phần tử trong danh sách chính
        final originalIndex = _menuItems.indexOf(item);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          color: AppColors.primarySoft.withValues(alpha: 0.1),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _categoryColor(item['category'] as String?),
              child: Icon(
                _categoryIcon(item['category'] as String?),
                color: AppColors.textDark,
              ),
            ),
            title: Text(
              item['name'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("${item['price']} VNĐ"),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () async {
                setState(() => _menuItems.removeAt(originalIndex));
                await _saveMenu();
              },
            ),
          ),
        );
      },
    );
  }

  IconData _categoryIcon(String? category) => switch (category) {
    'Cafe' => Icons.coffee_rounded,
    'Sinh tố' => Icons.blender_rounded,
    'Trà' => Icons.emoji_food_beverage_rounded,
    'Bánh ngọt' => Icons.cake_rounded,
    _ => Icons.restaurant_rounded,
  };

  Color _categoryColor(String? category) => switch (category) {
    'Cafe' => Colors.brown.shade100,
    'Sinh tố' => Colors.green.shade100,
    'Trà' => Colors.orange.shade100,
    'Bánh ngọt' => Colors.pink.shade100,
    _ => AppColors.primarySoft,
  };
}
