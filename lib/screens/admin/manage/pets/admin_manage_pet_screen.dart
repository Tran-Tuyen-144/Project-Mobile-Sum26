import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../theme/app_colors.dart';

import '../../../../services/cloudinary_upload_service.dart';

class AdminManagePetScreen extends StatefulWidget {
  const AdminManagePetScreen({super.key});

  @override
  State<AdminManagePetScreen> createState() => _AdminManagePetScreenState();
}

class _AdminManagePetScreenState extends State<AdminManagePetScreen> {
  final CollectionReference _petsCollection = FirebaseFirestore.instance
      .collection('pets');

  // Danh sách Pet giả (Mock Data) - Được đánh dấu isFirebase: false
  final List<Map<String, dynamic>> _mockPets = [
    {
      "id": "MOCK_001",
      "name": "Mailisa",
      "age": "2",
      "image": "assets/image/cat1.jpg",
      "breed": "Mèo lai",
      "health": "Khỏe mạnh, ăn tốt.",
      "status": "Sẵn sàng",
      "isFirebase": false,
    },
    {
      "id": "MOCK_002",
      "name": "Corgi Lucky",
      "age": "3",
      "image": "assets/image/dog1.jpg",
      "breed": "Corgi",
      "health": "Hơi béo phì, cần giảm cân.",
      "status": "Cần kiểm tra",
      "isFirebase": false,
    },
    {
      "id": "MOCK_003",
      "name": "Golden Max",
      "age": "4",
      "image": "assets/image/dog2.jpg",
      "breed": "Golden Retriever",
      "health": "Khỏe mạnh, năng động.",
      "status": "Sẵn sàng",
      "isFirebase": false,
    },
    {
      "id": "MOCK_004",
      "name": "Mèo Mochi",
      "age": "1",
      "image": "assets/images/cat2.jpg",
      "breed": "Mèo Anh Lông Ngắn",
      "health": "Mới tiêm phòng.",
      "status": "Sẵn sàng",
      "isFirebase": false,
    },
    {
      "id": "MOCK_005",
      "name": "Shiba Ken",
      "age": "2",
      "image": "assets/images/dog3.jpg",
      "breed": "Shiba Inu",
      "health": "Rụng lông nhiều.",
      "status": "Cần kiểm tra",
      "isFirebase": false,
    },
    {
      "id": "MOCK_006",
      "name": "Poodle Coco",
      "age": "3",
      "image": "assets/images/dog4.jpg",
      "breed": "Poodle",
      "health": "Khỏe mạnh.",
      "status": "Sẵn sàng",
      "isFirebase": false,
    },
    {
      "id": "MOCK_007",
      "name": "Mèo Luna",
      "age": "2",
      "image": "assets/images/cat3.jpg",
      "breed": "Mèo Xiêm",
      "health": "Khỏe mạnh.",
      "status": "Sẵn sàng",
      "isFirebase": false,
    },
    {
      "id": "MOCK_008",
      "name": "Husky Snow",
      "age": "5",
      "image": "assets/images/dog5.jpg",
      "breed": "Siberian Husky",
      "health": "Đang điều trị nấm da.",
      "status": "Cần kiểm tra",
      "isFirebase": false,
    },
  ];

  // Hàm Xóa Pet (Tự động nhận diện dữ liệu thật/giả)
  void _deletePet(Map<String, dynamic> pet) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa hồ sơ thú cưng này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Hủy',
              style: TextStyle(color: AppColors.textSoft),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);

              if (pet['isFirebase'] == true) {
                await _petsCollection.doc(pet['id']).delete();
              } else {
                setState(() {
                  _mockPets.removeWhere((p) => p['id'] == pet['id']);
                });
              }

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xóa hồ sơ thành công!')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.peach),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Đổi trạng thái nhanh
  void _toggleStatus(Map<String, dynamic> pet) async {
    final newStatus = pet['status'] == 'Sẵn sàng' ? 'Cần kiểm tra' : 'Sẵn sàng';

    if (pet['isFirebase'] == true) {
      await _petsCollection.doc(pet['id']).update({'status': newStatus});
    } else {
      setState(() {
        final index = _mockPets.indexWhere((p) => p['id'] == pet['id']);
        if (index != -1) _mockPets[index]['status'] = newStatus;
      });
    }
  }

  // Hàm Thêm / Sửa Pet (Sử dụng Cloudinary)
  void _showPetFormDialog({Map<String, dynamic>? existingPet}) {
    final bool isEdit = existingPet != null;

    final nameController = TextEditingController(
      text: isEdit ? existingPet['name'] : '',
    );
    final breedController = TextEditingController(
      text: isEdit ? existingPet['breed'] : '',
    );
    final ageController = TextEditingController(
      text: isEdit ? existingPet['age'].toString() : '',
    );
    final healthController = TextEditingController(
      text: isEdit ? existingPet['health'] : '',
    );

    String currentStatus = isEdit ? existingPet['status'] : 'Sẵn sàng';
    String? currentImageUrl = isEdit ? existingPet['image'] : '';
    bool isUploadingImage = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 24,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEdit ? 'Cập nhật hồ sơ Pet' : 'Thêm hồ sơ Pet mới',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Khu vực upload ảnh
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        try {
                          final image =
                              await CloudinaryUploadService.pickImageFromGallery();
                          if (image != null) {
                            setModalState(() => isUploadingImage = true);
                            final uploadResult =
                                await CloudinaryUploadService.uploadImageFile(
                                  image,
                                );
                            setModalState(() {
                              currentImageUrl =
                                  CloudinaryUploadService.optimizedImageUrl(
                                    uploadResult.imageUrl,
                                  );
                              isUploadingImage = false;
                            });
                          }
                        } catch (e) {
                          setModalState(() => isUploadingImage = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Lỗi tải ảnh: $e')),
                          );
                        }
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          _buildAvatar(currentImageUrl, radius: 40),
                          if (isUploadingImage)
                            const CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          if (currentImageUrl == null ||
                              currentImageUrl!.isEmpty)
                            const Icon(
                              Icons.add_a_photo_rounded,
                              size: 28,
                              color: AppColors.textSoft,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Tên thú cưng',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: breedController,
                          decoration: InputDecoration(
                            labelText: 'Giống loài',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: ageController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Tuổi',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: healthController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Tình trạng sức khỏe',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Trạng thái:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text(
                            'Sẵn sàng',
                            style: TextStyle(fontSize: 14),
                          ),
                          value: 'Sẵn sàng',
                          groupValue: currentStatus,
                          activeColor: AppColors.mint,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (val) =>
                              setModalState(() => currentStatus = val!),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text(
                            'Cần kiểm tra',
                            style: TextStyle(fontSize: 14),
                          ),
                          value: 'Cần kiểm tra',
                          groupValue: currentStatus,
                          activeColor: AppColors.peach,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (val) =>
                              setModalState(() => currentStatus = val!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isUploadingImage
                          ? null
                          : () async {
                              if (nameController.text.isEmpty) return;

                              final petData = {
                                'name': nameController.text,
                                'breed': breedController.text,
                                'age': ageController.text,
                                'health': healthController.text,
                                'status': currentStatus,
                                'image': currentImageUrl ?? '',
                                'isFirebase': true,
                              };

                              if (isEdit) {
                                if (existingPet['isFirebase'] == true) {
                                  await _petsCollection
                                      .doc(existingPet['id'])
                                      .update(petData);
                                } else {
                                  // Update dữ liệu giả
                                  setState(() {
                                    final index = _mockPets.indexWhere(
                                      (p) => p['id'] == existingPet['id'],
                                    );
                                    if (index != -1) {
                                      _mockPets[index] = {
                                        ...existingPet,
                                        ...petData,
                                      };
                                    }
                                  });
                                }
                              } else {
                                // Thêm mới
                                await _petsCollection.add(petData);
                              }

                              if (mounted) Navigator.pop(context);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        isEdit ? 'Lưu thay đổi' : 'Thêm thú cưng',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget hỗ trợ hiển thị Ảnh (Nhận diện URL mạng hoặc Assets cục bộ)
  Widget _buildAvatar(String? imageUrl, {double radius = 24}) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return CircleAvatar(radius: radius, backgroundColor: AppColors.cream);
    }

    // Nếu là link web (Cloudinary)
    if (imageUrl.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.network(
          imageUrl,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => CircleAvatar(
            radius: radius,
            backgroundColor: AppColors.peach.withValues(alpha: 0.2),
            child: Icon(
              Icons.pets_rounded,
              color: AppColors.peach,
              size: radius,
            ),
          ),
        ),
      );
    }
    // Nếu là dữ liệu Mock (Assets)
    else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.asset(
          imageUrl,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => CircleAvatar(
            radius: radius,
            backgroundColor: AppColors.peach.withValues(alpha: 0.2),
            child: Icon(
              Icons.pets_rounded,
              color: AppColors.peach,
              size: radius,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Hồ sơ thú cưng',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _petsCollection.snapshots(),
        builder: (context, snapshot) {
          // Khởi tạo mảng kết hợp
          List<Map<String, dynamic>> combinedPets = [];

          // 1. Thêm dữ liệu từ Firebase (nếu có)
          if (snapshot.hasData) {
            final firebaseDocs = snapshot.data!.docs;
            for (var doc in firebaseDocs) {
              final data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id;
              data['isFirebase'] = true;
              combinedPets.add(data);
            }
          }

          // 2. Nối thêm dữ liệu giả (Mock) vào sau cùng
          combinedPets.addAll(_mockPets);

          if (combinedPets.isEmpty) {
            return const Center(
              child: Text(
                'Chưa có hồ sơ thú cưng nào.',
                style: TextStyle(color: AppColors.textSoft),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: combinedPets.length,
            itemBuilder: (context, index) {
              final pet = combinedPets[index];
              final isReady = pet['status'] == 'Sẵn sàng';

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cream, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildAvatar(
                            pet['image'],
                          ), // Gọi hàm Render Ảnh thông minh
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${pet['name']} • ${pet['age']} tuổi',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  pet['breed'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSoft,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.edit_rounded,
                              color: AppColors.textSoft,
                              size: 20,
                            ),
                            onPressed: () =>
                                _showPetFormDialog(existingPet: pet),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: AppColors.peach,
                              size: 20,
                            ),
                            onPressed: () => _deletePet(pet),
                          ),
                        ],
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1, color: AppColors.cream),
                      ),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.favorite_rounded,
                            size: 16,
                            color: AppColors.peach,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Sức khỏe: ${pet['health'] ?? ''}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textDark,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      GestureDetector(
                        onTap: () => _toggleStatus(pet),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isReady
                                ? AppColors.mint.withValues(alpha: 0.2)
                                : AppColors.peach.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isReady
                                    ? Icons.check_circle_rounded
                                    : Icons.warning_rounded,
                                size: 14,
                                color: isReady
                                    ? AppColors.mint
                                    : AppColors.peach,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                pet['status'] ?? '',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isReady
                                      ? AppColors.mint
                                      : AppColors.peach,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPetFormDialog(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Thêm Pet',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
