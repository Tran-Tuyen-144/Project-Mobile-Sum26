import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../theme/app_colors.dart';
// ĐÃ SỬA: Import đúng vị trí
import 'checkout_vet_screen.dart';

class _VetItem {
  final String id;
  final String name;
  final int price;

  _VetItem({required this.id, required this.name, required this.price});

  @override
  bool operator ==(Object other) => identical(this, other) || other is _VetItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class AdminVetServiceScreen extends StatefulWidget {
  const AdminVetServiceScreen({super.key});
  @override
  State<AdminVetServiceScreen> createState() => _AdminVetServiceScreenState();
}

class _AdminVetServiceScreenState extends State<AdminVetServiceScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _petNameCtrl = TextEditingController();
  final _petDetailsCtrl = TextEditingController();

  final List<_VetItem> _mockVetServices = [
    _VetItem(id: 'mock_1', name: 'Khám tổng quát', price: 150000),
    _VetItem(id: 'mock_2', name: 'Tiêm phòng Vaccine', price: 200000),
    _VetItem(id: 'mock_3', name: 'Siêu âm / X-Quang', price: 300000),
    _VetItem(id: 'mock_4', name: 'Triệt sản chó/mèo', price: 500000),
  ];

  _VetItem? _mainService;
  final List<_VetItem> _extraServices = [];
  final DateTime _currentTime = DateTime.now();

  String formatCurrency(dynamic price) => price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

  int get totalAmount {
    int mainPrice = _mainService?.price ?? 0;
    int extraPrice = _extraServices.fold(0, (sum, item) => sum + item.price);
    return mainPrice + extraPrice;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Bệnh viện Y tế Vet', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Họ tên Chủ (*)', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Số điện thoại (*)', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _petNameCtrl, decoration: const InputDecoration(labelText: 'Tên thú cưng', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _petDetailsCtrl, decoration: const InputDecoration(labelText: 'Loài / Đặc điểm (*)', border: OutlineInputBorder())),
            const SizedBox(height: 25),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('vet_services').snapshots(),
              builder: (context, snapshot) {
                List<_VetItem> combinedServices = List.from(_mockVetServices);
                if (snapshot.hasData) {
                  final firebaseData = snapshot.data!.docs.map((doc) => _VetItem(
                    id: doc.id,
                    name: doc['name'] ?? 'Không tên',
                    price: doc['price'] ?? 0,
                  )).toList();
                  combinedServices.addAll(firebaseData);
                }

                return Column(
                  children: [
                    DropdownButtonFormField<_VetItem>(
                      decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Chọn dịch vụ chính'),
                      value: _mainService,
                      items: combinedServices.map((item) => DropdownMenuItem(value: item, child: Text("${item.name} - ${formatCurrency(item.price)}đ"))).toList(),
                      onChanged: (val) => setState(() => _mainService = val),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 15)),
          // ĐÃ SỬA: Gọi hàm điều hướng mới
          onPressed: _mainService == null ? null : () => _navigateToCheckout(),
          child: const Text("Xác nhận thanh toán", style: TextStyle(fontSize: 18, color: Colors.white)),
        ),
      ),
    );
  }

  // ĐÃ SỬA: Hàm điều hướng chuẩn
  void _navigateToCheckout() async {
    if (_nameCtrl.text.isEmpty || _phoneCtrl.text.isEmpty || _petDetailsCtrl.text.isEmpty || _mainService == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập đủ thông tin!')));
      return;
    }

    final orderData = {
      'category': 'vet',
      'customerName': _nameCtrl.text.trim(),
      'customerPhone': _phoneCtrl.text.trim(),
      'petName': _petNameCtrl.text.trim(),
      'petDetails': _petDetailsCtrl.text.trim(),
      'mainService': _mainService!.name,
      'extraServices': _extraServices.map((e) => e.name).toList(),
      'totalAmount': totalAmount,
      'checkupTime': _currentTime.toIso8601String(),
    };

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CheckoutVetScreen(orderData: orderData)),
    );

    if (result == true) {
      setState(() {
        _nameCtrl.clear(); _phoneCtrl.clear(); _petNameCtrl.clear(); _petDetailsCtrl.clear();
        _mainService = null; _extraServices.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thanh toán thành công!')));
    }
  }
}