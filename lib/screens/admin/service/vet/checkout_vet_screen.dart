import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../theme/app_colors.dart';

class CheckoutVetScreen extends StatefulWidget {
  final Map<String, dynamic> orderData; // Chứa thông tin khách, pet, dịch vụ, tiền

  const CheckoutVetScreen({super.key, required this.orderData});

  @override
  State<CheckoutVetScreen> createState() => _CheckoutVetScreenState();
}

class _CheckoutVetScreenState extends State<CheckoutVetScreen> {
  String _paymentMethod = 'Tiền mặt';
  String _money(int v) => '${v.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')}đ';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Xác nhận thanh toán Thú y")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text("TÓM TẮT DỊCH VỤ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const Divider(),
          ListTile(title: const Text("Chủ nuôi"), trailing: Text(widget.orderData['customerName'])),
          ListTile(title: const Text("Thú cưng"), trailing: Text(widget.orderData['petName'] ?? "Không tên")),
          ListTile(title: const Text("Dịch vụ chính"), trailing: Text(widget.orderData['mainService'])),
          if ((widget.orderData['extraServices'] as List).isNotEmpty)
            ListTile(title: const Text("Dịch vụ kèm"), trailing: Text((widget.orderData['extraServices'] as List).join(', '))),
          const Divider(),
          Text("TỔNG CỘNG: ${_money(widget.orderData['totalAmount'])}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),

          const SizedBox(height: 30),
          const Text("PHƯƠNG THỨC THANH TOÁN", style: TextStyle(fontWeight: FontWeight.bold)),
          RadioListTile(title: const Text("Tiền mặt"), value: 'Tiền mặt', groupValue: _paymentMethod, onChanged: (v) => setState(() => _paymentMethod = v!)),
          RadioListTile(title: const Text("Mã QR"), value: 'Mã QR', groupValue: _paymentMethod, onChanged: (v) => setState(() => _paymentMethod = v!)),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size(double.infinity, 50)),
          onPressed: () async {
            Map<String, dynamic> finalOrder = Map.from(widget.orderData);
            finalOrder['paymentMethod'] = _paymentMethod;
            finalOrder['status'] = 'completed';
            finalOrder['createdAt'] = FieldValue.serverTimestamp();

            await FirebaseFirestore.instance.collection('orders').add(finalOrder);
            if (mounted) Navigator.pop(context, true);
          },
          child: const Text("XÁC NHẬN HOÀN TẤT", style: TextStyle(color: Colors.white, fontSize: 18)),
        ),
      ),
    );
  }
}