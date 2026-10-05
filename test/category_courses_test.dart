import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:think_lab/categories.dart';
import 'package:think_lab/category_courses.dart';
import 'package:think_lab/course.dart';
import 'package:think_lab/course_details.dart';
import 'package:think_lab/index.dart';

import 'test_utils.dart';

/// Every category offered by the Categories screen.
const categoryNames = [
  'Development',
  'Design',
  'Marketing',
  'Business',
  'IT & Software',
  'Personal Development',
];

/// Scrolls to [finder] if needed and taps it.
Future<void> revealAndTap(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(finder, 300);
  }
  await tester.ensureVisible(finder);
  await tester.pump(const Duration(seconds: 1));
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Starts on the home screen and pushes the Categories page.
Future<void> openCategories(WidgetTester tester) async {
  ignoreOverflowErrors();
  await tester.pumpWidget(const MaterialApp(home: index()));
  await tester.pump(const Duration(seconds: 1));

  await revealAndTap(tester, find.text('See all').first);
  expect(find.byType(categories), findsOneWidget);
}

/// Asserts that every course of the open category list is on screen and that
/// no other course leaked into it.
Future<void> expectOnlyCoursesOf(WidgetTester tester, String category) async {
  for (final course in allCourses) {
    if (course.category == category) continue;
    expect(
      find.text(course.title),
      findsNothing,
      reason: '${course.title} (${course.category}) must not be listed',
    );
  }

  for (final course in coursesInCategory(category)) {
    if (find.text(course.title).evaluate().isEmpty) {
      await tester.scrollUntilVisible(find.text(course.title), 300);
    }
    await tester.ensureVisible(find.text(course.title));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text(course.title), findsOneWidget);
  }
}

void main() {
  testWidgets('Category cards show real counts, never the fake figures', (
    tester,
  ) async {
    await openCategories(tester);

    // Make sure every grid row is built before checking its label.
    await tester.drag(find.byType(GridView), const Offset(0, -320));
    await tester.pump(const Duration(seconds: 1));

    // The old static numbers are gone.
    for (final fake in [
      '1,240 courses',
      '860 courses',
      '540 courses',
      '720 courses',
      '980 courses',
      '430 courses',
    ]) {
      expect(find.text(fake), findsNothing, reason: '$fake is hardcoded');
    }

    // Every card shows its own dynamically calculated count.
    for (final name in categoryNames) {
      expect(
        find.text(courseCountLabel(name)),
        findsAtLeastNWidgets(1),
        reason: '$name should show "${courseCountLabel(name)}"',
      );
    }
  });

  testWidgets('Development opens a NEW page with only Development courses', (
    tester,
  ) async {
    await openCategories(tester);

    await revealAndTap(tester, find.text('Development'));
    expect(find.byType(CategoryCoursesPage), findsOneWidget);

    // Header: title + the REAL total, straight from the data.
    expect(find.text('Development'), findsOneWidget);
    expect(find.text(courseTotalLabel('Development')), findsOneWidget);
    final devCount = coursesInCategory('Development').length;
    expect(
      find.text(devCount == 1 ? '1 Course' : '$devCount Courses'),
      findsOneWidget,
      reason: 'count must be calculated, not fixed',
    );

    await expectOnlyCoursesOf(tester, 'Development');

    // Back returns to the Categories page.
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(CategoryCoursesPage), findsNothing);
    expect(find.byType(categories), findsOneWidget);
  });

  testWidgets('A category card opens the exact course details and price', (
    tester,
  ) async {
    await openCategories(tester);

    await revealAndTap(tester, find.text('Development'));

    final course = coursesInCategory('Development').first;
    await revealAndTap(tester, find.text(course.title));

    expect(find.byType(CourseDetails), findsOneWidget);
    expect(find.text(course.title), findsOneWidget);
    expect(find.text(course.price), findsOneWidget);
    expect(find.text('Add to Cart'), findsOneWidget);
    // Payment may never start from the details page.
    expect(find.text('Pay Now'), findsNothing);
    expect(find.text('Buy Now'), findsNothing);

    // No other course's information or price leaks in.
    for (final other in allCourses) {
      if (other.id == course.id) continue;
      expect(find.text(other.title), findsNothing);
    }
  });

  testWidgets('The same page works for every category', (tester) async {
    await openCategories(tester);

    for (final name in categoryNames) {
      // Back on the categories grid (first iteration: home -> See all).
      if (find.byType(categories).evaluate().isEmpty) {
        await openCategories(tester);
      }

      await revealAndTap(tester, find.text(name));
      expect(find.byType(CategoryCoursesPage), findsOneWidget);
      expect(find.text(name), findsOneWidget, reason: 'page title');
      expect(
        find.text(courseTotalLabel(name)),
        findsOneWidget,
        reason: 'count',
      );
      // Header total = filteredCourses.length, straight from the dataset.
      final expectedCount = coursesInCategory(name).length;
      expect(
        find.text(expectedCount == 1 ? '1 Course' : '$expectedCount Courses'),
        findsOneWidget,
        reason: 'count must be calculated, not fixed',
      );

      await expectOnlyCoursesOf(tester, name);

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(categories), findsOneWidget);
    }
  });

  testWidgets('Course cards carry a working favourite button', (tester) async {
    await openCategories(tester);

    await revealAndTap(tester, find.text('Marketing'));
    expect(find.byType(CategoryCoursesPage), findsOneWidget);

    // Make sure all Marketing cards are built before counting hearts.
    for (final course in coursesInCategory('Marketing')) {
      if (find.text(course.title).evaluate().isEmpty) {
        await tester.scrollUntilVisible(find.text(course.title), 300);
      }
    }
    await tester.pump(const Duration(seconds: 1));

    final marketing = coursesInCategory('Marketing');
    final likedBefore = marketing.where(isFavorite).length;
    expect(likedBefore, 1); // Digital Marketing starts as a favourite

    await tester.tap(find.byIcon(Icons.favorite));
    await tester.pumpAndSettle();

    expect(marketing.where(isFavorite).length, likedBefore - 1);
    expect(find.byIcon(Icons.favorite), findsNothing);
  });
}
