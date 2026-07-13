import 'package:flutter_test/flutter_test.dart';
import 'package:pethub_app/services/pet_booking_store.dart';

void main() {
  group('PetBookingStore', () {
    test('buildBookingData includes booking details', () {
      final payload = PetBookingStore.instance.buildBookingData(
        petName: 'Mailisa',
        customerName: 'An',
        tableNumber: '5',
        time: '19:00',
        note: 'Cần đeo dây',
      );

      expect(payload['petName'], 'Mailisa');
      expect(payload['customerName'], 'An');
      expect(payload['tableNumber'], '5');
      expect(payload['requestedTime'], '19:00');
      expect(payload['note'], 'Cần đeo dây');
      expect(payload['status'], 'pending');
    });
  });
}
