import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:think_lab/admin_dashboard.dart';
import 'package:think_lab/admin_login.dart';
import 'package:think_lab/login_user.dart';
import 'package:think_lab/session.dart';

import 'test_utils.dart';

void main() {
  setUp(() {
    signIn('guest');
  });

  testWidgets('LoginPage navigates to AdminLoginPage when Admin? Admin Login is clicked', (
    tester,
  ) async {
    ignoreOverflowErrors();

    await tester.pumpWidget(const MaterialApp(home: LoginPage()));
    await tester.pumpAndSettle();

    // Verify Admin Login text is displayed
    expect(find.text('Admin? Admin Login'), findsOneWidget);

    // Scroll to and tap "Admin? Admin Login"
    await tester.ensureVisible(find.text('Admin? Admin Login'));
    await tester.tap(find.text('Admin? Admin Login'));
    await tester.pumpAndSettle();

    // Verify Admin Portal screen is shown
    expect(find.byType(AdminLoginPage), findsOneWidget);
    expect(find.text('Admin Portal'), findsOneWidget);
    expect(find.text('Sign in to manage LearnHub.'), findsOneWidget);
    expect(find.text('ADMIN EMAIL'), findsOneWidget);
    expect(find.text('PASSWORD'), findsOneWidget);
    expect(find.text('Login to Dashboard'), findsOneWidget);
    expect(find.text('Back to Student Login'), findsOneWidget);
  });

  testWidgets('AdminLoginPage Back to Student Login returns to LoginPage', (
    tester,
  ) async {
    ignoreOverflowErrors();

    await tester.pumpWidget(const MaterialApp(home: LoginPage()));
    await tester.pumpAndSettle();

    // Open Admin Portal
    await tester.ensureVisible(find.text('Admin? Admin Login'));
    await tester.tap(find.text('Admin? Admin Login'));
    await tester.pumpAndSettle();
    expect(find.byType(AdminLoginPage), findsOneWidget);

    // Tap "Back to Student Login"
    await tester.ensureVisible(find.text('Back to Student Login'));
    await tester.tap(find.text('Back to Student Login'));
    await tester.pumpAndSettle();

    // Returned to LoginPage
    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('AdminLoginPage validates password and signs into dashboard', (
    tester,
  ) async {
    ignoreOverflowErrors();

    await tester.pumpWidget(const MaterialApp(home: AdminLoginPage()));
    await tester.pumpAndSettle();

    // Tapping without password triggers validation error
    await tester.tap(find.text('Login to Dashboard'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter password'), findsOneWidget);

    // Enter admin password
    final passwordField = find.byType(TextFormField).at(1);
    await tester.enterText(passwordField, 'admin123');
    await tester.pumpAndSettle();

    // Tap Login to Dashboard
    await tester.tap(find.text('Login to Dashboard'));
    await tester.pumpAndSettle();

    // Should navigate to AdminDashboardPage
    expect(find.byType(AdminDashboardPage), findsOneWidget);
    expect(find.text('Admin Panel'), findsOneWidget);
    expect(find.text('WELCOME BACK,'), findsOneWidget);
    expect(find.text('24.8k'), findsOneWidget);
    expect(find.text('Total Users'), findsOneWidget);
    expect(find.text('342'), findsOneWidget);
    expect(find.text('Total Courses'), findsOneWidget);
    expect(find.text('18.2k'), findsOneWidget);
    expect(find.text('Enrollments'), findsOneWidget);
    expect(find.text('₹12.8M'), findsOneWidget);
    expect(find.text('Total Revenue'), findsOneWidget);
    expect(find.text('Quick Actions'), findsOneWidget);
    expect(find.text('Add'), findsOneWidget);
    expect(find.text('Users'), findsWidgets);
    expect(find.text('Orders'), findsWidgets);
    expect(find.text('Quiz'), findsOneWidget);
    expect(currentUser.value, 'admin@learnhub.in');
  });
}
