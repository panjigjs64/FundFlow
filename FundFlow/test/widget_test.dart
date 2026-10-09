import 'package:flutter_test/flutter_test.dart';
import '../flutter_application_1/lib/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FundFlowApp());
    expect(find.text('FundFlow'), findsOneWidget);
  });
}