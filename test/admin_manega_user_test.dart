import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:think_lab/admin_dashboard.dart';
import 'package:think_lab/admin_manega_user.dart';

void main() {
  testWidgets('Users tab opens the Manage Users page', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AdminDashboardPage()));

    await tester.tap(find.byKey(const ValueKey('admin-nav-users')));
    await tester.pumpAndSettle();

    expect(find.byType(AdminManageUsersPage), findsOneWidget);
    expect(find.text('Manage Users'), findsOneWidget);
    expect(find.text('Aarav Sharma'), findsOneWidget);
  });

  testWidgets('Total Users statistic opens the Manage Users page', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AdminDashboardPage()));

    await tester.tap(find.byKey(const ValueKey('stat-card-users')));
    await tester.pumpAndSettle();

    expect(find.byType(AdminManageUsersPage), findsOneWidget);
    expect(find.text('Manage Users'), findsOneWidget);
  });

  testWidgets('Manage Users search filters the user list', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AdminManageUsersPage()));

    await tester.enterText(
      find.byKey(const ValueKey('manage-users-search')),
      'Kavya',
    );
    await tester.pumpAndSettle();

    expect(find.text('Kavya Reddy'), findsOneWidget);
    expect(find.text('Aarav Sharma'), findsNothing);
  });

  testWidgets('Edit User opens a full page and saves user details', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AdminManageUsersPage()));

    await tester.tap(find.byKey(const ValueKey('edit-user-u1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('edit-admin-user-page')), findsOneWidget);
    expect(find.text('User Details'), findsOneWidget);
    expect(find.text('Personal Information'), findsOneWidget);

    await tester.enterText(
      find.descendant(
        of: find.byKey(const ValueKey('edit-user-name')),
        matching: find.byType(TextField),
      ),
      'Aarav Sharma Updated',
    );
    await tester.tap(find.byKey(const ValueKey('save-user-u1')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('edit-admin-user-page')), findsNothing);
    expect(find.text('Aarav Sharma Updated'), findsOneWidget);
  });

  testWidgets('View opens the user profile and analytics page', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AdminManageUsersPage()));

    await tester.tap(find.byKey(const ValueKey('view-user-u1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('view-admin-user-page')), findsOneWidget);
    expect(find.text('User Profile'), findsOneWidget);
    expect(find.text('Learner Analytics'), findsOneWidget);
    expect(find.text('82%'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('view-user-back')));
    await tester.pumpAndSettle();
    expect(find.text('Manage Users'), findsOneWidget);
  });
}
