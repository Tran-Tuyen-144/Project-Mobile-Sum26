import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pethub_app/screens/role_select_screen.dart';
void main() { testWidgets('role screen renders', (tester) async { await tester.pumpWidget(const MaterialApp(home: RoleSelectScreen())); expect(find.byType(RoleSelectScreen), findsOneWidget); }); }
