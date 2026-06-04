import 'package:flutter_test/flutter_test.dart';
import 'package:adobeshortcuts/main.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app builds successfully.
    expect(find.byType(MyApp), findsOneWidget);
  });
}
