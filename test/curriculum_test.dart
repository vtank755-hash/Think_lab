import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:think_lab/course.dart';
import 'package:think_lab/course_details.dart';
import 'package:think_lab/index.dart';
import 'package:think_lab/lesson_page.dart';
import 'package:think_lab/module_detail_page.dart';
import 'package:think_lab/progress.dart';
import 'package:think_lab/purchases.dart';
import 'package:think_lab/session.dart';

import 'test_utils.dart';

/// Opens Module 1 of the Python course from the course details page.
Future<void> openPythonModule1(WidgetTester tester) async {
  await tester.ensureVisible(find.text('1. Getting Started with Python'));
  await tester.pump(const Duration(milliseconds: 300));
  await tester.tap(find.text('1. Getting Started with Python'));
  await tester.pumpAndSettle();
}

void main() {
  // Learning progress and enrolment are app-wide state: reset every test.
  setUp(() {
    resetLearningProgress();
    resetPurchases();
    signIn('guest');
  });

  final python = courseById('c5');

  testWidgets('Curriculum opens the module\'s complete lesson list', (
    tester,
  ) async {
    ignoreOverflowErrors();

    await tester.pumpWidget(MaterialApp(home: CourseDetails(course: python)));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Curriculum'), findsOneWidget);
    // Calculated from the data — 9 + 15 + 11 + 8.
    expect(find.text('0 / 43 lessons completed'), findsOneWidget);
    expect(find.text('0%'), findsOneWidget);
    expect(find.text('1. Getting Started with Python'), findsOneWidget);
    expect(find.text('9 lessons · 1h 45m'), findsOneWidget);

    // Tap module 1 → the module learning screen.
    await openPythonModule1(tester);

    expect(find.byType(ModuleDetailPage), findsOneWidget);
    expect(find.text('Module 1'), findsOneWidget);
    expect(find.text('Getting Started with Python'), findsOneWidget);
    expect(find.text('9 Lessons • 1h 45m'), findsOneWidget);
    expect(find.text('0 / 9 lessons completed'), findsOneWidget);

    // The lesson list comes from the course data, not a fixed screen.
    expect(find.text('1. What is Python?'), findsOneWidget);
    expect(find.text('2. Installing Python'), findsOneWidget);
    expect(find.text('08:25'), findsOneWidget);

    // Lazy list → the last lesson has to be scrolled into view.
    await tester.scrollUntilVisible(find.text('9. Practice Exercise'), 300);
    expect(find.text('9. Practice Exercise'), findsOneWidget);
    // No lesson of another module leaks in.
    expect(find.text('1. The for Loop'), findsNothing);

    // Not purchased → the existing locked behaviour is advertised.
    expect(
      find.text('Purchase this course to watch its lessons.'),
      findsOneWidget,
    );
  });

  testWidgets('A lesson opens the video page with its own context', (
    tester,
  ) async {
    ignoreOverflowErrors();
    unlockCourses([python]);

    await tester.pumpWidget(MaterialApp(home: CourseDetails(course: python)));
    await tester.pump(const Duration(seconds: 1));
    await openPythonModule1(tester);

    await tester.tap(find.text('1. What is Python?'));
    await tester.pumpAndSettle();

    expect(find.byType(LessonPage), findsOneWidget);
    expect(find.text('Module 1'), findsOneWidget);
    expect(find.text('Getting Started with Python'), findsOneWidget);
    expect(find.text('Lesson 1 / 9'), findsOneWidget);

    // Video player: play/pause, seek bar, current + total duration.
    expect(find.byIcon(Icons.play_arrow_rounded), findsWidgets);
    expect(find.byIcon(Icons.pause_rounded), findsNothing);
    expect(find.byType(Slider), findsOneWidget);
    expect(find.text('00:00'), findsOneWidget);
    expect(find.text('08:25'), findsOneWidget);
    expect(find.byIcon(Icons.fullscreen_rounded), findsOneWidget);

    // Lesson information below the video.
    expect(find.text('1. What is Python?'), findsOneWidget);
    expect(find.text('About this lesson'), findsOneWidget);
    expect(
      find.textContaining('Python is a high-level'),
      findsOneWidget,
      reason: 'context comes from the lesson data',
    );

    // Points, code example and notes sit further down the page.
    await tester.scrollUntilVisible(find.text("What you'll learn"), 300);
    expect(find.text("What you'll learn"), findsOneWidget);
    expect(find.text('What Python is used for'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Example'), 300);
    expect(find.text('Example'), findsOneWidget);
    expect(find.text('print("Hello, Python!")'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Notes'), 300);
    expect(find.text('Notes'), findsOneWidget);

    // Bottom of the lesson: completion + previous/next navigation.
    await tester.scrollUntilVisible(find.text('Next Lesson'), 300);
    expect(find.text('Mark as completed'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Previous'), findsOneWidget);
    final previous = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Previous'),
    );
    expect(previous.onPressed, isNull, reason: 'first lesson has no previous');
    expect(find.widgetWithText(FilledButton, 'Next Lesson'), findsOneWidget);
  });

  testWidgets('Unpaid users cannot reach the lesson content', (tester) async {
    ignoreOverflowErrors();
    // NOT purchased.

    await tester.pumpWidget(
      const MaterialApp(
        home: LessonPage(
          courseId: 'c5',
          moduleId: 'c5-module-1',
          lessonId: 'c5-module-1-lesson-1',
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('This lesson is locked'), findsOneWidget);
    expect(find.text('About this lesson'), findsNothing);
    expect(find.byType(Slider), findsNothing);
    expect(find.text('View course'), findsOneWidget);
  });

  testWidgets('Play, complete, and watch module + course progress update', (
    tester,
  ) async {
    ignoreOverflowErrors();
    unlockCourses([python]);

    await tester.pumpWidget(MaterialApp(home: CourseDetails(course: python)));
    await tester.pump(const Duration(seconds: 1));
    await openPythonModule1(tester);

    await tester.tap(find.text('1. What is Python?'));
    await tester.pumpAndSettle();

    // Play for two seconds → the clock and the saved position move.
    await tester.tap(find.byIcon(Icons.play_arrow_rounded));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('00:02'), findsOneWidget);
    expect(videoPositionFor('c5-module-1-lesson-1'), greaterThanOrEqualTo(2));

    await tester.tap(find.byIcon(Icons.pause_rounded));
    await tester.pump();
    expect(find.byIcon(Icons.play_arrow_rounded), findsWidgets);

    // Scrub to the very end → the lesson is completed.
    final slider = find.byType(Slider);
    final rect = tester.getRect(slider);
    await tester.tapAt(Offset(rect.right - 2, rect.center.dy));
    await tester.pump();

    expect(isLessonCompleted('c5-module-1-lesson-1'), isTrue);
    await tester.scrollUntilVisible(find.text('Completed'), 300);
    expect(find.text('Completed'), findsOneWidget);

    // Back on the module page → the check + progress are live.
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(ModuleDetailPage), findsOneWidget);
    expect(find.text('1 / 9 lessons completed'), findsOneWidget);
    expect(find.text('11%'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsWidgets);

    // Back on the course → course progress updated too.
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(CourseDetails), findsOneWidget);
    expect(find.text('1 / 43 lessons completed'), findsOneWidget);
    expect(
      find.text('1 / 9 lessons completed'),
      findsOneWidget,
      reason: 'module row carries its own progress',
    );
  });

  testWidgets('Next Lesson walks through the module and into the next one', (
    tester,
  ) async {
    ignoreOverflowErrors();
    unlockCourses([python]);

    // Start at the LAST lesson of module 1.
    await tester.pumpWidget(
      const MaterialApp(
        home: LessonPage(
          courseId: 'c5',
          moduleId: 'c5-module-1',
          lessonId: 'c5-module-1-lesson-9',
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Lesson 9 / 9'), findsOneWidget);
    expect(find.text('9. Practice Exercise'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Next Lesson'), 300);
    expect(find.text('Finish Course'), findsNothing);
    await tester.tap(find.widgetWithText(FilledButton, 'Next Lesson'));
    await tester.pumpAndSettle();

    // Module 1 → Module 2, lesson 1 — exactly the documented flow.
    expect(find.byType(LessonPage), findsOneWidget);
    expect(find.text('Module 2'), findsOneWidget);
    expect(find.text('Getting Started with Python'), findsNothing);
    expect(find.text('Loops, Functions & Collections'), findsOneWidget);
    expect(find.text('Lesson 1 / 15'), findsOneWidget);
    expect(find.text('1. The for Loop'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Previous'), 300);
    final previous = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Previous'),
    );
    expect(previous.onPressed, isNotNull);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Previous'));
    await tester.pumpAndSettle();
    expect(find.text('Module 1'), findsOneWidget);
    expect(find.text('9. Practice Exercise'), findsOneWidget);
  });

  testWidgets('Continue Learning resumes the last watched lesson', (
    tester,
  ) async {
    ignoreOverflowErrors();
    unlockCourses([python]);

    await tester.pumpWidget(
      const MaterialApp(
        home: LessonPage(
          courseId: 'c5',
          moduleId: 'c5-module-2',
          lessonId: 'c5-module-2-lesson-5',
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    // The resume point is remembered…
    expect(resumePoint(python), ('c5-module-2', 'c5-module-2-lesson-5'));
    expect(resumeOf('guest').value['c5'], 'c5-module-2/c5-module-2-lesson-5');

    // …and so is the playback position.
    await tester.tap(find.byIcon(Icons.play_arrow_rounded));
    await tester.pump(const Duration(seconds: 2));
    await tester.tap(find.byIcon(Icons.pause_rounded));
    await tester.pump();
    expect(
      videoPositionFor('c5-module-2-lesson-5'),
      greaterThanOrEqualTo(2),
      reason: 'video progress is remembered per lesson',
    );

    // Home → Continue Learning takes the user straight back to that lesson.
    await tester.pumpWidget(const MaterialApp(home: index()));
    await tester.pump(const Duration(seconds: 1));

    expect(
      find.text('Module 2 · 5. Defining Functions'),
      findsOneWidget,
      reason: 'resume label is dynamic',
    );
    expect(find.text('Course Progress'), findsOneWidget);

    await tester.ensureVisible(find.text('Python Programming'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Python Programming'));
    await tester.pumpAndSettle();

    expect(find.byType(LessonPage), findsOneWidget);
    expect(find.text('Lesson 5 / 15'), findsOneWidget);
    expect(find.text('5. Defining Functions'), findsOneWidget);
    expect(find.text('Module 2'), findsOneWidget);
    // Resumed, not restarted.
    expect(find.text('00:02'), findsWidgets);
  });

  testWidgets('Every course uses its own module data', (tester) async {
    ignoreOverflowErrors();

    // A different course → its own modules and lessons, same screen.
    await tester.pumpWidget(
      const MaterialApp(
        home: ModuleDetailPage(courseId: 'c1', moduleId: 'c1-module-1'),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Module 1'), findsOneWidget);
    expect(find.text('Introduction to HTML'), findsOneWidget);
    expect(find.text('1. How the Web Works'), findsOneWidget);
    expect(find.text('What is Python?'), findsNothing);
    expect(find.text('Loops, Functions & Collections'), findsNothing);
  });

  test('Lesson completion belongs to the current user', () {
    signIn('usera@learnhub.app');
    markLessonCompleted('c5-module-1-lesson-1');

    expect(isLessonCompleted('c5-module-1-lesson-1'), isTrue);
    expect(
      isLessonCompleted('c5-module-1-lesson-1', userId: 'userb@learnhub.app'),
      isFalse,
      reason: 'user B has not completed it',
    );

    signIn('userb@learnhub.app');
    expect(isLessonCompleted('c5-module-1-lesson-1'), isFalse);
    expect(completedInCourse(python), 0);

    signIn('usera@learnhub.app');
    expect(completedInCourse(python), 1);
    expect(progressPercent(1, 43), 2);
  });

  test('Module and course progress are calculated from the lesson data', () {
    expect(courseLessonCount(python), 43, reason: '9 + 15 + 11 + 8');
    expect(python.modules.length, 4);
    expect(python.modules[0].lessons.length, 9);
    expect(moduleMeta(python.modules[0]), '9 lessons · 1h 45m');
    expect(moduleHeadline(python.modules[0]), '9 Lessons • 1h 45m');
    expect(formatClock(durationInSeconds('08:25')), '08:25');
    expect(progressLabel(3, 9), '3 / 9 lessons completed');
    expect(progressPercent(3, 9), 33);

    // Ids: course → module → lesson, never titles.
    expect(moduleIdFor(python, 0), 'c5-module-1');
    expect(lessonIdFor(python, 0, 0), 'c5-module-1-lesson-1');
    expect(
      lessonById(python, 'c5-module-1', 'c5-module-1-lesson-1').title,
      '1. What is Python?',
    );
    expect(
      lessonVideo(python, 0, 0),
      'assets/videos/courses/python/lesson_01.mp4',
      reason: 'every lesson points at its own video',
    );
  });
}
