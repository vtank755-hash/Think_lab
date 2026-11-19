import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:think_lab/certificate_page.dart';
import 'package:think_lab/course.dart';
import 'package:think_lab/course_details.dart';
import 'package:think_lab/progress.dart';
import 'package:think_lab/purchases.dart';
import 'package:think_lab/quiz.dart';
import 'package:think_lab/quiz_page.dart';
import 'package:think_lab/quiz_results.dart';
import 'package:think_lab/session.dart';

import 'test_utils.dart';

void completeAllLessons(Course course) {
  for (var m = 0; m < course.modules.length; m++) {
    for (var i = 0; i < course.modules[m].lessons.length; i++) {
      markLessonCompleted(lessonIdFor(course, m, i));
    }
  }
}

Future<void> passQuiz(WidgetTester tester, CourseQuiz quiz) async {
  for (var i = 0; i < quiz.questions.length; i++) {
    final correct = quiz.questions[i].correctIndex;
    await tester.ensureVisible(find.byKey(quizOptionKey(correct)));
    await tester.pump();
    await tester.tap(find.byKey(quizOptionKey(correct)));
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

  testWidgets('CertificatePage renders certificate card and download/share buttons', (
    tester,
  ) async {
    ignoreOverflowErrors();

    await tester.pumpWidget(
      const MaterialApp(
        home: CertificatePage(
          courseId: 'c3',
          userName: 'Aarav Sharma',
          date: '12 Jun 2024',
          certificateId: 'LH-2024-8842',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Certificate'), findsOneWidget);
    expect(find.text('CERTIFICATE OF COMPLETION'), findsOneWidget);
    expect(find.text('This is proudly presented to'), findsOneWidget);
    expect(find.text('Aarav Sharma'), findsOneWidget);
    expect(find.text('for successfully completing'), findsOneWidget);
    expect(find.text('Digital Marketing Complete Guide'), findsOneWidget);
    expect(find.text('DATE'), findsOneWidget);
    expect(find.text('12 Jun 2024'), findsOneWidget);
    expect(find.text('CERTIFICATE ID'), findsOneWidget);
    expect(find.text('LH-2024-8842'), findsOneWidget);
    expect(find.text('LearnHub'), findsOneWidget);
    expect(find.text('Download'), findsOneWidget);
    expect(find.text('Share'), findsOneWidget);

    // Tap Download button
    await tester.tap(find.text('Download'));
    await tester.pump();
    expect(
      find.text('Certificate LH-2024-8842 downloaded successfully!'),
      findsOneWidget,
    );

    // Tap Share button
    await tester.tap(find.text('Share'));
    await tester.pump();
    expect(
      find.text(
        'Sharing certificate for Digital Marketing Complete Guide (LH-2024-8842)',
      ),
      findsOneWidget,
    );
  });

  testWidgets('Passing quiz provides View Certificate button which opens certificate', (
    tester,
  ) async {
    ignoreOverflowErrors();
    final marketing = courseById('c3');

    await tester.pumpWidget(
      MaterialApp(
        home: QuizPage(courseId: marketing.id),
      ),
    );
    await tester.pumpAndSettle();

    // Answer all questions correctly
    await passQuiz(tester, quizForCourse(marketing.id)!);
    await tester.tap(find.widgetWithText(FilledButton, 'Submit'));
    await tester.pumpAndSettle();

    expect(find.text('Quiz Completed'), findsOneWidget);
    expect(find.text('PASSED'), findsOneWidget);
    expect(find.text('View Certificate'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);

    // Tap View Certificate
    await tester.tap(find.text('View Certificate'));
    await tester.pumpAndSettle();

    expect(find.text('CERTIFICATE OF COMPLETION'), findsOneWidget);
    expect(find.text('Digital Marketing Complete Guide'), findsOneWidget);
    expect(find.text('Download'), findsOneWidget);
  });

  testWidgets('CompletionCard shows View Certificate when course is completed', (
    tester,
  ) async {
    ignoreOverflowErrors();
    final python = courseById('c5');
    unlockCourses([python]);
    completeAllLessons(python);
    saveQuizAttempt(python.id, score: 18, total: 20);

    await tester.pumpWidget(
      MaterialApp(
        home: CourseDetails(course: python),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Course successfully completed'), findsOneWidget);
    expect(find.text('View Certificate'), findsOneWidget);

    await tester.ensureVisible(find.text('View Certificate'));
    await tester.tap(find.text('View Certificate'));
    await tester.pumpAndSettle();

    expect(find.text('CERTIFICATE OF COMPLETION'), findsOneWidget);
    expect(find.text('Python Programming'), findsOneWidget);
    expect(find.text('Download'), findsOneWidget);
  });
}
