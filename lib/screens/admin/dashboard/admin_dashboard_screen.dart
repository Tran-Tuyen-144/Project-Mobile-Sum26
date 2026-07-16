import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../services/order_revenue_service.dart';
import '../../../theme/app_colors.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String selectedTime = 'Ngày';
  String selectedCategory = 'Tất cả';

  final List<String> timeFilters = ['Ngày', 'Tuần', 'Tháng', 'Năm'];

  final List<String> categories = [
    'Tất cả',
    'Café',
    'Spa',
    'Khách sạn',
    'Bệnh viện',
  ];

  static const Map<String, String> _categoryKeys = {
    'Café': 'cafe',
    'Spa': 'spa',
    'Khách sạn': 'hotel',
    'Bệnh viện': 'vet',
  };

  static const Map<String, Color> _categoryColors = {
    'Café': AppColors.peach,
    'Spa': AppColors.mint,
    'Khách sạn': AppColors.lavender,
    'Bệnh viện': AppColors.sky,
  };

  String _money(int value) {
    return '${value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}đ';
  }

  DateTime _startOfSelectedPeriod() {
    final now = DateTime.now();

    switch (selectedTime) {
      case 'Tuần':
        final today = DateTime(now.year, now.month, now.day);

        return today.subtract(Duration(days: today.weekday - 1));

      case 'Tháng':
        return DateTime(now.year, now.month);

      case 'Năm':
        return DateTime(now.year);

      case 'Ngày':
      default:
        return DateTime(now.year, now.month, now.day);
    }
  }

  DateTime _endOfSelectedPeriod() {
    final start = _startOfSelectedPeriod();

    switch (selectedTime) {
      case 'Tuần':
        return start.add(const Duration(days: 7));

      case 'Tháng':
        return DateTime(start.year, start.month + 1);

      case 'Năm':
        return DateTime(start.year + 1);

      case 'Ngày':
      default:
        return start.add(const Duration(days: 1));
    }
  }

  List<RevenueOrder> _filterOrders(List<RevenueOrder> orders) {
    final start = _startOfSelectedPeriod();
    final end = _endOfSelectedPeriod();
    final categoryKey = _categoryKeys[selectedCategory];

    return orders.where((order) {
      if (!order.isCompleted) {
        return false;
      }

      if (order.createdAt.isBefore(start) || !order.createdAt.isBefore(end)) {
        return false;
      }

      if (categoryKey != null && order.category != categoryKey) {
        return false;
      }

      return true;
    }).toList();
  }

  List<_RevenueBucket> _buildBuckets(List<RevenueOrder> orders) {
    late final List<_RevenueBucket> buckets;

    switch (selectedTime) {
      case 'Tuần':
        buckets = List.generate(
          7,
          (index) => _RevenueBucket(label: index == 6 ? 'CN' : 'T${index + 2}'),
        );

        for (final order in orders) {
          final index = order.createdAt.weekday - 1;

          if (index >= 0 && index < buckets.length) {
            buckets[index].add(order);
          }
        }

        break;

      case 'Tháng':
        buckets = List.generate(
          5,
          (index) => _RevenueBucket(label: 'W${index + 1}'),
        );

        for (final order in orders) {
          final index = ((order.createdAt.day - 1) ~/ 7).clamp(0, 4);

          buckets[index].add(order);
        }

        break;

      case 'Năm':
        buckets = List.generate(
          12,
          (index) => _RevenueBucket(label: 'T${index + 1}'),
        );

        for (final order in orders) {
          final index = order.createdAt.month - 1;

          if (index >= 0 && index < buckets.length) {
            buckets[index].add(order);
          }
        }

        break;

      case 'Ngày':
      default:
        buckets = List.generate(
          6,
          (index) => _RevenueBucket(label: '${index * 4}h'),
        );

        for (final order in orders) {
          final index = (order.createdAt.hour ~/ 4).clamp(0, 5);

          buckets[index].add(order);
        }

        break;
    }

    return buckets;
  }

  int _totalRevenue(List<RevenueOrder> orders) {
    return orders.fold<int>(0, (sum, order) => sum + order.totalAmount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<List<RevenueOrder>>(
        stream: OrderRevenueService.watchOrders(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Không tải được doanh thu:\n'
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allOrders = snapshot.data ?? const [];

          final filteredOrders = _filterOrders(allOrders);

          final buckets = _buildBuckets(filteredOrders);

          final totalRevenue = _totalRevenue(filteredOrders);

          final highestRevenue = buckets.fold<int>(
            0,
            (highest, bucket) => math.max(highest, bucket.revenue),
          );

          final chartMaxY = highestRevenue <= 0 ? 1.0 : highestRevenue * 1.2;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      _showFilterBottomSheet(context);
                    },
                    icon: const Icon(Icons.filter_list_rounded, size: 18),
                    label: Text(selectedCategory),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textDark,
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: AppColors.peach),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Wrap(
                        spacing: 8,
                        children: timeFilters
                            .map(
                              (time) => ChoiceChip(
                                label: Text(time),
                                selected: selectedTime == time,
                                selectedColor: AppColors.primary,
                                backgroundColor: Colors.white,
                                side: const BorderSide(color: AppColors.peach),
                                labelStyle: TextStyle(
                                  color: selectedTime == time
                                      ? Colors.white
                                      : AppColors.textDark,
                                  fontWeight: FontWeight.w700,
                                ),
                                onSelected: (selected) {
                                  if (!selected) {
                                    return;
                                  }

                                  setState(() {
                                    selectedTime = time;
                                  });
                                },
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Tổng quan '
                '${selectedTime.toLowerCase()}: '
                '$selectedCategory',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildSummaryCard(
                    'Doanh thu',
                    _money(totalRevenue),
                    Icons.attach_money_rounded,
                    AppColors.mint,
                  ),
                  const SizedBox(width: 12),
                  _buildSummaryCard(
                    'Đơn hoàn tất',
                    '${filteredOrders.length} đơn',
                    Icons.shopping_bag_rounded,
                    AppColors.peach,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Biểu đồ doanh thu',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Tổng các cột luôn bằng doanh thu '
                'của bộ lọc đang chọn.',
                style: TextStyle(color: AppColors.textSoft),
              ),
              const SizedBox(height: 16),
              Container(
                height: 270,
                padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.peach),
                ),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: chartMaxY,
                    minY: 0,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => AppColors.textDark,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final bucket = buckets[group.x];

                          return BarTooltipItem(
                            '${bucket.label}\n'
                            '${_money(rod.toY.round())}'
                            '\n${bucket.orderCount} đơn',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();

                            if (index < 0 || index >= buckets.length) {
                              return const SizedBox.shrink();
                            }

                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                buckets[index].label,
                                style: const TextStyle(
                                  color: AppColors.textSoft,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(buckets.length, (index) {
                      final bucket = buckets[index];

                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: bucket.revenue.toDouble(),
                            color: AppColors.primary,
                            width: selectedTime == 'Năm' ? 11 : 16,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildServicePerformance(allOrders),
              const SizedBox(height: 30),
            ],
          );
        },
      ),
    );
  }

  Widget _buildServicePerformance(List<RevenueOrder> allOrders) {
    final start = _startOfSelectedPeriod();
    final end = _endOfSelectedPeriod();

    final periodOrders = allOrders.where((order) {
      return order.isCompleted &&
          !order.createdAt.isBefore(start) &&
          order.createdAt.isBefore(end);
    }).toList();

    final labels = selectedCategory == 'Tất cả'
        ? _categoryKeys.keys.toList()
        : [selectedCategory];

    final periodRevenue = _totalRevenue(periodOrders);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hiệu quả các dịch vụ',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 16),
        ...labels.map((label) {
          final categoryKey = _categoryKeys[label];

          final categoryOrders = periodOrders.where((order) {
            return order.category == categoryKey;
          }).toList();

          final categoryRevenue = _totalRevenue(categoryOrders);

          final percentage = periodRevenue <= 0
              ? 0.0
              : categoryRevenue / periodRevenue;

          return _buildPerformanceRow(
            label,
            categoryOrders.length,
            categoryRevenue,
            _categoryColors[label] ?? AppColors.peach,
            percentage.clamp(0, 1),
          );
        }),
      ],
    );
  }

  Widget _buildPerformanceRow(
    String title,
    int count,
    int revenue,
    Color color,
    double percentage,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _money(revenue),
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    '$count đơn',
                    style: const TextStyle(
                      color: AppColors.textSoft,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage,
            color: color,
            backgroundColor: AppColors.cream,
            minHeight: 7,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color backgroundColor,
  ) {
    return Expanded(
      child: Container(
        constraints: const BoxConstraints(minHeight: 142),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: backgroundColor.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: backgroundColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.textDark),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textSoft,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                maxLines: 1,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: categories.map((category) {
              final selected = selectedCategory == category;

              return ListTile(
                leading: Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: selected ? AppColors.primary : AppColors.textSoft,
                ),
                title: Text(
                  category,
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                  ),
                ),
                onTap: () {
                  setState(() {
                    selectedCategory = category;
                  });

                  Navigator.of(bottomSheetContext).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _RevenueBucket {
  final String label;
  int revenue;
  int orderCount;

  _RevenueBucket({required this.label, this.revenue = 0, this.orderCount = 0});

  void add(RevenueOrder order) {
    revenue += order.totalAmount;
    orderCount++;
  }
}
