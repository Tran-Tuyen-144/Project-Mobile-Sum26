import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pethub_app/screens/customer/petprofile/booking_pet_screen.dart';

void main() {
  testWidgets('pet booking screen renders', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: BookingPetScreen(petName: 'Miu')),
    );

    expect(find.byType(BookingPetScreen), findsOneWidget);

    expect(find.byType(Form), findsOneWidget);

    expect(find.byType(TextFormField), findsNWidgets(4));

    expect(find.text('Miu'), findsOneWidget);

    expect(find.text('Xác nhận đặt'), findsOneWidget);
  });
}
