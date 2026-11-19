import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:think_lab/admin_courses_page.dart';
import 'package:think_lab/admin_dashboard.dart';
import 'package:think_lab/create_course_page.dart';

import 'test_utils.dart';

void main() {
  setUp(() {
    ignoreOverflowErrors();
  });

  Future<void> pumpCreateCourse(
    WidgetTester tester, {
    AdminCourse? initialCourse,
  }) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: CreateCoursePage(initialCourse: initialCourse),
      ),
    );
    await tester.pumpAndSettle();
  }

  // ── 1. Page renders headers, steps and fields in Create mode ───────────────
  testWidgets('CreateCoursePage renders header, step badges and default fields', (tester) async {
    await pumpCreateCourse(tester);

    expect(find.text('THINKE LAB'), findsOneWidget);
    expect(find.text('Create Course & Quiz'), findsOneWidget);
    expect(find.text('1. COURSE DETAILS'), findsOneWidget);
    expect(find.text('STEP 1 OF 3'), findsOneWidget);
    expect(find.text('2. COURSE MEDIA & LESSONS'), findsOneWidget);
    expect(find.text('STEP 2 OF 3'), findsOneWidget);

    expect(find.text('COURSE TITLE'), findsOneWidget);
    expect(find.text('CATEGORY'), findsOneWidget);
    expect(find.text('LEVEL'), findsOneWidget);
    expect(find.text('COURSE DESCRIPTION'), findsOneWidget);
    expect(find.text('PRICE (INR / ₹)'), findsOneWidget);
    expect(find.text('VISIBILITY'), findsOneWidget);
  });

  // ── 2. Page renders upload area and uploaded items ─────────────────────────
  testWidgets('CreateCoursePage renders media upload section and initial items', (tester) async {
    await pumpCreateCourse(tester);

    expect(find.text('Upload Course Video / Syllabus'), findsOneWidget);
    expect(find.text('Browse Files'), findsOneWidget);
    expect(find.text('Lesson_01_Intro_Design_Systems.mp4'), findsOneWidget);
    expect(find.text('Syllabus_Tokens_Framework.pdf'), findsOneWidget);
    expect(find.text('100% Uploaded'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('+ Upload Additional Resource'), findsOneWidget);
  });

  // ── 3. Add resource via Browse Files / Additional Resource ─────────────────
  testWidgets('Tapping upload resource adds a new resource item', (tester) async {
    await pumpCreateCourse(tester);

    expect(find.text('UPLOADED ITEMS (2)'), findsOneWidget);

    final btn = find.byKey(const ValueKey('upload-additional-btn'));
    await tester.ensureVisible(btn);
    await tester.tap(btn);
    await tester.pumpAndSettle();

    expect(find.text('UPLOADED ITEMS (3)'), findsOneWidget);
  });

  // ── 4. Delete resource removes item ────────────────────────────────────────
  testWidgets('Tapping trash icon deletes an uploaded resource', (tester) async {
    await pumpCreateCourse(tester);

    expect(find.text('Lesson_01_Intro_Design_Systems.mp4'), findsOneWidget);

    final trashBtn = find.byKey(const ValueKey('delete-resource-res_1'));
    await tester.ensureVisible(trashBtn);
    await tester.tap(trashBtn);
    await tester.pumpAndSettle();

    expect(find.text('Lesson_01_Intro_Design_Systems.mp4'), findsNothing);
    expect(find.text('UPLOADED ITEMS (1)'), findsOneWidget);
  });

  // ── 5. Edit mode loads initial course info ─────────────────────────────────
  testWidgets('CreateCoursePage in edit mode shows Edit Course & Quiz title and initial course data', (tester) async {
    final course = AdminCourse(
      id: 'c_edit_1',
      title: 'Advanced Flutter Architecture',
      instructor: 'Vikram Patel',
      students: '4.2k students',
      price: '₹ 2,499',
      imageAsset: 'assets/images/courses/web_dev.jpg',
      status: CourseStatus.active,
      category: 'Mobile Development',
      level: 'Advanced',
      description: 'Master clean architecture and testing.',
    );

    await pumpCreateCourse(tester, initialCourse: course);

    expect(find.text('Edit Course & Quiz'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);
    expect(find.text('Advanced Flutter Architecture'), findsOneWidget);
    expect(find.text('₹ 2,499'), findsOneWidget);
    expect(find.text('Master clean architecture and testing.'), findsOneWidget);
  });

  // ── 6. Save course pops with updated course ────────────────────────────────
  testWidgets('Saving course returns updated course data', (tester) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    AdminCourse? returnedCourse;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  key: const ValueKey('open-btn'),
                  onPressed: () async {
                    returnedCourse = await Navigator.push<AdminCourse>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateCoursePage(),
                      ),
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('open-btn')));
    await tester.pumpAndSettle();

    // Enter custom title
    await tester.enterText(
      find.byKey(const ValueKey('course-title-input')),
      'Full Stack Cloud Native Mastery',
    );
    await tester.pumpAndSettle();

    // Tap Save Draft
    await tester.tap(find.byKey(const ValueKey('save-course-btn')));
    await tester.pumpAndSettle();

    expect(returnedCourse, isNotNull);
    expect(returnedCourse!.title, 'Full Stack Cloud Native Mastery');
  });

  // ── 7. Cancel button pops back ─────────────────────────────────────────────
  testWidgets('Cancel button navigates back without saving', (tester) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: ElevatedButton(
                key: const ValueKey('open-btn'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateCoursePage(),
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('open-btn')));
    await tester.pumpAndSettle();

    expect(find.text('Create Course & Quiz'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('cancel-btn')));
    await tester.pumpAndSettle();

    expect(find.text('Open'), findsOneWidget);
    expect(find.text('Create Course & Quiz'), findsNothing);
  });

  // ── 8. Admin Dashboard quick action "Add" navigates to CreateCoursePage ────
  testWidgets('Dashboard quick action Add opens CreateCoursePage', (tester) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(home: AdminDashboardPage()),
    );
    await tester.pumpAndSettle();

    // Tap the Quick Action "Add"
    final addAction = find.text('Add');
    await tester.ensureVisible(addAction);
    await tester.tap(addAction);
    await tester.pumpAndSettle();

    expect(find.text('Create Course & Quiz'), findsOneWidget);
    expect(find.text('1. COURSE DETAILS'), findsOneWidget);
  });
}
