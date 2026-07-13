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
          name: 'Nguyá»…n Minh An',
          id: 'NV-CF-001',
          phone: '0901 234 567',
          departmentName: 'NhĂ¢n viĂªn CafĂ©',
          branch: 'PetHub Quáº­n 1',
          shift: 'Ca sĂ¡ng',
          shiftTime: '07:30 - 15:30',
          status: 'Äang lĂ m viá»‡c',
          avatarColor: AppColors.peach,
          icon: Icons.local_cafe_rounded,
        );

      case StaffDepartment.spa:
        return _StaffProfile(
          name: 'Tráº§n Ngá»c Mai',
          id: 'NV-SP-002',
          phone: '0912 345 678',
          departmentName: 'NhĂ¢n viĂªn Spa / KhĂ¡ch sáº¡n',
          branch: 'PetHub Quáº­n 1',
          shift: 'Ca hĂ nh chĂ­nh',
          shiftTime: '08:00 - 17:00',
          status: 'Äang lĂ m viá»‡c',
          avatarColor: AppColors.lavender,
          icon: Icons.pets_rounded,
        );

      case StaffDepartment.hospital:
        return _StaffProfile(
          name: 'LĂª HoĂ ng Nam',
          id: 'NV-BV-003',
          phone: '0987 654 321',
          departmentName: 'NhĂ¢n viĂªn Bá»‡nh viá»‡n',
          branch: 'PetHub Veterinary',
          shift: 'Ca sĂ¡ng',
          shiftTime: '08:00 - 16:00',
          status: 'Äang lĂ m viá»‡c',
          avatarColor: AppColors.sky,
          icon: Icons.medical_services_rounded,
        );

      case StaffDepartment.petCare:
      case StaffDepartment.reception:
        return _StaffProfile(
          name: 'NhĂ¢n viĂªn PetHub',
          id: 'NV-000',
          phone: '0900 000 000',
          departmentName: widget.department.title,
          branch: 'PetHub',
          shift: 'Ca táº¡m thá»i',
          shiftTime: '08:00 - 17:00',
          status: 'Äang lĂ m viá»‡c',
          avatarColor: widget.department.color,
          icon: widget.department.icon,
        );
    }
  }

  List<_StaffPageInfo> get pages {
    switch (widget.department) {
      case StaffDepartment.cafe:
        return const [
          _StaffPageInfo(title: 'Tá»•ng quan', icon: Icons.home_rounded),
          _StaffPageInfo(
            title: 'Äáº·t bĂ n',
            icon: Icons.table_restaurant_rounded,
          ),
          _StaffPageInfo(title: 'Menu', icon: Icons.restaurant_menu_rounded),
          _StaffPageInfo(title: 'Bill', icon: Icons.receipt_long_rounded),
        ];

      case StaffDepartment.spa:
        return const [
          _StaffPageInfo(title: 'Tá»•ng quan', icon: Icons.home_rounded),
          _StaffPageInfo(
            title: 'Lá»‹ch dá»‹ch vá»¥',
            icon: Icons.calendar_month_rounded,
          ),
          _StaffPageInfo(
            title: 'Táº¡o dá»‹ch vá»¥',
            icon: Icons.add_business_rounded,
          ),
          _StaffPageInfo(
            title: 'Phiáº¿u dá»‹ch vá»¥',
            icon: Icons.receipt_long_rounded,
          ),
        ];

      case StaffDepartment.hospital:
        return const [
          _StaffPageInfo(title: 'Tá»•ng quan', icon: Icons.home_rounded),
          _StaffPageInfo(
            title: 'Lá»‹ch khĂ¡m',
            icon: Icons.calendar_month_rounded,
          ),
          _StaffPageInfo(title: 'Bá»‡nh Ă¡n', icon: Icons.assignment_rounded),
          _StaffPageInfo(title: 'Chi phĂ­', icon: Icons.payments_rounded),
        ];

      case StaffDepartment.petCare:
      case StaffDepartment.reception:
        return const [
          _StaffPageInfo(title: 'Tá»•ng quan', icon: Icons.home_rounded),
        ];
    }
  }

  static List<_StaffTask> _tasksFor(StaffDepartment department) {
    switch (department) {
      case StaffDepartment.cafe:
        return [
          _StaffTask(
            time: '07:30 - 08:00',
            title: 'Kiá»ƒm tra khu vá»±c CafĂ©',
            description:
                'Kiá»ƒm tra bĂ n gháº¿, quáº§y pha cháº¿ vĂ  vá»‡ sinh Ä‘áº§u ca.',
          ),
          _StaffTask(
            time: '08:00 - 08:30',
            title: 'Kiá»ƒm tra Ä‘Æ¡n Ä‘áº·t bĂ n',
            description: 'Xem danh sĂ¡ch khĂ¡ch Ä‘Ă£ Ä‘áº·t bĂ n trong ngĂ y.',
          ),
          _StaffTask(
            time: '08:30 - 09:00',
            title: 'Kiá»ƒm tra Menu',
            description:
                'Cáº­p nháº­t mĂ³n cĂ²n phá»¥c vá»¥ vĂ  mĂ³n Ä‘Ă£ háº¿t.',
          ),
          _StaffTask(
            time: 'Trong ca',
            title: 'Tiáº¿p nháº­n khĂ¡ch vĂ  gá»i mĂ³n',
            description:
                'Tra cá»©u Ä‘áº·t bĂ n, chá»n mĂ³n vĂ  xuáº¥t Bill cho khĂ¡ch.',
          ),
          _StaffTask(
            time: '15:00 - 15:30',
            title: 'Kiá»ƒm kĂª cuá»‘i ca',
            description: 'Kiá»ƒm tra nguyĂªn liá»‡u vĂ  bĂ n giao cho ca sau.',
          ),
        ];

      case StaffDepartment.spa:
        return [
          _StaffTask(
            time: '08:00 - 08:30',
            title: 'Chuáº©n bá»‹ khu vá»±c Spa',
            description:
                'Kiá»ƒm tra khÄƒn, dá»¥ng cá»¥, phĂ²ng Spa vĂ  khu lÆ°u trĂº.',
          ),
          _StaffTask(
            time: '08:30 - 09:00',
            title: 'Kiá»ƒm tra lá»‹ch dá»‹ch vá»¥',
            description:
                'Xem lá»‹ch Spa vĂ  lá»‹ch gá»­i Pet khĂ¡ch sáº¡n trong ngĂ y.',
          ),
          _StaffTask(
            time: '09:00 - 10:00',
            title: 'Tiáº¿p nháº­n Pet',
            description:
                'XĂ¡c nháº­n thĂ´ng tin khĂ¡ch, Pet vĂ  tĂ¬nh tráº¡ng ban Ä‘áº§u.',
          ),
          _StaffTask(
            time: 'Trong ca',
            title: 'Kiá»ƒm tra Pet lÆ°u trĂº',
            description:
                'Theo dĂµi Äƒn uá»‘ng, sá»©c khá»e vĂ  khu vá»±c nghá»‰ cá»§a Pet.',
          ),
          _StaffTask(
            time: '16:00 - 17:00',
            title: 'BĂ n giao Pet cho khĂ¡ch',
            description:
                'Cáº­p nháº­t chi phĂ­, tĂ¬nh tráº¡ng Pet vĂ  thá»i gian nháº­n.',
          ),
        ];

      case StaffDepartment.hospital:
        return [
          _StaffTask(
            time: '08:00 - 08:30',
            title: 'Kiá»ƒm tra lá»‹ch khĂ¡m',
            description:
                'Xem danh sĂ¡ch khĂ¡ch vĂ  Pet Ä‘Ă£ Ä‘áº·t lá»‹ch khĂ¡m.',
          ),
          _StaffTask(
            time: '08:30 - 09:00',
            title: 'Chuáº©n bá»‹ phĂ²ng khĂ¡m',
            description:
                'Kiá»ƒm tra dá»¥ng cá»¥, thuá»‘c vĂ  thiáº¿t bá»‹ khĂ¡m.',
          ),
          _StaffTask(
            time: 'Trong ca',
            title: 'Tiáº¿p nháº­n Pet',
            description: 'XĂ¡c nháº­n thĂ´ng tin khĂ¡ch, Pet vĂ  lĂ½ do khĂ¡m.',
          ),
          _StaffTask(
            time: 'Sau má»—i lÆ°á»£t khĂ¡m',
            title: 'Cáº­p nháº­t bá»‡nh Ă¡n',
            description:
                'Ghi triá»‡u chá»©ng, cháº©n Ä‘oĂ¡n, thuá»‘c vĂ  hÆ°á»›ng dáº«n.',
          ),
          _StaffTask(
            time: '15:30 - 16:00',
            title: 'Kiá»ƒm tra lá»‹ch tĂ¡i khĂ¡m',
            description:
                'XĂ¡c nháº­n lá»‹ch tĂ¡i khĂ¡m vĂ  há»“ sÆ¡ cĂ²n thiáº¿u.',
          ),
        ];

      case StaffDepartment.petCare:
      case StaffDepartment.reception:
        return [
          _StaffTask(
            time: '08:00 - 09:00',
            title: 'CĂ´ng viá»‡c táº¡m thá»i',
            description: 'Chá»©c vá»¥ nĂ y táº¡m thá»i khĂ´ng sá»­ dá»¥ng.',
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
                                  'CĂ´ng viá»‡c hĂ´m nay',
                                  style: TextStyle(
                                    color: AppColors.textDark,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 19,
                                  ),
                                ),
                                Text(
                                  'ÄĂ£ hoĂ n thĂ nh $completedCount/${tasks.length}',
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
                  '${staff.id} â€¢ ${staff.departmentName}',
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
                        label: 'Chi nhĂ¡nh',
                        value: staff.branch,
                      ),
                      const Divider(height: 26),
                      _ProfileLine(
                        icon: Icons.work_rounded,
                        label: 'Khu vá»±c',
                        value: staff.departmentName,
                      ),
                      const Divider(height: 26),
                      _ProfileLine(
                        icon: Icons.schedule_rounded,
                        label: 'Ca lĂ m',
                        value: '${staff.shift} â€¢ ${staff.shiftTime}',
                      ),
                      const Divider(height: 26),
                      _ProfileLine(
                        icon: Icons.phone_rounded,
                        label: 'Sá»‘ Ä‘iá»‡n thoáº¡i',
                        value: staff.phone,
                      ),
                      const Divider(height: 26),
                      _ProfileLine(
                        icon: Icons.circle,
                        label: 'Tráº¡ng thĂ¡i',
                        value: staff.status,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                const SectionTitle(title: 'Tiáº¿n Ä‘á»™ cĂ´ng viá»‡c hĂ´m nay'),
                const SizedBox(height: 10),
                SoftCard(
                  color: AppColors.mint,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _ProfileTaskNumber(
                              label: 'Tá»•ng viá»‡c',
                              value: '${tasks.length}',
                            ),
                          ),
                          Expanded(
                            child: _ProfileTaskNumber(
                              label: 'HoĂ n thĂ nh',
                              value: '$completedCount',
                            ),
                          ),
                          Expanded(
                            child: _ProfileTaskNumber(
                              label: 'CĂ²n thiáº¿u',
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
                        '${(progress * 100).round()}% cĂ´ng viá»‡c Ä‘Ă£ hoĂ n thĂ nh',
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                const SectionTitle(title: 'ÄĂ£ hoĂ n thĂ nh'),
                const SizedBox(height: 9),
                if (completedTasks.isEmpty)
                  const _EmptyMessage(
                    message:
                        'ChÆ°a cĂ³ cĂ´ng viá»‡c nĂ o Ä‘Æ°á»£c hoĂ n thĂ nh.',
                  )
                else
                  ...completedTasks.map(
                    (task) => _ProfileTaskRow(task: task, completed: true),
                  ),
                const SizedBox(height: 20),
                const SectionTitle(title: 'CĂ²n thiáº¿u'),
                const SizedBox(height: 9),
                if (incompleteTasks.isEmpty)
                  const _EmptyMessage(
                    message: 'ÄĂ£ hoĂ n thĂ nh Ä‘áº§y Ä‘á»§ cĂ´ng viá»‡c.',
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
            tooltip: 'Profile nhĂ¢n viĂªn',
            onPressed: _openStaffProfile,
            icon: const Icon(
              Icons.account_circle_rounded,
              color: AppColors.primary,
              size: 29,
            ),
          ),
          IconButton(
            tooltip: 'Äá»•i chá»©c vá»¥',
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
                      'ChĂ o ${profile.name}',
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${profile.shift} â€¢ ${profile.shiftTime}\n${profile.branch}',
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
        const SectionTitle(title: 'CĂ´ng viá»‡c hĂ´m nay'),
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
                          'Danh sĂ¡ch cĂ´ng viá»‡c',
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${now.day}/${now.month}/${now.year} â€¢ '
                          '$completedCount/${tasks.length} hoĂ n thĂ nh',
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
                    '${(progress * 100).round()}% hoĂ n thĂ nh',
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'CĂ²n $remainingCount viá»‡c',
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
        SectionTitle(title: 'Chá»©c nÄƒng ${widget.department.shortTitle}'),
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
      if (title == 'Äáº·t bĂ n') {
        return 'BÆ°á»›c tiáº¿p theo sáº½ lĂ m form nháº­p tĂªn khĂ¡ch, sá»‘ Ä‘iá»‡n thoáº¡i vĂ  hiá»‡n tĂ³m táº¯t Ä‘áº·t bĂ n.';
      }

      if (title == 'Menu') {
        return 'BÆ°á»›c tiáº¿p theo sáº½ lĂ m giao diá»‡n chá»n mĂ³n, tĂ­nh tá»•ng tiá»n vĂ  xuáº¥t Bill.';
      }

      if (title == 'Bill') {
        return 'BÆ°á»›c tiáº¿p theo sáº½ lĂ m danh sĂ¡ch Bill vĂ  chi tiáº¿t hĂ³a Ä‘Æ¡n.';
      }
    }

    if (widget.department == StaffDepartment.spa) {
      if (title == 'Lá»‹ch dá»‹ch vá»¥') {
        return 'BÆ°á»›c sau sáº½ lĂ m danh sĂ¡ch lá»‹ch Spa vĂ  khĂ¡ch sáº¡n Pet.';
      }

      if (title == 'Táº¡o dá»‹ch vá»¥') {
        return 'BÆ°á»›c sau sáº½ lĂ m form thĂ´ng tin khĂ¡ch, Pet, ngĂ y giá» Spa, ngĂ y gá»­i nháº­n vĂ  chi phĂ­.';
      }

      if (title == 'Phiáº¿u dá»‹ch vá»¥') {
        return 'BÆ°á»›c sau sáº½ lĂ m phiáº¿u dá»‹ch vá»¥ Spa / KhĂ¡ch sáº¡n.';
      }
    }

    if (widget.department == StaffDepartment.hospital) {
      if (title == 'Lá»‹ch khĂ¡m') {
        return 'BÆ°á»›c sau sáº½ lĂ m danh sĂ¡ch lá»‹ch khĂ¡m cĂ³ ngĂ y giá», tĂªn khĂ¡ch, SÄT vĂ  lĂ½ do khĂ¡m.';
      }

      if (title == 'Bá»‡nh Ă¡n') {
        return 'BÆ°á»›c sau sáº½ lĂ m form há»“ sÆ¡ bá»‡nh Ă¡n khi khĂ¡m thĂº cÆ°ng.';
      }

      if (title == 'Chi phĂ­') {
        return 'BÆ°á»›c sau sáº½ lĂ m chi phĂ­ khĂ¡m vĂ  giao diá»‡n xuáº¥t bá»‡nh Ă¡n PDF.';
      }
    }

    return 'Chá»©c nÄƒng nĂ y sáº½ Ä‘Æ°á»£c lĂ m á»Ÿ bÆ°á»›c tiáº¿p theo.';
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
