import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:think_lab/auth_service.dart';
import 'package:think_lab/admin_dashboard.dart';
import 'package:think_lab/admin_login.dart';
import 'package:think_lab/index.dart';
import 'package:think_lab/login_user.dart';
import 'package:think_lab/session.dart';

import 'test_utils.dart';

void main() {
  late _FakeAuthService fakeAuth;

  setUp(() {
    signIn('guest');
    fakeAuth = _FakeAuthService();
    authService = fakeAuth;
  });

  tearDown(() {
    authService = FirebaseAuthService();
  });

  testWidgets(
    'LoginPage navigates to AdminLoginPage when Admin? Admin Login is clicked',
    (tester) async {
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
    },
  );

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

    final emailField = find.byType(TextFormField).at(0);
    await tester.enterText(emailField, 'admin@example.com');

    // Clear password to test validation error
    final passwordField = find.byType(TextFormField).at(1);
    await tester.enterText(passwordField, '');
    await tester.tap(find.text('Login to Dashboard'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter password'), findsOneWidget);

    // Enter admin password
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
    expect(currentUser.value, 'admin-uid');
    expect(isAdminSession.value, isTrue);
  });

  testWidgets('Admin login rejects an account without an admin role', (
    tester,
  ) async {
    ignoreOverflowErrors();
    fakeAuth.allowAdmin = false;
    await tester.pumpWidget(const MaterialApp(home: AdminLoginPage()));
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'learner@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.text('Login to Dashboard'));
    await tester.pumpAndSettle();

    expect(find.byType(AdminDashboardPage), findsNothing);
    expect(
      find.text('This account is not authorized for the Admin Portal.'),
      findsOneWidget,
    );
    expect(isAdminSession.value, isFalse);
  });

  testWidgets('Email text cannot route a student login to the admin panel', (
    tester,
  ) async {
    ignoreOverflowErrors();
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'admin@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    final loginButton = find.text('Login');
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(AdminDashboardPage), findsNothing);
    expect(isAdminSession.value, isFalse);
  });
}

class _FakeAuthService implements AuthService {
  bool allowAdmin = true;

  AuthenticatedUser get _user => AuthenticatedUser(
    id: 'admin-uid',
    profile: const UserProfile(name: 'Admin', email: 'admin@example.com'),
  );

  @override
  Future<AuthenticatedUser> signIn({
    required String email,
    required String password,
  }) async {
    return AuthenticatedUser(
      id: 'student-uid',
      profile: UserProfile(name: 'Learner', email: email),
    );
  }

  @override
  Future<AuthenticatedSession?> restoreSession() async => null;

  @override
  Future<AuthenticatedUser> register({
    required String name,
    required String email,
    required String password,
  }) async => AuthenticatedUser(
    id: 'new-user-uid',
    profile: UserProfile(name: name, email: email),
  );

  @override
  Future<void> updateProfile({
    required String name,
    required String phone,
    required String bio,
  }) async {}

  @override
  Future<AuthenticatedUser> signInAdmin({
    required String email,
    required String password,
  }) async {
    if (!allowAdmin) throw const AdminAccessDeniedException();
    return _user;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> signOut() async {}
}
