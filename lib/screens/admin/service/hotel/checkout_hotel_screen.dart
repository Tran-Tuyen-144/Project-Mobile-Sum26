import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../theme/app_colors.dart';

class CheckoutScreen extends StatefulWidget {
  final String category;
  final int totalAmount;
  final Map<String, dynamic> summaryData;
  final Future<void> Function()? onConfirm;

  const CheckoutScreen({
    super.key,
    required this.category,
    required this.totalAmount,
    required this.summaryData,
    this.onConfirm,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _paymentMethod = 'Tiền mặt';
  String _money(int v) => '${v.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')}đ';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Xác nhận thanh toán")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text("TÓM TẮT ĐẶT PHÒNG", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const Divider(),

          // Hiển thị thông tin tóm tắt trên một dòng
          ...widget.summaryData.entries.map((e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(e.key, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    e.value.toString(),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          )),

          const Divider(),
          const SizedBox(height: 10),
          Text("TỔNG CỘNG: ${_money(widget.totalAmount)}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),

          const SizedBox(height: 30),
          const Text("PHƯƠNG THỨC THANH TOÁN", style: TextStyle(fontWeight: FontWeight.bold)),
          RadioListTile(title: const Text("Tiền mặt"), value: 'Tiền mặt', groupValue: _paymentMethod, onChanged: (v) => setState(() => _paymentMethod = v!)),
          RadioListTile(title: const Text("Mã QR"), value: 'Mã QR', groupValue: _paymentMethod, onChanged: (v) => setState(() => _paymentMethod = v!)),

          if (_paymentMethod == 'Mã QR')
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Image.network(
                    "https://img.vietqr.io/image/970436-0987654321-compact2.png?amount=${widget.totalAmount}",
                    height: 180
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size(double.infinity, 50)),
          onPressed: () async {
            Map<String, dynamic> finalOrder = Map.from(widget.summaryData);
            finalOrder.addAll({
              'category': widget.category,
              'totalAmount': widget.totalAmount,
              'paymentMethod': _paymentMethod,
              'status': 'completed',
              'createdAt': FieldValue.serverTimestamp()
            });

            await FirebaseFirestore.instance.collection('orders').add(finalOrder);

            // Xử lý các logic đặc biệt của từng dịch vụ (như cập nhật trạng thái phòng)
            if (widget.onConfirm != null) await widget.onConfirm!();

            if (mounted) Navigator.pop(context, true);
          },
          child: const Text("XÁC NHẬN HOÀN TẤT", style: TextStyle(color: Colors.white, fontSize: 18)),
        ),
      ),
    );
  }
}