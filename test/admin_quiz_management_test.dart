import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:think_lab/admin_dashboard.dart';
import 'package:think_lab/admin_courses_page.dart';
import 'package:think_lab/admin_quiz_management.dart';
import 'package:think_lab/course.dart';
import 'package:think_lab/course_details.dart';
import 'package:think_lab/progress.dart';
import 'package:think_lab/quiz.dart';
import 'package:think_lab/quiz_page.dart';
import 'package:think_lab/quiz_results.dart';
import 'package:think_lab/session.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    resetAdminCreatedCourses();
    resetCourseQuizzes();
    resetLearningProgress();
    resetQuizResults();
    signIn('quiz-admin-test');
  });

  testWidgets('A newly created admin course appears in the quiz course list', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AdminCoursesPage())),
    );
    await tester.tap(find.byKey(const ValueKey('add-course-button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('course-title-input')),
      'New Admin Course',
    );
    final saveCourseButton = find.byKey(const ValueKey('save-course-btn'));
    await tester.ensureVisible(saveCourseButton);
    await tester.tap(saveCourseButton);
    await tester.pumpAndSettle();

    await tester.pumpWidget(const MaterialApp(home: AdminQuizManagementPage()));
    await tester.tap(find.byKey(const ValueKey('create-course-quiz')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('quiz-course-dropdown')));
    await tester.pumpAndSettle();

    expect(find.text('New Admin Course'), findsOneWidget);
  });

  testWidgets('Admin can add and edit quizzes attached to a course', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AdminDashboardPage()));
    final quizAction = find.byKey(const ValueKey('quick-action-quizzes'));
    await tester.ensureVisible(quizAction);
    await tester.tap(quizAction);
    await tester.pumpAndSettle();
    expect(find.byType(AdminQuizManagementPage), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('create-course-quiz')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('quiz-course-dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(courseById('c1').title).last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('quiz-title-field')),
      'HTML Basics',
    );
    await tester.drag(find.byType(Scrollable).last, const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('quiz-question-0')));
    await tester.enterText(
      find.byKey(const ValueKey('quiz-question-0')),
      'What does HTML stand for?',
    );
    for (var index = 0; index < 4; index++) {
      final option = find.byKey(ValueKey('quiz-option-0-$index'));
      await tester.ensureVisible(option);
      await tester.enterText(option, 'Answer $index');
    }
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    final saveButton = find.byKey(const ValueKey('save-course-quiz'));
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    var quiz = quizzesForCourse(
      'c1',
    ).singleWhere((item) => item.title == 'HTML Basics');
    expect(quiz.questions.single.text, 'What does HTML stand for?');
    quiz = quiz.copyWith(
      title: 'HTML Foundations',
      questions: const [
        QuizQuestion(
          topic: 'HTML',
          text: 'Which tag creates a link?',
          options: ['a', 'b', 'c', 'd'],
          correctIndex: 0,
        ),
      ],
    );
    await saveCourseQuiz(quiz);
    await tester.pumpAndSettle();
    quiz = quizzesForCourse('c1').singleWhere((item) => item.id == quiz.id);
    expect(find.text('HTML Foundations'), findsOneWidget);
    expect(quiz.questions.single.text, 'Which tag creates a link?');

    await tester.pumpWidget(
      MaterialApp(
        key: UniqueKey(),
        home: QuizPage(courseId: 'c1', quizId: quiz.id),
      ),
    );
    await tester.pump();
    expect(find.text('HTML Foundations'), findsOneWidget);
    expect(
      find.text('No quiz is available for this course yet.'),
      findsNothing,
    );
    expect(find.text('Which tag creates a link?'), findsOneWidget);
  });

  testWidgets('Editing a quiz updates its course catalog entry', (
    tester,
  ) async {
    final quiz = CourseQuiz(
      id: 'c1_editable',
      courseId: 'c1',
      title: 'Before Edit',
      questions: const [
        QuizQuestion(
          topic: 'HTML',
          text: 'Old question?',
          options: ['A', 'B', 'C', 'D'],
          correctIndex: 1,
        ),
      ],
      isFinal: false,
    );
    await saveCourseQuiz(quiz);
    saveQuizAttempt(
      'c1',
      quizId: quiz.id,
      score: 1,
      total: 1,
      passingPercentage: 70,
    );
    await tester.pumpWidget(const MaterialApp(home: AdminQuizManagementPage()));
    await tester.pump();

    await tester.tap(find.byKey(ValueKey('edit-quiz-${quiz.id}')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('quiz-title-field')),
      'After Edit',
    );
    final editorScroll = find.descendant(
      of: find.byType(AdminQuizEditorPage),
      matching: find.byType(Scrollable),
    );
    await tester.drag(editorScroll.first, const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('quiz-question-0')),
      'Updated question?',
    );
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.drag(editorScroll.first, const Offset(0, -800));
    await tester.pumpAndSettle();
    final saveButton = find.byKey(const ValueKey('save-course-quiz'));
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(find.text('After Edit'), findsOneWidget);
    expect(
      quizzesForCourse(
        'c1',
      ).singleWhere((item) => item.id == quiz.id).questions.single.text,
      'Updated question?',
    );
    expect(quizAttemptsFor('c1', quizId: quiz.id), isEmpty);
  });

  testWidgets('Published quizzes appear under their completed course', (
    tester,
  ) async {
    final course = courseById('c1');
    for (
      var moduleIndex = 0;
      moduleIndex < course.modules.length;
      moduleIndex++
    ) {
      for (
        var lessonIndex = 0;
        lessonIndex < course.modules[moduleIndex].lessons.length;
        lessonIndex++
      ) {
        markLessonCompleted(lessonIdFor(course, moduleIndex, lessonIndex));
      }
    }

    await saveCourseQuiz(
      CourseQuiz(
        id: 'c1_student_view',
        courseId: 'c1',
        title: 'HTML Practice',
        isFinal: false,
        questions: const [
          QuizQuestion(
            topic: 'HTML',
            text: 'Which tag adds a link?',
            options: ['a', 'b', 'c', 'd'],
            correctIndex: 0,
          ),
        ],
      ),
    );
    await tester.pumpWidget(MaterialApp(home: CourseDetails(course: course)));
    await tester.pump();

    expect(find.text('Course Quizzes'), findsOneWidget);
    final quizRow = find.byKey(const ValueKey('course-quiz-c1_student_view'));
    await tester.ensureVisible(quizRow);
    await tester.tap(quizRow);
    await tester.pumpAndSettle();
    expect(find.text('Which tag adds a link?'), findsOneWidget);
  });

  testWidgets('Admin can add a quiz directly from the course page', (
    tester,
  ) async {
    signInAdmin('admin@learnhub.in');
    final course = courseById('c1');
    await tester.pumpWidget(MaterialApp(home: CourseDetails(course: course)));
    await tester.pump();

    final addButton = find.byKey(const ValueKey('course-add-quiz-button'));
    expect(addButton, findsOneWidget);
    await tester.ensureVisible(addButton);
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    final editor = tester.widget<AdminQuizEditorPage>(
      find.byType(AdminQuizEditorPage),
    );
    expect(editor.courseId, isNull);
    expect(find.text('Select course'), findsOneWidget);
  });

  testWidgets('Student course page does not show the admin quiz button', (
    tester,
  ) async {
    signIn('student@example.com');
    await tester.pumpWidget(
      MaterialApp(home: CourseDetails(course: courseById('c1'))),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('course-add-quiz-button')), findsNothing);
  });

  test(
    'Quiz changes survive a catalog reload and stay course-specific',
    () async {
      final original = quizzesForCourse('c1').single;
      await saveCourseQuiz(
        CourseQuiz(
          id: 'c1_extra',
          courseId: 'c1',
          title: 'Added from admin',
          questions: const [
            QuizQuestion(
              topic: 'HTML',
              text: 'Which tag creates a link?',
              options: ['a', 'b', 'c', 'd'],
              correctIndex: 0,
            ),
          ],
          isFinal: false,
        ),
      );

      await loadSavedCourseQuizzes();

      expect(
        quizzesForCourse('c1').map((quiz) => quiz.id),
        contains('c1_extra'),
      );
      expect(quizzesForCourse('c2'), hasLength(1));
      expect(quizForCourse('c1')!.id, original.id);

      await deleteCourseQuiz('c1', 'c1_extra');
      await loadSavedCourseQuizzes();
      expect(
        quizzesForCourse('c1').map((quiz) => quiz.id),
        isNot(contains('c1_extra')),
      );
    },
  );
}
