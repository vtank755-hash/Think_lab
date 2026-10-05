import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:think_lab/Searches.dart';
import 'package:think_lab/index.dart';

void main() {
  testWidgets('Recommended "See all" opens the Searches page', (tester) async {
    // The fixed-width course cards overflow slightly under the test font's
    // metrics; that is unrelated to the navigation being checked here.
    final previousOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exception.toString().contains('overflowed')) {
        return;
      }
      previousOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = previousOnError);

    await tester.pumpWidget(const MaterialApp(home: index()));
    await tester.pump(const Duration(seconds: 1));

    // Categories, Popular Courses, Continue Learning, Recommended
    final seeAll = find.text('See all');
    expect(seeAll.evaluate().length, greaterThanOrEqualTo(4));

    await tester.ensureVisible(seeAll.last);
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(seeAll.last, warnIfMissed: true);
    await tester.pumpAndSettle();

    expect(find.byType(Searches), findsOneWidget);
    expect(find.text('Recent Searches'), findsOneWidget);
  });
}
