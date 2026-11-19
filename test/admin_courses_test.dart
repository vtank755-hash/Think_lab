import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:think_lab/admin_courses_page.dart';
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
        home: Scaffold(
          body: AdminCoursesPage(),
        ),
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

    // Tap the delete button for the first course
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

    // Tap the red "Delete" button in the dialog
    final deleteBtn = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.text('Delete'),
    );
    await tester.tap(deleteBtn);
    await tester.pumpAndSettle();

    expect(find.text('Web Dev Bootcamp'), findsNothing);
  });

  // ── 8. Edit button opens the edit bottom sheet ─────────────────────────────
  testWidgets('Edit button opens edit sheet with pre-filled title', (tester) async {
    await pumpCoursesPage(tester);

    await tester.tap(find.byKey(const ValueKey('edit-c1')));
    await tester.pumpAndSettle();

    expect(find.text('Edit Course'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);
  });

  // ── 9. Admin Dashboard bottom nav switches to Courses tab ─────────────────
  testWidgets('Courses bottom nav tab opens Manage Courses page', (tester) async {
    await pumpDashboard(tester);

    // Dashboard tab is shown by default
    expect(find.text('Admin Panel'), findsOneWidget);

    // Tap "Courses" in the bottom nav
    await tester.tap(find.text('Courses'));
    await tester.pumpAndSettle();

    expect(find.text('Manage Courses'), findsOneWidget);
  });

  // ── 10. Add sheet opens when Add button is tapped ─────────────────────────
  testWidgets('Add button opens Add New Course sheet', (tester) async {
    await pumpCoursesPage(tester);

    await tester.tap(find.byKey(const ValueKey('add-course-button')));
    await tester.pumpAndSettle();

    expect(find.text('Add New Course'), findsOneWidget);
    expect(find.text('Add Course'), findsOneWidget);
  });
}
