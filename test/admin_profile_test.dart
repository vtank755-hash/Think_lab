import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:think_lab/admin_dashboard.dart';
import 'package:think_lab/admin_profile.dart';

void main() {
  testWidgets('Profile tab opens the Admin Profile screen', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AdminDashboardPage()));

    await tester.tap(find.byKey(const ValueKey('admin-nav-profile')));
    await tester.pumpAndSettle();

    expect(find.byType(AdminProfilePage), findsOneWidget);
    expect(find.text('Admin Profile'), findsOneWidget);
    expect(find.text('Dr. Evelyn Reed'), findsOneWidget);
    expect(find.text('Apex Learning Academy'), findsOneWidget);
    expect(find.text('3,840'), findsOneWidget);
  });

  testWidgets('Profile back button returns to the dashboard', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AdminDashboardPage()));

    await tester.tap(find.byKey(const ValueKey('admin-nav-profile')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('admin-profile-back')));
    await tester.pumpAndSettle();

    expect(find.byType(AdminProfilePage), findsNothing);
    expect(find.text('WELCOME BACK,'), findsOneWidget);
  });

  testWidgets('Admin can edit and save profile details', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AdminDashboardPage()));

    await tester.tap(find.byKey(const ValueKey('admin-nav-profile')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('admin-profile-settings')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('admin-profile-edit-page')),
      findsOneWidget,
    );
    await tester.enterText(
      find.descendant(
        of: find.byKey(const ValueKey('admin-profile-name')),
        matching: find.byType(TextField),
      ),
      'Dr. Evelyn Reed Updated',
    );
    await tester.tap(find.byKey(const ValueKey('save-admin-profile')));
    await tester.pumpAndSettle();

    expect(find.text('Dr. Evelyn Reed Updated'), findsOneWidget);
    expect(find.byKey(const ValueKey('admin-profile-edit-page')), findsNothing);
  });

  testWidgets('Profile logout button opens logout confirmation', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AdminDashboardPage()));

    await tester.tap(find.byKey(const ValueKey('admin-nav-profile')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('admin-profile-logout')));
    await tester.pumpAndSettle();

    expect(find.text('Admin Logout'), findsOneWidget);
    expect(
      find.text('Do you want to log out of the Admin Panel?'),
      findsOneWidget,
    );
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(AdminProfilePage), findsOneWidget);
  });
}
