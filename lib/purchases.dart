import 'package:flutter/foundation.dart';

import 'course.dart';
import 'session.dart';

/// Purchases of every user: `userId -> the course ids that user paid for`.
///
/// The check is ALWAYS "current user id + course id" — never one global
/// `isPurchased` flag for the whole app:
///
/// ```dart
/// signIn('a@mail.com');
/// unlockCourses([courseById('c1')]);   // user A owns c1
/// signIn('b@mail.com');
/// isPurchased(courseById('c1'));       // false — user B does not
/// ```
final _purchasesByUser = <String, ValueNotifier<Set<String>>>{};

/// The purchases of one user, keyed by course id.
ValueNotifier<Set<String>> purchasesOf(String userId) => _purchasesByUser
    .putIfAbsent(userId, () => ValueNotifier<Set<String>>(<String>{}));

/// The signed-in user's purchases — the listenable the course details page
/// (and every other screen) reacts to.
ValueNotifier<Set<String>> get purchasedIds => purchasesOf(currentUser.value);

/// Whether THIS user has already paid for [course].
bool isPurchased(Course course, {String? userId}) =>
    purchasesOf(userId ?? currentUser.value).value.contains(course.id);

/// Unlocks every course in [courses] for the user who paid
/// (the signed-in user unless [userId] says otherwise).
void unlockCourses(Iterable<Course> courses, {String? userId}) {
  final purchases = purchasesOf(userId ?? currentUser.value);
  final next = Set<String>.of(purchases.value);
  for (final course in courses) {
    next.add(course.id);
  }
  purchases.value = next;
}

/// Locks every course of every user — tests only.
void resetPurchases() {
  for (final purchases in _purchasesByUser.values) {
    purchases.value = const <String>{};
  }
}
