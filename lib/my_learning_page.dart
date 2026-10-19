import 'package:flutter/material.dart';

import 'course.dart';
import 'open_lesson.dart';
import 'progress.dart';
import 'purchases.dart';
import 'quiz_page.dart';
import 'quiz_results.dart';
import 'session.dart';
import 'widgets/module_row.dart';
import 'widgets/progress_card.dart';

const _heading = Color(0xFF2B2356);
const _muted = Color(0xFF9A96B8);
const _purple = Color(0xFF6B45F0);
const _green = Color(0xFF25A55F);

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
// UI STRUCTURE (SCREEN VIEW)
//  1. Back button              -> GestureDetector + Icon (tap -> leave tab)
//  2. Page title               -> Text 'My Learning'
//  3. Segment tabs             -> GestureDetector pills 'In Progress' / 'Completed'
//  4. Empty state              -> Icon + Text + 'Browse courses' button
//  5. Course list              -> ListView.separated of course cards
//  6. Card thumbnail + title   -> Row (Image.asset + Text title/instructor)
//  7. Card progress bar        -> ProgressCard or 'Completed · 100%' badge
//  8. Card curriculum          -> Text 'Curriculum' + ModuleRow list
//  9. Card action button       -> FilledButton 'Continue' / 'Take Quiz' / certificate
// =====================================================
// MY LEARNING PAGE
// StatefulWidget is used here because the page rebuilds on account switch,
// on every lesson completion and on every saved quiz attempt.
// Shows the courses the user is learning (in progress)
// and the courses that are fully completed.
// Layout: Column -> header + two tabs + list of course cards.
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

                // Column = header, tabs, then the course list.
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(),
                    _segmentedTabs(),
                    if (courses.isEmpty)
                      // Expanded = fills the rest of screen with empty state.
                      Expanded(
                        child: _EmptyLearning(
                          tab: _tab,
                          enrolled: enrolled.isNotEmpty,
                          onBrowse: widget.onBack,
                        ),
                      )
                    else
                      // Expanded = fills the rest of screen with the list.
                      Expanded(
                        // ListView.separated = scrollable course cards with gaps.
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
      // Row = switch button beside the page title.
      child: Row(
        children: [
          // GestureDetector = tap leaves the Learning tab.
          GestureDetector(
            onTap: widget.onBack,
            // Container = white circle behind the switch icon.
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              // Icon = swap arrows glyph for leaving the tab.
              child: const Icon(Icons.swap_horiz, color: _heading, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          // Expanded = page title fills the remaining width.
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
      // GestureDetector = tap switches the active segment tab.
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _tab = index),
        // Container = pill background for the tab label.
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
      // Row = In Progress tab beside the Completed tab.
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
    // Real lesson counts for THIS user (percentages come from real data).
    final total = courseLessonCount(course);
    final done = completedInCourse(course, userId: user);
    // Lessons this user already finished (needed for each module row).
    final doneLessons = completedOf(user).value;
    // Stage 1 finished → the card offers the final quiz instead of Continue.
    final lessonsDone = isCourseLessonsComplete(course);

    // Card layout: top row (image + title) -> progress -> curriculum -> button.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Container = white rounded course card.
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
          // Column = thumbnail row then progress inside the card.
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row = course thumbnail beside title and instructor.
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    // Image.asset = course thumbnail picture.
                    child: Image.asset(
                      course.image,
                      width: 86,
                      height: 86,
                      fit: BoxFit.cover,
                      // Container = placeholder if the thumbnail is missing.
                      errorBuilder: (_, _, _) => Container(
                        width: 86,
                        height: 86,
                        color: const Color(0xFFEEE9FF),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          color: _purple,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Expanded = text column fills the leftover width.
                  Expanded(
                    // Column = course title above the instructor name.
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
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Real progress: '9 / 43 lessons completed' + '21%' + bar.
              if (completed)
                _completedBadge()
              else
                ProgressCard(completed: done, total: total),
            ],
          ),
        ),

        // Curriculum list — the same module rows as the Course Details page.
        if (course.modules.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Curriculum',
            style: TextStyle(
              color: _heading,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < course.modules.length; i++) ...[
            ModuleRow(
              course: course,
              moduleIndex: i,
              completedLessons: doneLessons,
            ),
            const SizedBox(height: 10),
          ],
        ],

        const SizedBox(height: 10),
        // One button: certificate (course done) / quiz (lessons done) / continue.
        if (completed)
          _certificateButton()
        else if (lessonsDone)
          _quizButton(context)
        else
          _continueButton(),
      ],
    );
  }

  // Green "Completed · 100%" badge for the Completed tab.
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
    // FilledButton = opens the final quiz of this course.
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
    // FilledButton = resumes the last watched lesson.
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
    // OutlinedButton = shows the course certificate.
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

  // The text depends on the tab and on whether the user enrolled in anything.
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
        // Column = icon, message, then browse button.
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Container = purple circle behind the empty-state icon.
            Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                color: Color(0xFFEEE9FF),
                shape: BoxShape.circle,
              ),
              // Icon = open book icon for the empty state.
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
              // FilledButton = goes back to browse courses.
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
