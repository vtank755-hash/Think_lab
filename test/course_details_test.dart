import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:think_lab/Searches.dart';
import 'package:think_lab/course_details.dart';
import 'package:think_lab/index.dart';

import 'test_utils.dart';

void main() {
  testWidgets('Tapping a search result opens the course details page', (
    tester,
  ) async {
    ignoreOverflowErrors();

    await tester.pumpWidget(const MaterialApp(home: Searches()));
    await tester.pump(const Duration(seconds: 1));

    await tester.enterText(find.byType(TextField), 'python');
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text('Python Programming'));
    await tester.pumpAndSettle();

    expect(find.byType(CourseDetails), findsOneWidget);
    expect(find.text('Python Programming'), findsOneWidget);
    expect(find.text('Arjun Rao'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Curriculum'), findsOneWidget);
    expect(find.text('Enroll Now'), findsOneWidget);
    expect(find.text('Add to Cart'), findsOneWidget);
  });

  testWidgets('Details page shows the selected course content', (tester) async {
    ignoreOverflowErrors();

    await tester.pumpWidget(const MaterialApp(home: Searches()));
    await tester.pump(const Duration(seconds: 1));

    await tester.enterText(find.byType(TextField), 'Complete Web');
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Complete Web Development Bootcamp'));
    await tester.pumpAndSettle();

    expect(find.text('Senior Full-Stack Developer'), findsOneWidget);
    expect(find.text('12.4k'), findsOneWidget);
    expect(find.text('42h'), findsOneWidget);
    expect(find.text('₹1,999'), findsOneWidget);
    expect(find.text('1. Introduction to HTML'), findsOneWidget);
    expect(
      find.text(
        'Master HTML, CSS, JavaScript, React and Node.js. Build 15 real-world '
        'projects and become a job-ready full-stack developer.',
      ),
      findsOneWidget,
    );

    // Back button returns to the search results.
    await tester.tap(find.byIcon(Icons.swap_horiz));
    await tester.pumpAndSettle();
    expect(find.byType(CourseDetails), findsNothing);
    expect(find.byType(Searches), findsOneWidget);
  });

  testWidgets('Every home course card opens the details page', (tester) async {
    ignoreOverflowErrors();

    await tester.pumpWidget(const MaterialApp(home: index()));
    await tester.pump(const Duration(seconds: 1));

    for (final title in [
      'Complete Web Development Bootcamp', // Popular Courses
      'Python Programming', // Continue Learning
      'Digital Marketing Fundamentals', // Recommended
    ]) {
      await tester.ensureVisible(find.text(title));
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text(title));
      await tester.pumpAndSettle();

      expect(
        find.byType(CourseDetails),
        findsOneWidget,
        reason: '$title should open the details page',
      );
      expect(find.text('Enroll Now'), findsOneWidget);
      expect(find.text('Add to Cart'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.swap_horiz));
      await tester.pumpAndSettle();
      expect(find.byType(CourseDetails), findsNothing);
    }
  });

  testWidgets('Each clicked course shows its OWN title and price', (
    tester,
  ) async {
    ignoreOverflowErrors();

    await tester.pumpWidget(const MaterialApp(home: Searches()));
    await tester.pump(const Duration(seconds: 1));

    const cases = <(String, String, String)>[
      ('Complete Web', 'Complete Web Development Bootcamp', '₹1,999'),
      ('UI/UX', 'UI/UX Design Masterclass', '₹1,499'),
      ('Digital Marketing', 'Digital Marketing Fundamentals', '₹999'),
      ('Business Management', 'Business Management Essentials', '₹1,299'),
      ('Python', 'Python Programming', '₹1,799'),
      ('Productivity', 'Personal Development & Productivity', '₹799'),
    ];

    for (final (query, title, price) in cases) {
      await tester.enterText(find.byType(TextField), query);
      await tester.pump(const Duration(seconds: 1));
      // `.last` skips the query typed into the search field itself.
      await tester.tap(find.text(title).last);
      await tester.pumpAndSettle();

      expect(find.byType(CourseDetails), findsOneWidget);
      expect(
        find.text(title),
        findsOneWidget,
        reason: 'details must show the clicked course title',
      );
      expect(
        find.text(price),
        findsOneWidget,
        reason: 'details must show the clicked course price',
      );

      await tester.tap(find.byIcon(Icons.swap_horiz));
      await tester.pumpAndSettle();
      expect(find.byType(CourseDetails), findsNothing);
    }
  });

  testWidgets('Favourite status comes from the selected course', (
    tester,
  ) async {
    ignoreOverflowErrors();

    await tester.pumpWidget(const MaterialApp(home: Searches()));
    await tester.pump(const Duration(seconds: 1));

    // c1 starts as a favourite in the course data.
    await tester.enterText(find.byType(TextField), 'Complete Web');
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Complete Web Development Bootcamp').last);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsNothing);

    // Toggling on the details page updates the shared state.
    await tester.tap(find.byIcon(Icons.favorite));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.favorite), findsNothing);
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);

    await tester.tap(find.byIcon(Icons.swap_horiz));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
  });
}
