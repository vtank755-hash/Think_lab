import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:think_lab/course.dart';
import 'package:think_lab/course_details.dart';
import 'package:think_lab/lesson_page.dart';
import 'package:think_lab/progress.dart';
import 'package:think_lab/purchases.dart';
import 'package:think_lab/quiz.dart';
import 'package:think_lab/quiz_page.dart';
import 'package:think_lab/quiz_results.dart';
import 'package:think_lab/session.dart';

import 'test_utils.dart';

/// Marks every lesson of [course] completed for the current user — STAGE 1 of
/// the two-stage completion rule (the final quiz is STAGE 2).
void completeLessons(Course course) {
  for (var m = 0; m < course.modules.length; m++) {
    for (var i = 0; i < course.modules[m].lessons.length; i++) {
      markLessonCompleted(lessonIdFor(course, m, i));
    }
  }
}

/// The saved (selected) decoration of answer option [index].
BoxDecoration optionColor(WidgetTester tester, int index) {
  final gesture = tester.widget<GestureDetector>(
    find.byKey(quizOptionKey(index)),
  );
  return (gesture.child as Container).decoration! as BoxDecoration;
}

/// Answers every question: the first [wrong] questions get a WRONG answer, the
/// rest the correct one — so the resulting score is `20 - wrong`.
Future<void> answerAll(
  WidgetTester tester,
  CourseQuiz quiz, {
  int wrong = 0,
}) async {
  expect(quiz.questions.length, 20);
  for (var i = 0; i < quiz.questions.length; i++) {
    final correct = quiz.questions[i].correctIndex;
    final pick = i < wrong ? (correct + 1) % 4 : correct;
    await tester.ensureVisible(find.byKey(quizOptionKey(pick)));
    await tester.pump();
    await tester.tap(find.byKey(quizOptionKey(pick)));
    await tester.pump();
    if (i < quiz.questions.length - 1) {
      await tester.tap(find.widgetWithText(FilledButton, 'Next'));
      await tester.pump();
    }
  }
}

void main() {
  setUp(() {
    resetLearningProgress();
    resetPurchases();
    resetQuizResults();
    signIn('guest');
  });

  final python = courseById('c5');

  // ---------------------------------------------------------------------
  // 1. Course-specific, dynamic, exactly 20 questions
  // ---------------------------------------------------------------------
  test('Every course loads its OWN quiz with exactly 20 questions', () {
    expect(allQuizzes.length, allCourses.length);

    for (final course in allCourses) {
      final quiz = quizForCourse(course.id);
      expect(quiz, isNotNull, reason: '${course.id} must have a quiz');
      expect(quiz!.courseId, course.id, reason: 'quiz must belong to course');
      expect(quiz.id, '${course.id}_final_quiz');
      expect(quiz.questions.length, quizQuestionCount);
      expect(quiz.questions.length, 20);

      for (var i = 0; i < quiz.questions.length; i++) {
        final q = quiz.questions[i];
        expect(q.options.length, 4);
        expect(q.correctIndex, inInclusiveRange(0, 3));
        expect(questionIdFor(quiz, i), '${quiz.id}_q${i + 1}');
        expect(q.text, isNotEmpty);
        expect(q.topic, isNotEmpty);
      }
    }

    // No shared quiz: different ids, titles and questions per course.
    expect(quizForCourse('c5')!.id, isNot(quizForCourse('c1')!.id));
    expect(quizForCourse('c5')!.title, isNot(quizForCourse('c1')!.title));
    expect(
      quizForCourse('c5')!.questions.map((q) => q.text),
      isNot(quizForCourse('c1')!.questions.map((q) => q.text)),
    );
    // Unknown course → nothing (never another course's questions).
    expect(quizForCourse('nope'), isNull);
  });

  // ---------------------------------------------------------------------
  // 2. Quiz is hidden until the course learning is completed
  // ---------------------------------------------------------------------
  testWidgets('The quiz is never offered before every lesson is completed', (
    tester,
  ) async {
    ignoreOverflowErrors();
    unlockCourses([python]);
    // Only 9 of 43 lessons done.
    for (var i = 0; i < 9; i++) {
      markLessonCompleted(lessonIdFor(python, 0, i));
    }

    await tester.pumpWidget(MaterialApp(home: CourseDetails(course: python)));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Take Quiz'), findsNothing);
    expect(find.text('Course learning completed'), findsNothing);

    // Last lesson of the last module with lessons still missing.
    await tester.pumpWidget(
      const MaterialApp(
        home: LessonPage(
          courseId: 'c5',
          moduleId: 'c5-module-4',
          lessonId: 'c5-module-4-lesson-8',
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.scrollUntilVisible(find.text('Finish Course'), 300);
    expect(find.text('Take Quiz'), findsNothing);
    expect(find.text('Course learning completed'), findsNothing);
    expect(find.text('Finish Course'), findsOneWidget);
  });

  testWidgets('Finishing the last lesson shows the completion state + quiz', (
    tester,
  ) async {
    ignoreOverflowErrors();
    unlockCourses([python]);
    completeLessons(python);
    expect(isCourseLessonsComplete(python), isTrue);
    expect(isCourseFullyCompleted(python), isFalse);

    await tester.pumpWidget(
      const MaterialApp(
        home: LessonPage(
          courseId: 'c5',
          moduleId: 'c5-module-4',
          lessonId: 'c5-module-4-lesson-8',
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.scrollUntilVisible(
      find.text('Course learning completed'),
      300,
    );

    expect(find.text('Course learning completed'), findsOneWidget);
    expect(find.text('Take Quiz'), findsWidgets); // banner + nav button
    expect(find.textContaining('Take the final quiz'), findsOneWidget);

    // The details page shows the same completion card.
    await tester.pumpWidget(MaterialApp(home: CourseDetails(course: python)));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Course learning completed'), findsOneWidget);
    expect(find.text('Take Quiz'), findsOneWidget);
  });

  // ---------------------------------------------------------------------
  // 3. Entry point + course-specific questions
  // ---------------------------------------------------------------------
  testWidgets(
    'Take Quiz on Course Details opens that course 20-question quiz',
    (tester) async {
      ignoreOverflowErrors();
      unlockCourses([python]);
      completeLessons(python);

      await tester.pumpWidget(MaterialApp(home: CourseDetails(course: python)));
      await tester.pump(const Duration(seconds: 1));

      await tester.ensureVisible(find.text('Take Quiz'));
      await tester.pump();
      await tester.tap(find.text('Take Quiz'));
      await tester.pumpAndSettle();

      expect(find.byType(QuizPage), findsOneWidget);
      expect(find.text('Module Quiz'), findsOneWidget);
      expect(find.text('Question 1 of 20'), findsOneWidget);
      expect(find.text('5%'), findsOneWidget);

      // Python course → Python questions only.
      final quiz = quizForCourse('c5')!;
      expect(find.text(quiz.questions.first.text), findsOneWidget);
      expect(find.text(quiz.questions.first.topic), findsOneWidget);
      expect(
        find.text(quizForCourse('c1')!.questions.first.text),
        findsNothing,
      );
      expect(find.text('Previous'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Next'), findsOneWidget);
    },
  );

  testWidgets('The quiz page shows the questions of ITS course only', (
    tester,
  ) async {
    ignoreOverflowErrors();

    await tester.pumpWidget(const MaterialApp(home: QuizPage(courseId: 'c1')));
    await tester.pump(const Duration(seconds: 1));

    final webQuiz = quizForCourse('c1')!;
    expect(find.text('Question 1 of 20'), findsOneWidget);
    expect(find.text(webQuiz.questions.first.text), findsOneWidget);
    expect(find.text(webQuiz.questions.first.topic), findsOneWidget);
    // Never the other course's content.
    expect(find.text(quizForCourse('c5')!.questions.first.text), findsNothing);

    // A course without quiz data never borrows another course's quiz.
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.pumpWidget(const MaterialApp(home: QuizPage(courseId: 'zz')));
    await tester.pump(const Duration(seconds: 1));
    expect(
      find.text('No quiz is available for this course yet.'),
      findsOneWidget,
    );
    expect(find.text('Question 1 of 20'), findsNothing);
  });

  // ---------------------------------------------------------------------
  // 4. Answer selection + Previous / Next keep the selections
  // ---------------------------------------------------------------------
  testWidgets('One answer per question, kept when moving Previous / Next', (
    tester,
  ) async {
    ignoreOverflowErrors();

    await tester.pumpWidget(const MaterialApp(home: QuizPage(courseId: 'c5')));
    await tester.pump(const Duration(seconds: 1));

    // Nothing selected yet.
    expect(optionColor(tester, 0).color, Colors.white);

    // Select option C on question 1.
    await tester.tap(find.byKey(quizOptionKey(2)));
    await tester.pump();
    expect(optionColor(tester, 2).color, quizSelectedOptionBg);
    expect(optionColor(tester, 0).color, Colors.white);

    // Next → pick B → Previous → C is STILL selected on question 1.
    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pump();
    expect(find.text('Question 2 of 20'), findsOneWidget);
    expect(optionColor(tester, 1).color, Colors.white);

    await tester.tap(find.byKey(quizOptionKey(1)));
    await tester.pump();
    expect(optionColor(tester, 1).color, quizSelectedOptionBg);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Previous'));
    await tester.pump();
    expect(find.text('Question 1 of 20'), findsOneWidget);
    expect(
      optionColor(tester, 2).color,
      quizSelectedOptionBg,
    ); // still selected
    expect(optionColor(tester, 0).color, Colors.white);
    expect(optionColor(tester, 1).color, Colors.white);

    // Previous is disabled on question 1.
    expect(
      tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'Previous'),
      ),
      isA<OutlinedButton>().having((b) => b.onPressed, 'onPressed', isNull),
    );
  });

  // ---------------------------------------------------------------------
  // 5. Dynamic progress (calculated, never written by hand)
  // ---------------------------------------------------------------------
  testWidgets('Question counter and % progress are calculated dynamically', (
    tester,
  ) async {
    ignoreOverflowErrors();

    await tester.pumpWidget(const MaterialApp(home: QuizPage(courseId: 'c5')));
    await tester.pump(const Duration(seconds: 1));

    Future<void> expectState(String counter, String percent) async {
      expect(find.text(counter), findsOneWidget);
      expect(find.text(percent), findsOneWidget);
    }

    await expectState('Question 1 of 20', '5%');

    for (var i = 2; i <= 10; i++) {
      await tester.tap(find.widgetWithText(FilledButton, 'Next'));
      await tester.pump();
    }
    await expectState('Question 10 of 20', '50%');

    for (var i = 11; i <= 15; i++) {
      await tester.tap(find.widgetWithText(FilledButton, 'Next'));
      await tester.pump();
    }
    await expectState('Question 15 of 20', '75%');

    for (var i = 16; i <= 20; i++) {
      await tester.tap(find.widgetWithText(FilledButton, 'Next'));
      await tester.pump();
    }
    await expectState('Question 20 of 20', '100%');

    // Last question: Submit instead of Next, Previous still available.
    expect(find.widgetWithText(FilledButton, 'Submit'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Next'), findsNothing);
    expect(find.widgetWithText(OutlinedButton, 'Previous'), findsOneWidget);
  });

  // ---------------------------------------------------------------------
  // 6. Submit → real score, 75% boundary, pass marks the course complete
  // ---------------------------------------------------------------------
  testWidgets('Scoring 15 / 20 (exactly 75%) passes and completes the course', (
    tester,
  ) async {
    ignoreOverflowErrors();
    unlockCourses([python]);
    completeLessons(python);

    await tester.pumpWidget(MaterialApp(home: CourseDetails(course: python)));
    await tester.pump(const Duration(seconds: 1));
    await tester.ensureVisible(find.text('Take Quiz'));
    await tester.pump();
    await tester.tap(find.text('Take Quiz'));
    await tester.pumpAndSettle();

    // 5 wrong answers → 15 / 20 = 75%.
    await answerAll(tester, quizForCourse('c5')!, wrong: 5);
    await tester.tap(find.widgetWithText(FilledButton, 'Submit'));
    await tester.pumpAndSettle();

    expect(find.text('Quiz Completed'), findsOneWidget);
    expect(
      find.text('Congratulations! You completed the final quiz.'),
      findsOneWidget,
    );
    expect(find.text('Score'), findsOneWidget);
    expect(find.text('15 / 20'), findsOneWidget);
    expect(find.text('75%'), findsOneWidget);
    expect(find.text('PASSED'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Retry Quiz'), findsNothing);

    // Stage 2 reached → the course is finally fully completed.
    expect(isQuizPassed('c5'), isTrue);
    expect(isCourseFullyCompleted(python), isTrue);
    expect(latestQuizAttempt('c5')!.attempt, 1);
    expect(latestQuizAttempt('c5')!.percentage, 75);

    // Details card flips to the success state after returning.
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Course successfully completed'), findsOneWidget);
    expect(find.text('Take Quiz'), findsNothing);
  });

  testWidgets('Below 75% fails, does NOT complete the course, Retry restarts', (
    tester,
  ) async {
    ignoreOverflowErrors();
    unlockCourses([python]);
    completeLessons(python);

    await tester.pumpWidget(MaterialApp(home: CourseDetails(course: python)));
    await tester.pump(const Duration(seconds: 1));
    await tester.ensureVisible(find.text('Take Quiz'));
    await tester.pump();
    await tester.tap(find.text('Take Quiz'));
    await tester.pumpAndSettle();

    // 6 wrong answers → 14 / 20 = 70% → FAIL.
    await answerAll(tester, quizForCourse('c5')!, wrong: 6);
    await tester.tap(find.widgetWithText(FilledButton, 'Submit'));
    await tester.pumpAndSettle();

    expect(find.text('Quiz Not Passed'), findsOneWidget);
    expect(find.text('Your Score'), findsOneWidget);
    expect(find.text('14 / 20'), findsOneWidget);
    expect(find.text('70%'), findsOneWidget);
    expect(find.text('Minimum Passing Score'), findsOneWidget);
    expect(find.text('75%'), findsOneWidget);
    expect(find.text('NOT PASSED'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Retry Quiz'), findsOneWidget);

    // A failed attempt never completes the course (stage 2 missing).
    expect(isQuizPassed('c5'), isFalse);
    expect(isCourseLessonsComplete(python), isTrue);
    expect(isCourseFullyCompleted(python), isFalse);

    // Retry → back to question 1 with cleared answers.
    await tester.tap(find.widgetWithText(FilledButton, 'Retry Quiz'));
    await tester.pumpAndSettle();
    expect(find.text('Question 1 of 20'), findsOneWidget);
    expect(find.text('5%'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Submit'), findsNothing);
    // All four answers were cleared by the retry.
    for (var i = 0; i < 4; i++) {
      if (tester.any(find.byKey(quizOptionKey(i)))) {
        expect(optionColor(tester, i).color, Colors.white);
      }
    }

    // Second attempt: a perfect score → PASS.
    await answerAll(tester, quizForCourse('c5')!);
    await tester.tap(find.widgetWithText(FilledButton, 'Submit'));
    await tester.pumpAndSettle();

    expect(find.text('Quiz Completed'), findsOneWidget);
    expect(find.text('20 / 20'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
    expect(find.text('PASSED'), findsOneWidget);
    expect(isCourseFullyCompleted(python), isTrue);

    // Both attempts were stored separately for this course.
    expect(quizAttemptsFor('c5').length, 2);
    expect(quizAttemptsFor('c5').first.attempt, 1);
    expect(quizAttemptsFor('c5').first.percentage, 70);
    expect(quizAttemptsFor('c5').last.attempt, 2);
    expect(quizAttemptsFor('c5').last.percentage, 100);
  });

  testWidgets('14 / 20 (70%) fails while 15 / 20 (75%) passes', (tester) async {
    ignoreOverflowErrors();

    // First: 70% → fail.
    await tester.pumpWidget(const MaterialApp(home: QuizPage(courseId: 'c5')));
    await tester.pump(const Duration(seconds: 1));
    await answerAll(tester, quizForCourse('c5')!, wrong: 6);
    await tester.tap(find.widgetWithText(FilledButton, 'Submit'));
    await tester.pumpAndSettle();

    expect(find.text('Quiz Not Passed'), findsOneWidget);
    expect(find.text('70%'), findsOneWidget);
    expect(find.text('Retry Quiz'), findsOneWidget);

    // Retry and score 75% → pass.
    await tester.tap(find.widgetWithText(FilledButton, 'Retry Quiz'));
    await tester.pumpAndSettle();
    await answerAll(tester, quizForCourse('c5')!, wrong: 5);
    await tester.tap(find.widgetWithText(FilledButton, 'Submit'));
    await tester.pumpAndSettle();

    expect(find.text('Quiz Completed'), findsOneWidget);
    expect(find.text('15 / 20'), findsOneWidget);
    expect(find.text('75%'), findsOneWidget);
    expect(find.text('PASSED'), findsOneWidget);
    expect(isQuizPassed('c5'), isTrue);
    expect(quizAttemptsFor('c5').length, 2);
  });

  // ---------------------------------------------------------------------
  // 7. Results are per USER + COURSE
  // ---------------------------------------------------------------------
  test('Results belong to the current user and to that course', () {
    signIn('a@mail.com');
    completeLessons(python);

    // User A passes the Python quiz.
    saveQuizAttempt('c5', score: 16, total: 20);
    expect(isQuizPassed('c5', userId: 'a@mail.com'), isTrue);
    expect(latestQuizAttempt('c5', userId: 'a@mail.com')!.percentage, 80);
    expect(isCourseFullyCompleted(python, userId: 'a@mail.com'), isTrue);

    // User B has no result for the same course.
    signIn('b@mail.com');
    expect(isQuizPassed('c5'), isFalse);
    expect(latestQuizAttempt('c5'), isNull);
    expect(quizAttemptsFor('c5'), isEmpty);
    expect(isCourseFullyCompleted(python), isFalse);

    // User A's other courses keep their own (empty) results.
    expect(latestQuizAttempt('c1', userId: 'a@mail.com'), isNull);
    expect(isQuizPassed('c1', userId: 'a@mail.com'), isFalse);

    // Attempts are numbered and stored separately per course.
    signIn('a@mail.com');
    saveQuizAttempt('c5', score: 14, total: 20);
    final attempts = quizAttemptsFor('c5', userId: 'a@mail.com');
    expect(attempts.length, 2);
    expect(attempts.first.attempt, 1);
    expect(attempts.first.passed, isTrue);
    expect(attempts.last.attempt, 2);
    expect(attempts.last.percentage, 70);
  });

  // ---------------------------------------------------------------------
  // 8. Two-stage rule: lessons alone never complete the course
  // ---------------------------------------------------------------------
  test('Finishing lessons alone does NOT complete the course', () {
    expect(isCourseFullyCompleted(python), isFalse);

    completeLessons(python);
    expect(isCourseLessonsComplete(python), isTrue);
    expect(isCourseFullyCompleted(python), isFalse);
    expect(completionStateOf(python), CourseCompletionState.quizPending);

    saveQuizAttempt('c5', score: 10, total: 20); // 50% → fail
    expect(isCourseFullyCompleted(python), isFalse);
    expect(completionStateOf(python), CourseCompletionState.quizPending);

    saveQuizAttempt('c5', score: 16, total: 20); // 80% → pass
    expect(isCourseFullyCompleted(python), isTrue);
    expect(completionStateOf(python), CourseCompletionState.completed);
  });
}
