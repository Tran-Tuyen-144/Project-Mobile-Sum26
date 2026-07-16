import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class TableBookingItem {
  final String id;
  final int tableId;
  final String name;
  final int seats;
  final String branch;
  final String status;

  const TableBookingItem({
    required this.id,
    required this.tableId,
    required this.name,
    required this.seats,
    required this.branch,
    required this.status,
  });

  bool get isBooked => status == 'booked';

  TableBookingItem copyWith({String? name, int? seats, String? status}) =>
      TableBookingItem(
        id: id,
        tableId: tableId,
        name: name ?? this.name,
        seats: seats ?? this.seats,
        branch: branch,
        status: status ?? this.status,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'tableId': tableId,
    'name': name,
    'seats': seats,
    'branch': branch,
    'status': status,
  };

  factory TableBookingItem.fromJson(Map<String, dynamic> json) =>
      TableBookingItem(
        id: json['id'] as String? ?? '',
        tableId: json['tableId'] as int? ?? 0,
        name: json['name'] as String? ?? 'Bàn',
        seats: json['seats'] as int? ?? 2,
        branch: json['branch'] as String? ?? '',
        status: json['status'] as String? ?? 'available',
      );
}

/// Single local source of truth for the customer booking grid and admin table
/// plan.  It intentionally works when Firestore permissions are unavailable.
class TableBookingService {
  static const branches = ['PetHub'];
  static const _storageKey = 'table_booking_map_v1';
  static final Map<String, List<TableBookingItem>> _tablesByBranch = {};
  static final Map<String, StreamController<List<TableBookingItem>>>
  _controllers = {};
  static bool _restoreStarted = false;

  static void initializeTables() {
    for (final branch in branches) {
      _tablesByBranch.putIfAbsent(branch, () => _defaultTables(branch));
      _emit(branch);
    }
    _restoreFromDisk();
  }

  static List<TableBookingItem> tablesFor(String branch) {
    initializeTables();
    _tablesByBranch.putIfAbsent(branch, () => _defaultTables(branch));
    return List.unmodifiable(_tablesByBranch[branch] ?? const []);
  }

  static Stream<List<TableBookingItem>> tableStream(String branch) {
    initializeTables();
    _tablesByBranch.putIfAbsent(branch, () => _defaultTables(branch));
    final controller = _controllers.putIfAbsent(
      branch,
      () => StreamController<List<TableBookingItem>>.broadcast(),
    );
    Future.microtask(() => _emit(branch));
    return controller.stream;
  }

  static Future<void> bookTable(String branch, int tableId) async {
    initializeTables();
    final tables = _tablesByBranch.putIfAbsent(
      branch,
      () => _defaultTables(branch),
    );
    if (!tables.any((table) => table.tableId == tableId && !table.isBooked)) {
      throw StateError('Bàn này không còn trống.');
    }
    _tablesByBranch[branch] = tables
        .map(
          (table) => table.tableId == tableId
              ? table.copyWith(status: 'booked')
              : table,
        )
        .toList();
    _emit(branch);
    await _persist();
  }

  static Future<void> releaseTable(String branch, int tableId) async {
    initializeTables();
    _tablesByBranch[branch] = (_tablesByBranch[branch] ?? [])
        .map(
          (table) => table.tableId == tableId
              ? table.copyWith(status: 'available')
              : table,
        )
        .toList();
    _emit(branch);
    await _persist();
  }

  static Future<void> addTable({
    required String branch,
    required String name,
    required int seats,
  }) async {
    initializeTables();
    final tables = _tablesByBranch[branch] ?? [];
    final nextId =
        tables.fold<int>(
          0,
          (max, table) => table.tableId > max ? table.tableId : max,
        ) +
        1;
    _tablesByBranch[branch] = [
      ...tables,
      _table(
        branch,
        nextId,
        name.trim().isEmpty ? 'Bàn $nextId' : name.trim(),
        seats < 1 ? 2 : seats,
        'available',
      ),
    ];
    _emit(branch);
    await _persist();
  }

  static Future<void> deleteTable(String branch, int tableId) async {
    initializeTables();
    _tablesByBranch[branch] = (_tablesByBranch[branch] ?? [])
        .where((item) => item.tableId != tableId)
        .toList();
    _emit(branch);
    await _persist();
  }

  static List<TableBookingItem> _defaultTables(String branch) => [
    _table(branch, 1, 'Bàn A1', 2, 'available'),
    _table(branch, 2, 'Bàn A2', 2, 'available'),
    _table(branch, 3, 'Bàn B1', 4, 'available'),
    _table(branch, 4, 'Bàn B2', 4, 'available'),
    _table(branch, 5, 'Bàn C1', 6, 'available'),
    _table(branch, 6, 'Bàn C2', 6, 'available'),
  ];

  static TableBookingItem _table(
    String branch,
    int tableId,
    String name,
    int seats,
    String status,
  ) => TableBookingItem(
    id: '${branch}_$tableId',
    tableId: tableId,
    name: name,
    seats: seats,
    branch: branch,
    status: status,
  );

  static void _restoreFromDisk() {
    if (_restoreStarted) return;
    _restoreStarted = true;
    Future(() async {
      try {
        final raw = (await SharedPreferences.getInstance()).getString(
          _storageKey,
        );
        if (raw == null) return;
        final values = jsonDecode(raw) as List<dynamic>;
        final restored = <String, List<TableBookingItem>>{};
        for (final value in values) {
          final item = TableBookingItem.fromJson(value as Map<String, dynamic>);
          if (item.branch.isNotEmpty && item.tableId > 0) {
            restored.putIfAbsent(item.branch, () => []).add(item);
          }
        }
        if (restored.isEmpty) return;
        _tablesByBranch.addAll(restored);
        for (final branch in _tablesByBranch.keys) {
          _emit(branch);
        }
      } catch (_) {
        // Defaults remain usable if old/corrupt local data cannot be decoded.
      }
    });
  }

  static Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final values = _tablesByBranch.values
        .expand((items) => items)
        .map((item) => item.toJson())
        .toList();
    await prefs.setString(_storageKey, jsonEncode(values));
  }

  static void _emit(String branch) {
    final controller = _controllers[branch];
    if (controller != null && !controller.isClosed)
      controller.add(List.unmodifiable(_tablesByBranch[branch] ?? []));
  }
}
