import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flightpath_frontend/main.dart';

void main() {
  testWidgets('App renders login screen initially', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: FlightpathApp()));
    await tester.pumpAndSettle();

    expect(find.text('FLIGHTPATH'), findsOneWidget);
    expect(find.text('Sign In to Flightpath'), findsOneWidget);
  });
}
