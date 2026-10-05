import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:think_lab/categories.dart';
import 'package:think_lab/index.dart';
import 'package:think_lab/widgets/nav_bar.dart';

import '../test_utils.dart';

void main() {
  testWidgets('Home screen uses the shared NavBar', (tester) async {
    ignoreOverflowErrors();

    await tester.pumpWidget(const MaterialApp(home: index()));
    await tester.pump(const Duration(seconds: 1));

    final bar = tester.widget<NavBar>(find.byType(NavBar));
    expect(bar.currentIndex, 0);
    expect(find.byType(NavBar), findsOneWidget);
    for (final item in navItems) {
      expect(find.text(item.label), findsOneWidget);
    }

    // Tapping a tab switches the placeholder screen.
    await tester.tap(find.text('Wishlist'));
    await tester.pumpAndSettle();
    expect(tester.widget<NavBar>(find.byType(NavBar)).currentIndex, 2);
  });

  testWidgets('Categories screen links to the same shared NavBar', (
    tester,
  ) async {
    ignoreOverflowErrors();

    await tester.pumpWidget(const MaterialApp(home: index()));
    await tester.pump(const Duration(seconds: 1));

    // "See all" next to Categories pushes the categories page.
    await tester.tap(find.text('See all').first);
    await tester.pumpAndSettle();
    expect(find.byType(categories), findsOneWidget);
    // Only the top route is visible to finders, so one bar is on screen.
    expect(find.byType(NavBar), findsOneWidget);
    for (final item in navItems) {
      expect(find.text(item.label), findsOneWidget);
    }

    // Home on the categories bar goes back to the home screen.
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.byType(categories), findsNothing);
    expect(find.byType(NavBar), findsOneWidget);
  });
}
