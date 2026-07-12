import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../booking_confirm/booking_confirm_data.dart';
import 'pet_detail_screen.dart';

class PetListScreen extends StatelessWidget {
  final String? tableBookingId;
  final BookingConfirmData? bookingData;

  PetListScreen({super.key, this.tableBookingId, this.bookingData});

  final List<Map<String, dynamic>> pets = [
    {
      'name': 'Mailisa',
      'age': '2 tuổi',
      'status': 'Khỏe mạnh',
      'isAvailable': true,
    },
    {
      'name': 'Corgi Lucky',
      'age': '3 tuổi',
      'status': 'Đã tiêm phòng',
      'isAvailable': true,
    },
    {
      'name': 'Golden Max',
      'age': '4 tuổi',
      'status': 'Đang được theo dõi',
      'isAvailable': false,
    },
    {
      'name': 'Mèo Mochi',
      'age': '1 tuổi',
      'status': 'Khỏe mạnh',
      'isAvailable': true,
    },
    {
      'name': 'Shiba Ken',
      'age': '2 tuổi',
      'status': 'Khỏe mạnh',
      'isAvailable': true,
    },
    {
      'name': 'Poodle Coco',
      'age': '3 tuổi',
      'status': 'Đã tiêm phòng',
      'isAvailable': false,
    },
    {
      'name': 'Mèo Luna',
      'age': '2 tuổi',
      'status': 'Khỏe mạnh',
      'isAvailable': true,
    },
    {
      'name': 'Husky Snow',
      'age': '5 tuổi',
      'status': 'Cần chăm sóc đặc biệt',
      'isAvailable': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isSelectingPet = bookingData != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isSelectingPet ? 'Chọn thú cưng' : 'Hồ sơ thú cưng'),
      ),
      body: ListView.builder(
        itemCount: pets.length,
        itemBuilder: (context, index) {
          final pet = pets[index];
          final isAvailable = pet['isAvailable'] as bool;
          final isLocked = isSelectingPet && !isAvailable;
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            color: isLocked ? Colors.grey.shade200 : null,
            child: ListTile(
              enabled: !isLocked,
              leading: CircleAvatar(
                radius: 28,
                backgroundColor: isLocked
                    ? Colors.grey.shade300
                    : Colors.orange.shade100,
                child: Icon(
                  isLocked ? Icons.lock_rounded : Icons.pets,
                  color: isLocked
                      ? Colors.grey.shade600
                      : Colors.orange.shade800,
                ),
              ),
              title: Text(pet['name'] as String),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('${pet['age']} • Tình trạng: ${pet['status']}'),
                  const SizedBox(height: 4),
                  Text(
                    isAvailable
                        ? 'Còn trống — có thể chọn'
                        : 'Đã được người khác chọn',
                    style: TextStyle(
                      color: isAvailable
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              isThreeLine: true,
              trailing: Icon(
                isLocked ? Icons.lock_rounded : Icons.arrow_forward_ios,
                color: isLocked ? Colors.red.shade700 : null,
              ),
              onTap: () {
                if (isSelectingPet) {
                  if (!isAvailable) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Thú cưng này đã được người khác chọn.'),
                      ),
                    );
                    return;
                  }
                  context.push(
                    '/booking-confirm',
                    extra: bookingData!.copyWith(
                      petName: pet['name'] as String,
                      petStatus: pet['status'] as String,
                    ),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PetDetailScreen(pet: pet)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
