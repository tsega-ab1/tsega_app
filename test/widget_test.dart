import 'package:flutter_test/flutter_test.dart';
import 'package:tsega_app/main.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(const TsegaApp());
    expect(find.byType(TsegaApp), findsOneWidget);
  });
}
