import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../theme/app_colors.dart';
import 'checkout_hotel_screen.dart';

class AdminHotelServiceScreen extends StatefulWidget {
  const AdminHotelServiceScreen({super.key});
  @override
  State<AdminHotelServiceScreen> createState() => _AdminHotelServiceScreenState();
}

class _AdminHotelServiceScreenState extends State<AdminHotelServiceScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String _selectedCategory = 'Phòng Tiêu chuẩn';
  DocumentSnapshot? _selectedRoom;

  DateTime? _checkIn;
  DateTime? _checkOut;

  String formatCurrency(dynamic price) => price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  String formatDate(DateTime? date) {
    if (date == null) return '';
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  int get totalAmount {
    if (_selectedRoom == null || _checkIn == null || _checkOut == null) return 0;
    int days = _checkOut!.difference(_checkIn!).inDays;
    if (days <= 0) days = 1;
    return (_selectedRoom!['price'] as int) * days;
  }

  Future<void> _pickDate(bool isCheckIn) async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: isCheckIn ? DateTime.now() : (_checkIn ?? DateTime.now()),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100)
    );
    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkIn = picked;
          if (_checkOut != null && _checkOut!.isBefore(_checkIn!)) _checkOut = null;
        } else {
          _checkOut = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Đặt phòng Khách sạn', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Họ tên (*)', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: _phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Số điện thoại', border: OutlineInputBorder())),
            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton.icon(
                  icon: const Icon(Icons.calendar_today, color: Colors.white),
                  label: Text(_checkIn == null ? "Chọn ngày Nhận phòng" : "Nhận phòng: ${formatDate(_checkIn)}", style: const TextStyle(fontSize: 16, color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, alignment: Alignment.centerLeft, padding: const EdgeInsets.symmetric(horizontal: 16)),
                  onPressed: () => _pickDate(true)
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton.icon(
                  icon: const Icon(Icons.event_available, color: Colors.white),
                  label: Text(_checkOut == null ? "Chọn ngày Trả phòng" : "Trả phòng: ${formatDate(_checkOut)}", style: const TextStyle(fontSize: 16, color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary.withOpacity(0.8), alignment: Alignment.centerLeft, padding: const EdgeInsets.symmetric(horizontal: 16)),
                  onPressed: _checkIn == null ? null : () => _pickDate(false)
              ),
            ),
            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Loại phòng', border: OutlineInputBorder()),
              value: _selectedCategory,
              items: ['Phòng Tiêu chuẩn', 'Phòng VIP', 'Phòng Cao cấp'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) => setState(() { _selectedCategory = val!; _selectedRoom = null; }),
            ),
            const SizedBox(height: 15),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('hotel_rooms')
                  .where('status', isEqualTo: 'Trống')
                .where('category', isEqualTo: _selectedCategory).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                final rooms = snapshot.data?.docs ?? [];
                if (rooms.isEmpty) return const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text("Không có phòng trống cho hạng này.", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)));

                return Column(
                  children: rooms.map((room) => Card(
                    color: _selectedRoom?.id == room.id ? AppColors.primary.withOpacity(0.2) : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: _selectedRoom?.id == room.id ? AppColors.primary : Colors.grey.shade300)),
                    child: ListTile(
                      title: Text("Phòng ${room['roomNumber']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("${formatCurrency(room['price'])}đ / đêm"),
                      trailing: _selectedRoom?.id == room.id ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
                      onTap: () => setState(() => _selectedRoom = room),
                    ),
                  )).toList(),
                );
              },
            ),
            const SizedBox(height: 15),
            TextField(controller: _noteCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Ghi chú thêm', border: OutlineInputBorder())),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, -5))]),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: (_selectedRoom == null || _checkIn == null || _checkOut == null)
                ? null
                : () => _navigateToCheckout(),
            child: const Text("Thanh toán", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  void _navigateToCheckout() async {
    if (_nameCtrl.text.isEmpty || _selectedRoom == null || _checkIn == null || _checkOut == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng điền đủ thông tin!'), backgroundColor: Colors.red));
      return;
    }

    // Gói thông tin tóm tắt để truyền sang màn hình Checkout
    final summary = {
      'Họ tên': _nameCtrl.text,
      'SĐT': _phoneCtrl.text,
      'Phòng': "Phòng ${_selectedRoom!['roomNumber']}",
      'Nhận phòng': formatDate(_checkIn),
      'Trả phòng': formatDate(_checkOut),
      'Ghi chú': _noteCtrl.text,
    };

    // Chuyển sang màn hình Checkout
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CheckoutScreen(
        category: 'hotel',
        totalAmount: totalAmount,
        summaryData: summary,
        onConfirm: () async {
          // Cập nhật trạng thái phòng trong Firebase sau khi thanh toán thành công
          await FirebaseFirestore.instance.collection('hotel_rooms').doc(_selectedRoom!.id).update({'status': 'Đã thuê'});
        },
      )),
    );

    if (result == true) {
      setState(() {
        _nameCtrl.clear();
        _phoneCtrl.clear();
        _noteCtrl.clear();
        _selectedRoom = null;
        _checkIn = null;
        _checkOut = null;
      });
    }
  }
}