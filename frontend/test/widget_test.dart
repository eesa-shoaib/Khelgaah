import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('app renders auth screen after bootstrap', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
  });
}
