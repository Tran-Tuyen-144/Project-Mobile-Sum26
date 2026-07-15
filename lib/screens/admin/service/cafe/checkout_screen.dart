import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CheckoutScreen extends StatefulWidget {
  final int totalAmount;
  final Map<String, int> cart;
  final Map<String, dynamic> cartItems;

  const CheckoutScreen({
    super.key,
    required this.totalAmount,
    required this.cart,
    required this.cartItems,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _orderType = 'Tại quán';
  String? _selectedTableId;
  String? _selectedTableName;
  String _paymentMethod = 'Tiền mặt';

  String _money(int v) =>
      '${v.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')}đ';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Xác nhận & Thanh toán")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "TÓM TẮT ĐƠN HÀNG",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const Divider(),
          ...widget.cart.entries.map(
            (e) => ListTile(
              title: Text(widget.cartItems[e.key].name),
              trailing: Text(
                "x${e.value} | ${_money(widget.cartItems[e.key].price * e.value)}",
              ),
            ),
          ),
          const Divider(),
          Text(
            "TỔNG CỘNG: ${_money(widget.totalAmount)}",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          const Text(
            "HÌNH THỨC PHỤC VỤ",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Expanded(
                child: RadioListTile(
                  title: const Text("Tại quán"),
                  value: 'Tại quán',
                  groupValue: _orderType,
                  onChanged: (v) => setState(() => _orderType = v!),
                ),
              ),
              Expanded(
                child: RadioListTile(
                  title: const Text("Mang về"),
                  value: 'Mang về',
                  groupValue: _orderType,
                  onChanged: (v) => setState(() => _orderType = v!),
                ),
              ),
            ],
          ),
          if (_orderType == 'Tại quán')
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('tables')
                  .where('status', isEqualTo: 'Trống')
                  .snapshots(),
              builder: (ctx, snap) => DropdownButtonFormField(
                decoration: const InputDecoration(
                  labelText: "Chọn bàn trống",
                  border: OutlineInputBorder(),
                ),
                items:
                    snap.data?.docs
                        .map(
                          (t) => DropdownMenuItem(
                            value: t.id,
                            child: Text(t['name']),
                          ),
                        )
                        .toList() ??
                    [],
                onChanged: (v) {
                  _selectedTableId = v as String;
                  _selectedTableName = snap.data!.docs.firstWhere(
                    (t) => t.id == v,
                  )['name'];
                },
              ),
            ),
          const SizedBox(height: 20),
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
            if (_orderType == 'Tại quán' && _selectedTableId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Vui lòng chọn bàn!")),
              );
              return;
            }
            await FirebaseFirestore.instance.collection('orders').add({
              'category': 'cafe',
              'totalAmount': widget.totalAmount,
              'orderType': _orderType,
              'tableName': _selectedTableName,
              'paymentMethod': _paymentMethod,
              'items': widget.cart.entries
                  .map(
                    (e) => {
                      'name': widget.cartItems[e.key].name,
                      'qty': e.value,
                    },
                  )
                  .toList(),
              'status': 'completed',
              'createdAt': FieldValue.serverTimestamp(),
            });
            if (_orderType == 'Tại quán') {
              await FirebaseFirestore.instance
                  .collection('tables')
                  .doc(_selectedTableId)
                  .update({'status': 'Đã thuê'});
            }
            if (mounted) Navigator.pop(context, true);
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
