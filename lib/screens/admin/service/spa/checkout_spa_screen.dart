import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../theme/app_colors.dart';

class CheckoutSpaScreen extends StatefulWidget {
  final String customerName;
  final String customerPhone;
  final String serviceName;
  final int totalAmount;

  const CheckoutSpaScreen({
    super.key,
    required this.customerName,
    required this.customerPhone,
    required this.serviceName,
    required this.totalAmount,
  });

  @override
  State<CheckoutSpaScreen> createState() => _CheckoutSpaScreenState();
}

class _CheckoutSpaScreenState extends State<CheckoutSpaScreen> {
  String _paymentMethod = 'Tiền mặt';
  String _money(int v) =>
      '${v.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')}đ';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Thanh toán dịch vụ Spa")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "THÔNG TIN DỊCH VỤ",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const Divider(),
          ListTile(
            title: const Text("Khách hàng"),
            trailing: Text(
              widget.customerName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            title: const Text("Số điện thoại"),
            trailing: Text(widget.customerPhone),
          ),
          ListTile(
            title: const Text("Dịch vụ"),
            trailing: Text(
              widget.serviceName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(),
          Text(
            "TỔNG TIỀN: ${_money(widget.totalAmount)}",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 30),
          const Text(
            "PHƯƠNG THỨC THANH TOÁN",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          RadioListTile(
            title: const Text("Tiền mặt"),
            value: 'Tiền mặt',
            groupValue: _paymentMethod,
            onChanged: (v) => setState(() => _paymentMethod = v!),
          ),
          RadioListTile(
            title: const Text("Mã QR"),
            value: 'Mã QR',
            groupValue: _paymentMethod,
            onChanged: (v) => setState(() => _paymentMethod = v!),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            minimumSize: const Size(double.infinity, 50),
          ),
          onPressed: () async {
            // Lưu đơn Spa vào Firestore
            await FirebaseFirestore.instance.collection('orders').add({
              'category': 'spa',
              'customerName': widget.customerName,
              'customerPhone': widget.customerPhone,
              'serviceName': widget.serviceName,
              'totalAmount': widget.totalAmount,
              'paymentMethod': _paymentMethod,
              'status': 'completed',
              'createdAt': FieldValue.serverTimestamp(),
            });
            if (mounted) {
              Navigator.pop(context, true); // Trả về true để reset màn hình Spa
            }
          },
          child: const Text(
            "HOÀN TẤT THANH TOÁN",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ),
    );
  }
}
