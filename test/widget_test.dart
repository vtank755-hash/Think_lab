// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:think_lab/main.dart';

void main() {
  testWidgets('shows LearnHub splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const LearnHubApp());

    expect(find.text('LearnHub'), findsOneWidget);
    expect(find.text('Learn Anytime, Anywhere'), findsOneWidget);
    expect(find.text('Enter'), findsOneWidget);
  });

  testWidgets('Enter opens login screen immediately', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const LearnHubApp());
    await tester.tap(find.text('Enter'));
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('automatically opens login screen after three seconds', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const LearnHubApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsOneWidget);
  });
}
