// SESSION - remembers WHICH user is logged in right now.
// Purchases and learning progress look this id up, so every user
// sees only their own data.
import 'package:flutter/foundation.dart';

/// User profile details shown across the app.
class UserProfile {
  final String name;
  final String email;
  final String phone;
  final String bio;
  final String avatar;

  const UserProfile({
    this.name = 'Aarav Sharma',
    this.email = 'aarav.sharma@email.com',
    this.phone = '+91 98765 43210',
    this.bio =
        'Aspiring Designer & Developer. Learning new skills daily on LearnHub!',
    this.avatar = 'assets/images/profile/avatar.jpg',
  });

  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? bio,
    String? avatar,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      avatar: avatar ?? this.avatar,
    );
  }
}

/// Profile information of the currently active user.
final userProfile = ValueNotifier<UserProfile>(const UserProfile());

/// The id of the user who is signed in right now.
///
/// The login screen stores the e-mail address that was typed in, so every
/// wishlist and every purchase in the app belongs to that id and to nobody
/// else: user A can own course `c1` while user B does not.
final currentUser = ValueNotifier<String>('guest');

/// Whether the current session entered through the admin login flow.
final isAdminSession = ValueNotifier<bool>(false);

/// Applies a user returned by the authenticated backend.
void setAuthenticatedSession(
  String userId,
  UserProfile profile, {
  bool isAdmin = false,
}) {
  currentUser.value = userId;
  userProfile.value = profile;
  isAdminSession.value = isAdmin;
}

/// Signs [userId] in — called by the login screen on a successful login.
/// Kept for local state tests; production sign-in uses the authentication API.
void signIn(String userId) {
  final id = userId.trim();
  currentUser.value = id.isEmpty ? 'guest' : id;
  isAdminSession.value = false;
  if (id.contains('@')) {
    userProfile.value = userProfile.value.copyWith(email: id);
  }
}

/// Signs in through the admin portal.
void signInAdmin(String userId) {
  signIn(userId);
  isAdminSession.value = true;
}

/// Updates current user profile details.
void updateProfile({
  String? name,
  String? email,
  String? phone,
  String? bio,
  String? avatar,
}) {
  userProfile.value = userProfile.value.copyWith(
    name: name,
    email: email,
    phone: phone,
    bio: bio,
    avatar: avatar,
  );
}

/// Signs the current user out.
void signOut() {
  currentUser.value = 'guest';
  isAdminSession.value = false;
}

/// Resets profile to default state (tests only).
void resetProfile() {
  userProfile.value = const UserProfile();
}
