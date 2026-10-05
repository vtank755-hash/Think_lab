import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:think_lab/Searches.dart';
import 'package:think_lab/index.dart';

import 'test_utils.dart';

void main() {
  testWidgets('Home search bar opens the Searches page', (tester) async {
    ignoreOverflowErrors();

    await tester.pumpWidget(const MaterialApp(home: index()));
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text('Search courses, topics...'));
    await tester.pumpAndSettle();

    expect(find.byType(Searches), findsOneWidget);
    expect(find.text('Search Courses'), findsOneWidget);
    expect(find.text('Start typing to find courses'), findsOneWidget);
    // Nothing is listed until the user searches for something.
    expect(find.text('Complete Web Development Bootcamp'), findsNothing);
  });

  testWidgets('Typing in Searches shows only matching courses', (tester) async {
    ignoreOverflowErrors();

    await tester.pumpWidget(const MaterialApp(home: Searches()));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Search Courses'), findsOneWidget);
    expect(find.text('Digital Marketing Fundamentals'), findsNothing);

    await tester.enterText(find.byType(TextField), 'marketing');
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Results (1)'), findsOneWidget);
    expect(find.text('Digital Marketing Fundamentals'), findsOneWidget);
    expect(find.text('Python Programming'), findsNothing);

    await tester.enterText(find.byType(TextField), 'python');
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Results (1)'), findsOneWidget);
    expect(find.text('Python Programming'), findsOneWidget);
    expect(find.text('Digital Marketing Fundamentals'), findsNothing);

    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Results (0)'), findsOneWidget);
    expect(find.text('No courses found for "zzz"'), findsOneWidget);
  });

  testWidgets('Tapping a search chip runs that search', (tester) async {
    ignoreOverflowErrors();

    await tester.pumpWidget(const MaterialApp(home: Searches()));
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text('Design').last);
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Results (1)'), findsOneWidget);
    expect(find.text('UI/UX Design Masterclass'), findsOneWidget);
    expect(find.text('Complete Web Development Bootcamp'), findsNothing);
  });
}
