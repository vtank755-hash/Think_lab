import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:think_lab/Searches.dart';
import 'package:think_lab/index.dart';

import 'test_utils.dart';

void main() {
  testWidgets('Recommended "See all" opens the Searches page', (tester) async {
    ignoreOverflowErrors();

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

  testWidgets('"See all" next to Popular Courses opens the Searches page', (
    tester,
  ) async {
    ignoreOverflowErrors();

    await tester.pumpWidget(const MaterialApp(home: index()));
    await tester.pump(const Duration(seconds: 1));

    // 0 = Categories, 1 = Popular Courses, 2 = Continue Learning, 3 = Recommended
    final popularSeeAll = find.text('See all').at(1);
    await tester.ensureVisible(popularSeeAll);
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(popularSeeAll);
    await tester.pumpAndSettle();

    expect(find.byType(Searches), findsOneWidget);
    expect(find.text('Search Courses'), findsOneWidget);
    expect(find.text('Recent Searches'), findsOneWidget);
  });
}
