import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:think_lab/auth_service.dart';
import 'package:think_lab/edit_profile_page.dart';
import 'package:think_lab/index.dart';
import 'package:think_lab/session.dart';
import 'package:think_lab/wishlist_page.dart';

import 'test_utils.dart';

void main() {
  late _ProfileTestAuthService fakeAuth;

  setUp(() {
    resetProfile();
    signIn('guest');
    fakeAuth = _ProfileTestAuthService();
    authService = fakeAuth;
  });

  tearDown(() {
    authService = FirebaseAuthService();
  });

  testWidgets('Profile tab displays user details, menu items and logout', (
    tester,
  ) async {
    ignoreOverflowErrors();

    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    await tester.pumpAndSettle();

    // Tap Profile tab in NavBar
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    // Verify User card
    expect(find.text('Aarav Sharma'), findsOneWidget);
    expect(find.text('aarav.sharma@email.com'), findsOneWidget);
    expect(find.byKey(const ValueKey('profile-edit-button')), findsOneWidget);

    // Verify Menu options
    expect(find.text('My Learning'), findsOneWidget);
    expect(find.text('Certificates'), findsOneWidget);
    expect(find.byKey(const ValueKey('profile-menu-wishlist')), findsOneWidget);
    expect(find.byKey(const ValueKey('profile-logout-button')), findsOneWidget);
  });

  testWidgets('Profile menu navigates to My Learning and Wishlist tabs', (
    tester,
  ) async {
    ignoreOverflowErrors();

    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    await tester.pumpAndSettle();

    // Switch to Profile tab
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    // Tap My Learning -> should switch to My Learning screen
    await tester.tap(find.byKey(const ValueKey('profile-menu-learning')));
    await tester.pumpAndSettle();
    expect(find.text('In Progress'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);

    // Switch back to Profile tab
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    // Tap Wishlist -> should switch to Wishlist screen
    await tester.tap(find.byKey(const ValueKey('profile-menu-wishlist')));
    await tester.pumpAndSettle();
    expect(find.byType(WishlistPage), findsOneWidget);
  });

  testWidgets(
    'Certificates menu item opens the Certificate screen with download option',
    (tester) async {
      ignoreOverflowErrors();

      await tester.pumpWidget(const MaterialApp(home: HomePage()));
      await tester.pumpAndSettle();

      // Switch to Profile tab
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      // Tap Certificates
      await tester.tap(find.byKey(const ValueKey('profile-menu-certificates')));
      await tester.pumpAndSettle();

      // Verify Certificate page
      expect(find.text('CERTIFICATE OF COMPLETION'), findsOneWidget);
      expect(find.text('Download'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
      expect(find.text('LearnHub'), findsOneWidget);
    },
  );

  testWidgets(
    'Edit Profile modifies profile info and reflects on Profile and Home',
    (tester) async {
      ignoreOverflowErrors();

      await tester.pumpWidget(const MaterialApp(home: HomePage()));
      await tester.pumpAndSettle();

      // Switch to Profile tab
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      // Tap Edit Profile
      await tester.tap(find.byKey(const ValueKey('profile-edit-button')));
      await tester.pumpAndSettle();

      expect(find.text('FULL NAME'), findsOneWidget);
      expect(find.text('PHONE NUMBER'), findsOneWidget);
      expect(find.text('BIO'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField).at(1)).readOnly,
        isTrue,
      );

      // Edit Name
      final nameField = find.widgetWithText(TextField, 'Aarav Sharma');
      await tester.enterText(nameField, 'Aarav Sharma Updated');

      // Tap Save Changes
      await tester.ensureVisible(find.text('Save Changes'));
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      // Verify updated name on Profile tab
      expect(find.text('Aarav Sharma Updated'), findsOneWidget);
      expect(fakeAuth.updatedName, 'Aarav Sharma Updated');

      // Switch to Home tab and verify updated greeting name
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.text('Aarav Sharma Updated'), findsOneWidget);
    },
  );

  testWidgets('Profile remains unchanged when the Firestore update fails', (
    tester,
  ) async {
    ignoreOverflowErrors();
    fakeAuth.failProfileUpdate = true;

    await tester.pumpWidget(const MaterialApp(home: EditProfilePage()));
    await tester.enterText(find.byType(TextField).first, 'Unpersisted Name');
    await tester.ensureVisible(find.text('Save Changes'));
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    expect(userProfile.value.name, 'Aarav Sharma');
    expect(find.text('Edit Profile'), findsOneWidget);
    expect(
      find.text('Unable to complete the request. Please try again.'),
      findsOneWidget,
    );
  });

  testWidgets('Logout shows dialog confirmation', (tester) async {
    ignoreOverflowErrors();

    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    await tester.pumpAndSettle();

    // Switch to Profile tab
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    // Scroll to and tap Logout
    await tester.ensureVisible(
      find.byKey(const ValueKey('profile-logout-button')),
    );
    await tester.tap(find.byKey(const ValueKey('profile-logout-button')));
    await tester.pumpAndSettle();

    expect(
      find.text('Are you sure you want to log out of your LearnHub account?'),
      findsOneWidget,
    );
    expect(find.text('Cancel'), findsOneWidget);

    // Tap Cancel
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('profile-logout-button')), findsOneWidget);
  });
}

class _ProfileTestAuthService implements AuthService {
  bool failProfileUpdate = false;
  String? updatedName;

  @override
  Future<AuthenticatedUser> signIn({
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<AuthenticatedSession?> restoreSession() async => null;

  @override
  Future<AuthenticatedUser> register({
    required String name,
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<void> updateProfile({
    required String name,
    required String phone,
    required String bio,
  }) async {
    if (failProfileUpdate) throw StateError('Firestore update failed');
    updatedName = name;
  }

  @override
  Future<AuthenticatedUser> signInAdmin({
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      throw UnimplementedError();

  @override
  Future<void> signOut() async {}
}
