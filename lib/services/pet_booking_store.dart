import 'package:flutter/material.dart';

class PetProfile {
  final String name;
  final String age;
  final String healthStatus;
  final String bookingStatus;
  final bool isAvailable;
  final Color color;

  const PetProfile({
    required this.name,
    required this.age,
    required this.healthStatus,
    required this.bookingStatus,
    required this.isAvailable,
    required this.color,
  });

  PetProfile copyWith({
    String? name,
    String? age,
    String? healthStatus,
    String? bookingStatus,
    bool? isAvailable,
    Color? color,
  }) {
    return PetProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      healthStatus: healthStatus ?? this.healthStatus,
      bookingStatus: bookingStatus ?? this.bookingStatus,
      isAvailable: isAvailable ?? this.isAvailable,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'healthStatus': healthStatus,
      'bookingStatus': bookingStatus,
      'isAvailable': isAvailable,
    };
  }
}

class PetBookingStore {
  PetBookingStore._();

  static final PetBookingStore instance = PetBookingStore._();

  final ValueNotifier<List<PetProfile>> petsNotifier = ValueNotifier<List<PetProfile>>(
    [
      PetProfile(
        name: 'Mailisa',
        age: '2 tuổi',
        healthStatus: 'Khỏe mạnh',
        bookingStatus: 'Có sẵn',
        isAvailable: true,
        color: Colors.orange.shade100,
      ),
      PetProfile(
        name: 'Corgi Lucky',
        age: '3 tuổi',
        healthStatus: 'Đã tiêm phòng',
        bookingStatus: 'Có sẵn',
        isAvailable: true,
        color: Colors.blue.shade100,
      ),
      PetProfile(
        name: 'Golden Max',
        age: '4 tuổi',
        healthStatus: 'Đang được theo dõi',
        bookingStatus: 'Đã được đặt',
        isAvailable: false,
        color: Colors.grey,
      ),
      PetProfile(
        name: 'Mèo Mochi',
        age: '1 tuổi',
        healthStatus: 'Khỏe mạnh',
        bookingStatus: 'Có sẵn',
        isAvailable: true,
        color: Colors.green.shade100,
      ),
      PetProfile(
        name: 'Shiba Ken',
        age: '2 tuổi',
        healthStatus: 'Khỏe mạnh',
        bookingStatus: 'Có sẵn',
        isAvailable: true,
        color: Colors.yellow.shade100,
      ),
      PetProfile(
        name: 'Poodle Coco',
        age: '3 tuổi',
        healthStatus: 'Đã tiêm phòng',
        bookingStatus: 'Đã được đặt',
        isAvailable: false,
        color: Colors.grey,
      ),
      PetProfile(
        name: 'Mèo Luna',
        age: '2 tuổi',
        healthStatus: 'Khỏe mạnh',
        bookingStatus: 'Có sẵn',
        isAvailable: true,
        color: Colors.pink.shade100,
      ),
      PetProfile(
        name: 'Husky Snow',
        age: '5 tuổi',
        healthStatus: 'Cần chăm sóc đặc biệt',
        bookingStatus: 'Đã được đặt',
        isAvailable: false,
        color: Colors.grey,
      ),
      PetProfile(
        name: 'Chó Beo',
        age: '2 tuổi',
        healthStatus: 'Khỏe mạnh',
        bookingStatus: 'Có sẵn',
        isAvailable: true,
        color: Colors.purple.shade100,
      ),
      PetProfile(
        name: 'Mèo Tama',
        age: '3 tuổi',
        healthStatus: 'Đã tiêm phòng',
        bookingStatus: 'Có sẵn',
        isAvailable: true,
        color: Colors.teal.shade100,
      ),
      PetProfile(
        name: 'Cún Miu',
        age: '1 tuổi',
        healthStatus: 'Khỏe mạnh',
        bookingStatus: 'Có sẵn',
        isAvailable: true,
        color: Colors.lime.shade100,
      ),
      PetProfile(
        name: 'Mèo Nâu',
        age: '4 tuổi',
        healthStatus: 'Đang theo dõi',
        bookingStatus: 'Đã được đặt',
        isAvailable: false,
        color: Colors.brown.shade200,
      ),
      PetProfile(
        name: 'Pug Cookie',
        age: '2 tuổi',
        healthStatus: 'Khỏe mạnh',
        bookingStatus: 'Có sẵn',
        isAvailable: true,
        color: Colors.cyan.shade100,
      ),
    ],
  );

  List<PetProfile> get pets => petsNotifier.value;

  void markPetBooked(String petName) {
    final index = pets.indexWhere((pet) => pet.name == petName);
    if (index == -1) {
      return;
    }

    final currentPet = pets[index];
    if (currentPet.bookingStatus == 'Đã được đặt') {
      return;
    }

    final updatedPets = [...pets];
    updatedPets[index] = currentPet.copyWith(
      bookingStatus: 'Đã được đặt',
      isAvailable: false,
    );
    petsNotifier.value = updatedPets;
  }
}
