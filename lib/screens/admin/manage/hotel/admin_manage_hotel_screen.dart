import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../theme/app_colors.dart';
import '../../../../services/cloudinary_upload_service.dart';

class AdminManageHotelScreen extends StatefulWidget {
  const AdminManageHotelScreen({super.key});

  @override
  State<AdminManageHotelScreen> createState() => _AdminManageHotelScreenState();
}

class _AdminManageHotelScreenState extends State<AdminManageHotelScreen> {
  final CollectionReference _hotelCollection = FirebaseFirestore.instance.collection('hotel_rooms');

  // 3 Hạng phòng theo yêu cầu
  final List<String> _roomCategories = ['Phòng Tiêu chuẩn', 'Phòng VIP', 'Phòng Cao cấp'];

  // Trạng thái phòng
  final List<String> _roomStatuses = ['Trống', 'Đã thuê'];

  // Dữ liệu giả để test
  final List<Map<String, dynamic>> _mockRooms = [
    {
      "id": "R1", "roomNumber": "101", "category": "Phòng Tiêu chuẩn", "price": 400000,
      "description": "Phòng giường đôi có cửa sổ.", "requirements": "Không hút thuốc",
      "services": "Wifi, Nước suối", "image": "", "status": "Trống", "isFirebase": false
    },
    {
      "id": "R2", "roomNumber": "201", "category": "Phòng VIP", "price": 800000,
      "description": "Phòng rộng view biển.", "requirements": "Không mang thú cưng",
      "services": "Wifi, Ăn sáng, Massage", "image": "", "status": "Đã thuê", "isFirebase": false
    },
  ];

  // Hàm định dạng tiền tệ có dấu chấm phân cách
  String formatCurrency(dynamic price) {
    if (price == null) return '0';
    String priceStr = price.toString();
    return priceStr.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Quản lý Phòng', style: TextStyle(fontWeight: FontWeight.bold))),
      body: StreamBuilder<QuerySnapshot>(
        stream: _hotelCollection.snapshots(),
        builder: (context, snapshot) {
          List<Map<String, dynamic>> combined = [];

          if (snapshot.hasData) {
            combined.addAll(snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id;
              data['isFirebase'] = true;
              return data;
            }));
          }
          combined.addAll(_mockRooms);

          // Thống kê số lượng
          int total = combined.length;
          int standardCount = combined.where((r) => r['category'] == 'Phòng Tiêu chuẩn').length;
          int vipCount = combined.where((r) => r['category'] == 'Phòng VIP').length;
          int luxuryCount = combined.where((r) => r['category'] == 'Phòng Cao cấp').length;
          int availableCount = combined.where((r) => r['status'] == 'Trống').length;

          return Column(
            children: [
              // BẢNG THỐNG KÊ CHI TIẾT
              Container(
                margin: const EdgeInsets.all(15),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10, spreadRadius: 2)],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Tổng số phòng:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("$total ($availableCount Trống)", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatBadge("Tiêu chuẩn", standardCount, Colors.blue),
                        _buildStatBadge("VIP", vipCount, Colors.orange),
                        _buildStatBadge("Cao cấp", luxuryCount, Colors.purple),
                      ],
                    )
                  ],
                ),
              ),

              // DANH SÁCH PHÒNG
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  itemCount: combined.length,
                  itemBuilder: (context, index) {
                    final item = combined[index];
                    final isFirebase = item['isFirebase'] == true;
                    final isAvailable = item['status'] == 'Trống';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          leading: Container(
                            width: 60, height: 60,
                            decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                image: (item['image'] != null && item['image'] != "")
                                    ? DecorationImage(image: NetworkImage(item['image']), fit: BoxFit.cover) : null
                            ),
                            child: (item['image'] == null || item['image'] == "")
                                ? const Icon(Icons.hotel, color: AppColors.primary) : null,
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Phòng ${item['roomNumber']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              // Badge Trạng thái
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                    color: isAvailable ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8)
                                ),
                                child: Text(item['status'], style: TextStyle(color: isAvailable ? Colors.green : Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                              )
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 5),
                              Text("${item['category']} • ${formatCurrency(item['price'])}đ"),
                              const SizedBox(height: 3),
                              Text("Dịch vụ: ${item['services']}", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                          trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                if (isFirebase) {
                                  _hotelCollection.doc(item['id']).delete();
                                } else {
                                  setState(() => _mockRooms.removeWhere((r) => r['id'] == item['id']));
                                }
                              }
                          ),
                          onTap: () => _showRoomForm(item: item),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRoomForm(),
        label: const Text("Thêm phòng"),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  // Widget vẽ badge thống kê
  Widget _buildStatBadge(String title, int count, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text("$count", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  // FORM THÊM / SỬA PHÒNG
  void _showRoomForm({Map<String, dynamic>? item}) {
    final roomNoCtrl = TextEditingController(text: item?['roomNumber'] ?? '');
    // MẸO: Khi load lên form cũng định dạng sẵn có dấu chấm cho đẹp
    final priceCtrl = TextEditingController(text: item != null ? formatCurrency(item['price']) : '');
    final descCtrl = TextEditingController(text: item?['description'] ?? '');
    final reqCtrl = TextEditingController(text: item?['requirements'] ?? '');
    final servicesCtrl = TextEditingController(text: item?['services'] ?? '');

    String selectedCat = item?['category'] ?? _roomCategories.first;
    String selectedStatus = item?['status'] ?? _roomStatuses.first;
    String? currentImageUrl = item?['image'] ?? '';
    bool isUploading = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(item == null ? 'Thêm phòng mới' : 'Cập nhật phòng'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Upload ảnh phòng
                GestureDetector(
                  onTap: () async {
                    final image = await CloudinaryUploadService.pickImageFromGallery();
                    if (image != null) {
                      setDialogState(() => isUploading = true);
                      final result = await CloudinaryUploadService.uploadImageFile(image);
                      setDialogState(() {
                        currentImageUrl = CloudinaryUploadService.optimizedImageUrl(result.imageUrl);
                        isUploading = false;
                      });
                    }
                  },
                  child: Container(
                    height: 120, width: double.infinity,
                    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
                    child: isUploading
                        ? const Center(child: CircularProgressIndicator())
                        : (currentImageUrl != null && currentImageUrl != ""
                        ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(currentImageUrl!, fit: BoxFit.cover))
                        : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo, color: Colors.grey, size: 30), Text("Thêm ảnh phòng")])),
                  ),
                ),
                const SizedBox(height: 15),

                // Trạng thái phòng (Đổi màu theo trạng thái)
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  items: _roomStatuses.map((s) => DropdownMenuItem(value: s, child: Text(s, style: TextStyle(color: s == 'Trống' ? Colors.green : Colors.red, fontWeight: FontWeight.bold)))).toList(),
                  onChanged: (val) => setDialogState(() => selectedStatus = val!),
                  decoration: const InputDecoration(labelText: 'Trạng thái hiện tại', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(child: TextField(controller: roomNoCtrl, decoration: const InputDecoration(labelText: 'Số phòng', border: OutlineInputBorder()))),
                    const SizedBox(width: 10),
                    Expanded(child: TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Giá tiền', border: OutlineInputBorder()))),
                  ],
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedCat,
                  items: _roomCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) => setDialogState(() => selectedCat = val!),
                  decoration: const InputDecoration(labelText: 'Hạng phòng', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(controller: servicesCtrl, decoration: const InputDecoration(labelText: 'Dịch vụ kèm (VD: Ăn sáng, Massage)', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Mô tả phòng', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: reqCtrl, decoration: const InputDecoration(labelText: 'Yêu cầu (VD: Không hút thuốc)', border: OutlineInputBorder())),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: isUploading ? null : () async {
                final roomNo = roomNoCtrl.text.trim();
                if (roomNo.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập Số phòng!'), backgroundColor: Colors.orange));
                  return;
                }

                // CẢI TIẾN: Lọc bỏ toàn bộ dấu chấm, phẩy, chữ... chỉ giữ lại số trước khi lưu vào DB
                String rawPrice = priceCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
                int finalPrice = int.tryParse(rawPrice) ?? 0;

                final data = {
                  'roomNumber': roomNo, 'price': finalPrice, // Dùng số đã được lọc sạch
                  'category': selectedCat, 'status': selectedStatus,
                  'description': descCtrl.text, 'requirements': reqCtrl.text,
                  'services': servicesCtrl.text, 'image': currentImageUrl
                };

                try {
                  if (item != null) {
                    if (item['isFirebase'] == true) {
                      await _hotelCollection.doc(item['id']).update(data);
                    } else {
                      setState(() {
                        final index = _mockRooms.indexWhere((r) => r['id'] == item['id']);
                        if (index != -1) _mockRooms[index] = {..._mockRooms[index], ...data};
                      });
                    }
                  } else {
                    await _hotelCollection.add(data);
                  }
                  if (mounted) Navigator.pop(dialogContext);
                } catch (e) {
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }
}