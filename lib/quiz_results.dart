import 'package:flutter/foundation.dart';

import 'course.dart';
import 'progress.dart';
import 'quiz.dart';
import 'session.dart';

// -----------------------------------------------------------------------------
// Per-user quiz results and the two-stage course completion rule.
//
// Stage 1 — every lesson completed      → "course learning completed"
// Stage 2 — final quiz score >= 75%     → "course successfully completed"
//
// Results are stored per USER + COURSE (+ the attempt number), exactly like
// the cart, wishlist and progress stores, so User A's result never shows up
// for User B:
//
// ```dart
// signIn('a@mail.com');
// saveQuizAttempt('c5', score: 16, total: 20);   // A: 80% PASSED
// signIn('b@mail.com');
// isQuizPassed('c5');                            // false — B's own record
// ```
// -----------------------------------------------------------------------------

/// ONE attempt of a course quiz by one user.
class QuizAttempt {
  /// 1-based attempt number for this course (`1`, `2`, `3`, …).
  final int attempt;

  /// Correct answers, e.g. `16`.
  final int score;

  /// Total questions, e.g. `20`.
  final int total;

  const QuizAttempt({
    required this.attempt,
    required this.score,
    required this.total,
  });

  /// `80` for 16 / 20 — calculated, never stored as a fixed number.
  int get percentage => total <= 0 ? 0 : ((score / total) * 100).round();

  /// Passes at exactly 75% and above.
  bool get passed => percentage >= quizPassingPercentage;
}

/// `userId -> (courseId -> attempts of that course)`.
final _attemptsByUser =
    <String, ValueNotifier<Map<String, List<QuizAttempt>>>>{};

/// Quiz attempts of one user, keyed by course id.
ValueNotifier<Map<String, List<QuizAttempt>>> quizAttemptsOf(String userId) =>
    _attemptsByUser.putIfAbsent(
      userId,
      () => ValueNotifier<Map<String, List<QuizAttempt>>>({}),
    );

/// Every attempt this user made for [courseId], oldest first.
List<QuizAttempt> quizAttemptsFor(String courseId, {String? userId}) =>
    quizAttemptsOf(userId ?? currentUser.value).value[courseId] ??
    const <QuizAttempt>[];

/// The latest attempt (the current result) for [courseId], or `null`.
QuizAttempt? latestQuizAttempt(String courseId, {String? userId}) {
  final attempts = quizAttemptsFor(courseId, userId: userId);
  return attempts.isEmpty ? null : attempts.last;
}

/// Whether THIS user ever passed the final quiz of [courseId].
bool isQuizPassed(String courseId, {String? userId}) =>
    quizAttemptsFor(courseId, userId: userId).any((a) => a.passed);

/// Saves one attempt (every attempt is kept separately) and returns it.
QuizAttempt saveQuizAttempt(
  String courseId, {
  required int score,
  required int total,
  String? userId,
}) {
  final uid = userId ?? currentUser.value;
  final notifier = quizAttemptsOf(uid);
  final next = Map<String, List<QuizAttempt>>.of(notifier.value);
  final attempts = List<QuizAttempt>.of(
    next[courseId] ?? const <QuizAttempt>[],
  );
  final attempt = QuizAttempt(
    attempt: attempts.length + 1,
    score: score,
    total: total,
  );
  attempts.add(attempt);
  next[courseId] = attempts;
  notifier.value = next;
  return attempt;
}

// -----------------------------------------------------------------------------
// Two-stage completion
// -----------------------------------------------------------------------------

/// STAGE 1 — every lesson of the course is completed (learning finished).
///
/// This alone does NOT complete the course: the final quiz is still required.
bool isCourseLessonsComplete(Course course, {String? userId}) {
  final total = courseLessonCount(course);
  return total > 0 && completedInCourse(course, userId: userId) >= total;
}

/// STAGE 2 — lessons completed AND the final quiz passed (>= 75%).
///
/// The course only gets its final successful status when BOTH stages hold.
bool isCourseFullyCompleted(Course course, {String? userId}) =>
    isCourseLessonsComplete(course, userId: userId) &&
    isQuizPassed(course.id, userId: userId);

/// What the completion card / lesson banner should say right now.
enum CourseCompletionState {
  /// Lessons still missing → no quiz anywhere yet.
  inProgress,

  /// All lessons done, quiz not passed → offer "Take Quiz".
  quizPending,

  /// Quiz passed → course successfully completed.
  completed,
}

CourseCompletionState completionStateOf(Course course, {String? userId}) {
  if (!isCourseLessonsComplete(course, userId: userId)) {
    return CourseCompletionState.inProgress;
  }
  if (!isQuizPassed(course.id, userId: userId)) {
    return CourseCompletionState.quizPending;
  }
  return CourseCompletionState.completed;
}

/// Wipes every user's quiz attempts — tests only.
void resetQuizResults() {
  for (final notifier in _attemptsByUser.values) {
    notifier.value = const <String, List<QuizAttempt>>{};
  }
}
