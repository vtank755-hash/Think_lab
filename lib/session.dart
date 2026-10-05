import 'package:flutter/foundation.dart';

/// The id of the user who is signed in right now.
///
/// The login screen stores the e-mail address that was typed in, so every
/// wishlist and every purchase in the app belongs to that id and to nobody
/// else: user A can own course `c1` while user B does not.
final currentUser = ValueNotifier<String>('guest');

/// Signs [userId] in — called by the login screen on a successful login.
void signIn(String userId) {
  final id = userId.trim();
  currentUser.value = id.isEmpty ? 'guest' : id;
}
