import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:think_lab/admin_dashboard.dart';
import 'package:think_lab/admin_enrollments_page.dart';

void main() {
  testWidgets('Dashboard enrollments stat opens total enrollments', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AdminDashboardPage()));
    await tester.ensureVisible(
      find.byKey(const ValueKey('stat-card-enrollments')),
    );
    await tester.tap(find.byKey(const ValueKey('stat-card-enrollments')));
    await tester.pumpAndSettle();

    expect(find.byType(AdminEnrollmentsPage), findsOneWidget);
    expect(find.text('Total Enrollments'), findsOneWidget);
    expect(find.text('Sarah Jenkins'), findsOneWidget);
  });

  testWidgets('Enrollment filters and search narrow the learner list', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AdminEnrollmentsPage()));

    await tester.tap(find.byKey(const ValueKey('enrollment-filter-Completed')));
    await tester.pumpAndSettle();
    expect(find.text('Marcus Vance'), findsOneWidget);
    expect(find.text('Sarah Jenkins'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('enrollment-filter-All')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('enrollment-search')),
      'David',
    );
    await tester.pumpAndSettle();

    expect(find.text('David Kim'), findsOneWidget);
    expect(find.text('Elena Rostova'), findsNothing);
  });

  testWidgets('Course selector updates enrollment summary', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AdminEnrollmentsPage()));

    await tester.tap(find.byKey(const ValueKey('enrollment-course-select')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('UI/UX Masterclass').last);
    await tester.pumpAndSettle();

    expect(find.text('860'), findsOneWidget);
    expect(find.text('150 certified'), findsOneWidget);
  });
}
