// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_colors.dart';
import '../../widgets/section_title.dart';
import '../../widgets/soft_card.dart';
import 'staff_department.dart';

class StaffMainScreen extends StatefulWidget {
  final StaffDepartment department;

  const StaffMainScreen({super.key, required this.department});

  @override
  State<StaffMainScreen> createState() => _StaffMainScreenState();
}

class _StaffMainScreenState extends State<StaffMainScreen> {
  int selectedIndex = 0;

  late final List<_StaffTask> tasks;

  @override
  void initState() {
    super.initState();
    tasks = _tasksFor(widget.department);
  }

  int get completedCount {
    return tasks.where((task) => task.isCompleted).length;
  }

  int get remainingCount {
    return tasks.length - completedCount;
  }

  double get progress {
    if (tasks.isEmpty) return 0;
    return completedCount / tasks.length;
  }

  _StaffProfile get profile {
    switch (widget.department) {
      case StaffDepartment.cafe:
        return _StaffProfile(
          name: 'Nguyễn Minh An',
          id: 'NV-CF-001',
          phone: '0901 234 567',
          departmentName: 'Nhân viên Café',
          branch: 'PetHub Quận 1',
          shift: 'Ca sáng',
          shiftTime: '07:30 - 15:30',
          status: 'Đang làm việc',
          avatarColor: AppColors.peach,
          icon: Icons.local_cafe_rounded,
        );

      case StaffDepartment.spa:
        return _StaffProfile(
          name: 'Trần Ngọc Mai',
          id: 'NV-SP-002',
          phone: '0912 345 678',
          departmentName: 'Nhân viên Spa / Khách sạn',
          branch: 'PetHub Quận 1',
          shift: 'Ca hành chính',
          shiftTime: '08:00 - 17:00',
          status: 'Đang làm việc',
          avatarColor: AppColors.lavender,
          icon: Icons.pets_rounded,
        );

      case StaffDepartment.hospital:
        return _StaffProfile(
          name: 'Lê Hoàng Nam',
          id: 'NV-BV-003',
          phone: '0987 654 321',
          departmentName: 'Nhân viên Bệnh viện',
          branch: 'PetHub Veterinary',
          shift: 'Ca sáng',
          shiftTime: '08:00 - 16:00',
          status: 'Đang làm việc',
          avatarColor: AppColors.sky,
          icon: Icons.medical_services_rounded,
        );

      case StaffDepartment.petCare:
      case StaffDepartment.reception:
        return _StaffProfile(
          name: 'Nhân viên PetHub',
          id: 'NV-000',
          phone: '0900 000 000',
          departmentName: widget.department.title,
          branch: 'PetHub',
          shift: 'Ca tạm thời',
          shiftTime: '08:00 - 17:00',
          status: 'Đang làm việc',
          avatarColor: widget.department.color,
          icon: widget.department.icon,
        );
    }
  }

  List<_StaffPageInfo> get pages {
    switch (widget.department) {
      case StaffDepartment.cafe:
        return const [
          _StaffPageInfo(title: 'Tổng quan', icon: Icons.home_rounded),
          _StaffPageInfo(
            title: 'Đặt bàn',
            icon: Icons.table_restaurant_rounded,
          ),
          _StaffPageInfo(title: 'Menu', icon: Icons.restaurant_menu_rounded),
          _StaffPageInfo(title: 'Bill', icon: Icons.receipt_long_rounded),
        ];

      case StaffDepartment.spa:
        return const [
          _StaffPageInfo(title: 'Tổng quan', icon: Icons.home_rounded),
          _StaffPageInfo(
            title: 'Lịch dịch vụ',
            icon: Icons.calendar_month_rounded,
          ),
          _StaffPageInfo(
            title: 'Tạo dịch vụ',
            icon: Icons.add_business_rounded,
          ),
          _StaffPageInfo(
            title: 'Phiếu dịch vụ',
            icon: Icons.receipt_long_rounded,
          ),
        ];

      case StaffDepartment.hospital:
        return const [
          _StaffPageInfo(title: 'Tổng quan', icon: Icons.home_rounded),
          _StaffPageInfo(
            title: 'Lịch khám',
            icon: Icons.calendar_month_rounded,
          ),
          _StaffPageInfo(title: 'Bệnh án', icon: Icons.assignment_rounded),
          _StaffPageInfo(title: 'Chi phí', icon: Icons.payments_rounded),
        ];

      case StaffDepartment.petCare:
      case StaffDepartment.reception:
        return const [
          _StaffPageInfo(title: 'Tổng quan', icon: Icons.home_rounded),
        ];
    }
  }

  static List<_StaffTask> _tasksFor(StaffDepartment department) {
    switch (department) {
      case StaffDepartment.cafe:
        return [
          _StaffTask(
            time: '07:30 - 08:00',
            title: 'Kiểm tra khu vực Café',
            description: 'Kiểm tra bàn ghế, quầy pha chế và vệ sinh đầu ca.',
          ),
          _StaffTask(
            time: '08:00 - 08:30',
            title: 'Kiểm tra đơn đặt bàn',
            description: 'Xem danh sách khách đã đặt bàn trong ngày.',
          ),
          _StaffTask(
            time: '08:30 - 09:00',
            title: 'Kiểm tra Menu',
            description: 'Cập nhật món còn phục vụ và món đã hết.',
          ),
          _StaffTask(
            time: 'Trong ca',
            title: 'Tiếp nhận khách và gọi món',
            description: 'Tra cứu đặt bàn, chọn món và xuất Bill cho khách.',
          ),
          _StaffTask(
            time: '15:00 - 15:30',
            title: 'Kiểm kê cuối ca',
            description: 'Kiểm tra nguyên liệu và bàn giao cho ca sau.',
          ),
        ];

      case StaffDepartment.spa:
        return [
          _StaffTask(
            time: '08:00 - 08:30',
            title: 'Chuẩn bị khu vực Spa',
            description: 'Kiểm tra khăn, dụng cụ, phòng Spa và khu lưu trú.',
          ),
          _StaffTask(
            time: '08:30 - 09:00',
            title: 'Kiểm tra lịch dịch vụ',
            description: 'Xem lịch Spa và lịch gửi Pet khách sạn trong ngày.',
          ),
          _StaffTask(
            time: '09:00 - 10:00',
            title: 'Tiếp nhận Pet',
            description: 'Xác nhận thông tin khách, Pet và tình trạng ban đầu.',
          ),
          _StaffTask(
            time: 'Trong ca',
            title: 'Kiểm tra Pet lưu trú',
            description: 'Theo dõi ăn uống, sức khỏe và khu vực nghỉ của Pet.',
          ),
          _StaffTask(
            time: '16:00 - 17:00',
            title: 'Bàn giao Pet cho khách',
            description: 'Cập nhật chi phí, tình trạng Pet và thời gian nhận.',
          ),
        ];

      case StaffDepartment.hospital:
        return [
          _StaffTask(
            time: '08:00 - 08:30',
            title: 'Kiểm tra lịch khám',
            description: 'Xem danh sách khách và Pet đã đặt lịch khám.',
          ),
          _StaffTask(
            time: '08:30 - 09:00',
            title: 'Chuẩn bị phòng khám',
            description: 'Kiểm tra dụng cụ, thuốc và thiết bị khám.',
          ),
          _StaffTask(
            time: 'Trong ca',
            title: 'Tiếp nhận Pet',
            description: 'Xác nhận thông tin khách, Pet và lý do khám.',
          ),
          _StaffTask(
            time: 'Sau mỗi lượt khám',
            title: 'Cập nhật bệnh án',
            description: 'Ghi triệu chứng, chẩn đoán, thuốc và hướng dẫn.',
          ),
          _StaffTask(
            time: '15:30 - 16:00',
            title: 'Kiểm tra lịch tái khám',
            description: 'Xác nhận lịch tái khám và hồ sơ còn thiếu.',
          ),
        ];

      case StaffDepartment.petCare:
      case StaffDepartment.reception:
        return [
          _StaffTask(
            time: '08:00 - 09:00',
            title: 'Công việc tạm thời',
            description: 'Chức vụ này tạm thời không sử dụng.',
          ),
        ];
    }
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
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.82,
              minChildSize: 0.55,
              maxChildSize: 0.95,
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
                          CircleAvatar(
                            backgroundColor: widget.department.color,
                            child: Icon(
                              widget.department.icon,
                              color: AppColors.textDark,
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
                                  'Đã hoàn thành $completedCount/${tasks.length}',
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
                          value: progress,
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
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: SoftCard(
                              color: Colors.white,
                              padding: const EdgeInsets.all(12),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  setState(() {
                                    task.isCompleted = !task.isCompleted;
                                  });

                                  setSheetState(() {});
                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Radio<bool>(
                                      value: true,
                                      groupValue: task.isCompleted,
                                      activeColor: AppColors.primary,
                                      onChanged: (_) {
                                        setState(() {
                                          task.isCompleted = !task.isCompleted;
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
    final completedTasks = tasks.where((task) => task.isCompleted).toList();
    final incompleteTasks = tasks.where((task) => !task.isCompleted).toList();
    final staff = profile;

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
          initialChildSize: 0.88,
          minChildSize: 0.62,
          maxChildSize: 0.96,
          builder: (context, scrollController) {
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
                CircleAvatar(
                  radius: 45,
                  backgroundColor: staff.avatarColor,
                  child: Icon(staff.icon, color: AppColors.primary, size: 45),
                ),
                const SizedBox(height: 12),
                Text(
                  staff.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${staff.id} • ${staff.departmentName}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSoft,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 22),
                SoftCard(
                  color: Colors.white,
                  child: Column(
                    children: [
                      _ProfileLine(
                        icon: Icons.store_rounded,
                        label: 'Chi nhánh',
                        value: staff.branch,
                      ),
                      const Divider(height: 26),
                      _ProfileLine(
                        icon: Icons.work_rounded,
                        label: 'Khu vực',
                        value: staff.departmentName,
                      ),
                      const Divider(height: 26),
                      _ProfileLine(
                        icon: Icons.schedule_rounded,
                        label: 'Ca làm',
                        value: '${staff.shift} • ${staff.shiftTime}',
                      ),
                      const Divider(height: 26),
                      _ProfileLine(
                        icon: Icons.phone_rounded,
                        label: 'Số điện thoại',
                        value: staff.phone,
                      ),
                      const Divider(height: 26),
                      _ProfileLine(
                        icon: Icons.circle,
                        label: 'Trạng thái',
                        value: staff.status,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                const SectionTitle(title: 'Tiến độ công việc hôm nay'),
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
                              value: '${tasks.length}',
                            ),
                          ),
                          Expanded(
                            child: _ProfileTaskNumber(
                              label: 'Hoàn thành',
                              value: '$completedCount',
                            ),
                          ),
                          Expanded(
                            child: _ProfileTaskNumber(
                              label: 'Còn thiếu',
                              value: '$remainingCount',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(progress * 100).round()}% công việc đã hoàn thành',
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
                  const _EmptyMessage(
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
                  const _EmptyMessage(
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

  @override
  Widget build(BuildContext context) {
    final currentPages = pages;

    if (selectedIndex >= currentPages.length) {
      selectedIndex = 0;
    }

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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
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
      body: IndexedStack(
        index: selectedIndex,
        children: [
          _buildOverviewPage(),
          ...currentPages.skip(1).map((page) => _buildPlaceholderPage(page)),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: currentPages.map((page) {
          return NavigationDestination(
            icon: Icon(page.icon),
            selectedIcon: Icon(page.icon),
            label: page.title,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOverviewPage() {
    final now = DateTime.now();
    final currentPages = pages;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              colors: [widget.department.color, AppColors.cream],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 33,
                backgroundColor: Colors.white.withValues(alpha: 0.85),
                child: Icon(
                  widget.department.icon,
                  color: AppColors.primary,
                  size: 31,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chào ${profile.name}',
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${profile.shift} • ${profile.shiftTime}\n${profile.branch}',
                      style: const TextStyle(
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
                          '$completedCount/${tasks.length} hoàn thành',
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
                  value: progress,
                  minHeight: 10,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '${(progress * 100).round()}% hoàn thành',
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Còn $remainingCount việc',
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
        SectionTitle(title: 'Chức năng ${widget.department.shortTitle}'),
        const SizedBox(height: 11),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ...List.generate(currentPages.length - 1, (index) {
              final realIndex = index + 1;
              final page = currentPages[realIndex];

              return SizedBox(
                width: (MediaQuery.of(context).size.width - 48) / 2,
                child: _FeatureCard(
                  title: page.title,
                  icon: page.icon,
                  color: widget.department.color,
                  onTap: () {
                    setState(() {
                      selectedIndex = realIndex;
                    });
                  },
                ),
              );
            }),
            SizedBox(
              width: (MediaQuery.of(context).size.width - 48) / 2,
              child: _FeatureCard(
                title: 'Profile',
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

  Widget _buildPlaceholderPage(_StaffPageInfo page) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
      children: [
        SectionTitle(title: page.title),
        const SizedBox(height: 14),
        SoftCard(
          color: Colors.white,
          child: Column(
            children: [
              CircleAvatar(
                radius: 42,
                backgroundColor: widget.department.color,
                child: Icon(page.icon, size: 42, color: AppColors.textDark),
              ),
              const SizedBox(height: 16),
              Text(
                page.title,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _placeholderText(page.title),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSoft, height: 1.45),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _placeholderText(String title) {
    if (widget.department == StaffDepartment.cafe) {
      if (title == 'Đặt bàn') {
        return 'Bước tiếp theo sẽ làm form nhập tên khách, số điện thoại và hiện tóm tắt đặt bàn.';
      }

      if (title == 'Menu') {
        return 'Bước tiếp theo sẽ làm giao diện chọn món, tính tổng tiền và xuất Bill.';
      }

      if (title == 'Bill') {
        return 'Bước tiếp theo sẽ làm danh sách Bill và chi tiết hóa đơn.';
      }
    }

    if (widget.department == StaffDepartment.spa) {
      if (title == 'Lịch dịch vụ') {
        return 'Bước sau sẽ làm danh sách lịch Spa và khách sạn Pet.';
      }

      if (title == 'Tạo dịch vụ') {
        return 'Bước sau sẽ làm form thông tin khách, Pet, ngày giờ Spa, ngày gửi nhận và chi phí.';
      }

      if (title == 'Phiếu dịch vụ') {
        return 'Bước sau sẽ làm phiếu dịch vụ Spa / Khách sạn.';
      }
    }

    if (widget.department == StaffDepartment.hospital) {
      if (title == 'Lịch khám') {
        return 'Bước sau sẽ làm danh sách lịch khám có ngày giờ, tên khách, SĐT và lý do khám.';
      }

      if (title == 'Bệnh án') {
        return 'Bước sau sẽ làm form hồ sơ bệnh án khi khám thú cưng.';
      }

      if (title == 'Chi phí') {
        return 'Bước sau sẽ làm chi phí khám và giao diện xuất bệnh án PDF.';
      }
    }

    return 'Chức năng này sẽ được làm ở bước tiếp theo.';
  }
}

class _StaffPageInfo {
  final String title;
  final IconData icon;

  const _StaffPageInfo({required this.title, required this.icon});
}

class _StaffProfile {
  final String name;
  final String id;
  final String phone;
  final String departmentName;
  final String branch;
  final String shift;
  final String shiftTime;
  final String status;
  final Color avatarColor;
  final IconData icon;

  const _StaffProfile({
    required this.name,
    required this.id,
    required this.phone,
    required this.departmentName,
    required this.branch,
    required this.shift,
    required this.shiftTime,
    required this.status,
    required this.avatarColor,
    required this.icon,
  });
}

class _StaffTask {
  final String time;
  final String title;
  final String description;

  bool isCompleted = false;

  _StaffTask({
    required this.time,
    required this.title,
    required this.description,
  });
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({
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
            backgroundColor: Colors.white.withValues(alpha: 0.8),
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

class _ProfileLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileLine({
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
  final _StaffTask task;
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

class _EmptyMessage extends StatelessWidget {
  final String message;

  const _EmptyMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: Colors.white,
      child: Text(message, style: const TextStyle(color: AppColors.textSoft)),
    );
  }
}
