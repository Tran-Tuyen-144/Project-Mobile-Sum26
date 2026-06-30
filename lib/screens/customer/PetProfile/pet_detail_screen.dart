import 'package:flutter/material.dart';
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

            Image.asset(
              pet["image"],
              height: 220,
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
                          builder: (_) => BookingPetScreen(
                            petName: pet["name"],
                          ),
                        ),
                      );
                    },
                    child: const Text("Xác nhận đặt bàn"),
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