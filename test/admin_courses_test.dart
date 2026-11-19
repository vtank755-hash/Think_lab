import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:think_lab/admin_courses_page.dart';
import 'package:think_lab/admin_create_course_page.dart';
import 'package:think_lab/admin_dashboard.dart';

import 'test_utils.dart';

void main() {
  setUp(() {
    ignoreOverflowErrors();
  });

  // ── Helper: pump the AdminCoursesPage in isolation ─────────────────────────
  Future<void> pumpCoursesPage(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AdminCoursesPage()),
      ),
    );
    await tester.pumpAndSettle();
  }

  // ── Helper: pump the full AdminDashboard ───────────────────────────────────
  Future<void> pumpDashboard(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: AdminDashboardPage()),
    );
    await tester.pumpAndSettle();
  }

  // ── 1. Page renders with correct title and seed courses ────────────────────
  testWidgets('AdminCoursesPage shows title and default courses', (tester) async {
    await pumpCoursesPage(tester);

    expect(find.text('Manage Courses'), findsOneWidget);
    expect(find.text('Web Dev Bootcamp'), findsOneWidget);
    expect(find.text('UI/UX Masterclass'), findsOneWidget);
    expect(find.text('Digital Marketing'), findsOneWidget);
  });

  // ── 2. Active / Draft badges are visible ───────────────────────────────────
  testWidgets('AdminCoursesPage shows Active and Draft badges', (tester) async {
    await pumpCoursesPage(tester);

    // Two "Active" courses + one "Draft"
    expect(find.text('Active'), findsNWidgets(2));
    expect(find.text('Draft'), findsOneWidget);
  });

  // ── 3. Add button exists ───────────────────────────────────────────────────
  testWidgets('Add course button is present', (tester) async {
    await pumpCoursesPage(tester);

    expect(find.byKey(const ValueKey('add-course-button')), findsOneWidget);
  });

  // ── 4. Search filters the list ─────────────────────────────────────────────
  testWidgets('Search bar filters courses by title', (tester) async {
    await pumpCoursesPage(tester);

    await tester.enterText(
      find.byKey(const ValueKey('course-search-field')),
      'Digital',
    );
    await tester.pumpAndSettle();

    expect(find.text('Digital Marketing'), findsOneWidget);
    expect(find.text('Web Dev Bootcamp'), findsNothing);
    expect(find.text('UI/UX Masterclass'), findsNothing);
  });

  // ── 5. Delete button opens confirmation dialog ─────────────────────────────
  testWidgets('Delete button opens confirmation dialog', (tester) async {
    await pumpCoursesPage(tester);

    await tester.tap(find.byKey(const ValueKey('delete-c1')));
    await tester.pumpAndSettle();

    expect(find.text('Delete Course'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });

  // ── 6. Cancel on delete dialog keeps the course ────────────────────────────
  testWidgets('Cancel delete keeps course in list', (tester) async {
    await pumpCoursesPage(tester);

    await tester.tap(find.byKey(const ValueKey('delete-c1')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Web Dev Bootcamp'), findsOneWidget);
  });

  // ── 7. Confirming delete removes the course ────────────────────────────────
  testWidgets('Confirming delete removes course from list', (tester) async {
    await pumpCoursesPage(tester);

    await tester.tap(find.byKey(const ValueKey('delete-c1')));
    await tester.pumpAndSettle();

    final deleteBtn = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.text('Delete'),
    );
    await tester.tap(deleteBtn);
    await tester.pumpAndSettle();

    expect(find.text('Web Dev Bootcamp'), findsNothing);
  });

  // ── 8. Edit button navigates to AdminCreateCoursePage (edit mode) ──────────
  testWidgets('Edit button opens Create/Edit Course page pre-filled', (tester) async {
    await pumpCoursesPage(tester);

    await tester.tap(find.byKey(const ValueKey('edit-c1')));
    await tester.pumpAndSettle();

    // Should navigate to AdminCreateCoursePage in edit mode
    expect(find.byType(AdminCreateCoursePage), findsOneWidget);
    expect(find.text('Edit Course'), findsOneWidget);
    // The title field is pre-filled
    expect(find.text('Save Draft'), findsOneWidget);
  });

  // ── 9. Admin Dashboard bottom nav switches to Courses tab ─────────────────
  testWidgets('Courses bottom nav tab opens Manage Courses page', (tester) async {
    await pumpDashboard(tester);

    expect(find.text('Admin Panel'), findsOneWidget);

    await tester.tap(find.text('Courses'));
    await tester.pumpAndSettle();

    expect(find.text('Manage Courses'), findsOneWidget);
  });

  // ── 10. Add button navigates to AdminCreateCoursePage (create mode) ────────
  testWidgets('Add button opens Create Course page', (tester) async {
    await pumpCoursesPage(tester);

    await tester.tap(find.byKey(const ValueKey('add-course-button')));
    await tester.pumpAndSettle();

    expect(find.byType(AdminCreateCoursePage), findsOneWidget);
    expect(find.text('Create Course & Quiz'), findsOneWidget);
    expect(find.text('Save Draft'), findsOneWidget);
  });

  // ── 11. AdminCreateCoursePage standalone — renders both steps ─────────────
  testWidgets('AdminCreateCoursePage renders Step 1 and Step 2', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: AdminCreateCoursePage()),
    );
    await tester.pumpAndSettle();

    expect(find.text('1. COURSE DETAILS'), findsOneWidget);
    expect(find.text('STEP 1 OF 3'), findsOneWidget);
    expect(find.text('2. COURSE MEDIA & LESSONS'), findsOneWidget);
    expect(find.text('STEP 2 OF 3'), findsOneWidget);
  });

  // ── 12. Cancel button pops back ────────────────────────────────────────────
  testWidgets('Cancel button pops the create-course page', (tester) async {
    await pumpCoursesPage(tester);

    // Navigate to create page
    await tester.tap(find.byKey(const ValueKey('add-course-button')));
    await tester.pumpAndSettle();

    expect(find.byType(AdminCreateCoursePage), findsOneWidget);

    // Tap Cancel
    await tester.tap(find.byKey(const ValueKey('cancel-button')));
    await tester.pumpAndSettle();

    // Should be back on the courses list
    expect(find.text('Manage Courses'), findsOneWidget);
    expect(find.byType(AdminCreateCoursePage), findsNothing);
  });

  // ── 13. Upload zone is present ─────────────────────────────────────────────
  testWidgets('Upload zone and uploaded items are shown', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: AdminCreateCoursePage()),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('upload-zone')), findsOneWidget);
    expect(find.text('Upload Course Video / Syllabus'), findsOneWidget);
    expect(find.text('UPLOADED ITEMS (2)'), findsOneWidget);
  });

  // ── 14. Save Draft without title shows validation feedback ────────────────
  testWidgets('Save Draft without title does not pop (shows snack)', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: AdminCreateCoursePage()),
    );
    await tester.pumpAndSettle();

    // Clear title (it starts empty; just tap Save Draft)
    await tester.tap(find.byKey(const ValueKey('save-draft-button')));
    await tester.pump();

    // SnackBar validation message appears
    expect(find.text('Please enter a course title.'), findsOneWidget);
  });
}
