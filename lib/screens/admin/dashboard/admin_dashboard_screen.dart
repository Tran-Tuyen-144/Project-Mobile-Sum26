import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../theme/app_colors.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String selectedTime = 'Ngày';
  String selectedCategory = 'Tất cả';

  final List<String> timeFilters = ['Ngày', 'Tuần', 'Tháng', 'Năm'];
  final List<String> categories = ['Tất cả', 'Café', 'Spa', 'Khách sạn', 'Bệnh viện'];

  final Map<String, Map<String, int>> detailedStats = {
    'Café': {'Café muối': 120, 'Matcha': 30, 'Nước ép thơm': 40},
    'Spa': {'Cắt lông': 30, 'Sấy': 20, 'Tắm': 50},
    'Khách sạn': {'Phòng tiêu chuẩn': 30, 'Phòng VIP': 70},
    'Bệnh viện': {'Khám tổng quát': 30, 'Tiêm phòng': 20, 'Phẫu thuật': 5},
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // --- BỘ LỌC ---
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => _showFilterBottomSheet(context),
                icon: const Icon(Icons.filter_list_rounded, size: 18),
                label: Text(selectedCategory),
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.textDark),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Wrap(
                    spacing: 8,
                    children: timeFilters.map((time) => ChoiceChip(
                      label: Text(time),
                      selected: selectedTime == time,
                      onSelected: (val) => setState(() => selectedTime = time),
                    )).toList(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Text('Tổng quan ${selectedTime.toLowerCase()}: $selectedCategory',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildSummaryCard('Doanh thu', '2.450.000đ', Icons.attach_money_rounded, AppColors.mint),
              const SizedBox(width: 16),
              _buildSummaryCard('Đơn hàng', '18 đơn', Icons.shopping_bag_rounded, AppColors.peach),
            ],
          ),

          const SizedBox(height: 32),
          const Text('Biểu đồ xu hướng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // --- BIỂU ĐỒ TƯƠNG TÁC ---
          Container(
            height: 250,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.cream)),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppColors.textDark,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                      '${rod.toY.toInt()}0.000đ',
                      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: _getBottomTitles)),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: _generateBarGroups(),
              ),
            ),
          ),

          const SizedBox(height: 32),
          _buildDynamicServiceList(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // --- LOGIC BIỂU ĐỒ ---
  Widget _getBottomTitles(double value, TitleMeta meta) {
    List<String> titles;
    if (selectedTime == 'Ngày') titles = ['0h', '6h', '12h', '18h', '24h'];
    else if (selectedTime == 'Tuần') titles = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    else if (selectedTime == 'Tháng') titles = ['W1', 'W2', 'W3', 'W4'];
    else titles = ['Q1', 'Q2', 'Q3', 'Q4'];
    return Text(titles[value.toInt() % titles.length], style: const TextStyle(fontSize: 10));
  }

  List<BarChartGroupData> _generateBarGroups() {
    List<double> values = (selectedTime == 'Tuần') ? [40, 70, 50, 85, 60, 30, 45] : [20, 50, 40, 90];
    return List.generate(values.length, (i) => BarChartGroupData(
      x: i,
      barRods: [BarChartRodData(toY: values[i], color: AppColors.primary, width: 16, borderRadius: BorderRadius.circular(4))],
    ));
  }

  // --- LOGIC HIỂN THỊ DỊCH VỤ ---
  Widget _buildDynamicServiceList() {
    if (selectedCategory == 'Tất cả') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Hiệu quả các dịch vụ chính', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildPerformanceRow('Café', 190, 'đơn', AppColors.peach, 0.8),
          _buildPerformanceRow('Spa', 100, 'đơn', AppColors.mint, 0.6),
          _buildPerformanceRow('Khách sạn', 100, 'đơn', AppColors.lavender, 0.5),
          _buildPerformanceRow('Bệnh viện', 55, 'ca', AppColors.sky, 0.3),
        ],
      );
    } else {
      final items = detailedStats[selectedCategory] ?? {};
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Chi tiết dịch vụ: $selectedCategory', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.cream)),
            child: Column(
              children: items.entries.map((entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key, style: const TextStyle(fontSize: 15)),
                    Text('${entry.value} đơn', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
              )).toList(),
            ),
          )
        ],
      );
    }
  }

  Widget _buildPerformanceRow(String title, int count, String unit, Color color, double percentage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(children: [
        Row(children: [Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 12), Text(title), const Spacer(), Text('$count $unit', style: const TextStyle(fontWeight: FontWeight.bold))]),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: percentage, color: color, backgroundColor: AppColors.cream, minHeight: 6, borderRadius: BorderRadius.circular(3)),
      ]),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color bgColor) {
    return Expanded(child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: bgColor.withOpacity(0.3), borderRadius: BorderRadius.circular(24)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon), const SizedBox(height: 16), Text(title), Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900))])));
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(context: context, builder: (context) => Column(mainAxisSize: MainAxisSize.min, children: categories.map((cat) => ListTile(title: Text(cat), onTap: () { setState(() => selectedCategory = cat); Navigator.pop(context); })).toList()));
  }
}