import 'package:flutter/material.dart';

import 'booking_pet_screen.dart';

class PetDetailScreen extends StatelessWidget {
  const PetDetailScreen({super.key, required this.pet});

  final Map<String, dynamic> pet;

  @override
  Widget build(BuildContext context) {
    final booked = pet['bookingStatus'] == 'Đã được đặt';
    return Scaffold(
      appBar: AppBar(title: Text(pet['name'] as String)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.pets, size: 100),
            Text(
              pet['name'] as String,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.cake),
              title: const Text('Tuổi'),
              subtitle: Text(pet['age'] as String),
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Sức khỏe'),
              subtitle: Text(pet['healthStatus'] as String),
            ),
            const Spacer(),
            FilledButton(
              onPressed: booked
                  ? null
                  : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            BookingPetScreen(petName: pet['name'] as String),
                      ),
                    ),
              child: Text(booked ? 'Pet đã được đặt' : 'Đặt pet'),
            ),
          ],
        ),
      ),
    );
  }
}
