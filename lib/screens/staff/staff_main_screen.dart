import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_colors.dart';
import '../../widgets/section_title.dart';
import '../../widgets/soft_card.dart';
import 'staff_department.dart';

class StaffMainScreen extends StatefulWidget {
  final StaffDepartment department;

  const StaffMainScreen({
    super.key,
    required this.department,
  });

  @override
  State<StaffMainScreen> createState() => _StaffMainScreenState();
}

class _StaffMainScreenState extends State<StaffMainScreen> {
  int selectedIndex = 0;

  late final List<Widget> screens;

  @override
  void initState() {
    super.initState();

    screens = [
      StaffWorkboardScreen(
        department: widget.department,
      ),
      StaffOrdersScreen(
        department: widget.department,
      ),
      const StaffPetManagementScreen(),
      const StaffCheckInScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        centerTitle: false,
        title: Row(
          children: [
            CircleAvatar(
              radius: 21,
              backgroundColor: widget.department.color,
              child: Icon(
                widget.department.icon,
                color: AppColors.textDark,
                size: 21,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PetHub Staff',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    widget.department.title,
                    style: const TextStyle(
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
            tooltip: 'Đổi chức vụ',
            onPressed: () {
              context.go('/staff-role');
            },
            icon: const Icon(
              Icons.swap_horiz_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: IndexedStack(
        index: selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.view_timeline_outlined),
            selectedIcon: Icon(Icons.view_timeline_rounded),
            label: 'Công việc',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Đơn hàng',
          ),
          NavigationDestination(
            icon: Icon(Icons.pets_outlined),
            selectedIcon: Icon(Icons.pets_rounded),
            label: 'Pet',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner_outlined),
            selectedIcon: Icon(Icons.qr_code_scanner_rounded),
            label: 'Check-in',
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// WORKBOARD
// ==========================================================

class StaffWorkboardScreen extends StatefulWidget {
  final StaffDepartment department;

  const StaffWorkboardScreen({
    super.key,
    required this.department,
  });

  @override
  State<StaffWorkboardScreen> createState() =>
      _StaffWorkboardScreenState();
}

class _StaffWorkboardScreenState
    extends State<StaffWorkboardScreen> {
  late final List<_WorkTask> tasks;

  @override
  void initState() {
    super.initState();
    tasks = _createTasks(widget.department);
  }

  List<_WorkTask> _createTasks(
      StaffDepartment department,
      ) {
    switch (department) {
      case StaffDepartment.cafe:
        return [
          _WorkTask(
            time: '07:30',
            title: 'Kiểm tra khu vực Café',
            description:
            'Kiểm tra bàn, máy pha và nguyên liệu đầu ca.',
            icon: Icons.storefront_rounded,
          ),
          _WorkTask(
            time: '08:15',
            title: 'Xử lý đơn gọi nước',
            description:
            'Xác nhận các đơn khách đã gọi trước.',
            icon: Icons.local_cafe_rounded,
          ),
          _WorkTask(
            time: '10:00',
            title: 'Cập nhật đơn đã hoàn thành',
            description:
            'Kiểm tra và chuyển trạng thái đơn sang Đã xong.',
            icon: Icons.task_alt_rounded,
          ),
          _WorkTask(
            time: '14:00',
            title: 'Bổ sung nguyên liệu',
            description:
            'Kiểm tra tồn kho sữa, cà phê và bánh.',
            icon: Icons.inventory_2_rounded,
          ),
        ];

      case StaffDepartment.spa:
        return [
          _WorkTask(
            time: '08:00',
            title: 'Chuẩn bị phòng Spa',
            description:
            'Kiểm tra dụng cụ, khăn và sản phẩm chăm sóc.',
            icon: Icons.bathtub_rounded,
          ),
          _WorkTask(
            time: '09:00',
            title: 'Spa cho bé Mochi',
            description:
            'Tắm, sấy và vệ sinh tai theo yêu cầu.',
            icon: Icons.pets_rounded,
          ),
          _WorkTask(
            time: '10:30',
            title: 'Cập nhật tình trạng Pet',
            description:
            'Ghi chú da, lông và hành vi trong quá trình spa.',
            icon: Icons.edit_note_rounded,
          ),
          _WorkTask(
            time: '11:00',
            title: 'Tải ảnh sau Spa',
            description:
            'Chụp và cập nhật hình ảnh sau khi hoàn thành.',
            icon: Icons.add_a_photo_rounded,
          ),
        ];

      case StaffDepartment.hospital:
        return [
          _WorkTask(
            time: '08:30',
            title: 'Kiểm tra lịch khám',
            description:
            'Xem danh sách Pet có lịch khám trong ngày.',
            icon: Icons.calendar_month_rounded,
          ),
          _WorkTask(
            time: '09:15',
            title: 'Khám sức khỏe bé Lucky',
            description:
            'Kiểm tra nhiệt độ và tình trạng ăn uống.',
            icon: Icons.health_and_safety_rounded,
          ),
          _WorkTask(
            time: '10:00',
            title: 'Cập nhật bệnh án',
            description:
            'Ghi chẩn đoán, thuốc và lịch tái khám.',
            icon: Icons.medical_information_rounded,
          ),
          _WorkTask(
            time: '15:00',
            title: 'Theo dõi Pet sau điều trị',
            description:
            'Cập nhật tình trạng hồi phục cho khách.',
            icon: Icons.monitor_heart_rounded,
          ),
        ];

      case StaffDepartment.petCare:
        return [
          _WorkTask(
            time: '07:45',
            title: 'Kiểm tra sức khỏe Pet',
            description:
            'Kiểm tra ăn uống và biểu hiện đầu ngày.',
            icon: Icons.health_and_safety_rounded,
          ),
          _WorkTask(
            time: '09:00',
            title: 'Sắp lịch Pet khu vực Café',
            description:
            'Phân ca phù hợp, tránh Pet làm việc quá tải.',
            icon: Icons.schedule_rounded,
          ),
          _WorkTask(
            time: '11:30',
            title: 'Cho Pet nghỉ giữa ca',
            description:
            'Đưa Pet về khu vực nghỉ và bổ sung nước.',
            icon: Icons.hotel_rounded,
          ),
          _WorkTask(
            time: '16:00',
            title: 'Cập nhật hồ sơ sức khỏe',
            description:
            'Ghi chú tình trạng Pet cuối ngày.',
            icon: Icons.assignment_rounded,
          ),
        ];

      case StaffDepartment.reception:
        return [
          _WorkTask(
            time: '07:30',
            title: 'Kiểm tra danh sách đặt bàn',
            description:
            'Đối chiếu đơn đặt bàn trong ngày.',
            icon: Icons.table_restaurant_rounded,
          ),
          _WorkTask(
            time: '08:00',
            title: 'Chuẩn bị khu vực Check-in',
            description:
            'Kiểm tra thiết bị và mã xác nhận.',
            icon: Icons.qr_code_scanner_rounded,
          ),
          _WorkTask(
            time: '09:30',
            title: 'Xác nhận khách đến quán',
            description:
            'Quét QR và cập nhật trạng thái đặt bàn.',
            icon: Icons.how_to_reg_rounded,
          ),
          _WorkTask(
            time: '17:00',
            title: 'Đối soát Check-in',
            description:
            'Kiểm tra đơn đã đến và đơn vắng mặt.',
            icon: Icons.fact_check_rounded,
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final completed =
        tasks.where((task) => task.isCompleted).length;

    final date = DateTime.now();

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: widget.department.color,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 31,
                backgroundColor: Colors.white.withOpacity(0.8),
                child: const Icon(
                  Icons.today_rounded,
                  color: AppColors.primary,
                  size: 30,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Công việc hôm nay',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${date.day}/${date.month}/${date.year} • ${widget.department.shortTitle}',
                      style: const TextStyle(
                        color: AppColors.textSoft,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _StaffStatCard(
                label: 'Tổng việc',
                value: '${tasks.length}',
                icon: Icons.list_alt_rounded,
                color: AppColors.sky,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StaffStatCard(
                label: 'Hoàn thành',
                value: '$completed',
                icon: Icons.task_alt_rounded,
                color: AppColors.mint,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StaffStatCard(
                label: 'Còn lại',
                value: '${tasks.length - completed}',
                icon: Icons.pending_actions_rounded,
                color: AppColors.peach,
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),
        SectionTitle(
          title: 'Lịch theo khung giờ',
          actionText: '$completed/${tasks.length}',
        ),
        const SizedBox(height: 10),
        ...List.generate(
          tasks.length,
              (index) {
            final task = tasks[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SoftCard(
                color: Colors.white,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Text(
                          task.time,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: task.isCompleted
                              ? AppColors.mint
                              : AppColors.primarySoft,
                          child: Icon(
                            task.isCompleted
                                ? Icons.check_rounded
                                : task.icon,
                            color: AppColors.textDark,
                            size: 21,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
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
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  task.isCompleted =
                                  !task.isCompleted;
                                });
                              },
                              icon: Icon(
                                task.isCompleted
                                    ? Icons.undo_rounded
                                    : Icons.check_circle_outline_rounded,
                              ),
                              label: Text(
                                task.isCompleted
                                    ? 'Hoàn tác'
                                    : 'Hoàn thành',
                              ),
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
      ],
    );
  }
}

// ==========================================================
// ORDERS
// ==========================================================

class StaffOrdersScreen extends StatefulWidget {
  final StaffDepartment department;

  const StaffOrdersScreen({
    super.key,
    required this.department,
  });

  @override
  State<StaffOrdersScreen> createState() =>
      _StaffOrdersScreenState();
}

class _StaffOrdersScreenState
    extends State<StaffOrdersScreen> {
  final List<String> areas = const [
    'Café',
    'Spa',
    'Bệnh viện',
  ];

  late String selectedArea;

  final List<_StaffOrder> orders = [
    _StaffOrder(
      id: 'CF-1024',
      area: 'Café',
      customerName: 'Nguyễn Hải Yến',
      title: '2 Cà phê sữa • 1 Bánh tiramisu',
      time: '08:30',
      status: 'Chờ xác nhận',
    ),
    _StaffOrder(
      id: 'CF-1025',
      area: 'Café',
      customerName: 'Trần Ngọc Hương Quế',
      title: '1 Matcha latte • 1 Bánh quy',
      time: '09:00',
      status: 'Đang xử lý',
    ),
    _StaffOrder(
      id: 'SP-2081',
      area: 'Spa',
      customerName: 'Phạm Minh Anh',
      title: 'Spa toàn thân cho Mochi',
      petName: 'Mochi',
      time: '09:15',
      status: 'Chờ xác nhận',
    ),
    _StaffOrder(
      id: 'SP-2082',
      area: 'Spa',
      customerName: 'Lê Hoàng Nam',
      title: 'Tắm và vệ sinh tai cho Lucky',
      petName: 'Lucky',
      time: '10:30',
      status: 'Đang xử lý',
    ),
    _StaffOrder(
      id: 'BV-3012',
      area: 'Bệnh viện',
      customerName: 'Võ Thảo Nhi',
      title: 'Khám tình trạng bỏ ăn',
      petName: 'Milo',
      time: '11:00',
      status: 'Chờ xác nhận',
    ),
  ];

  @override
  void initState() {
    super.initState();

    switch (widget.department) {
      case StaffDepartment.spa:
        selectedArea = 'Spa';
        break;
      case StaffDepartment.hospital:
        selectedArea = 'Bệnh viện';
        break;
      default:
        selectedArea = 'Café';
    }
  }

  void _advanceStatus(_StaffOrder order) {
    setState(() {
      if (order.status == 'Chờ xác nhận') {
        order.status = 'Đang xử lý';
      } else if (order.status == 'Đang xử lý') {
        order.status = 'Đã xong';
      }
    });
  }

  Future<void> _editNote(
      _StaffOrder order,
      ) async {
    final controller =
    TextEditingController(text: order.note);

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            order.area == 'Bệnh viện'
                ? 'Ghi chú bệnh án'
                : 'Ghi chú dịch vụ',
          ),
          content: TextField(
            controller: controller,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: order.area == 'Bệnh viện'
                  ? 'Nhập tình trạng, chẩn đoán, thuốc...'
                  : 'Nhập tình trạng da, lông, hành vi...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(
                  controller.text.trim(),
                );
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (result == null) return;

    setState(() {
      order.note = result;
    });
  }

  void _addAfterSpaPhoto(_StaffOrder order) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Thêm hình ảnh sau Spa',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primarySoft,
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  title: const Text('Chụp ảnh'),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);

                    setState(() {
                      order.imageCount++;
                    });
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.sky,
                    child: Icon(
                      Icons.photo_library_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  title: const Text('Chọn từ thư viện'),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);

                    setState(() {
                      order.imageCount++;
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = orders
        .where((order) => order.area == selectedArea)
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
      children: [
        const SectionTitle(
          title: 'Xử lý đơn hàng',
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: areas.map((area) {
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: ChoiceChip(
                  selected: selectedArea == area,
                  label: Text(area),
                  onSelected: (_) {
                    setState(() {
                      selectedArea = area;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),
        if (filteredOrders.isEmpty)
          const SoftCard(
            color: Colors.white,
            child: Text(
              'Không có đơn hàng trong khu vực này.',
            ),
          )
        else
          ...filteredOrders.map(
                (order) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 13),
                child: SoftCard(
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor:
                            _areaColor(order.area),
                            child: Icon(
                              _areaIcon(order.area),
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order.id,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  order.customerName,
                                  style: const TextStyle(
                                    color: AppColors.textDark,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _StatusPill(
                            status: order.status,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        order.title,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        '${order.time}${order.petName == null ? '' : ' • Pet: ${order.petName}'}',
                        style: const TextStyle(
                          color: AppColors.textSoft,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (order.note.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.cream,
                            borderRadius:
                            BorderRadius.circular(16),
                          ),
                          child: Text(
                            order.note,
                            style: const TextStyle(
                              color: AppColors.textSoft,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                      if (order.imageCount > 0) ...[
                        const SizedBox(height: 10),
                        Text(
                          '${order.imageCount} hình ảnh sau Spa',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (order.status != 'Đã xong')
                            FilledButton.icon(
                              onPressed: () {
                                _advanceStatus(order);
                              },
                              icon: Icon(
                                order.status ==
                                    'Chờ xác nhận'
                                    ? Icons.check_rounded
                                    : Icons.task_alt_rounded,
                              ),
                              label: Text(
                                order.status ==
                                    'Chờ xác nhận'
                                    ? 'Xác nhận'
                                    : 'Đã xong',
                              ),
                            ),
                          if (order.area != 'Café')
                            OutlinedButton.icon(
                              onPressed: () {
                                _editNote(order);
                              },
                              icon: const Icon(
                                Icons.edit_note_rounded,
                              ),
                              label: Text(
                                order.area == 'Bệnh viện'
                                    ? 'Bệnh án'
                                    : 'Ghi chú',
                              ),
                            ),
                          if (order.area == 'Spa')
                            OutlinedButton.icon(
                              onPressed: () {
                                _addAfterSpaPhoto(order);
                              },
                              icon: const Icon(
                                Icons.add_a_photo_rounded,
                              ),
                              label: const Text('Thêm ảnh'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Color _areaColor(String area) {
    switch (area) {
      case 'Spa':
        return AppColors.lavender;
      case 'Bệnh viện':
        return AppColors.sky;
      default:
        return AppColors.peach;
    }
  }

  IconData _areaIcon(String area) {
    switch (area) {
      case 'Spa':
        return Icons.bathtub_rounded;
      case 'Bệnh viện':
        return Icons.medical_services_rounded;
      default:
        return Icons.local_cafe_rounded;
    }
  }
}

// ==========================================================
// PET MANAGEMENT
// ==========================================================

class StaffPetManagementScreen extends StatefulWidget {
  const StaffPetManagementScreen({super.key});

  @override
  State<StaffPetManagementScreen> createState() =>
      _StaffPetManagementScreenState();
}

class _StaffPetManagementScreenState
    extends State<StaffPetManagementScreen> {
  final List<_ManagedPet> pets = [
    _ManagedPet(
      name: 'Miu',
      breed: 'Mèo Anh lông ngắn',
      shift: '08:00 - 11:00',
      workMinutes: 120,
      maxMinutes: 180,
      healthStatus: 'Tốt',
      note: 'Ăn uống bình thường.',
    ),
    _ManagedPet(
      name: 'Lucky',
      breed: 'Corgi',
      shift: '09:00 - 12:00',
      workMinutes: 165,
      maxMinutes: 180,
      healthStatus: 'Cần nghỉ',
      note: 'Hơi mệt sau khi chơi lâu.',
    ),
    _ManagedPet(
      name: 'Max',
      breed: 'Golden Retriever',
      shift: '14:00 - 17:00',
      workMinutes: 90,
      maxMinutes: 180,
      healthStatus: 'Tốt',
      note: 'Tâm trạng vui vẻ.',
    ),
  ];

  Future<void> _updatePet(
      _ManagedPet pet,
      ) async {
    String selectedStatus = pet.healthStatus;

    final controller =
    TextEditingController(text: pet.note);

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                'Cập nhật ${pet.name}',
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Tình trạng sức khỏe',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Tốt',
                        child: Text('Tốt'),
                      ),
                      DropdownMenuItem(
                        value: 'Theo dõi',
                        child: Text('Theo dõi'),
                      ),
                      DropdownMenuItem(
                        value: 'Cần nghỉ',
                        child: Text('Cần nghỉ'),
                      ),
                      DropdownMenuItem(
                        value: 'Cần khám',
                        child: Text('Cần khám'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;

                      setDialogState(() {
                        selectedStatus = value;
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: controller,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Ghi chú sức khỏe',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                      false,
                    );
                  },
                  child: const Text('Hủy'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                      true,
                    );
                  },
                  child: const Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
    );

    if (shouldSave == true) {
      setState(() {
        pet.healthStatus = selectedStatus;
        pet.note = controller.text.trim();
      });
    }

    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
      children: [
        const SectionTitle(
          title: 'Quản lý Pet',
        ),
        const SizedBox(height: 6),
        const Text(
          'Theo dõi thời gian làm việc để tránh Pet bị quá tải.',
          style: TextStyle(
            color: AppColors.textSoft,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 18),
        ...pets.map(
              (pet) {
            final progress =
            (pet.workMinutes / pet.maxMinutes)
                .clamp(0.0, 1.0)
                .toDouble();

            final nearOverload = progress >= 0.85;

            return Padding(
              padding: const EdgeInsets.only(bottom: 13),
              child: SoftCard(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 29,
                          backgroundColor:
                          AppColors.primarySoft,
                          child: Icon(
                            Icons.pets_rounded,
                            color: AppColors.textDark,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                pet.name,
                                style: const TextStyle(
                                  color: AppColors.textDark,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 17,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                pet.breed,
                                style: const TextStyle(
                                  color: AppColors.textSoft,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _HealthPill(
                          status: pet.healthStatus,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 19,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 7),
                        Text(
                          'Ca làm: ${pet.shift}',
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 13),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Đã làm ${pet.workMinutes}/${pet.maxMinutes} phút',
                            style: TextStyle(
                              color: nearOverload
                                  ? Colors.redAccent
                                  : AppColors.textSoft,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          '${(progress * 100).round()}%',
                          style: TextStyle(
                            color: nearOverload
                                ? Colors.redAccent
                                : AppColors.primary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 9,
                      borderRadius:
                      BorderRadius.circular(99),
                      backgroundColor:
                      AppColors.cream,
                      color: nearOverload
                          ? Colors.redAccent
                          : AppColors.primary,
                    ),
                    if (nearOverload) ...[
                      const SizedBox(height: 10),
                      const Text(
                        'Pet sắp đạt giới hạn làm việc, cần sắp xếp thời gian nghỉ.',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Text(
                      pet.note,
                      style: const TextStyle(
                        color: AppColors.textSoft,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _updatePet(pet);
                        },
                        icon: const Icon(
                          Icons.health_and_safety_rounded,
                        ),
                        label: const Text(
                          'Cập nhật sức khỏe',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ==========================================================
// CHECK-IN
// ==========================================================

class StaffCheckInScreen extends StatefulWidget {
  const StaffCheckInScreen({super.key});

  @override
  State<StaffCheckInScreen> createState() =>
      _StaffCheckInScreenState();
}

class _StaffCheckInScreenState
    extends State<StaffCheckInScreen> {
  final TextEditingController codeController =
  TextEditingController();

  final List<_CheckInRecord> records = [];

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  void _simulateScan() {
    final timestamp =
    DateTime.now().millisecondsSinceEpoch.toString();

    final code =
        'PH-${timestamp.substring(timestamp.length - 6)}';

    codeController.text = code;

    _confirmCheckIn();
  }

  void _confirmCheckIn() {
    final code = codeController.text.trim();

    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vui lòng quét hoặc nhập mã đặt bàn.',
          ),
        ),
      );
      return;
    }

    final record = _CheckInRecord(
      code: code,
      customerName: 'Khách hàng PetHub',
      tableName: 'Bàn A3',
      time: TimeOfDay.now().format(context),
    );

    setState(() {
      records.insert(0, record);
      codeController.clear();
    });

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.mint,
            child: Icon(
              Icons.check_rounded,
              color: AppColors.textDark,
              size: 32,
            ),
          ),
          title: const Text(
            'Check-in thành công',
          ),
          content: Text(
            'Mã ${record.code}\n'
                '${record.customerName} • ${record.tableName}',
            textAlign: TextAlign.center,
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Hoàn tất'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
      children: [
        const SectionTitle(
          title: 'Quản lý Check-in',
        ),
        const SizedBox(height: 6),
        const Text(
          'Quét mã QR của khách để xác nhận đơn đặt bàn.',
          style: TextStyle(
            color: AppColors.textSoft,
          ),
        ),
        const SizedBox(height: 20),
        SoftCard(
          color: Colors.white,
          child: Column(
            children: [
              Container(
                height: 230,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                child: const Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.qr_code_scanner_rounded,
                      size: 100,
                      color: AppColors.primary,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Đặt mã QR vào giữa khung',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Giao diện mô phỏng camera quét QR',
                      style: TextStyle(
                        color: AppColors.textSoft,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _simulateScan,
                  icon: const Icon(
                    Icons.camera_alt_rounded,
                  ),
                  label: const Text(
                    'Mở camera quét QR',
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const SectionTitle(
          title: 'Nhập mã thủ công',
        ),
        const SizedBox(height: 10),
        SoftCard(
          color: Colors.white,
          child: Column(
            children: [
              TextField(
                controller: codeController,
                textCapitalization:
                TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Mã đặt bàn',
                  hintText: 'Ví dụ: PH-123456',
                  prefixIcon: Icon(
                    Icons.confirmation_number_rounded,
                  ),
                ),
              ),
              const SizedBox(height: 13),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _confirmCheckIn,
                  icon: const Icon(
                    Icons.how_to_reg_rounded,
                  ),
                  label: const Text(
                    'Xác nhận Check-in',
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SectionTitle(
          title: 'Check-in gần đây',
          actionText: '${records.length}',
        ),
        const SizedBox(height: 10),
        if (records.isEmpty)
          const SoftCard(
            color: Colors.white,
            child: Text(
              'Chưa có lượt Check-in nào.',
              style: TextStyle(
                color: AppColors.textSoft,
              ),
            ),
          )
        else
          ...records.map(
                (record) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SoftCard(
                  color: Colors.white,
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppColors.mint,
                        child: Icon(
                          Icons.check_rounded,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              record.code,
                              style: const TextStyle(
                                color: AppColors.textDark,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${record.customerName} • ${record.tableName}',
                              style: const TextStyle(
                                color: AppColors.textSoft,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        record.time,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

// ==========================================================
// SHARED MODELS + WIDGETS
// ==========================================================

class _WorkTask {
  final String time;
  final String title;
  final String description;
  final IconData icon;

  bool isCompleted;

  _WorkTask({
    required this.time,
    required this.title,
    required this.description,
    required this.icon,
    this.isCompleted = false,
  });
}

class _StaffOrder {
  final String id;
  final String area;
  final String customerName;
  final String title;
  final String time;
  final String? petName;

  String status;
  String note;
  int imageCount;

  _StaffOrder({
    required this.id,
    required this.area,
    required this.customerName,
    required this.title,
    required this.time,
    required this.status,
    this.petName,
    this.note = '',
    this.imageCount = 0,
  });
}

class _ManagedPet {
  final String name;
  final String breed;
  final String shift;
  final int workMinutes;
  final int maxMinutes;

  String healthStatus;
  String note;

  _ManagedPet({
    required this.name,
    required this.breed,
    required this.shift,
    required this.workMinutes,
    required this.maxMinutes,
    required this.healthStatus,
    required this.note,
  });
}

class _CheckInRecord {
  final String code;
  final String customerName;
  final String tableName;
  final String time;

  const _CheckInRecord({
    required this.code,
    required this.customerName,
    required this.tableName,
    required this.time,
  });
}

class _StaffStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StaffStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: color,
      padding: const EdgeInsets.all(13),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.textDark,
          ),
          const SizedBox(height: 7),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w900,
              fontSize: 19,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSoft,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;

  const _StatusPill({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color color;

    switch (status) {
      case 'Đã xong':
        color = AppColors.mint;
        break;
      case 'Đang xử lý':
        color = AppColors.sky;
        break;
      default:
        color = AppColors.peach;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
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

class _HealthPill extends StatelessWidget {
  final String status;

  const _HealthPill({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color color;

    switch (status) {
      case 'Tốt':
        color = AppColors.mint;
        break;
      case 'Theo dõi':
        color = AppColors.sky;
        break;
      case 'Cần khám':
        color = AppColors.pink;
        break;
      default:
        color = AppColors.peach;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
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