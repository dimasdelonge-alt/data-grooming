import 'package:flutter_test/flutter_test.dart';
import 'package:datagrooming_v3/main.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(const JeniCathouseApp());
    expect(find.text('Beranda'), findsOneWidget);
  });
}
