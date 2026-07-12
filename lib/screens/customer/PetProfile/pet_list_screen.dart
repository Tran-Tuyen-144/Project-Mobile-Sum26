import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../services/pet_booking_store.dart';
import '../booking_confirm/booking_confirm_data.dart';
import 'pet_detail_screen.dart';

class PetListScreen extends StatelessWidget {
  final String? tableBookingId;
  final BookingConfirmData? bookingData;

  PetListScreen({super.key, this.tableBookingId, this.bookingData});

  @override
  Widget build(BuildContext context) {
    final isSelectingPet = bookingData != null;
    final petStore = PetBookingStore.instance;

    return Scaffold(
      appBar: AppBar(
        title: Text(isSelectingPet ? 'Chọn thú cưng' : 'Hồ sơ thú cưng'),
      ),
      body: ValueListenableBuilder<List<PetProfile>>(
        valueListenable: petStore.petsNotifier,
        builder: (context, pets, _) {
          return ListView.builder(
            itemCount: pets.length,
            itemBuilder: (context, index) {
              final pet = pets[index];
              final isAvailable = pet.isAvailable;
              final isBooked = pet.bookingStatus == 'Đã được đặt';
              final isLocked = !isAvailable || isBooked;

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
                  title: Text(pet.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('${pet.age} • Tình trạng: ${pet.healthStatus}'),
                      const SizedBox(height: 4),
                      Text(
                        isBooked
                            ? 'Đã được đặt'
                            : isAvailable
                                ? 'Còn trống — có thể chọn'
                                : 'Đã được người khác chọn',
                        style: TextStyle(
                          color: isBooked || !isAvailable
                              ? Colors.red.shade700
                              : Colors.green.shade700,
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
                    if (isLocked) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isBooked
                                ? 'Thú cưng này đã được đặt.'
                                : 'Thú cưng này hiện không thể chọn.',
                          ),
                        ),
                      );
                      return;
                    }

                    if (isSelectingPet) {
                      context.push(
                        '/booking-confirm',
                        extra: bookingData!.copyWith(
                          petName: pet.name,
                          petStatus: pet.bookingStatus,
                        ),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PetDetailScreen(pet: pet.toMap()),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
