import 'package:flutter/material.dart';

import 'cart.dart';
import 'cart_page.dart';
import 'course.dart';
import 'module_detail_page.dart';
import 'progress.dart';
import 'purchases.dart';
import 'quiz.dart';
import 'quiz_page.dart';
import 'quiz_results.dart';
import 'session.dart';
import 'open_lesson.dart';

const _heading = Color(0xFF2B2356);
const _muted = Color(0xFF9A96B8);
const _accent = Color(0xFF7B5CFF);
const _purple = Color(0xFF6B45F0);
const _chipBg = Color(0xFFF4F1FF);
const _star = Color(0xFFF5A623);

/// The single, reusable course details page.
///
/// It holds no course data of its own: everything on screen comes from the
/// [course] that was passed in, including the price and the favourite state.
///
/// ```dart
/// Navigator.push(context,
///   MaterialPageRoute(builder: (_) => CourseDetails(course: course)));
/// ```
class CourseDetails extends StatefulWidget {
  final Course course;

  const CourseDetails({super.key, required this.course});

  @override
  State<CourseDetails> createState() => _CourseDetailsState();
}

class _CourseDetailsState extends State<CourseDetails> {
  Course get course => widget.course;

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _heading,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  void _toggleFavorite() {
    toggleFavorite(course);
    _snack(
      isFavorite(course)
          ? '${course.title} added to favourites'
          : '${course.title} removed from favourites',
    );
  }

  void _openCart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CartPage()),
    );
  }

  /// Adds THIS course to the cart and opens the cart page straight away —
  /// no notification in between (addToCart never creates duplicates).
  ///
  /// There is deliberately NO direct payment here: the only way to pay is
  /// Cart → Pay Now → Checkout.
  void _addToCart() {
    addToCart(course);
    _openCart();
  }

  /// "Start Learning" — opens the user's last watched lesson, or the very
  /// first one. Shares the SAME helper as the home card and My Learning's
  /// "Continue", so resume behaves identically everywhere.
  void _startLearning() {
    if (openCourseLesson(context, course)) return;
    _snack(
      isPurchased(course)
          ? 'No lessons available yet'
          : 'Purchase this course to start learning',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _hero(),
                Transform.translate(
                  offset: const Offset(0, -26),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(22, 24, 22, 26),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _tag(),
                        const SizedBox(height: 14),
                        _title(),
                        const SizedBox(height: 18),
                        _instructor(),
                        const SizedBox(height: 20),
                        _stats(),
                        const SizedBox(height: 26),
                        _sectionHeading('Description'),
                        const SizedBox(height: 10),
                        Text(
                          course.description,
                          style: const TextStyle(
                            color: _muted,
                            fontSize: 14,
                            height: 1.55,
                          ),
                        ),
                        if (course.modules.isNotEmpty) ...[_curriculum()],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(left: 0, right: 0, bottom: 0, child: _buyBar()),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------- hero

  Widget _hero() {
    return SizedBox(
      height: 290,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            course.image,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFF241C4A),
              child: const Icon(
                Icons.code_rounded,
                color: Colors.white54,
                size: 64,
              ),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x33000000), Color(0x00000000)],
              ),
            ),
          ),
          Positioned(
            left: 18,
            top: 18,
            child: _roundButton(
              icon: Icons.swap_horiz,
              onTap: () => Navigator.pop(context),
            ),
          ),
          Positioned(right: 18, top: 18, child: _favoriteButton()),
          Positioned(
            left: 28,
            bottom: 52,
            child: GestureDetector(
              onTap: () => _snack('Playing preview of ${course.title}'),
              child: Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: _purple,
                  size: 34,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Favourite state of the clicked course, shared with the rest of the app.
  Widget _favoriteButton() {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: favoriteIds,
      builder: (context, ids, _) {
        final liked = ids.contains(course.id);
        return _roundButton(
          icon: liked ? Icons.favorite : Icons.favorite_border,
          color: liked ? const Color(0xFFFF4D6D) : _heading,
          onTap: _toggleFavorite,
        );
      },
    );
  }

  Widget _roundButton({
    required IconData icon,
    required VoidCallback onTap,
    Color color = _heading,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }

  // ------------------------------------------------------------- content

  Widget _tag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEEE9FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        course.category,
        style: const TextStyle(
          color: _purple,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _title() {
    return Text(
      course.title,
      style: const TextStyle(
        color: _heading,
        fontSize: 26,
        fontWeight: FontWeight.w800,
        height: 1.15,
      ),
    );
  }

  Widget _instructor() {
    return Row(
      children: [
        ClipOval(
          child: Image.network(
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
            width: 46,
            height: 46,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 46,
              height: 46,
              color: _chipBg,
              child: const Icon(Icons.person, color: _purple),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                course.instructor,
                style: const TextStyle(
                  color: _heading,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                course.instructorRole,
                style: const TextStyle(color: _accent, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stats() {
    return Row(
      children: [
        _statCard(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star_rounded, color: _star, size: 18),
              const SizedBox(width: 4),
              Text(
                course.rating,
                style: const TextStyle(
                  color: _heading,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          label: 'Rating',
        ),
        const SizedBox(width: 10),
        _statCard(
          child: Text(
            course.students,
            style: const TextStyle(
              color: _heading,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          label: 'Students',
        ),
        const SizedBox(width: 10),
        _statCard(
          child: Text(
            course.duration,
            style: const TextStyle(
              color: _heading,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          label: 'Duration',
        ),
      ],
    );
  }

  Widget _statCard({required Widget child, required String label}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: _chipBg,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            child,
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: _muted, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeading(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: _heading,
        fontSize: 17,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  /// Curriculum section: live course progress + one clickable row per module.
  ///
  /// Tapping a row opens the module's complete lesson list
  /// (`ModuleDetailPage`), so the curriculum is a real navigation tree and
  /// never a dead end.
  Widget _curriculum() {
    // Rebuilds whenever a lesson is completed anywhere in the app, and again
    // whenever a quiz attempt is saved (pass flips the card to success).
    return ValueListenableBuilder<Map<String, List<QuizAttempt>>>(
      valueListenable: quizAttemptsOf(currentUser.value),
      builder: (context, attempts, _) {
        return ValueListenableBuilder<Set<String>>(
          valueListenable: completedLessons,
          builder: (context, done, _) {
            final total = courseLessonCount(course);
            final completed = completedInCourse(course);
            final percent = progressPercent(completed, total);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 26),
                _sectionHeading('Curriculum'),
                const SizedBox(height: 12),
                if (total > 0) ...[
                  _courseProgress(completed, total, percent),
                  const SizedBox(height: 14),
                  // Stage 1 done → the final quiz appears (never earlier).
                  if (completed >= total) ...[
                    _completionCard(),
                    const SizedBox(height: 14),
                  ],
                ],
                for (var i = 0; i < course.modules.length; i++) ...[
                  _moduleRow(i, done),
                  const SizedBox(height: 12),
                ],
              ],
            );
          },
        );
      },
    );
  }

  /// Course completion card — the two-stage rule in one place:
  ///
  /// * all lessons done, quiz not passed → "Course learning completed" with
  ///   **Take Quiz**;
  /// * quiz passed (>= 75%) → "Course successfully completed".
  ///
  /// Shown only when every lesson is completed: the quiz is never offered
  /// before the learning stage is finished.
  Widget _completionCard() {
    final passed = isQuizPassed(course.id);
    final attempt = latestQuizAttempt(course.id);
    final total = courseLessonCount(course);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: passed ? const Color(0xFFE4F7EC) : const Color(0xFFEEE9FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                passed
                    ? Icons.check_circle_rounded
                    : Icons.emoji_events_rounded,
                color: passed ? const Color(0xFF25A55F) : _purple,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  passed
                      ? 'Course successfully completed'
                      : 'Course learning completed',
                  style: const TextStyle(
                    color: _heading,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            passed
                ? 'Final quiz passed with ${attempt?.percentage}% '
                      '(${attempt?.score}/${attempt?.total}).'
                : 'All $total lessons completed. Take the final quiz — '
                      '$quizQuestionCount questions, $quizPassingPercentage% '
                      'or higher completes the course.',
            style: TextStyle(
              color: passed ? const Color(0xFF25A55F) : _muted,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          if (!passed) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuizPage(courseId: course.id),
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: _purple,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Take Quiz',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Course progress — `15 / 43 lessons completed` + `35%`, calculated from
  /// the real lesson data of THIS course.
  Widget _courseProgress(int completed, int total, int percent) {
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

  /// One module row — the existing card design, now clickable and carrying
  /// this module's own progress.
  Widget _moduleRow(int moduleIndex, Set<String> done) {
    final module = course.modules[moduleIndex];
    final total = module.lessons.length;
    var completed = 0;
    for (var i = 0; i < total; i++) {
      if (done.contains(lessonIdFor(course, moduleIndex, i))) completed++;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ModuleDetailPage(
            courseId: course.id,
            moduleId: moduleIdFor(course, moduleIndex),
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _chipBg,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _purple,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.desktop_mac_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    module.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _heading,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  // Calculated: '9 lessons · 1h 45m'.
                  Text(
                    moduleMeta(module),
                    style: const TextStyle(color: _muted, fontSize: 12),
                  ),
                  if (completed > 0) ...[
                    const SizedBox(height: 3),
                    Text(
                      '$completed / $total lessons completed',
                      style: const TextStyle(
                        color: _purple,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: _muted),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------- bottom bar

  /// Bottom bar — the button follows the course's state:
  ///
  /// * not in cart       → [ Add to Cart ]
  /// * in the cart       → [ Go to Cart ]
  /// * already purchased → \u2713 Course Unlocked + [ Start Learning ]
  ///
  /// The purchase check is ALWAYS "signed-in user id + course id" (never one
  /// global flag), so user A can own a course that user B does not.
  Widget _buyBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: ValueListenableBuilder<String>(
          valueListenable: currentUser,
          builder: (context, user, _) {
            return ValueListenableBuilder<Set<String>>(
              valueListenable: purchasesOf(user),
              builder: (context, bought, _) {
                final purchased = bought.contains(course.id);
                return ValueListenableBuilder<Set<String>>(
                  valueListenable: cartIds,
                  builder: (context, inCartIds, _) {
                    final inCart = inCartIds.contains(course.id);

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (purchased) ...[
                          const _UnlockedBanner(),
                          const SizedBox(height: 12),
                        ],
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Price',
                                  style: TextStyle(color: _muted, fontSize: 12),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  course.price,
                                  style: const TextStyle(
                                    color: _purple,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: _stateButton(
                                purchased: purchased,
                                inCart: inCart,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  /// The single action button for the current state of this course.
  Widget _stateButton({required bool purchased, required bool inCart}) {
    if (purchased) {
      return FilledButton(
        onPressed: _startLearning,
        style: FilledButton.styleFrom(
          backgroundColor: _purple,
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: const Text(
          'Start Learning',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      );
    }

    if (inCart) {
      return FilledButton(
        onPressed: _openCart,
        style: FilledButton.styleFrom(
          backgroundColor: _purple,
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: const Text(
          'Go to Cart',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      );
    }

    return OutlinedButton(
      onPressed: _addToCart,
      style: OutlinedButton.styleFrom(
        foregroundColor: _purple,
        side: const BorderSide(color: _purple, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      child: const Text(
        'Add to Cart',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// Green "✓ Course Unlocked" banner shown once the course is purchased.
class _UnlockedBanner extends StatelessWidget {
  const _UnlockedBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE4F7EC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle_rounded, color: Color(0xFF25A55F), size: 18),
          SizedBox(width: 8),
          Text(
            'Course Unlocked',
            style: TextStyle(
              color: Color(0xFF1E8E4E),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
