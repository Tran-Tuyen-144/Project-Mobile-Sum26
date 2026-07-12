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

            const SizedBox(height: 20),

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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CustomerBookingScreen(
                            petName: pet["name"],
                          ),
                        ),
                      );
                    },
                    child: Text("Đặt ${pet["name"]} Online"),
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D6A8D),
                    ),
                    onPressed: () {
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