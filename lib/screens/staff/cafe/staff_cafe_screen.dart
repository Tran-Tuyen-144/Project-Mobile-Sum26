import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/app_colors.dart';
import '../../../widgets/section_title.dart';
import '../../../widgets/soft_card.dart';

class StaffCafeScreen extends StatefulWidget {
  const StaffCafeScreen({super.key});

  @override
  State<StaffCafeScreen> createState() => _StaffCafeScreenState();
}

class _StaffCafeScreenState extends State<StaffCafeScreen> {
  int _selectedIndex = 0;

  final TextEditingController _bookingNameController = TextEditingController();

  final TextEditingController _bookingPhoneController = TextEditingController();

  final TextEditingController _customerNameController = TextEditingController();

  final TextEditingController _customerPhoneController =
      TextEditingController();

  final TextEditingController _tableController = TextEditingController();

  final List<_CafeTask> _tasks = [
    _CafeTask(
      time: '07:30 - 08:00',
      title: 'Kiểm tra khu vực Café',
      description: 'Kiểm tra bàn ghế, khu vực khách ngồi và vệ sinh đầu ca.',
    ),
    _CafeTask(
      time: '08:00 - 08:30',
      title: 'Kiểm tra Menu',
      description:
          'Kiểm tra món còn phục vụ, món đã hết và nguyên liệu trong ngày.',
    ),
    _CafeTask(
      time: '08:30 - 11:30',
      title: 'Tiếp nhận khách và gọi món',
      description: 'Tra cứu đặt bàn, xác nhận khách đến và tạo đơn gọi món.',
    ),
    _CafeTask(
      time: '11:30 - 12:00',
      title: 'Kiểm tra khu vực Pet',
      description: 'Kiểm tra nước uống, đồ chơi và tình trạng khu vực Pet.',
    ),
    _CafeTask(
      time: '14:30 - 15:00',
      title: 'Kiểm kê cuối ca',
      description:
          'Kiểm tra nguyên liệu và bàn giao công việc cho ca tiếp theo.',
    ),
  ];

  final List<_CafeMenuItem> _menuItems = [
    _CafeMenuItem(
      id: 'MN001',
      name: 'Cà phê sữa',
      category: 'Cà phê',
      price: 35000,
      icon: Icons.local_cafe_rounded,
      color: AppColors.peach,
    ),
    _CafeMenuItem(
      id: 'MN002',
      name: 'Cà phê đen',
      category: 'Cà phê',
      price: 30000,
      icon: Icons.coffee_rounded,
      color: AppColors.peach,
    ),
    _CafeMenuItem(
      id: 'MN003',
      name: 'Matcha Latte',
      category: 'Đồ uống',
      price: 45000,
      icon: Icons.emoji_food_beverage_rounded,
      color: AppColors.mint,
    ),
    _CafeMenuItem(
      id: 'MN004',
      name: 'Trà đào',
      category: 'Đồ uống',
      price: 40000,
      icon: Icons.local_drink_rounded,
      color: AppColors.sky,
    ),
    _CafeMenuItem(
      id: 'MN005',
      name: 'Bánh Tiramisu',
      category: 'Bánh ngọt',
      price: 45000,
      icon: Icons.cake_rounded,
      color: AppColors.lavender,
    ),
    _CafeMenuItem(
      id: 'MN006',
      name: 'Bánh quy hình Pet',
      category: 'Bánh ngọt',
      price: 30000,
      icon: Icons.cookie_rounded,
      color: AppColors.primarySoft,
    ),
  ];

  final List<_CafeBill> _bills = [];

  _BookingSummary? _bookingSummary;

  String _selectedMenuCategory = 'Tất cả';

  final List<String> _menuCategories = const [
    'Tất cả',
    'Cà phê',
    'Đồ uống',
    'Bánh ngọt',
  ];

  int get _completedTaskCount {
    return _tasks.where((task) => task.isCompleted).length;
  }

  int get _remainingTaskCount {
    return _tasks.length - _completedTaskCount;
  }

  double get _taskProgress {
    if (_tasks.isEmpty) return 0;

    return _completedTaskCount / _tasks.length;
  }

  int get _orderTotal {
    return _menuItems.fold(
      0,
      (total, item) => total + item.price * item.quantity,
    );
  }

  List<_CafeMenuItem> get _selectedOrderItems {
    return _menuItems.where((item) => item.quantity > 0).toList();
  }

  @override
  void dispose() {
    _bookingNameController.dispose();
    _bookingPhoneController.dispose();
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _tableController.dispose();

    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _openTaskList() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final completed = _tasks.where((task) => task.isCompleted).length;

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.78,
              minChildSize: 0.55,
              maxChildSize: 0.94,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: AppColors.primarySoft,
                            child: Icon(
                              Icons.task_alt_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Công việc hôm nay',
                                  style: TextStyle(
                                    color: AppColors.textDark,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 19,
                                  ),
                                ),
                                Text(
                                  'Đã hoàn thành $completed/${_tasks.length}',
                                  style: const TextStyle(
                                    color: AppColors.textSoft,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.pop(bottomSheetContext);
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: _tasks.isEmpty ? 0 : completed / _tasks.length,
                          minHeight: 9,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
                        itemCount: _tasks.length,
                        itemBuilder: (context, index) {
                          final task = _tasks[index];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: SoftCard(
                              color: Colors.white,
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Checkbox(
                                    value: task.isCompleted,
                                    shape: const CircleBorder(),
                                    activeColor: AppColors.primary,
                                    onChanged: (value) {
                                      setState(() {
                                        task.isCompleted = value ?? false;
                                      });

                                      setSheetState(() {});
                                    },
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          task.time,
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          task.title,
                                          style: TextStyle(
                                            color: AppColors.textDark,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 15,
                                            decoration: task.isCompleted
                                                ? TextDecoration.lineThrough
                                                : null,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          task.description,
                                          style: const TextStyle(
                                            color: AppColors.textSoft,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _openStaffProfile() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (bottomSheetContext) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          minChildSize: 0.62,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            final completedTasks = _tasks
                .where((task) => task.isCompleted)
                .toList();

            final incompleteTasks = _tasks
                .where((task) => !task.isCompleted)
                .toList();

            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const CircleAvatar(
                  radius: 45,
                  backgroundColor: AppColors.primarySoft,
                  child: Icon(
                    Icons.badge_rounded,
                    color: AppColors.primary,
                    size: 45,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Nguyễn Minh An',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'NV-CF-001 • Nhân viên Café',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSoft,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 22),
                const SoftCard(
                  color: Colors.white,
                  child: Column(
                    children: [
                      _ProfileInformationLine(
                        icon: Icons.store_rounded,
                        label: 'Chi nhánh',
                        value: 'PetHub Quận 1',
                      ),
                      Divider(height: 26),
                      _ProfileInformationLine(
                        icon: Icons.schedule_rounded,
                        label: 'Ca làm',
                        value: 'Ca sáng • 07:30 - 15:30',
                      ),
                      Divider(height: 26),
                      _ProfileInformationLine(
                        icon: Icons.phone_rounded,
                        label: 'Số điện thoại',
                        value: '0901 234 567',
                      ),
                      Divider(height: 26),
                      _ProfileInformationLine(
                        icon: Icons.circle,
                        label: 'Trạng thái',
                        value: 'Đang làm việc',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                const SectionTitle(title: 'Tiến độ hôm nay'),
                const SizedBox(height: 10),
                SoftCard(
                  color: AppColors.mint,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _ProfileTaskNumber(
                              label: 'Tổng việc',
                              value: '${_tasks.length}',
                            ),
                          ),
                          Expanded(
                            child: _ProfileTaskNumber(
                              label: 'Hoàn thành',
                              value: '$_completedTaskCount',
                            ),
                          ),
                          Expanded(
                            child: _ProfileTaskNumber(
                              label: 'Còn thiếu',
                              value: '$_remainingTaskCount',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: _taskProgress,
                          minHeight: 10,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(_taskProgress * 100).round()}% công việc đã hoàn thành',
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                const SectionTitle(title: 'Đã hoàn thành'),
                const SizedBox(height: 9),
                if (completedTasks.isEmpty)
                  const _EmptyTaskMessage(
                    message: 'Chưa có công việc nào được hoàn thành.',
                  )
                else
                  ...completedTasks.map(
                    (task) => _ProfileTaskRow(task: task, completed: true),
                  ),
                const SizedBox(height: 20),
                const SectionTitle(title: 'Còn thiếu'),
                const SizedBox(height: 9),
                if (incompleteTasks.isEmpty)
                  const _EmptyTaskMessage(
                    message: 'Đã hoàn thành đầy đủ công việc.',
                  )
                else
                  ...incompleteTasks.map(
                    (task) => _ProfileTaskRow(task: task, completed: false),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  void _searchBooking() {
    final customerName = _bookingNameController.text.trim();

    final phoneNumber = _bookingPhoneController.text.trim();

    if (customerName.isEmpty || phoneNumber.isEmpty) {
      _showMessage('Vui lòng nhập đầy đủ tên và số điện thoại.');
      return;
    }

    setState(() {
      _bookingSummary = _BookingSummary(
        customerName: customerName,
        phoneNumber: phoneNumber,
        bookingDate: '20/07/2026',
        bookingTime: '09:30',
        branchName: 'PetHub Quận 1',
        tableName: 'Bàn A03',
        guestCount: 4,
        serviceName: 'Gọi món tại quầy',
        status: 'Đã xác nhận',
      );
    });
  }

  void _confirmCustomerArrival() {
    final booking = _bookingSummary;

    if (booking == null) return;

    setState(() {
      booking.status = 'Khách đã đến';
    });

    _showMessage('Đã xác nhận khách đến quán.');
  }

  void _increaseQuantity(_CafeMenuItem item) {
    setState(() {
      item.quantity++;
    });
  }

  void _decreaseQuantity(_CafeMenuItem item) {
    if (item.quantity <= 0) return;

    setState(() {
      item.quantity--;
    });
  }

  void _clearCurrentOrder() {
    setState(() {
      for (final item in _menuItems) {
        item.quantity = 0;
      }
    });
  }

  void _createBill() {
    final customerName = _customerNameController.text.trim();

    final phoneNumber = _customerPhoneController.text.trim();

    final tableName = _tableController.text.trim();

    if (customerName.isEmpty || phoneNumber.isEmpty || tableName.isEmpty) {
      _showMessage('Vui lòng nhập tên khách, số điện thoại và số bàn.');
      return;
    }

    if (_selectedOrderItems.isEmpty) {
      _showMessage('Vui lòng chọn ít nhất một món.');
      return;
    }

    final now = DateTime.now();

    final bill = _CafeBill(
      id: 'CF-${now.millisecondsSinceEpoch.toString().substring(7)}',
      customerName: customerName,
      phoneNumber: phoneNumber,
      tableName: tableName,
      staffName: 'Nguyễn Minh An',
      createdTime:
          '${now.hour.toString().padLeft(2, '0')}:'
          '${now.minute.toString().padLeft(2, '0')} '
          '${now.day}/${now.month}/${now.year}',
      items: _selectedOrderItems
          .map(
            (item) => _CafeBillItem(
              name: item.name,
              quantity: item.quantity,
              unitPrice: item.price,
            ),
          )
          .toList(),
      total: _orderTotal,
    );

    setState(() {
      _bills.insert(0, bill);

      for (final item in _menuItems) {
        item.quantity = 0;
      }
    });

    _showBillDialog(bill);
  }

  void _showBillDialog(_CafeBill bill) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 650),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.pets_rounded,
                    color: AppColors.primary,
                    size: 42,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'PET HUB CAFÉ',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w900,
                      fontSize: 21,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'HÓA ĐƠN THANH TOÁN',
                    style: TextStyle(
                      color: AppColors.textSoft,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _BillInformationLine(label: 'Mã Bill', value: bill.id),
                  _BillInformationLine(
                    label: 'Khách hàng',
                    value: bill.customerName,
                  ),
                  _BillInformationLine(
                    label: 'Số điện thoại',
                    value: bill.phoneNumber,
                  ),
                  _BillInformationLine(label: 'Số bàn', value: bill.tableName),
                  _BillInformationLine(
                    label: 'Nhân viên',
                    value: bill.staffName,
                  ),
                  _BillInformationLine(
                    label: 'Thời gian',
                    value: bill.createdTime,
                  ),
                  const Divider(height: 28),
                  ...bill.items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${item.name} x${item.quantity}',
                              style: const TextStyle(
                                color: AppColors.textDark,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            _formatMoney(item.total),
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const Divider(height: 28),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Tổng tiền',
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      Text(
                        _formatMoney(bill.total),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 19,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Cảm ơn quý khách đã sử dụng dịch vụ PetHub!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSoft, height: 1.4),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                      },
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Hoàn tất'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHomeScreen(),
      _buildBookingScreen(),
      _buildMenuScreen(),
      _buildBillScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        centerTitle: false,
        title: const Row(
          children: [
            CircleAvatar(
              radius: 21,
              backgroundColor: AppColors.peach,
              child: Icon(Icons.local_cafe_rounded, color: AppColors.primary),
            ),
            SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PetHub Staff',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Nhân viên Café',
                    style: TextStyle(
                      color: AppColors.textSoft,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Profile nhân viên',
            onPressed: _openStaffProfile,
            icon: const Icon(
              Icons.account_circle_rounded,
              color: AppColors.primary,
              size: 29,
            ),
          ),
          IconButton(
            tooltip: 'Đổi chức vụ',
            onPressed: () {
              context.go('/staff-role');
            },
            icon: const Icon(
              Icons.swap_horiz_rounded,
              color: AppColors.textSoft,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Tổng quan',
          ),
          NavigationDestination(
            icon: Icon(Icons.table_restaurant_outlined),
            selectedIcon: Icon(Icons.table_restaurant_rounded),
            label: 'Đặt bàn',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu_rounded),
            label: 'Menu',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Bill',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeScreen() {
    final now = DateTime.now();

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              colors: [AppColors.peach, AppColors.primarySoft, AppColors.cream],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Row(
            children: [
              CircleAvatar(
                radius: 33,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.waving_hand_rounded,
                  color: AppColors.primary,
                  size: 31,
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chào Nguyễn Minh An',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Ca sáng • 07:30 - 15:30\nPetHub Quận 1',
                      style: TextStyle(
                        color: AppColors.textSoft,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const SectionTitle(title: 'Công việc hôm nay'),
        const SizedBox(height: 11),

        // Chỉ có một card công việc.
        SoftCard(
          color: AppColors.mint,
          onTap: _openTaskList,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.task_alt_rounded,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Danh sách công việc',
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${now.day}/${now.month}/${now.year} • '
                          '$_completedTaskCount/${_tasks.length} hoàn thành',
                          style: const TextStyle(
                            color: AppColors.textSoft,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: _taskProgress,
                  minHeight: 10,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '${(_taskProgress * 100).round()}% hoàn thành',
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Còn $_remainingTaskCount việc',
                    style: const TextStyle(
                      color: AppColors.textSoft,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        const SectionTitle(title: 'Chức năng Café'),
        const SizedBox(height: 11),
        Row(
          children: [
            Expanded(
              child: _CafeFeatureCard(
                title: 'Tra cứu\nđặt bàn',
                icon: Icons.search_rounded,
                color: AppColors.sky,
                onTap: () {
                  setState(() {
                    _selectedIndex = 1;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CafeFeatureCard(
                title: 'Menu và\ngọi món',
                icon: Icons.restaurant_menu_rounded,
                color: AppColors.peach,
                onTap: () {
                  setState(() {
                    _selectedIndex = 2;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _CafeFeatureCard(
                title: 'Danh sách\nBill',
                icon: Icons.receipt_long_rounded,
                color: AppColors.lavender,
                onTap: () {
                  setState(() {
                    _selectedIndex = 3;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CafeFeatureCard(
                title: 'Profile\nnhân viên',
                icon: Icons.badge_rounded,
                color: AppColors.mint,
                onTap: _openStaffProfile,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBookingScreen() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
      children: [
        const SectionTitle(title: 'Tra cứu đặt bàn'),
        const SizedBox(height: 6),
        const Text(
          'Nhập tên và số điện thoại của khách để tìm thông tin đặt bàn.',
          style: TextStyle(color: AppColors.textSoft, height: 1.4),
        ),
        const SizedBox(height: 18),
        SoftCard(
          color: Colors.white,
          child: Column(
            children: [
              TextField(
                controller: _bookingNameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Tên khách hàng',
                  hintText: 'Ví dụ: Nguyễn Hải Yến',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _bookingPhoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại',
                  hintText: 'Ví dụ: 0901234567',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _searchBooking,
                  icon: const Icon(Icons.search_rounded),
                  label: const Text('Tìm đơn đặt bàn'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (_bookingSummary == null)
          const SoftCard(
            color: AppColors.cream,
            child: Column(
              children: [
                Icon(
                  Icons.table_restaurant_rounded,
                  size: 56,
                  color: AppColors.primarySoft,
                ),
                SizedBox(height: 10),
                Text(
                  'Thông tin đặt bàn sẽ hiển thị tại đây.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSoft,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        else
          _buildBookingSummary(_bookingSummary!),
      ],
    );
  }

  Widget _buildBookingSummary(_BookingSummary booking) {
    return SoftCard(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 27,
                backgroundColor: AppColors.sky,
                child: Icon(
                  Icons.table_restaurant_rounded,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Tóm tắt đặt bàn',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ),
              _BookingStatusChip(status: booking.status),
            ],
          ),
          const Divider(height: 30),
          _BookingInformationLine(
            label: 'Khách hàng',
            value: booking.customerName,
          ),
          _BookingInformationLine(
            label: 'Số điện thoại',
            value: booking.phoneNumber,
          ),
          _BookingInformationLine(
            label: 'Ngày đặt',
            value: booking.bookingDate,
          ),
          _BookingInformationLine(label: 'Giờ đến', value: booking.bookingTime),
          _BookingInformationLine(
            label: 'Chi nhánh',
            value: booking.branchName,
          ),
          _BookingInformationLine(label: 'Bàn', value: booking.tableName),
          _BookingInformationLine(
            label: 'Số khách',
            value: '${booking.guestCount}',
          ),
          _BookingInformationLine(label: 'Dịch vụ', value: booking.serviceName),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: booking.status == 'Khách đã đến'
                  ? null
                  : _confirmCustomerArrival,
              icon: const Icon(Icons.how_to_reg_rounded),
              label: Text(
                booking.status == 'Khách đã đến'
                    ? 'Đã xác nhận khách đến'
                    : 'Xác nhận khách đến',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuScreen() {
    final filteredItems = _selectedMenuCategory == 'Tất cả'
        ? _menuItems
        : _menuItems
              .where((item) => item.category == _selectedMenuCategory)
              .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 150),
      children: [
        const SectionTitle(title: 'Menu gọi món'),
        const SizedBox(height: 12),
        SoftCard(
          color: Colors.white,
          child: Column(
            children: [
              TextField(
                controller: _customerNameController,
                decoration: const InputDecoration(
                  labelText: 'Tên khách hàng',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _customerPhoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _tableController,
                decoration: const InputDecoration(
                  labelText: 'Số bàn',
                  hintText: 'Ví dụ: A03',
                  prefixIcon: Icon(Icons.table_restaurant_outlined),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _menuCategories.map((category) {
              return Padding(
                padding: const EdgeInsets.only(right: 9),
                child: ChoiceChip(
                  selected: _selectedMenuCategory == category,
                  label: Text(category),
                  onSelected: (_) {
                    setState(() {
                      _selectedMenuCategory = category;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 18),
        ...filteredItems.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SoftCard(
              color: Colors.white,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 27,
                    backgroundColor: item.color,
                    child: Icon(item.icon, color: AppColors.textDark),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.category,
                          style: const TextStyle(
                            color: AppColors.textSoft,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _formatMoney(item.price),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _decreaseQuantity(item);
                    },
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text(
                    '${item.quantity}',
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _increaseQuantity(item);
                    },
                    icon: const Icon(
                      Icons.add_circle_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 10),
        SoftCard(
          color: AppColors.primarySoft,
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Số món đã chọn',
                      style: TextStyle(
                        color: AppColors.textSoft,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '${_selectedOrderItems.length}',
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Tổng tiền',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  Text(
                    _formatMoney(_orderTotal),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectedOrderItems.isEmpty
                          ? null
                          : _clearCurrentOrder,
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text('Xóa món'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _createBill,
                      icon: const Icon(Icons.receipt_long_rounded),
                      label: const Text('Xuất Bill'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBillScreen() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
      children: [
        SectionTitle(title: 'Danh sách Bill', actionText: '${_bills.length}'),
        const SizedBox(height: 6),
        const Text(
          'Danh sách hóa đơn được tạo trong ca làm hiện tại.',
          style: TextStyle(color: AppColors.textSoft),
        ),
        const SizedBox(height: 18),
        if (_bills.isEmpty)
          const SoftCard(
            color: Colors.white,
            child: Column(
              children: [
                Icon(
                  Icons.receipt_long_rounded,
                  size: 58,
                  color: AppColors.primarySoft,
                ),
                SizedBox(height: 10),
                Text(
                  'Chưa có Bill nào được tạo.',
                  style: TextStyle(
                    color: AppColors.textSoft,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          )
        else
          ..._bills.map((bill) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SoftCard(
                color: Colors.white,
                onTap: () {
                  _showBillDialog(bill);
                },
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 27,
                      backgroundColor: AppColors.lavender,
                      child: Icon(
                        Icons.receipt_long_rounded,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bill.id,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            bill.customerName,
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${bill.tableName} • ${bill.createdTime}',
                            style: const TextStyle(
                              color: AppColors.textSoft,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatMoney(bill.total),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 15,
                          color: AppColors.textSoft,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}

// ============================================================
// WIDGET DÙNG CHUNG
// ============================================================

class _CafeFeatureCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CafeFeatureCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: color,
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 27,
            backgroundColor: Colors.white.withOpacity(0.8),
            child: Icon(icon, color: AppColors.textDark, size: 27),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w900,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileInformationLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInformationLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 21),
        const SizedBox(width: 11),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSoft,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileTaskNumber extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileTaskNumber({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textSoft,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _ProfileTaskRow extends StatelessWidget {
  final _CafeTask task;
  final bool completed;

  const _ProfileTaskRow({required this.task, required this.completed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: SoftCard(
        color: Colors.white,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: completed ? AppColors.mint : AppColors.peach,
              child: Icon(
                completed ? Icons.check_rounded : Icons.pending_actions_rounded,
                size: 19,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    task.time,
                    style: const TextStyle(
                      color: AppColors.textSoft,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyTaskMessage extends StatelessWidget {
  final String message;

  const _EmptyTaskMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: Colors.white,
      child: Text(message, style: const TextStyle(color: AppColors.textSoft)),
    );
  }
}

class _BookingInformationLine extends StatelessWidget {
  final String label;
  final String value;

  const _BookingInformationLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSoft,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
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

class _BookingStatusChip extends StatelessWidget {
  final String status;

  const _BookingStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status == 'Khách đã đến'
        ? AppColors.mint
        : AppColors.primarySoft;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: AppColors.textDark,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _BillInformationLine extends StatelessWidget {
  final String label;
  final String value;

  const _BillInformationLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          SizedBox(
            width: 95,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSoft),
            ),
          ),
          Expanded(
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

// ============================================================
// DỮ LIỆU MẪU TRONG GIAO DIỆN
// ============================================================

class _CafeTask {
  final String time;
  final String title;
  final String description;

  bool isCompleted;

  _CafeTask({
    required this.time,
    required this.title,
    required this.description,
    this.isCompleted = false,
  });
}

class _BookingSummary {
  final String customerName;
  final String phoneNumber;
  final String bookingDate;
  final String bookingTime;
  final String branchName;
  final String tableName;
  final int guestCount;
  final String serviceName;

  String status;

  _BookingSummary({
    required this.customerName,
    required this.phoneNumber,
    required this.bookingDate,
    required this.bookingTime,
    required this.branchName,
    required this.tableName,
    required this.guestCount,
    required this.serviceName,
    required this.status,
  });
}

class _CafeMenuItem {
  final String id;
  final String name;
  final String category;
  final int price;
  final IconData icon;
  final Color color;

  int quantity;

  _CafeMenuItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.icon,
    required this.color,
    this.quantity = 0,
  });
}

class _CafeBillItem {
  final String name;
  final int quantity;
  final int unitPrice;

  const _CafeBillItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });

  int get total => quantity * unitPrice;
}

class _CafeBill {
  final String id;
  final String customerName;
  final String phoneNumber;
  final String tableName;
  final String staffName;
  final String createdTime;
  final List<_CafeBillItem> items;
  final int total;

  const _CafeBill({
    required this.id,
    required this.customerName,
    required this.phoneNumber,
    required this.tableName,
    required this.staffName,
    required this.createdTime,
    required this.items,
    required this.total,
  });
}

String _formatMoney(int value) {
  final text = value.toString();
  final result = StringBuffer();

  for (var index = 0; index < text.length; index++) {
    if (index > 0 && (text.length - index) % 3 == 0) {
      result.write('.');
    }

    result.write(text[index]);
  }

  return '${result.toString()} đ';
}
