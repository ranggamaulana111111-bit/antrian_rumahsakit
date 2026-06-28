import 'package:flutter_test/flutter_test.dart';
import 'package:antrian/app.dart';

void main() {
  testWidgets('App renders splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MediQueueApp());

    expect(find.text('MediQueue'), findsOneWidget);
    expect(find.text('Aplikasi Antrean Rumah Sakit'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
  });
}
