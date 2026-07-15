import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../storage/booking_history_storage.dart';
import '../../../storage/table_booking_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/section_title.dart';
import '../../../widgets/soft_card.dart';
import '../booking_confirm/booking_confirm_data.dart';
import 'customer_drink_order_screen.dart';
import '../petprofile/pet_list_screen.dart';
import '../../admin/table/admin_table_form_screen.dart';

class CustomerBookingScreen extends StatefulWidget {
  final String petName;

  const CustomerBookingScreen({super.key, this.petName = 'Thú cưng của bạn'});

  @override
  State<CustomerBookingScreen> createState() => _CustomerBookingScreenState();
}

class _CustomerBookingScreenState extends State<CustomerBookingScreen> {
  int selectedBranch = 0;
  int selectedGuest = 2;
  int? selectedTable;
  String? selectedTableName;
  Timer? _clockTimer;
  DateTime _now = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 30);
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  List<BookingHistoryItem> _bookingHistory = [];
  final Set<String> _locallyBookedTables = {};

  final branches = const [
    'PetHub Quận 1',
    'PetHub Bình Thạnh',
    'PetHub Thủ Đức',
  ];

  final tables = const [
    _TableItem(id: 1, name: 'Bàn A1', seats: 2, status: TableStatus.available),
    _TableItem(id: 2, name: 'Bàn A2', seats: 2, status: TableStatus.available),
    _TableItem(id: 3, name: 'Bàn B1', seats: 4, status: TableStatus.available),
    _TableItem(id: 4, name: 'Bàn B2', seats: 4, status: TableStatus.available),
    _TableItem(id: 5, name: 'Bàn C1', seats: 6, status: TableStatus.available),
    _TableItem(id: 6, name: 'Bàn C2', seats: 6, status: TableStatus.available),
  ];

  @override
  void initState() {
    super.initState();
    TableBookingService.initializeTables();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _now = DateTime.now();
      });
    });
    _loadBookingHistory();
    unawaited(_syncBookingHistory());
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _customerNameController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadBookingHistory() async {
    final history = await BookingHistoryStorage.loadBookings();
    if (!mounted) return;
    setState(() {
      _bookingHistory = history;
      _locallyBookedTables
        ..clear()
        ..addAll(
          history
              .where((booking) => booking.status != BookingStatus.cancelled)
              .map(
                (booking) => _localBookingKey(booking.branch, booking.tableId),
              ),
        );
    });
  }

  Future<void> _syncBookingHistory() async {
    await BookingHistoryStorage.syncLocalBookings();
    await _loadBookingHistory();
  }

  String _bookingId() {
    return DateTime.now().microsecondsSinceEpoch.toString();
  }

  List<TableBookingItem> _localTableItems(String branch) {
    return tables
        .map(
          (item) => TableBookingItem(
            id: '${branch}_${item.id}',
            tableId: item.id,
            name: item.name,
            seats: item.seats,
            branch: branch,
            status: item.status == TableStatus.booked ? 'booked' : 'available',
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final selectedDayText = _bookingDateValue(_selectedDate);
    final selectedTimeText = _bookingTimeValue(_selectedTime);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BookingHeader(petName: widget.petName),

          const SizedBox(height: 12),

          _LiveClockCard(now: _now),

          const SizedBox(height: 24),

          const SectionTitle(title: 'Chọn chi nhánh'),

          const SizedBox(height: 12),

          _BranchSelector(
            branches: branches,
            selectedIndex: selectedBranch,
            onSelected: (index) {
              setState(() {
                selectedBranch = index;
                selectedTable = null;
                selectedTableName = null;
              });
            },
          ),

          const SizedBox(height: 24),

          SectionTitle(
            title: 'Chọn bàn',
            actionText: 'Thêm bàn',
            onActionTap: _addTableForBranch,
          ),

          const SizedBox(height: 12),

          _TableLegend(),

          const SizedBox(height: 12),

          StreamBuilder<List<TableBookingItem>>(
            stream: TableBookingService.tableStream(branches[selectedBranch]),
            builder: (context, snapshot) {
              final isLoading =
                  snapshot.connectionState == ConnectionState.waiting;
              final branch = branches[selectedBranch];
              final tableItems = snapshot.data?.isNotEmpty == true
                  ? snapshot.data!
                  : _localTableItems(branch);
              final displayTables = tableItems
                  .map(
                    (table) =>
                        _locallyBookedTables.contains(
                          _localBookingKey(branch, table.tableId),
                        )
                        ? table.copyWith(status: 'booked')
                        : table,
                  )
                  .toList();
              final availableCount = displayTables
                  .where(
                    (table) => !table.isBooked && table.seats >= selectedGuest,
                  )
                  .length;
              final allTablesBooked = displayTables.every(
                (table) => table.isBooked,
              );

              return isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : Column(
                      children: [
                        if (availableCount == 0) ...[
                          _TableUnavailableNotice(
                            message: allTablesBooked
                                ? 'Chi nhánh này đã hết bàn trống.'
                                : 'Không còn bàn phù hợp cho $selectedGuest khách.',
                          ),
                          const SizedBox(height: 12),
                        ],
                        _TableGrid(
                          tables: displayTables,
                          guests: selectedGuest,
                          selectedTable: selectedTable,
                          onSelected: (table) {
                            if (table.isBooked || table.seats < selectedGuest) {
                              return;
                            }

                            setState(() {
                              selectedTable = table.tableId;
                              selectedTableName = table.name;
                            });
                          },
                        ),
                      ],
                    );
            },
          ),

          const SizedBox(height: 26),

          const SectionTitle(title: 'Thông tin đặt bàn'),

          const SizedBox(height: 12),

          _BookingInputPanel(
            selectedDayText: selectedDayText,
            selectedTimeText: selectedTimeText,
            guests: selectedGuest,
            onPickDate: _pickBookingDate,
            onPickTime: _pickBookingTime,
            onMinusGuest: () {
              if (selectedGuest > 1) {
                setState(() {
                  selectedGuest--;
                });
              }
            },
            onPlusGuest: () {
              if (selectedGuest < 10) {
                setState(() {
                  selectedGuest++;
                  final selectedSeats = _selectedTableSeats();
                  if (selectedSeats != null && selectedGuest > selectedSeats) {
                    selectedTable = null;
                    selectedTableName = null;
                  }
                });
              }
            },
          ),

          const SizedBox(height: 24),

          const SectionTitle(title: 'Thông tin liên hệ'),

          const SizedBox(height: 12),

          _ContactForm(
            nameController: _customerNameController,
            phoneController: _phoneController,
            noteController: _noteController,
          ),

          const SizedBox(height: 26),

          _BookingSummary(
            branch: branches[selectedBranch],
            day: selectedDayText,
            time: selectedTimeText,
            guests: selectedGuest,
            tableName: selectedTable == null
                ? 'Chưa chọn bàn'
                : selectedTableName ?? 'Bàn $selectedTable',
          ),

          const SizedBox(height: 18),

          if (_bookingHistory.isNotEmpty) ...[
            SectionTitle(
              title: 'Lịch sử đặt bàn',
              actionText: '${_bookingHistory.length} lịch',
            ),
            const SizedBox(height: 12),
            _BookingHistoryList(
              bookings: _bookingHistory.take(3).toList(),
              onCancel: (booking) async {
                await BookingHistoryStorage.updateStatus(
                  booking.id,
                  BookingStatus.cancelled,
                );
                await TableBookingService.releaseTable(
                  booking.branch,
                  booking.tableId,
                );
                await _loadBookingHistory();
              },
            ),
            const SizedBox(height: 18),
          ],
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: selectedTable == null
                  ? null
                  : () {
                      final customerName = _customerNameController.text.trim();

                      if (customerName.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Vui lòng nhập tên khách hàng.'),
                          ),
                        );
                        return;
                      }

                      final tableName =
                          selectedTableName ?? 'Bàn $selectedTable';

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PetListScreen(
                            bookingData: BookingConfirmData(
                              petNames: const [],
                              petStatus: '',
                              customerName: customerName,
                              branch: branches[selectedBranch],
                              day: selectedDayText,
                              time: selectedTimeText,
                              guests: selectedGuest,
                              tableName: tableName,
                            ),
                          ),
                        ),
                      );
                    },
              icon: const Icon(Icons.pets_rounded),
              label: const Text(
                'Đặt Pet Online',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CustomerDrinkOrderScreen(),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2D6A8D),
                side: const BorderSide(color: Color(0xFF8ECAE6), width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: const Icon(Icons.local_cafe_rounded),
              label: const Text(
                'Gọi nước trước',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: selectedTable == null
                  ? null
                  : () async {
                      final localContext = context;
                      final phone = _phoneController.text.trim();
                      if (!_isValidPhone(phone)) {
                        ScaffoldMessenger.of(localContext).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Số điện thoại không hợp lệ. Vui lòng nhập đủ 10 số.',
                            ),
                          ),
                        );
                        return;
                      }
                      final tableName =
                          selectedTableName ?? 'Bàn $selectedTable';
                      final branch = branches[selectedBranch];
                      final tableId = selectedTable!;
                      final now = DateTime.now();
                      var bookingStatus = BookingStatus.confirmed;
                      final bookingData = BookingConfirmData(
                        branch: branch,
                        day: selectedDayText,
                        time: selectedTimeText,
                        guests: selectedGuest,
                        tableName: tableName,
                      );

                      try {
                        await TableBookingService.bookTable(branch, tableId);
                      } on StateError {
                        if (localContext.mounted) {
                          ScaffoldMessenger.of(localContext).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Bàn này vừa được đặt. Vui lòng chọn bàn khác.',
                              ),
                            ),
                          );
                        }
                        return;
                      } catch (error) {
                        bookingStatus = BookingStatus.pendingSync;
                      }

                      final booking = BookingHistoryItem(
                        id: _bookingId(),
                        createdAt: now,
                        branch: branch,
                        day: selectedDayText,
                        time: selectedTimeText,
                        guests: selectedGuest,
                        tableId: tableId,
                        tableName: tableName,
                        customerName: _customerNameController.text.trim(),
                        phone: phone,
                        note: _noteController.text.trim(),
                        status: bookingStatus,
                      );
                      final uploaded = await BookingHistoryStorage.saveBooking(
                        booking,
                      );
                      if (!uploaded) {
                        bookingStatus = BookingStatus.pendingSync;
                        await BookingHistoryStorage.updateStatus(
                          booking.id,
                          bookingStatus,
                          syncRemote: false,
                        );
                      }

                      await _loadBookingHistory();

                      if (!localContext.mounted) return;
                      if (bookingStatus == BookingStatus.pendingSync) {
                        ScaffoldMessenger.of(localContext).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Đã lưu lịch đặt bàn trên máy. Firestore sẽ cần kiểm tra lại kết nối/quyền ghi.',
                            ),
                          ),
                        );
                      }
                      setState(() {
                        _locallyBookedTables.add(
                          _localBookingKey(branch, tableId),
                        );
                        selectedTable = null;
                        selectedTableName = null;
                      });
                      localContext.push('/booking-confirm', extra: bookingData);
                    },
              icon: const Icon(Icons.check_circle_rounded),
              label: const Text('Xác nhận đặt bàn'),
            ),
          ),
        ],
      ),
    );
  }

  int? _selectedTableSeats() {
    final tableId = selectedTable;
    if (tableId == null) return null;

    final liveTables = TableBookingService.tablesFor(branches[selectedBranch]);
    for (final table in liveTables) {
      if (table.tableId == tableId) return table.seats;
    }

    for (final table in tables) {
      if (table.id == tableId) return table.seats;
    }
    return null;
  }

  Future<void> _addTableForBranch() async {
    final data = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const AdminTableFormScreen()),
    );
    if (data == null) return;
    await TableBookingService.addTable(
      branch: branches[selectedBranch],
      name: data['name'] as String? ?? '',
      seats: int.tryParse(data['seats']?.toString() ?? '') ?? 2,
    );
  }

  String _localBookingKey(String branch, int tableId) {
    return '$branch-$tableId';
  }

  bool _isValidPhone(String phone) {
    return RegExp(r'^\d{10}$').hasMatch(phone);
  }

  Future<void> _pickBookingDate() async {
    final today = DateTime(_now.year, _now.month, _now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(today) ? today : _selectedDate,
      firstDate: today,
      lastDate: today.add(const Duration(days: 45)),
      helpText: 'Chọn ngày đặt bàn',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;
    setState(() {
      _selectedDate = DateTime(picked.year, picked.month, picked.day);
    });
  }

  Future<void> _pickBookingTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      helpText: 'Chọn giờ đặt bàn',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;
    setState(() {
      _selectedTime = picked;
    });
  }

  String _bookingDateValue(DateTime date) {
    final today = DateTime(_now.year, _now.month, _now.day);
    final normalized = DateTime(date.year, date.month, date.day);
    final label = normalized == today ? 'Hôm nay' : _weekdayLabel(date.weekday);
    return '$label, ${_twoDigits(date.day)}/${_twoDigits(date.month)}/${date.year}';
  }

  String _bookingTimeValue(TimeOfDay time) {
    return '${_twoDigits(time.hour)}:${_twoDigits(time.minute)}';
  }

  String _weekdayLabel(int weekday) {
    return switch (weekday) {
      DateTime.monday => 'Thứ 2',
      DateTime.tuesday => 'Thứ 3',
      DateTime.wednesday => 'Thứ 4',
      DateTime.thursday => 'Thứ 5',
      DateTime.friday => 'Thứ 6',
      DateTime.saturday => 'Thứ 7',
      DateTime.sunday => 'CN',
      _ => '',
    };
  }

  String _twoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }
}

class _BookingHeader extends StatelessWidget {
  final String petName;

  const _BookingHeader({required this.petName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1E4),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFFFD7B8)),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.event_seat_rounded,
              color: AppColors.primary,
              size: 34,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đặt bàn trước',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  'Thú cưng đã chọn: $petName',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Chọn chi nhánh, giờ ghé và chiếc bàn ấm áp cho bạn cùng bé pet.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveClockCard extends StatelessWidget {
  final DateTime now;

  const _LiveClockCard({required this.now});

  @override
  Widget build(BuildContext context) {
    final timeText =
        '${_twoDigits(now.hour)}:${_twoDigits(now.minute)}:${_twoDigits(now.second)}';
    final dateText =
        '${_weekdayLabel(now.weekday)}, ${_twoDigits(now.day)}/${_twoDigits(now.month)}/${now.year}';

    return SoftCard(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.primarySoft,
            child: Icon(Icons.schedule_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timeText,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(dateText, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _weekdayLabel(int weekday) {
    return switch (weekday) {
      DateTime.monday => 'Thứ 2',
      DateTime.tuesday => 'Thứ 3',
      DateTime.wednesday => 'Thứ 4',
      DateTime.thursday => 'Thứ 5',
      DateTime.friday => 'Thứ 6',
      DateTime.saturday => 'Thứ 7',
      DateTime.sunday => 'Chủ nhật',
      _ => '',
    };
  }

  String _twoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }
}

class _ContactForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController noteController;

  const _ContactForm({
    required this.nameController,
    required this.phoneController,
    required this.noteController,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: const Color(0xFFFFFCF8),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          TextField(
            controller: nameController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white,
              labelText: 'Tên khách',
              hintText: 'Ví dụ: Nguyễn Hiếu',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white,
              labelText: 'Số điện thoại',
              hintText: 'Nhân viên dùng để xác nhận lịch',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: noteController,
            minLines: 2,
            maxLines: 3,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white,
              labelText: 'Ghi chú',
              hintText: 'Ví dụ: có bé mèo, cần bàn yên tĩnh...',
              prefixIcon: Icon(Icons.note_alt_outlined),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingInputPanel extends StatelessWidget {
  final String selectedDayText;
  final String selectedTimeText;
  final int guests;
  final VoidCallback onPickDate;
  final VoidCallback onPickTime;
  final VoidCallback onMinusGuest;
  final VoidCallback onPlusGuest;

  const _BookingInputPanel({
    required this.selectedDayText,
    required this.selectedTimeText,
    required this.guests,
    required this.onPickDate,
    required this.onPickTime,
    required this.onMinusGuest,
    required this.onPlusGuest,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: const Color(0xFFFFFCF8),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _PickerTile(
                  icon: Icons.calendar_month_rounded,
                  label: 'Ngày',
                  value: selectedDayText,
                  color: AppColors.sky,
                  onTap: onPickDate,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PickerTile(
                  icon: Icons.watch_later_rounded,
                  label: 'Giờ',
                  value: selectedTimeText,
                  color: AppColors.peach,
                  onTap: onPickTime,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFFE1C8)),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.mint,
                  child: Icon(Icons.groups_rounded, color: AppColors.textDark),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Số lượng khách',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$guests khách',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Giảm khách',
                  onPressed: onMinusGuest,
                  icon: const Icon(Icons.remove_circle_outline_rounded),
                ),
                IconButton(
                  tooltip: 'Tăng khách',
                  onPressed: onPlusGuest,
                  icon: const Icon(
                    Icons.add_circle_rounded,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _PickerTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          height: 118,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFFE1C8)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: color,
                child: Icon(icon, color: AppColors.textDark),
              ),
              const Spacer(),
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 4),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 15,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingHistoryList extends StatelessWidget {
  final List<BookingHistoryItem> bookings;
  final ValueChanged<BookingHistoryItem> onCancel;

  const _BookingHistoryList({required this.bookings, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: bookings.map((booking) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SoftCard(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: AppColors.peach,
                      child: Icon(
                        Icons.event_available_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${booking.tableName} • ${booking.branch}',
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${booking.day} lúc ${booking.time} • ${booking.guests} khách',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    _StatusPill(status: booking.status),
                  ],
                ),
                if (booking.customerName.isNotEmpty ||
                    booking.phone.isNotEmpty ||
                    booking.note.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    [
                      if (booking.customerName.isNotEmpty)
                        'Khách: ${booking.customerName}',
                      if (booking.phone.isNotEmpty) 'SĐT: ${booking.phone}',
                      if (booking.note.isNotEmpty) 'Ghi chú: ${booking.note}',
                    ].join(' • '),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                if (booking.status != BookingStatus.cancelled) ...[
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => onCancel(booking),
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Hủy lịch này'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final BookingStatus status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status == BookingStatus.confirmed
        ? AppColors.mint
        : status == BookingStatus.cancelled
        ? const Color(0xFFE5E0DC)
        : AppColors.sky;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        status.label,
        style: const TextStyle(
          color: AppColors.textDark,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _BranchSelector extends StatelessWidget {
  final List<String> branches;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _BranchSelector({
    required this.branches,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(branches.length, (index) {
        final isSelected = selectedIndex == index;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SoftCard(
            color: isSelected ? const Color(0xFFFFE8D6) : Colors.white,
            onTap: () => onSelected(index),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: isSelected ? Colors.white : AppColors.peach,
                  child: Icon(
                    Icons.storefront_rounded,
                    color: isSelected ? AppColors.primary : AppColors.textDark,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        branches[index],
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        index == 0
                            ? 'Cafe mèo • Còn nhiều bàn'
                            : index == 1
                            ? 'Cafe cún • Không gian sân vườn'
                            : 'Pet cafe & spa • Gần trường đại học',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),

                Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.circle_outlined,
                  color: isSelected ? AppColors.primary : AppColors.textSoft,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _TableLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _LegendDot(color: AppColors.mint, text: 'Trống'),
        SizedBox(width: 14),
        _LegendDot(color: AppColors.primary, text: 'Đang chọn'),
        SizedBox(width: 14),
        _LegendDot(color: Colors.white, text: 'Đã đặt/full'),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String text;

  const _LegendDot({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(text, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _TableUnavailableNotice extends StatelessWidget {
  final String message;

  const _TableUnavailableNotice({required this.message});

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: Colors.white,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.peach,
            child: Icon(Icons.event_busy_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableGrid extends StatelessWidget {
  final List<TableBookingItem> tables;
  final int guests;
  final int? selectedTable;
  final ValueChanged<TableBookingItem> onSelected;

  const _TableGrid({
    required this.tables,
    required this.guests,
    required this.selectedTable,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: tables.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 104,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final table = tables[index];
        final isSelected = selectedTable == table.tableId;
        final isBooked = table.isBooked;
        final isFull = table.seats < guests;
        final isDisabled = isBooked || isFull;

        Color cardColor;

        if (isDisabled) {
          cardColor = Colors.white;
        } else if (isSelected) {
          cardColor = AppColors.primary;
        } else {
          cardColor = AppColors.mint;
        }

        return SoftCard(
          color: cardColor,
          onTap: isDisabled ? null : () => onSelected(table),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.table_restaurant_rounded,
                color: isSelected
                    ? Colors.white
                    : isDisabled
                    ? AppColors.textSoft
                    : AppColors.textDark,
              ),

              const Spacer(),

              Text(
                table.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  color: isSelected
                      ? Colors.white
                      : isDisabled
                      ? AppColors.textSoft
                      : AppColors.textDark,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                isBooked
                    ? 'Đã có khách đặt'
                    : isFull
                    ? 'Full với $guests khách'
                    : '${table.seats} ghế • Còn trống',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isSelected ? Colors.white70 : AppColors.textSoft,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BookingSummary extends StatelessWidget {
  final String branch;
  final String day;
  final String time;
  final int guests;
  final String tableName;

  const _BookingSummary({
    required this.branch,
    required this.day,
    required this.time,
    required this.guests,
    required this.tableName,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: AppColors.lavender,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tóm tắt đặt bàn',
            style: Theme.of(context).textTheme.titleMedium,
          ),

          const SizedBox(height: 12),

          _SummaryRow(label: 'Chi nhánh', value: branch),
          _SummaryRow(label: 'Thời gian', value: '$day • $time'),
          _SummaryRow(label: 'Số khách', value: '$guests khách'),
          _SummaryRow(label: 'Bàn', value: tableName),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: Row(
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum TableStatus { available, booked }

class _TableItem {
  final int id;
  final String name;
  final int seats;
  final TableStatus status;

  const _TableItem({
    required this.id,
    required this.name,
    required this.seats,
    required this.status,
  });
}
