import 'package:flutter/material.dart';

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
  final TextEditingController tableController = TextEditingController();
  final TextEditingController hourController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  String _bookingMode = 'online';
  String _bookingStatus = 'pending';

  final Map<String, String> _statusLabels = {
    'pending': 'Chờ xác nhận',
    'confirmed': 'Đã xác nhận',
    'serving': 'Đang phục vụ',
    'completed': 'Hoàn thành',
    'cancelled': 'Đã hủy',
  };

  @override
  Widget build(BuildContext context) {
    final isWalkIn = _bookingMode == 'walk_in';
    final currentStatusLabel = _statusLabels[_bookingStatus] ?? 'Chờ xác nhận';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Đặt bàn"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Đặt bàn với ${widget.petName}",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isWalkIn
                    ? "Bạn đang chọn gọi tại chỗ để đến trực tiếp."
                    : "Bạn đang chọn đặt online để giữ chỗ trước.",
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              SegmentedButton<String>(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith((states) {
                    return states.contains(MaterialState.selected)
                        ? AppColors.primarySoft
                        : AppColors.cream;
                  }),
                  foregroundColor: MaterialStateProperty.resolveWith((states) {
                    return states.contains(MaterialState.selected)
                        ? AppColors.textDark
                        : AppColors.textSoft;
                  }),
                  side: MaterialStateProperty.all(
                    BorderSide(color: AppColors.primarySoft),
                  ),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                segments: const [
                  ButtonSegment<String>(
                    value: 'online',
                    label: Text('Đặt online'),
                    icon: Icon(Icons.online_prediction),
                  ),
                  ButtonSegment<String>(
                    value: 'walk_in',
                    label: Text('Đặt tại chỗ'),
                    icon: Icon(Icons.room_service_outlined),
                  ),
                ],
                selected: <String>{_bookingMode},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _bookingMode = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Trạng thái: $currentStatusLabel',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _bookingStatus,
                decoration: const InputDecoration(
                  labelText: 'Trạng thái đơn',
                  border: OutlineInputBorder(),
                ),
                items: _statusLabels.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _bookingStatus = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: tableController,
                decoration: const InputDecoration(
                  labelText: "Số bàn",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Vui lòng nhập số bàn";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: hourController,
                decoration: InputDecoration(
                  labelText: isWalkIn ? "Giờ đến" : "Giờ đặt",
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return isWalkIn ? "Vui lòng nhập giờ đến" : "Vui lòng nhập giờ đặt";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Ghi chú",
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
                      child: const Text("Hủy"),
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
                          final message = isWalkIn
                              ? 'Đã ghi nhận gọi tại chỗ cho ${widget.petName}. Trạng thái: $currentStatusLabel'
                              : 'Đặt online thành công cho ${widget.petName}. Trạng thái: $currentStatusLabel';

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(message)),
                          );

                          Navigator.pop(context);
                        }
                      },
                      child: const Text("Xác nhận"),
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