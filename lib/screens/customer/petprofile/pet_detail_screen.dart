import 'package:flutter/material.dart';

import '../../../models/pet_booking.dart';
import '../booking/customer_booking_screen.dart';
import 'booking_pet_screen.dart';

class PetDetailScreen extends StatelessWidget {
  final Map<String, dynamic> pet;

  const PetDetailScreen({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    final name = (pet['name'] ?? 'Thú cưng').toString();
    final age = (pet['age'] ?? 'Chưa cập nhật').toString();

    final healthStatus = (pet['healthStatus'] ?? 'Khỏe mạnh').toString();

    final bookingStatus = (pet['bookingStatus'] ?? 'Có sẵn').toString();

    final isUnavailable =
        bookingStatus == 'Đã được đặt' || pet['isAvailable'] == false;

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.pets, size: 80, color: Colors.orange.shade800),
            ),
            const SizedBox(height: 20),
            Text(
              name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUnavailable
                    ? Colors.red.shade50
                    : Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isUnavailable
                        ? Icons.lock_rounded
                        : Icons.check_circle_rounded,
                    color: isUnavailable
                        ? Colors.red.shade700
                        : Colors.green.shade700,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isUnavailable ? 'Đã được đặt' : bookingStatus,
                    style: TextStyle(
                      color: isUnavailable
                          ? Colors.red.shade700
                          : Colors.green.shade700,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.cake_rounded),
              title: const Text('Tuổi'),
              subtitle: Text(age),
            ),
            const ListTile(
              leading: Icon(Icons.pets_rounded),
              title: Text('Đặc điểm'),
              subtitle: Text('Thân thiện, thích chơi với khách'),
            ),
            ListTile(
              leading: const Icon(Icons.favorite_rounded),
              title: const Text('Sức khỏe'),
              subtitle: Text(healthStatus),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isUnavailable
                    ? null
                    : () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) {
                              return CustomerBookingScreen(petName: name);
                            },
                          ),
                        );
                      },
                icon: const Icon(Icons.language_rounded),
                label: Text('Đặt $name Online'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isUnavailable
                    ? null
                    : () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) {
                              return BookingPetScreen(
                                petName: name,
                                bookingType: BookingType.offline,
                              );
                            },
                          ),
                        );
                      },
                icon: const Icon(Icons.table_restaurant_rounded),
                label: Text('Đặt $name tại chỗ'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Quay lại'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
