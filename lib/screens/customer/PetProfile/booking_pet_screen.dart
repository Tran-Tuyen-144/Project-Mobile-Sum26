import 'package:flutter/material.dart';

import '../../../services/pet_booking_store.dart';
import '../../../theme/app_colors.dart';

class BookingPetScreen extends StatefulWidget {

  final String petName;

  const BookingPetScreen({
    super.key,
    required this.petName,
  });

  @override
  State<BookingPetScreen> createState() => _BookingPetScreenState();
}

class _BookingPetScreenState extends State<BookingPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController customerController = TextEditingController();
  final TextEditingController tableController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  late final String _selectedPetName;

  @override
  void initState() {
    super.initState();
    _selectedPetName = widget.petName;
  }

  @override
  void dispose() {
    customerController.dispose();
    tableController.dispose();
    timeController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt Pet Offline'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Đặt pet offline: $_selectedPetName',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Nhập thông tin khách, số bàn và thời gian gọi pet để tạo đơn đặt pet tại quán.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: customerController,
                decoration: const InputDecoration(
                  labelText: 'Tên khách hoặc SĐT',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên khách hoặc SĐT';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: tableController,
                decoration: const InputDecoration(
                  labelText: 'Số bàn',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số bàn';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: timeController,
                decoration: const InputDecoration(
                  labelText: 'Thời gian gọi pet',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập thời gian gọi pet';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Yêu cầu của khách (nếu muốn ghi chú thêm)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.textSoft,
                        foregroundColor: AppColors.textDark,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          PetBookingStore.instance.markPetBooked(_selectedPetName);
                          showDialog(
                            context: context,
                            builder: (_) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                title: const Text('Đặt pet thành công'),
                                content: Text(
                                  'Đã đặt $_selectedPetName thành công cho ${customerController.text}.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Đóng'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      child: const Text('Xác nhận đặt'),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}