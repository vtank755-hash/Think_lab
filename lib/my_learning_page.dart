import 'package:flutter/material.dart';

import 'course.dart';
import 'open_lesson.dart';
import 'progress.dart';
import 'purchases.dart';
import 'quiz_page.dart';
import 'quiz_results.dart';
import 'session.dart';

const _heading = Color(0xFF2B2356);
const _muted = Color(0xFF9A96B8);
const _purple = Color(0xFF6B45F0);
const _green = Color(0xFF25A55F);
const _chipBg = Color(0xFFF4F1FF);

/// The **My Learning** tab — every course the signed-in user is taking.
///
/// Exactly as designed:
///
/// * **In Progress** — enrolled courses that are not finished yet, showing the
///   course title, instructor, the REAL progress percentage (calculated from
///   the per-user lesson completion, never a fixed 65%) and a **Continue**
///   button that opens the last watched lesson;
/// * **Completed** — courses where every lesson is done: a `Completed · 100%`
///   badge and **View Certificate**.
///
/// Everything is driven by the same per-user stores as the rest of the app
/// (`purchases.dart` + `progress.dart`), so two accounts see their own lists.
// =====================================================
// MY LEARNING PAGE
// Shows the courses the user is learning (in progress)
// and the courses that are fully completed.
// =====================================================
class MyLearningPage extends StatefulWidget {
  /// Leaves the Learning tab (back to Home).
  final VoidCallback? onBack;

  const MyLearningPage({super.key, this.onBack});

  @override
  State<MyLearningPage> createState() => _MyLearningPageState();
}

class _MyLearningPageState extends State<MyLearningPage> {
  /// 0 = In Progress, 1 = Completed.
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    // Rebuilds on account switch, on every lesson completion AND on every
    // saved quiz attempt (the two-stage completion rule needs all three).
    return ValueListenableBuilder<String>(
      valueListenable: currentUser,
      builder: (context, user, _) {
        return ValueListenableBuilder<Map<String, List<QuizAttempt>>>(
          valueListenable: quizAttemptsOf(user),
          builder: (context, attempts, _) {
            return ValueListenableBuilder<Set<String>>(
              valueListenable: completedOf(user),
              builder: (context, done, _) {
                final enrolled = allCourses.where(isPurchased).toList();
                // In Progress = not fully completed yet (lessons AND quiz).
                final inProgress = enrolled
                    .where((c) => !isCourseFullyCompleted(c, userId: user))
                    .toList();
                // Completed = lessons finished AND final quiz passed (75%+).
                final completed = enrolled
                    .where((c) => isCourseFullyCompleted(c, userId: user))
                    .toList();
                final courses = _tab == 0 ? inProgress : completed;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(),
                    _segmentedTabs(),
                    if (courses.isEmpty)
                      Expanded(
                        child: _EmptyLearning(
                          tab: _tab,
                          enrolled: enrolled.isNotEmpty,
                          onBrowse: widget.onBack,
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                          itemCount: courses.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) => _LearningCard(
                            course: courses[index],
                            completed: _tab == 1,
                            onContinue: () =>
                                _continue(context, courses[index]),
                            onCertificate: () => _certificate(courses[index]),
                          ),
                        ),
                      ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  // ------------------------------------------------------------ actions

  /// Continue → the last watched lesson (or the first one) of that course.
  void _continue(BuildContext context, Course course) {
    if (openCourseLesson(context, course)) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isPurchased(course)
              ? 'No lessons available yet'
              : 'Purchase this course to start learning',
        ),
      ),
    );
  }

  /// Demo certificate — the app has no certificate storage yet.
  void _certificate(Course course) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Certificate for ${course.title} (demo)')),
    );
  }

  // ------------------------------------------------------------ header

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: Row(
        children: [
          GestureDetector(
            onTap: widget.onBack,
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.swap_horiz, color: _heading, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'My Learning',
              style: TextStyle(
                color: _heading,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// `In Progress` (filled pill) / `Completed` (plain) segmented tabs.
  Widget _segmentedTabs() {
    Widget tab(int index, String label) {
      final active = _tab == index;
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _tab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: active ? _purple : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : _purple,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 4),
      child: Row(children: [tab(0, 'In Progress'), tab(1, 'Completed')]),
    );
  }
}

// -----------------------------------------------------------------------------
// Course card
// -----------------------------------------------------------------------------

class _LearningCard extends StatelessWidget {
  final Course course;

  /// Whether this card belongs to the Completed tab.
  final bool completed;
  final VoidCallback onContinue;
  final VoidCallback onCertificate;

  const _LearningCard({
    required this.course,
    required this.completed,
    required this.onContinue,
    required this.onCertificate,
  });

  @override
  Widget build(BuildContext context) {
    final user = currentUser.value;
    final total = courseLessonCount(course);
    final done = completedInCourse(course, userId: user);
    final percent = progressPercent(done, total);
    // Stage 1 finished → the card offers the final quiz instead of Continue.
    final lessonsDone = isCourseLessonsComplete(course);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  course.image,
                  width: 86,
                  height: 86,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 86,
                    height: 86,
                    color: const Color(0xFFEEE9FF),
                    child: const Icon(Icons.menu_book_rounded, color: _purple),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _heading,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course.instructor,
                      style: const TextStyle(
                        color: _purple,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (completed)
                      _completedBadge()
                    else
                      _progress(done, total, percent),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (completed)
          _certificateButton()
        else if (lessonsDone)
          _quizButton(context)
        else
          _continueButton(),
      ],
    );
  }

  /// Course progress card — the SAME style as the Curriculum block on Course
  /// Details: `9 / 43 lessons completed` + `21%` + bar, all calculated from
  /// the real lesson data of THIS course.
  Widget _progress(int completed, int total, int percent) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _chipBg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  progressLabel(completed, total),
                  style: const TextStyle(color: _muted, fontSize: 13),
                ),
              ),
              Text(
                '$percent%',
                style: const TextStyle(
                  color: _purple,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : completed / total,
              minHeight: 8,
              color: _purple,
              backgroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _completedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE4F7EC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        'Completed · 100%',
        style: TextStyle(
          color: _green,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  /// STAGE 1 done, quiz not passed → the card offers the final quiz of THIS
  /// course instead of "Continue".
  Widget _quizButton(BuildContext context) {
    return FilledButton(
      // All lessons finished -> Open the final quiz of this course.
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => QuizPage(courseId: course.id)),
      ),
      style: FilledButton.styleFrom(
        backgroundColor: _purple,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: const Text(
        'Take Quiz',
        style: TextStyle(
          color: Colors.white,
          fontSize: 14.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _continueButton() {
    return FilledButton(
      onPressed: onContinue,
      style: FilledButton.styleFrom(
        backgroundColor: _purple,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: const Text(
        'Continue',
        style: TextStyle(
          color: Colors.white,
          fontSize: 14.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _certificateButton() {
    return OutlinedButton(
      onPressed: onCertificate,
      style: OutlinedButton.styleFrom(
        foregroundColor: _purple,
        side: const BorderSide(color: _purple, width: 1.5),
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: const Text(
        'View Certificate',
        style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Empty states
// -----------------------------------------------------------------------------

class _EmptyLearning extends StatelessWidget {
  /// 0 = In Progress, 1 = Completed.
  final int tab;

  /// Whether the user has enrolled in anything at all.
  final bool enrolled;
  final VoidCallback? onBrowse;

  const _EmptyLearning({
    required this.tab,
    required this.enrolled,
    this.onBrowse,
  });

  String get _message {
    if (tab == 0) {
      return enrolled
          ? 'You finished every enrolled course — nice!'
          : "You haven't enrolled in any course yet.";
    }
    return 'No completed courses yet. Finish a course to get your certificate.';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                color: Color(0xFFEEE9FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                color: _purple,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _muted, fontSize: 14, height: 1.5),
            ),
            if (tab == 0 && !enrolled) ...[
              const SizedBox(height: 18),
              FilledButton(
                onPressed: onBrowse,
                style: FilledButton.styleFrom(
                  backgroundColor: _purple,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 26,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Browse courses',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
