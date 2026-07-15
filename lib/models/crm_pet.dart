import 'package:cloud_firestore/cloud_firestore.dart';

class CrmPet {
  final String id;
  final String ownerId;
  final String name;
  final String species;
  final String breed;
  final List<DateTime> vaccinationDates;
  final String dietaryNotes;
  final String medicalHistory;

  const CrmPet({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.species,
    required this.breed,
    required this.vaccinationDates,
    required this.dietaryNotes,
    required this.medicalHistory,
  });

  factory CrmPet.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    final dates =
        (data['vaccinationDates'] as List<dynamic>? ?? const [])
            .whereType<Timestamp>()
            .map((date) => date.toDate())
            .toList()
          ..sort();
    return CrmPet(
      id: doc.id,
      ownerId: data['ownerId'] as String? ?? '',
      name: data['name'] as String? ?? 'Chưa đặt tên',
      species: data['species'] as String? ?? 'Khác',
      breed: data['breed'] as String? ?? 'Chưa cập nhật',
      vaccinationDates: dates,
      dietaryNotes: data['dietaryNotes'] as String? ?? '',
      medicalHistory: data['medicalHistory'] as String? ?? '',
    );
  }

  DateTime? get lastVaccination =>
      vaccinationDates.isEmpty ? null : vaccinationDates.last;

  bool get vaccinationDue =>
      lastVaccination == null ||
      DateTime.now().difference(lastVaccination!).inDays >= 365;
}
