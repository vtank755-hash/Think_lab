// Simple app-start tests:
// 1) the splash screen shows the LearnHub name and tagline;
// 2) after 3 seconds the app moves to the Login page by itself.

import 'package:flutter_test/flutter_test.dart';

import 'package:think_lab/main.dart';

void main() {
  testWidgets('shows LearnHub splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const LearnHubApp());

    expect(find.text('LearnHub'), findsOneWidget);
    expect(find.text('Learn Anytime, Anywhere'), findsOneWidget);
  });

  testWidgets('automatically opens login screen after three seconds', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const LearnHubApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
  });
}
