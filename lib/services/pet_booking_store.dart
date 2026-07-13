import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/pet_booking.dart';

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
  FirebaseFirestore? _firestore;

  final ValueNotifier<List<PetProfile>> petsNotifier =
      ValueNotifier<List<PetProfile>>([
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
      ]);

  List<PetProfile> get pets => petsNotifier.value;

  Map<String, dynamic> buildBookingData({
    required String petName,
    required String customerName,
    required String tableNumber,
    required String time,
    required String note,
  }) {
    return {
      'petName': petName,
      'customerName': customerName,
      'tableNumber': tableNumber,
      'requestedTime': time,
      'note': note,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  Future<void> saveBooking({
    required String petName,
    required String customerName,
    required String tableNumber,
    required String time,
    required String note,
  }) async {
    final bookingData = buildBookingData(
      petName: petName,
      customerName: customerName,
      tableNumber: tableNumber,
      time: time,
      note: note,
    );

    _firestore ??= FirebaseFirestore.instance;
    await _firestore!.collection('bookings').add(bookingData);
  }

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

  void markPetAvailable(String petName) {
    final index = pets.indexWhere((pet) => pet.name == petName);
    if (index == -1) return;
    final updatedPets = [...pets];
    updatedPets[index] = updatedPets[index].copyWith(
      bookingStatus: 'Có sẵn',
      isAvailable: true,
    );
    petsNotifier.value = updatedPets;
  }
}

class BookingPetLimitException implements Exception {
  @override
  String toString() => 'Mỗi booking chỉ được đặt tối đa 3 pet.';
}

extension PetBookingStoreBookings on PetBookingStore {
  CollectionReference<Map<String, dynamic>> get _bookings =>
      FirebaseFirestore.instance.collection('bookings');

  Future<PetBooking?> findActiveBooking({
    required String customerId,
    required BookingType bookingType,
  }) async {
    final snapshot = await _bookings
        .where('customerId', isEqualTo: customerId)
        .where('bookingType', isEqualTo: bookingType.value)
        .where('status', isEqualTo: BookingStatus.active.value)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return PetBooking.fromFirestore(snapshot.docs.first);
  }

  Stream<List<PetBooking>> bookingHistory(String customerId) => _bookings
      .where('customerId', isEqualTo: customerId)
      .snapshots()
      .map((snapshot) {
        final bookings = snapshot.docs.map(PetBooking.fromFirestore).toList();
        bookings.sort(
          (a, b) => (b.createdAt ?? b.bookingDate).compareTo(
            a.createdAt ?? a.bookingDate,
          ),
        );
        return bookings;
      });

  Future<PetBooking> createModernBooking({
    required String customerId,
    required String customerName,
    required BookingType bookingType,
    required String petName,
    required DateTime bookingDate,
    required String startTime,
    String? address,
    String? tableNumber,
    required String note,
  }) async {
    final ref = _bookings.doc();
    final booking = PetBooking(
      bookingId: ref.id,
      customerId: customerId,
      customerName: customerName,
      bookingType: bookingType,
      pets: [petName],
      bookingDate: bookingDate,
      startTime: startTime,
      address: address,
      tableNumber: tableNumber,
      note: note,
      status: BookingStatus.active,
    );
    final data = booking.toMap()..['createdAt'] = FieldValue.serverTimestamp();
    await ref.set(data);
    markPetBooked(petName);
    return booking;
  }

  Future<PetBooking> createOnlineTableBooking({
    required String customerId,
    required String customerName,
    required List<String> petNames,
    required String branch,
    required String day,
    required String time,
    required int guests,
    required String tableName,
  }) async {
    if (petNames.isEmpty) throw StateError('Vui lòng chọn ít nhất một pet.');
    if (petNames.length > 3) throw BookingPetLimitException();
    final ref = _bookings.doc();
    final booking = PetBooking(
      bookingId: ref.id,
      customerId: customerId,
      customerName: customerName,
      bookingType: BookingType.online,
      pets: petNames,
      bookingDate: DateTime.now(),
      startTime: time,
      address: branch,
      tableNumber: tableName,
      note: 'Ngày: $day • $guests khách',
      status: BookingStatus.active,
    );
    final data = booking.toMap()
      ..['createdAt'] = FieldValue.serverTimestamp()
      ..['branch'] = branch
      ..['day'] = day
      ..['guests'] = guests;
    await ref.set(data);
    for (final petName in petNames) {
      markPetBooked(petName);
    }
    return booking;
  }

  Future<void> addPetToBooking({
    required String bookingId,
    required String petName,
  }) async {
    final ref = _bookings.doc(bookingId);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      if (!snapshot.exists) throw StateError('Booking không tồn tại.');
      final booking = PetBooking.fromFirestore(snapshot);
      if (!booking.isActive) throw StateError('Booking không còn hiệu lực.');
      if (booking.pets.length >= 3) throw BookingPetLimitException();
      if (booking.pets.contains(petName)) return;
      transaction.update(ref, {
        'pets': [
          ...booking.pets,
          {'name': petName},
        ],
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
    markPetBooked(petName);
  }

  Future<void> updateModernBooking(PetBooking booking) async {
    if (booking.pets.isEmpty) {
      throw StateError('Booking phải có ít nhất một pet.');
    }
    if (booking.pets.length > 3) throw BookingPetLimitException();
    final ref = _bookings.doc(booking.bookingId);
    final previousSnapshot = await ref.get();
    final previous = previousSnapshot.exists
        ? PetBooking.fromFirestore(previousSnapshot)
        : null;
    await ref.update(booking.toMap());
    for (final petName in previous?.pets ?? const <String>[]) {
      if (!booking.pets.contains(petName)) markPetAvailable(petName);
    }
    for (final petName in booking.pets) {
      markPetBooked(petName);
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    final ref = _bookings.doc(bookingId);
    final snapshot = await ref.get();
    if (!snapshot.exists) return;
    final booking = PetBooking.fromFirestore(snapshot);
    await ref.update({
      'status': BookingStatus.cancelled.value,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    for (final petName in booking.pets) {
      markPetAvailable(petName);
    }
  }
}
