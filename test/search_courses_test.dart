import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:think_lab/Searches.dart';
import 'package:think_lab/index.dart';

/// The fixed-width course cards overflow a little under the test font's
/// metrics; that is unrelated to the navigation being checked here.
void ignoreOverflowErrors() {
  final previousOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.exception.toString().contains('overflowed')) return;
    previousOnError?.call(details);
  };
  addTearDown(() => FlutterError.onError = previousOnError);
}

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
    // No courses are listed until the user searches for something.
    expect(find.text('Web Development Bootcamp'), findsNothing);
  });

  testWidgets('Typing in Searches shows only matching courses',
      (tester) async {
    ignoreOverflowErrors();

    await tester.pumpWidget(const MaterialApp(home: Searches()));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Search Courses'), findsOneWidget);
    expect(find.text('Web Development Bootcamp'), findsNothing);

    await tester.enterText(find.byType(TextField), 'react');
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Results (1)'), findsOneWidget);
    expect(find.text('React JS from Zero to Hero'), findsOneWidget);
    expect(find.text('Web Development Bootcamp'), findsNothing);

    await tester.enterText(find.byType(TextField), 'marketing');
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Results (3)'), findsOneWidget);
    expect(find.text('SEO Foundations'), findsOneWidget);
    expect(find.text('React JS from Zero to Hero'), findsNothing);

    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Results (0)'), findsOneWidget);
    expect(find.text('No courses found for "zzz"'), findsOneWidget);
  });

  testWidgets('Tapping a search chip runs that search', (tester) async {
    ignoreOverflowErrors();

    await tester.pumpWidget(const MaterialApp(home: Searches()));
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text('Figma').last);
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Results (1)'), findsOneWidget);
    expect(find.text('Figma for Beginners'), findsOneWidget);
  });
}
