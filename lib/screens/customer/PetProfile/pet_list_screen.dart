import 'package:flutter/material.dart';
import 'pet_detail_screen.dart';

class PetListScreen extends StatelessWidget {
  PetListScreen({super.key});

  final List<Map<String, dynamic>> pets = [
    {
      "name": "Mailisa",
      "age": "2 tuổi",
      "image": "assets/images/cat1.jpg",
    },
    {
      "name": "Corgi Lucky",
      "age": "3 tuổi",
      "image": "assets/images/dog1.jpg",
    },
    {
      "name": "Golden Max",
      "age": "4 tuổi",
      "image": "assets/images/dog2.jpg",
    },
    {
      "name": "Mèo Mochi",
      "age": "1 tuổi",
      "image": "assets/images/cat2.jpg",
    },
    {
      "name": "Shiba Ken",
      "age": "2 tuổi",
      "image": "assets/images/dog3.jpg",
    },
    {
      "name": "Poodle Coco",
      "age": "3 tuổi",
      "image": "assets/images/dog4.jpg",
    },
    {
      "name": "Mèo Luna",
      "age": "2 tuổi",
      "image": "assets/images/cat3.jpg",
    },
    {
      "name": "Husky Snow",
      "age": "5 tuổi",
      "image": "assets/images/dog5.jpg",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hồ sơ thú cưng"),
      ),
      body: ListView.builder(
        itemCount: pets.length,
        itemBuilder: (context, index) {
          final pet = pets[index];

          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              leading: CircleAvatar(
                radius: 28,
                backgroundColor: Colors.orange.shade100,
                child: Icon(
                  Icons.pets,
                  color: Colors.orange.shade800,
                ),
              ),
              title: Text(pet["name"]),
              subtitle: Text(pet["age"]),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PetDetailScreen(
                      pet: pet,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}