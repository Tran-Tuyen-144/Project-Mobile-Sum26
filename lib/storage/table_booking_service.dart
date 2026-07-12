import 'dart:async';

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

  TableBookingItem copyWith({String? status}) {
    return TableBookingItem(
      id: id,
      tableId: tableId,
      name: name,
      seats: seats,
      branch: branch,
      status: status ?? this.status,
    );
  }
}

class TableBookingService {
  static final Map<String, List<TableBookingItem>> _tablesByBranch = {};
  static final Map<String, StreamController<List<TableBookingItem>>>
  _controllers = {};

  static void initializeTables() {
    const branches = ['PetHub Quận 1', 'PetHub Bình Thạnh', 'PetHub Thủ Đức'];

    for (final branch in branches) {
      _tablesByBranch.putIfAbsent(
        branch,
        () => [
          _table(branch, 1, 'Bàn A1', 2, 'available'),
          _table(branch, 2, 'Bàn A2', 2, 'booked'),
          _table(branch, 3, 'Bàn B1', 4, 'available'),
          _table(branch, 4, 'Bàn B2', 4, 'available'),
          _table(branch, 5, 'Bàn C1', 6, 'available'),
          _table(branch, 6, 'Bàn C2', 6, 'available'),
        ],
      );
      _emit(branch);
    }
  }

  static Stream<List<TableBookingItem>> tableStream(String branch) {
    initializeTables();
    final controller = _controllers.putIfAbsent(
      branch,
      () => StreamController<List<TableBookingItem>>.broadcast(),
    );

    Future.microtask(() => _emit(branch));
    return controller.stream;
  }

  static Future<void> bookTable(String branch, int tableId) async {
    initializeTables();
    final tables = _tablesByBranch[branch] ?? [];
    _tablesByBranch[branch] = tables.map((table) {
      return table.tableId == tableId
          ? table.copyWith(status: 'booked')
          : table;
    }).toList();
    _emit(branch);
  }

  static TableBookingItem _table(
    String branch,
    int tableId,
    String name,
    int seats,
    String status,
  ) {
    return TableBookingItem(
      id: '${branch}_$tableId',
      tableId: tableId,
      name: name,
      seats: seats,
      branch: branch,
      status: status,
    );
  }

  static void _emit(String branch) {
    final controller = _controllers[branch];
    if (controller == null || controller.isClosed) return;
    controller.add(List.unmodifiable(_tablesByBranch[branch] ?? []));
  }
}
