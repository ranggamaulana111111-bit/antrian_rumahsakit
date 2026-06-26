import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel/app.dart';

void main() {
  testWidgets('Splash screen displays branding and auto-navigates',
      (tester) async {
    await tester.pumpWidget(const TravelPackApp());

    expect(find.text('TravelPack'), findsOneWidget);
    expect(find.text('Pack Smarter, Travel Better'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('WELCOME BACK'), findsOneWidget);
  });

  testWidgets('Login form validates empty submission', (tester) async {
    await tester.pumpWidget(const TravelPackApp());
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(seconds: 2));

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('Username tidak boleh kosong'), findsOneWidget);
    expect(find.text('Password tidak boleh kosong'), findsOneWidget);
  });

  testWidgets('Login fails and recovers with wrong credentials',
      (tester) async {
    await tester.pumpWidget(const TravelPackApp());
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(seconds: 2));

    final usernameField = find.widgetWithText(TextFormField, 'Username');
    final passwordField = find.widgetWithText(TextFormField, 'Password');

    await tester.enterText(usernameField, 'User Salah');
    await tester.enterText(passwordField, 'Pass Salah');

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump(const Duration(seconds: 3));

    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('Login success navigates to new page', (tester) async {
    await tester.pumpWidget(const TravelPackApp());
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(seconds: 2));

    final usernameField = find.widgetWithText(TextFormField, 'Username');
    final passwordField = find.widgetWithText(TextFormField, 'Password');

    await tester.enterText(usernameField, 'ADMIN');
    await tester.enterText(passwordField, 'ADMIN');

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump(const Duration(seconds: 3));
    // additional pump to settle the route transition
    await tester.pump(const Duration(milliseconds: 500));

    // After navigation, the app should show a Scaffold with some content
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('TravelPack'), findsWidgets);
  });
}
