import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../theme/app_colors.dart';
// ĐÃ SỬA: Chuyển import lên đúng vị trí đầu file
import 'checkout_spa_screen.dart';

class _SpaItem {
  final String id;
  final String name;
  final int price;
  _SpaItem({required this.id, required this.name, required this.price});
}

class AdminSpaServiceScreen extends StatefulWidget {
  const AdminSpaServiceScreen({super.key});
  @override
  State<AdminSpaServiceScreen> createState() => _AdminSpaServiceScreenState();
}

class _AdminSpaServiceScreenState extends State<AdminSpaServiceScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  final List<_SpaItem> _mockSpaServices = [
    _SpaItem(id: 'mock_1', name: 'Tắm sấy cơ bản (Dưới 5kg)', price: 100000),
    _SpaItem(id: 'mock_2', name: 'Cắt tỉa lông tạo kiểu', price: 250000),
    _SpaItem(id: 'mock_3', name: 'Cắt móng & Vệ sinh tai', price: 50000),
  ];

  String? _selectedServiceId;
  _SpaItem? _selectedServiceData;

  String formatCurrency(dynamic price) => price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Đặt lịch Spa', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Thông tin khách hàng", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Họ tên khách hàng (*)', border: OutlineInputBorder())),
            const SizedBox(height: 15),
            TextField(controller: _phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Số điện thoại', border: OutlineInputBorder())),
            const SizedBox(height: 25),

            const Text("Dịch vụ sử dụng", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('spa_services').snapshots(),
              builder: (context, snapshot) {
                List<_SpaItem> combinedServices = List.from(_mockSpaServices);
                if (snapshot.hasData) {
                  final firebaseData = snapshot.data!.docs.map((doc) => _SpaItem(
                    id: doc.id,
                    name: doc['name'] ?? 'Không tên',
                    price: doc['price'] ?? 0,
                  )).toList();
                  combinedServices.addAll(firebaseData);
                }

                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Chọn dịch vụ Spa', border: OutlineInputBorder()),
                  value: _selectedServiceId,
                  items: combinedServices.map((item) => DropdownMenuItem(
                      value: item.id,
                      child: Text("${item.name} - ${formatCurrency(item.price)}đ")
                  )).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedServiceId = val;
                      _selectedServiceData = combinedServices.firstWhere((e) => e.id == val);
                    });
                  },
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, -5))]),
        child: SafeArea(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            // ĐÃ SỬA: Gọi hàm _navigateToCheckout mới thay vì hàm BottomSheet cũ
            onPressed: _selectedServiceData == null ? null : () => _navigateToCheckout(),
            child: Text(
                _selectedServiceData == null ? "Chọn dịch vụ trước" : "Thanh toán",
                style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)
            ),
          ),
        ),
      ),
    );
  }

  // ĐÃ SỬA: Hàm luồng Checkout mới
  void _navigateToCheckout() async {
    if (_nameCtrl.text.isEmpty || _selectedServiceData == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập tên và chọn dịch vụ!'), backgroundColor: Colors.red));
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CheckoutSpaScreen(
        customerName: _nameCtrl.text,
        customerPhone: _phoneCtrl.text,
        serviceName: _selectedServiceData!.name,
        totalAmount: _selectedServiceData!.price,
      )),
    );

    if (result == true) {
      setState(() {
        _nameCtrl.clear();
        _phoneCtrl.clear();
        _selectedServiceId = null;
        _selectedServiceData = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đặt lịch Spa thành công!'), backgroundColor: Colors.green));
    }
  }
}