import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'session.dart';

class AuthenticatedUser {
  final String id;
  final UserProfile profile;

  const AuthenticatedUser({required this.id, required this.profile});
}

class AuthenticatedSession {
  final AuthenticatedUser user;
  final bool isAdmin;

  const AuthenticatedSession({required this.user, required this.isAdmin});
}

abstract interface class AuthService {
  Future<AuthenticatedUser> signIn({
    required String email,
    required String password,
  });

  Future<AuthenticatedSession?> restoreSession();

  Future<AuthenticatedUser> register({
    required String name,
    required String email,
    required String password,
  });

  Future<void> updateProfile({
    required String name,
    required String phone,
    required String bio,
  });

  Future<AuthenticatedUser> signInAdmin({
    required String email,
    required String password,
  });

  Future<void> sendPasswordResetEmail(String email);

  Future<void> signOut();
}

AuthService authService = FirebaseAuthService();

class FirebaseAuthService implements AuthService {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  @override
  Future<AuthenticatedUser> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;
    if (user == null) throw StateError('Authentication returned no user.');
    try {
      return await _loadProfile(user);
    } on FirebaseException {
      await _auth.signOut();
      rethrow;
    }
  }

  @override
  Future<AuthenticatedSession?> restoreSession() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final admin = await _firestore.collection('admins').doc(user.uid).get();
    return AuthenticatedSession(
      user: await _loadProfile(user),
      isAdmin: admin.exists,
    );
  }

  @override
  Future<AuthenticatedUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;
    if (user == null) throw StateError('Registration returned no user.');

    await user.updateDisplayName(name.trim());
    final profile = UserProfile(
      name: name.trim(),
      email: user.email ?? email.trim(),
    );
    await _firestore.collection('users').doc(user.uid).set({
      'name': profile.name,
      'email': profile.email,
      'phone': profile.phone,
      'bio': profile.bio,
      'avatar': profile.avatar,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return AuthenticatedUser(id: user.uid, profile: profile);
  }

  @override
  Future<void> updateProfile({
    required String name,
    required String phone,
    required String bio,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'A signed-in user is required to update a profile.',
      );
    }

    await _firestore.collection('users').doc(user.uid).update({
      'name': name.trim(),
      'phone': phone.trim(),
      'bio': bio.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<AuthenticatedUser> signInAdmin({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;
    if (user == null) throw StateError('Authentication returned no user.');

    final DocumentSnapshot<Map<String, dynamic>> admin;
    try {
      admin = await _firestore.collection('admins').doc(user.uid).get();
    } on FirebaseException {
      await _auth.signOut();
      rethrow;
    }
    if (!admin.exists) {
      await _auth.signOut();
      throw const AdminAccessDeniedException();
    }
    try {
      return await _loadProfile(user);
    } on FirebaseException {
      await _auth.signOut();
      rethrow;
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  @override
  Future<void> signOut() => _auth.signOut();

  Future<AuthenticatedUser> _loadProfile(User user) async {
    final profileRef = _firestore.collection('users').doc(user.uid);
    final snapshot = await profileRef.get();
    final data = snapshot.data();
    if (data == null) {
      final profile = UserProfile(
        name: user.displayName ?? '',
        email: user.email ?? '',
      );
      await profileRef.set({
        'name': profile.name,
        'email': profile.email,
        'phone': profile.phone,
        'bio': profile.bio,
        'avatar': profile.avatar,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return AuthenticatedUser(id: user.uid, profile: profile);
    }

    final profile = UserProfile(
      name: (data['name'] as String?) ?? user.displayName ?? '',
      email: user.email ?? (data['email'] as String?) ?? '',
      phone: data['phone'] as String? ?? '',
      bio: data['bio'] as String? ?? '',
      avatar: data['avatar'] as String? ?? 'assets/images/profile/avatar.jpg',
    );
    return AuthenticatedUser(id: user.uid, profile: profile);
  }
}

class AdminAccessDeniedException implements Exception {
  const AdminAccessDeniedException();
}

String authErrorMessage(Object error) {
  if (error is AdminAccessDeniedException) {
    return 'This account is not authorized for the Admin Portal.';
  }
  if (error is FirebaseAuthException) {
    return switch (error.code) {
      'invalid-email' => 'Enter a valid email address.',
      'invalid-credential' || 'wrong-password' || 'user-not-found' =>
        'Email or password is incorrect.',
      'email-already-in-use' => 'An account already exists for this email.',
      'weak-password' => 'Choose a stronger password.',
      'user-disabled' => 'This account has been disabled.',
      'too-many-requests' => 'Too many attempts. Please try again later.',
      'network-request-failed' => 'Check your internet connection and retry.',
      'operation-not-allowed' => 'Email and password sign-in is not enabled.',
      _ => 'Authentication failed. Please try again.',
    };
  }
  if (error is FirebaseException && error.code == 'permission-denied') {
    return 'Your account does not have permission to access this data.';
  }
  return 'Unable to complete the request. Please try again.';
}
