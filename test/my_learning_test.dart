import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:think_lab/course.dart';
import 'package:think_lab/index.dart';
import 'package:think_lab/lesson_page.dart';
import 'package:think_lab/my_learning_page.dart';
import 'package:think_lab/progress.dart';
import 'package:think_lab/purchases.dart';
import 'package:think_lab/quiz_results.dart';
import 'package:think_lab/session.dart';

import 'test_utils.dart';

/// Marks every lesson of [course] completed for the current user.
void completeCourse(Course course) {
  for (var m = 0; m < course.modules.length; m++) {
    for (var i = 0; i < course.modules[m].lessons.length; i++) {
      markLessonCompleted(lessonIdFor(course, m, i));
    }
  }
}

/// Opens the Learning tab from the home screen.
Future<void> openLearningTab(WidgetTester tester) async {
  await tester.tap(find.text('Learning'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    resetLearningProgress();
    resetPurchases();
    resetQuizResults();
    signIn('guest');
  });

  final python = courseById('c5');

  testWidgets('Learning tab opens the My Learning screen', (tester) async {
    ignoreOverflowErrors();

    await tester.pumpWidget(const MaterialApp(home: index()));
    await tester.pump(const Duration(seconds: 1));
    await openLearningTab(tester);

    expect(find.byType(MyLearningPage), findsOneWidget);
    expect(find.text('My Learning'), findsOneWidget);
    expect(find.text('In Progress'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);

    // Nothing enrolled yet → the designed empty state.
    expect(
      find.text("You haven't enrolled in any course yet."),
      findsOneWidget,
    );
    expect(find.text('Browse courses'), findsOneWidget);

    // The other tab has its own empty state.
    await tester.tap(find.text('Completed'));
    await tester.pump();
    expect(
      find.text(
        'No completed courses yet. Finish a course to get your '
        'certificate.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('In Progress shows the REAL progress and Continue resumes', (
    tester,
  ) async {
    ignoreOverflowErrors();
    unlockCourses([python]);

    // 9 of 43 lessons done → 21%, not a fixed 65%.
    for (var i = 0; i < 9; i++) {
      markLessonCompleted(lessonIdFor(python, 0, i));
    }
    // The user stopped at module 1, lesson 5.
    setResumePoint(python, 'c5-module-1', 'c5-module-1-lesson-5');

    await tester.pumpWidget(const MaterialApp(home: index()));
    await tester.pump(const Duration(seconds: 1));
    await openLearningTab(tester);

    expect(find.text('Python Programming'), findsOneWidget);
    expect(find.text('Arjun Rao'), findsOneWidget);
    // Same progress block as Course Details' Curriculum: `9 / 43 …` + `21%`.
    expect(find.text('9 / 43 lessons completed'), findsOneWidget);
    expect(find.text('21%'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Completed · 100%'), findsNothing);

    // Continue → straight into the remembered lesson.
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.byType(LessonPage), findsOneWidget);
    expect(find.text('Module 1'), findsOneWidget);
    expect(find.text('Lesson 5 / 9'), findsOneWidget);
    expect(find.text('5. Data Types'), findsOneWidget);
  });

  testWidgets('A finished course takes the quiz, then moves to Completed', (
    tester,
  ) async {
    ignoreOverflowErrors();
    unlockCourses([python]);
    completeCourse(python);

    await tester.pumpWidget(const MaterialApp(home: index()));
    await tester.pump(const Duration(seconds: 1));
    await openLearningTab(tester);

    // STAGE 1 only (lessons done, quiz NOT passed) → still In Progress and
    // the card offers the final quiz instead of "Continue".
    expect(find.text('Python Programming'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
    expect(find.text('Take Quiz'), findsOneWidget);
    expect(find.text('Continue'), findsNothing);
    expect(find.text('Completed · 100%'), findsNothing);

    // STAGE 2 (quiz passed) → the course finally moves to Completed.
    saveQuizAttempt('c5', score: 16, total: 20);
    await tester.pump();

    expect(
      find.text('You finished every enrolled course — nice!'),
      findsOneWidget,
    );
    expect(find.text('Take Quiz'), findsNothing);

    await tester.tap(find.text('Completed'));
    await tester.pump();

    expect(find.text('Python Programming'), findsOneWidget);
    expect(find.text('Completed · 100%'), findsOneWidget);
    expect(find.text('View Certificate'), findsOneWidget);
    expect(find.text('Continue'), findsNothing);

    await tester.tap(find.text('View Certificate'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.text('Certificate for Python Programming (demo)'),
      findsOneWidget,
    );
  });

  testWidgets('Progress updates live when a lesson is completed', (
    tester,
  ) async {
    ignoreOverflowErrors();
    unlockCourses([python]);
    setResumePoint(python, 'c5-module-1', 'c5-module-1-lesson-1');

    await tester.pumpWidget(const MaterialApp(home: index()));
    await tester.pump(const Duration(seconds: 1));
    await openLearningTab(tester);

    expect(find.text('0%'), findsOneWidget);

    // A lesson gets finished while the tab is open → the bar follows.
    markLessonCompleted(lessonIdFor(python, 0, 0));
    await tester.pump();

    expect(find.text('2%'), findsOneWidget);
    expect(find.text('0%'), findsNothing);
  });
}
