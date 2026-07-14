import 'package:flutter/material.dart';
import '../../../../models/staff/cafe_bill.dart';
import '../../../../storage/staff_bill_storage.dart';
import '../../../../theme/app_colors.dart';

class CafeMenuTab extends StatefulWidget {
  const CafeMenuTab({super.key});

  @override
  State<CafeMenuTab> createState() => _CafeMenuTabState();
}

class _CafeMenuTabState extends State<CafeMenuTab> {
  final TextEditingController _customerController = TextEditingController();
  final Map<String, int> _cart = {};

  final List<Map<String, dynamic>> _drinks = [
    {'name': 'Latte Mây Xanh', 'price': 45000},
    {'name': 'Cappuccino PetHub', 'price': 49000},
    {'name': 'Trà Đào Cam Sả', 'price': 42000},
    {'name': 'Sinh Tố Bơ Sữa', 'price': 50000},
  ];

  int get _totalPrice {
    int total = 0;
    _cart.forEach((name, qty) {
      final item = _drinks.firstWhere((e) => e['name'] == name);
      total += (item['price'] as int) * qty;
    });
    return total;
  }

  void _exportBill() async {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn món!')));
      return;
    }

    final bill = CafeBill(
      id: 'BILL-${DateTime.now().millisecondsSinceEpoch}',
      customerName: _customerController.text.isNotEmpty ? _customerController.text : 'Khách lẻ',
      staffName: 'Nguyễn Minh An',
      totalPrice: _totalPrice,
      items: _cart,
      createdAt: DateTime.now(),
    );

    bool success = await StaffBillStorage.createBill(bill);

    if (success) {
      setState(() { _cart.clear(); _customerController.clear(); });
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text('Thành công', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
            content: const Text('Bill đã được lưu lên hệ thống.', style: TextStyle(color: AppColors.textSoft)),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))
              )
            ],
          )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
          title: const Text('Order & Xuất Bill', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textDark,
          elevation: 0
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: TextField(
              controller: _customerController,
              style: const TextStyle(color: AppColors.textDark),
              decoration: InputDecoration(
                labelText: 'Tên khách hàng (Tùy chọn)',
                labelStyle: const TextStyle(color: AppColors.textSoft),
                prefixIcon: const Icon(Icons.person, color: AppColors.textSoft),
                filled: true,
                fillColor: AppColors.surface,
                enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: AppColors.cream, width: 2), borderRadius: BorderRadius.circular(16)),
                focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: AppColors.primary, width: 2), borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              itemCount: _drinks.length,
              itemBuilder: (context, index) {
                final item = _drinks[index];
                final name = item['name'] as String;
                final qty = _cart[name] ?? 0;

                return Card(
                  color: AppColors.surface,
                  elevation: 0,
                  shape: RoundedRectangleBorder(side: const BorderSide(color: AppColors.cream, width: 2), borderRadius: BorderRadius.circular(16)),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: Text(name, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.textDark)),
                    subtitle: Text('${item['price']}đ', style: const TextStyle(color: AppColors.textSoft, fontWeight: FontWeight.bold)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            icon: Icon(Icons.remove_circle_outline, color: qty > 0 ? AppColors.textDark : AppColors.textSoft),
                            onPressed: () => setState(() {
                              if (qty > 1) _cart[name] = qty - 1; else _cart.remove(name);
                            })
                        ),
                        SizedBox(
                            width: 24,
                            child: Text('$qty', textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark))
                        ),
                        IconButton(
                            icon: const Icon(Icons.add_circle, color: AppColors.primary),
                            onPressed: () => setState(() => _cart[name] = qty + 1)
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Color(0x0C000000), blurRadius: 15, offset: Offset(0, -5))]
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tổng tiền', style: TextStyle(color: AppColors.textSoft, fontWeight: FontWeight.w600)),
                    Text('${_totalPrice}đ', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primary)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _exportBill,
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.surface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                  ),
                  icon: const Icon(Icons.print_rounded),
                  label: const Text('Xuất Bill', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}