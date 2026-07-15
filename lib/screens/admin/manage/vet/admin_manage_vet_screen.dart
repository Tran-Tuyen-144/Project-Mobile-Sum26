import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../theme/app_colors.dart';
import '../../../../services/cloudinary_upload_service.dart';

class AdminManageVetScreen extends StatelessWidget {
  const AdminManageVetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // 2 Tabs: Dịch vụ và Bác sĩ
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'Bệnh viện Thú y',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(icon: Icon(Icons.medical_services), text: 'Dịch vụ'),
              Tab(icon: Icon(Icons.people), text: 'Bác sĩ Thú y'),
            ],
          ),
        ),
        body: const TabBarView(children: [_VetServicesTab(), _VetDoctorsTab()]),
      ),
    );
  }
}

// ==========================================
// TAB 1: QUẢN LÝ DỊCH VỤ
// ==========================================
class _VetServicesTab extends StatefulWidget {
  const _VetServicesTab();
  @override
  State<_VetServicesTab> createState() => _VetServicesTabState();
}

class _VetServicesTabState extends State<_VetServicesTab> {
  final CollectionReference _servicesCollection = FirebaseFirestore.instance
      .collection('vet_services');

  final List<Map<String, dynamic>> _mockServices = [
    {
      "id": "VS1",
      "name": "Khám tổng quát",
      "description": "Kiểm tra sức khỏe toàn diện cho thú cưng",
      "price": 150000,
      "isFirebase": false,
    },
    {
      "id": "VS2",
      "name": "Tiêm phòng Vaccine",
      "description": "Tiêm phòng dại và các bệnh phổ biến",
      "price": 200000,
      "isFirebase": false,
    },
  ];
  String formatCurrency(dynamic price) {
    if (price == null) return '0';
    String priceStr = price.toString();
    // Tự động chèn dấu chấm sau mỗi 3 chữ số
    return priceStr.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<QuerySnapshot>(
        stream: _servicesCollection.snapshots(),
        builder: (context, snapshot) {
          List<Map<String, dynamic>> combined = [];
          if (snapshot.hasData) {
            combined.addAll(
              snapshot.data!.docs.map(
                (doc) => {
                  ...doc.data() as Map<String, dynamic>,
                  'id': doc.id,
                  'isFirebase': true,
                },
              ),
            );
          }
          combined.addAll(_mockServices);

          return Column(
            children: [
              _buildHeaderStat("Tổng số Dịch vụ Y tế:", combined.length),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: combined.length,
                  itemBuilder: (context, index) {
                    final item = combined[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.healing, color: Colors.blue),
                        ),
                        title: Text(
                          item['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "${formatCurrency(item['price'])}đ\n${item['description']}",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        isThreeLine: true,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => item['isFirebase'] == true
                              ? _servicesCollection.doc(item['id']).delete()
                              : setState(
                                  () => _mockServices.removeWhere(
                                    (s) => s['id'] == item['id'],
                                  ),
                                ),
                        ),
                        onTap: () => _showServiceForm(item: item),
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
        onPressed: () => _showServiceForm(),
        label: const Text("Thêm Dịch vụ"),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showServiceForm({Map<String, dynamic>? item}) {
    final nameCtrl = TextEditingController(text: item?['name'] ?? '');
    final priceCtrl = TextEditingController(
      text: item?['price']?.toString() ?? '',
    );
    final descCtrl = TextEditingController(text: item?['description'] ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(item == null ? 'Thêm Dịch vụ' : 'Cập nhật Dịch vụ'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tên dịch vụ (*)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Giá tiền',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Mô tả chi tiết',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng nhập Tên dịch vụ!'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              final data = {
                'name': nameCtrl.text.trim(),
                'price': int.tryParse(priceCtrl.text) ?? 0,
                'description': descCtrl.text.trim(),
              };

              if (item != null) {
                item['isFirebase'] == true
                    ? await _servicesCollection.doc(item['id']).update(data)
                    : setState(() {
                        final idx = _mockServices.indexWhere(
                          (s) => s['id'] == item['id'],
                        );
                        if (idx != -1) {
                          _mockServices[idx] = {..._mockServices[idx], ...data};
                        }
                      });
              } else {
                await _servicesCollection.add(data);
              }
              if (mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// TAB 2: QUẢN LÝ BÁC SĨ
// ==========================================
class _VetDoctorsTab extends StatefulWidget {
  const _VetDoctorsTab();
  @override
  State<_VetDoctorsTab> createState() => _VetDoctorsTabState();
}

class _VetDoctorsTabState extends State<_VetDoctorsTab> {
  final CollectionReference _doctorsCollection = FirebaseFirestore.instance
      .collection('vet_doctors');

  final List<Map<String, dynamic>> _mockDoctors = [
    {
      "id": "D1",
      "doctorId": "BS01",
      "name": "Nguyễn Văn A",
      "specialty": "Ngoại khoa",
      "phone": "0987654321",
      "email": "bs.a@pethub.com",
      "image": "",
      "isFirebase": false,
    },
    {
      "id": "D2",
      "doctorId": "BS02",
      "name": "Trần Thị B",
      "specialty": "Nội khoa",
      "phone": "0123456789",
      "email": "bs.b@pethub.com",
      "image": "",
      "isFirebase": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<QuerySnapshot>(
        stream: _doctorsCollection.snapshots(),
        builder: (context, snapshot) {
          List<Map<String, dynamic>> combined = [];
          if (snapshot.hasData) {
            combined.addAll(
              snapshot.data!.docs.map(
                (doc) => {
                  ...doc.data() as Map<String, dynamic>,
                  'id': doc.id,
                  'isFirebase': true,
                },
              ),
            );
          }
          combined.addAll(_mockDoctors);

          return Column(
            children: [
              _buildHeaderStat("Tổng số Bác sĩ:", combined.length),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: combined.length,
                  itemBuilder: (context, index) {
                    final item = combined[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.2,
                          ),
                          backgroundImage:
                              (item['image'] != null && item['image'] != "")
                              ? NetworkImage(item['image'])
                              : null,
                          child: (item['image'] == null || item['image'] == "")
                              ? const Icon(
                                  Icons.person,
                                  color: AppColors.primary,
                                )
                              : null,
                        ),
                        title: Text(
                          "${item['name']} (${item['doctorId']})",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Chuyên khoa: ${item['specialty']}\nSĐT: ${item['phone']}",
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => item['isFirebase'] == true
                              ? _doctorsCollection.doc(item['id']).delete()
                              : setState(
                                  () => _mockDoctors.removeWhere(
                                    (d) => d['id'] == item['id'],
                                  ),
                                ),
                        ),
                        onTap: () => _showDoctorForm(item: item),
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
        onPressed: () => _showDoctorForm(),
        label: const Text("Thêm Bác sĩ"),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showDoctorForm({Map<String, dynamic>? item}) {
    final idCtrl = TextEditingController(text: item?['doctorId'] ?? '');
    final nameCtrl = TextEditingController(text: item?['name'] ?? '');
    final specCtrl = TextEditingController(text: item?['specialty'] ?? '');
    final phoneCtrl = TextEditingController(text: item?['phone'] ?? '');
    final emailCtrl = TextEditingController(text: item?['email'] ?? '');

    String? currentImageUrl = item?['image'] ?? '';
    bool isUploading = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(item == null ? 'Thêm Bác sĩ' : 'Hồ sơ Bác sĩ'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Avatar upload
                GestureDetector(
                  onTap: () async {
                    final image =
                        await CloudinaryUploadService.pickImageFromGallery();
                    if (image != null) {
                      setDialogState(() => isUploading = true);
                      final result =
                          await CloudinaryUploadService.uploadImageFile(image);
                      setDialogState(() {
                        currentImageUrl =
                            CloudinaryUploadService.optimizedImageUrl(
                              result.imageUrl,
                            );
                        isUploading = false;
                      });
                    }
                  },
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    backgroundImage:
                        (currentImageUrl != null && currentImageUrl != "")
                        ? NetworkImage(currentImageUrl!)
                        : null,
                    child: isUploading
                        ? const CircularProgressIndicator()
                        : ((currentImageUrl == null || currentImageUrl == "")
                              ? const Icon(
                                  Icons.camera_alt,
                                  color: Colors.grey,
                                  size: 30,
                                )
                              : null),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: idCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Mã BS',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Họ & Tên (*)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: specCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Chuyên khoa',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Số điện thoại',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: isUploading
                  ? null
                  : () async {
                      if (nameCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Vui lòng nhập Tên bác sĩ!'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }
                      final data = {
                        'doctorId': idCtrl.text.trim(),
                        'name': nameCtrl.text.trim(),
                        'specialty': specCtrl.text.trim(),
                        'phone': phoneCtrl.text.trim(),
                        'email': emailCtrl.text.trim(),
                        'image': currentImageUrl,
                      };

                      try {
                        if (item != null) {
                          item['isFirebase'] == true
                              ? await _doctorsCollection
                                    .doc(item['id'])
                                    .update(data)
                              : setState(() {
                                  final idx = _mockDoctors.indexWhere(
                                    (d) => d['id'] == item['id'],
                                  );
                                  if (idx != -1) {
                                    _mockDoctors[idx] = {
                                      ..._mockDoctors[idx],
                                      ...data,
                                    };
                                  }
                                });
                        } else {
                          await _doctorsCollection.add(data);
                        }
                        if (mounted) Navigator.pop(dialogContext);
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Lỗi: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
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

// UI Tái sử dụng: Bảng thống kê số lượng
Widget _buildHeaderStat(String title, int count) {
  return Container(
    margin: const EdgeInsets.fromLTRB(15, 15, 15, 0),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    decoration: BoxDecoration(
      color: AppColors.primary.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        Text(
          "$count",
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    ),
  );
}
