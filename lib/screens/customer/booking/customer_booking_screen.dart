import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../booking_confirm/booking_confirm_data.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/section_title.dart';
import '../../../widgets/soft_card.dart';
import 'customer_drink_order_screen.dart';
class CustomerBookingScreen extends StatefulWidget {
  const CustomerBookingScreen({super.key});

  @override
  State<CustomerBookingScreen> createState() => _CustomerBookingScreenState();
}

class _CustomerBookingScreenState extends State<CustomerBookingScreen> {
  int selectedBranch = 0;
  int selectedDay = 0;
  int selectedTime = 1;
  int selectedGuest = 2;
  int? selectedTable;

  final branches = const [
    'PetHub Quận 1',
    'PetHub Bình Thạnh',
    'PetHub Thủ Đức',
  ];

  final days = const [
    'Hôm nay',
    'Ngày mai',
    'Thứ 7',
    'CN',
  ];

  final times = const [
    '09:00',
    '10:30',
    '13:00',
    '15:30',
    '18:00',
    '20:00',
  ];

  final tables = const [
    _TableItem(id: 1, name: 'Bàn A1', seats: 2, status: TableStatus.available),
    _TableItem(id: 2, name: 'Bàn A2', seats: 2, status: TableStatus.booked),
    _TableItem(id: 3, name: 'Bàn B1', seats: 4, status: TableStatus.available),
    _TableItem(id: 4, name: 'Bàn B2', seats: 4, status: TableStatus.available),
    _TableItem(id: 5, name: 'Bàn C1', seats: 6, status: TableStatus.booked),
    _TableItem(id: 6, name: 'Bàn C2', seats: 6, status: TableStatus.available),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _BookingHeader(),

          const SizedBox(height: 24),

          const SectionTitle(title: 'Chọn chi nhánh'),

          const SizedBox(height: 12),

          _BranchSelector(
            branches: branches,
            selectedIndex: selectedBranch,
            onSelected: (index) {
              setState(() {
                selectedBranch = index;
              });
            },
          ),

          const SizedBox(height: 24),

          const SectionTitle(title: 'Chọn ngày'),

          const SizedBox(height: 12),

          _HorizontalSelector(
            items: days,
            selectedIndex: selectedDay,
            onSelected: (index) {
              setState(() {
                selectedDay = index;
              });
            },
          ),

          const SizedBox(height: 24),

          const SectionTitle(title: 'Chọn khung giờ'),

          const SizedBox(height: 12),

          _TimeGrid(
            times: times,
            selectedIndex: selectedTime,
            onSelected: (index) {
              setState(() {
                selectedTime = index;
              });
            },
          ),

          const SizedBox(height: 24),

          const SectionTitle(title: 'Số lượng khách'),

          const SizedBox(height: 12),

          _GuestCounter(
            value: selectedGuest,
            onMinus: () {
              if (selectedGuest > 1) {
                setState(() {
                  selectedGuest--;
                });
              }
            },
            onPlus: () {
              if (selectedGuest < 10) {
                setState(() {
                  selectedGuest++;
                });
              }
            },
          ),

          const SizedBox(height: 24),

          SectionTitle(
            title: 'Chọn bàn',
            actionText: 'Sơ đồ quán',
            onActionTap: () {},
          ),

          const SizedBox(height: 12),

          _TableLegend(),

          const SizedBox(height: 12),

          _TableGrid(
            tables: tables,
            selectedTable: selectedTable,
            onSelected: (table) {
              if (table.status == TableStatus.booked) {
                return;
              }

              setState(() {
                selectedTable = table.id;
              });
            },
          ),

          const SizedBox(height: 26),

          _BookingSummary(
            branch: branches[selectedBranch],
            day: days[selectedDay],
            time: times[selectedTime],
            guests: selectedGuest,
            tableName: selectedTable == null
                ? 'Chưa chọn bàn'
                : tables.firstWhere((item) => item.id == selectedTable).name,
          ),

          const SizedBox(height: 18),

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
                side: const BorderSide(
                  color: Color(0xFF8ECAE6),
                  width: 1.5,
                ),
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
                  : () {
                final tableName = tables
                    .firstWhere((item) => item.id == selectedTable)
                    .name;

                context.push(
                  '/booking-confirm',
                  extra: BookingConfirmData(
                    branch: branches[selectedBranch],
                    day: days[selectedDay],
                    time: times[selectedTime],
                    guests: selectedGuest,
                    tableName: tableName,
                  ),
                );
              },
              icon: const Icon(Icons.check_circle_rounded),
              label: const Text('Xác nhận đặt bàn'),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingHeader extends StatelessWidget {
  const _BookingHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.peach,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.75),
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
                const SizedBox(height: 6),
                Text(
                  'Chọn chi nhánh, giờ ghé và chiếc bàn ấm áp cho bạn cùng bé pet.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.4,
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
            color: isSelected ? AppColors.primarySoft : Colors.white,
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 16,
                        ),
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

class _HorizontalSelector extends StatelessWidget {
  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _HorizontalSelector({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;

          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => onSelected(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              alignment: Alignment.center,
              child: Text(
                items[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TimeGrid extends StatelessWidget {
  final List<String> times;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _TimeGrid({
    required this.times,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: times.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisExtent: 48,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final isSelected = selectedIndex == index;

        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => onSelected(index),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              times[index],
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GuestCounter extends StatelessWidget {
  final int value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _GuestCounter({
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: Colors.white,
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.peach,
            child: Icon(
              Icons.groups_rounded,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              '$value khách',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),

          IconButton(
            onPressed: onMinus,
            icon: const Icon(Icons.remove_circle_outline_rounded),
          ),

          IconButton(
            onPressed: onPlus,
            icon: const Icon(
              Icons.add_circle_rounded,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
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
        _LegendDot(color: Color(0xFFE5E0DC), text: 'Đã đặt'),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String text;

  const _LegendDot({
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _TableGrid extends StatelessWidget {
  final List<_TableItem> tables;
  final int? selectedTable;
  final ValueChanged<_TableItem> onSelected;

  const _TableGrid({
    required this.tables,
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
        final isSelected = selectedTable == table.id;
        final isBooked = table.status == TableStatus.booked;

        Color cardColor;

        if (isBooked) {
          cardColor = const Color(0xFFE5E0DC);
        } else if (isSelected) {
          cardColor = AppColors.primary;
        } else {
          cardColor = AppColors.mint;
        }

        return SoftCard(
          color: cardColor,
          onTap: () => onSelected(table),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.table_restaurant_rounded,
                color: isSelected ? Colors.white : AppColors.textDark,
              ),

              const Spacer(),

              Text(
                table.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  color: isSelected ? Colors.white : AppColors.textDark,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                isBooked ? 'Đã có khách đặt' : '${table.seats} ghế • Còn trống',
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

  const _SummaryRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: Row(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
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

enum TableStatus {
  available,
  booked,
}

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