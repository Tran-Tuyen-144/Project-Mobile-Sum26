import 'package:flutter/material.dart';
import '../booking/customer_booking_screen.dart';
import 'booking_pet_screen.dart';

class PetDetailScreen extends StatelessWidget {
  final Map<String, dynamic> pet;

  const PetDetailScreen({
    super.key,
    required this.pet,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pet["name"]),
      ),
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
              child: Icon(
                Icons.pets,
                size: 80,
                color: Colors.orange.shade800,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              pet["name"],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            if (pet["bookingStatus"] != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                decoration: BoxDecoration(
                  color: pet["bookingStatus"] == 'Đã được đặt'
                      ? Colors.red.shade50
                      : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      pet["bookingStatus"] == 'Đã được đặt'
                          ? Icons.lock_rounded
                          : Icons.check_circle_rounded,
                      color: pet["bookingStatus"] == 'Đã được đặt'
                          ? Colors.red.shade700
                          : Colors.green.shade700,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      pet["bookingStatus"],
                      style: TextStyle(
                        color: pet["bookingStatus"] == 'Đã được đặt'
                            ? Colors.red.shade700
                            : Colors.green.shade700,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

            ListTile(
              leading: const Icon(Icons.cake),
              title: const Text("Tuổi"),
              subtitle: Text(pet["age"]),
            ),

            const ListTile(
              leading: Icon(Icons.pets),
              title: Text("Đặc điểm"),
              subtitle: Text("Thân thiện, thích chơi với khách"),
            ),

            const ListTile(
              leading: Icon(Icons.favorite),
              title: Text("Sức khỏe"),
              subtitle: Text("Khỏe mạnh"),
            ),

            const SizedBox(height: 30),

            Row(
              children: [

                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
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
                      backgroundColor: pet["bookingStatus"] == 'Đã được đặt'
                          ? Colors.grey
                          : const Color(0xFF2D6A8D),
                    ),
                    onPressed: pet["bookingStatus"] == 'Đã được đặt'
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BookingPetScreen(
                                  petName: pet["name"],
                                ),
                              ),
                            );
                          },
                    child: Text("Đặt ${pet["name"]} Tại chỗ"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
