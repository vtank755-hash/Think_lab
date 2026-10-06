import 'package:flutter/foundation.dart';

import 'course.dart';
import 'session.dart';

// ---------------------------------------------------------------------------
// Per-user learning progress: completion, resume point and video positions.
//
// Everything is keyed by the SIGNED-IN USER id plus the lesson id, exactly
// like the cart and the purchases — never one global flag:
//
/// ```dart
/// signIn('a@mail.com');
/// markLessonCompleted('c5-module-1-lesson-1');   // only user A completed it
/// signIn('b@mail.com');
/// isLessonCompleted('c5-module-1-lesson-1');     // false
/// ```
// ---------------------------------------------------------------------------

/// `userId -> completed lesson ids`.
final _completedByUser = <String, ValueNotifier<Set<String>>>{};

/// Completed lesson ids of one user.
ValueNotifier<Set<String>> completedOf(String userId) => _completedByUser
    .putIfAbsent(userId, () => ValueNotifier<Set<String>>(<String>{}));

/// Completed lessons of the CURRENT user.
ValueNotifier<Set<String>> get completedLessons =>
    completedOf(currentUser.value);

/// Whether this user already finished [lessonId].
bool isLessonCompleted(String lessonId, {String? userId}) =>
    completedOf(userId ?? currentUser.value).value.contains(lessonId);

/// Marks one lesson finished / unfinished — completion is tracked
/// individually, never for a whole module at once.
void markLessonCompleted(
  String lessonId, {
  bool completed = true,
  String? userId,
}) {
  final notifier = completedOf(userId ?? currentUser.value);
  final next = Set<String>.of(notifier.value);
  if (completed) {
    next.add(lessonId);
  } else {
    next.remove(lessonId);
  }
  notifier.value = next;
}

/// `userId -> (courseId -> 'moduleId/lessonId')` — where the user stopped.
final _resumeByUser = <String, ValueNotifier<Map<String, String>>>{};

/// Resume points of one user, keyed by course id.
ValueNotifier<Map<String, String>> resumeOf(String userId) => _resumeByUser
    .putIfAbsent(userId, () => ValueNotifier<Map<String, String>>({}));

/// Saves the lesson the user is currently watching for [course].
void setResumePoint(
  Course course,
  String moduleId_,
  String lessonId_, {
  String? userId,
}) {
  final notifier = resumeOf(userId ?? currentUser.value);
  final next = Map<String, String>.of(notifier.value);
  next[course.id] = '$moduleId_/$lessonId_';
  notifier.value = next;
}

/// The lesson this user last opened for [course]:
/// `(moduleId, lessonId)` or `null` when nothing was watched yet.
(String, String)? resumePoint(Course course, {String? userId}) {
  final stored = resumeOf(userId ?? currentUser.value).value[course.id];
  if (stored == null) return null;
  final parts = stored.split('/');
  if (parts.length != 2) return null;
  return (parts[0], parts[1]);
}

/// `userId -> (lessonId -> seconds watched)`.
final _videoByUser = <String, ValueNotifier<Map<String, int>>>{};

/// Saved video positions of one user, keyed by lesson id.
ValueNotifier<Map<String, int>> videoPositionsOf(String userId) =>
    _videoByUser.putIfAbsent(userId, () => ValueNotifier<Map<String, int>>({}));

/// Where this user's playback of [lessonId] stopped (seconds from 0).
int videoPositionFor(String lessonId, {String? userId}) =>
    videoPositionsOf(userId ?? currentUser.value).value[lessonId] ?? 0;

/// Remembers the playback position of one lesson so returning to it
/// continues approximately where the user left off.
void saveVideoPosition(String lessonId, int seconds, {String? userId}) {
  final notifier = videoPositionsOf(userId ?? currentUser.value);
  final next = Map<String, int>.of(notifier.value);
  next[lessonId] = seconds.clamp(0, 24 * 3600);
  notifier.value = next;
}

// ---------------------------------------------------------- counts / labels

/// Lessons of [moduleIndex] this user has completed.
int completedInModule(Course course, int moduleIndex, {String? userId}) {
  final module = course.modules[moduleIndex];
  var done = 0;
  for (var i = 0; i < module.lessons.length; i++) {
    if (isLessonCompleted(
      lessonIdFor(course, moduleIndex, i),
      userId: userId,
    )) {
      done++;
    }
  }
  return done;
}

/// Lessons of the whole course this user has completed.
int completedInCourse(Course course, {String? userId}) {
  var done = 0;
  for (var i = 0; i < course.modules.length; i++) {
    done += completedInModule(course, i, userId: userId);
  }
  return done;
}

/// `33` for 3 of 9 lessons — rounded, never hardcoded.
int progressPercent(int completed, int total) =>
    total <= 0 ? 0 : ((completed / total) * 100).round();

/// `3 / 9 lessons completed`.
String progressLabel(int completed, int total) =>
    '$completed / $total lessons completed';

/// Wipes completion, resume points and video positions of every user —
/// tests only.
void resetLearningProgress() {
  for (final notifier in _completedByUser.values) {
    notifier.value = const <String>{};
  }
  for (final notifier in _resumeByUser.values) {
    notifier.value = const <String, String>{};
  }
  for (final notifier in _videoByUser.values) {
    notifier.value = const <String, int>{};
  }
}
