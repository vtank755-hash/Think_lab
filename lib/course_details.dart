import 'package:flutter/material.dart';

import 'cart.dart';
import 'cart_page.dart';
import 'course.dart';
import 'progress.dart';
import 'purchases.dart';
import 'quiz_results.dart';
import 'session.dart';
import 'open_lesson.dart';
import 'widgets/completion_card.dart';
import 'widgets/module_row.dart';
import 'widgets/progress_card.dart';

const _heading = Color(0xFF2B2356);
const _muted = Color(0xFF9A96B8);
const _accent = Color(0xFF7B5CFF);
const _purple = Color(0xFF6B45F0);
const _chipBg = Color(0xFFF4F1FF);
const _star = Color(0xFFF5A623);

// =====================================================
// UI STRUCTURE (SCREEN VIEW)
//  1. Back button              -> GestureDetector + Icon (tap -> previous page)
//  2. Course image             -> Image.asset (hero banner)
//  3. Favourite heart          -> ValueListenableBuilder + Icon (tap -> toggle)
//  4. Preview play button      -> GestureDetector + Icon (tap -> play preview)
//  5. Category tag             -> Container + Text
//  6. Course title             -> Text
//  7. Instructor row           -> Row (avatar Image.asset + name Text)
//  8. Stats row                -> Row (Rating / Students / Duration)
//  9. Description              -> Text
// 10. Curriculum block         -> ProgressCard + ModuleRow list
// 11. Bottom action bar        -> price Text + Add to Cart / Start Learning
// =====================================================
/// COURSE DETAILS PAGE (StatefulWidget)
///
/// StatefulWidget is used here because the page rebuilds when the user buys
/// the course, adds it to the cart, or completes a lesson.
/// Layout: Scaffold -> Stack (scrollable content + fixed bottom buy bar).
///
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

  // Small message shown at the bottom of the screen (SnackBar).
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

  // Add the course to favourites, or remove it again.
  void _toggleFavorite() {
    toggleFavorite(course);
    _snack(
      isFavorite(course)
          ? '${course.title} added to favourites'
          : '${course.title} removed from favourites',
    );
  }

  void _openCart() {
    // Cart icon tapped -> Open the Cart page.
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
    // Buy Now / Add to Cart -> Save the course in the cart and open it.
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
    // Scaffold = the whole course details page.
    return Scaffold(
      backgroundColor: Colors.white,
      // Stack: scrollable page content + the buy bar fixed at the bottom.
      body: Stack(
        children: [
          // SingleChildScrollView = scrollable page content.
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 110),
            // Column = vertical stack: hero banner, then content card.
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _hero(),
                Transform.translate(
                  offset: const Offset(0, -26),
                  // Container = white rounded card holding course info.
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(22, 24, 22, 26),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    // Column = tag, title, stats, description, curriculum.
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
          // Positioned = pins the buy bar to the bottom edge.
          Positioned(left: 0, right: 0, bottom: 0, child: _buyBar()),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------- hero

  // Top banner image with back, favourite and preview-play buttons.
  Widget _hero() {
    return SizedBox(
      height: 290,
      width: double.infinity,
      // Stack = layers the buttons over the banner image.
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image.asset = the course banner photo.
          Image.asset(
            course.image,
            fit: BoxFit.cover,
            // Container = dark placeholder if the image fails to load.
            errorBuilder: (_, _, _) => Container(
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
          // Positioned = places the back button top-left.
          Positioned(
            left: 18,
            top: 18,
            child: _roundButton(
              icon: Icons.swap_horiz,
              onTap: () => Navigator.pop(context),
            ),
          ),
          // Positioned = places the favourite heart top-right.
          Positioned(right: 18, top: 18, child: _favoriteButton()),
          // Positioned = places play button lower-left of the banner.
          Positioned(
            left: 28,
            bottom: 52,
            // GestureDetector = tap plays the course preview.
            child: GestureDetector(
              onTap: () => _snack('Playing preview of ${course.title}'),
              // Container = white circle behind the play triangle.
              child: Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                // Icon = play triangle glyph.
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
    // ValueListenableBuilder = rebuilds heart when favourites change.
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
    // GestureDetector = makes the round icon button tappable.
    return GestureDetector(
      onTap: onTap,
      // Container = white circle behind the icon.
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        // Icon = symbol drawn inside the round button.
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }

  // ------------------------------------------------------------- content

  Widget _tag() {
    // Container = purple category tag chip.
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

  // Row: instructor photo on the left, name and role on the right.
  Widget _instructor() {
    return Row(
      children: [
        ClipOval(
          // Image.asset = instructor's round profile photo.
          child: Image.asset(
            'assets/images/profile/avatar.jpg',
            width: 46,
            height: 46,
            fit: BoxFit.cover,
            // Container = fallback avatar when the photo is missing.
            errorBuilder: (_, _, _) => Container(
              width: 46,
              height: 46,
              color: _chipBg,
              child: const Icon(Icons.person, color: _purple),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Expanded = name column fills the leftover width.
        Expanded(
          // Column = instructor name above the role.
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

  // Row of three small cards: rating, students and duration.
  Widget _stats() {
    return Row(
      children: [
        _statCard(
          // Row = star icon beside the rating number.
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon = gold star before the rating value.
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
    // Expanded = makes every stat card share equal width.
    return Expanded(
      // Container = light purple stat card background.
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: _chipBg,
          borderRadius: BorderRadius.circular(18),
        ),
        // Column = stat value above its label.
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
        // ValueListenableBuilder = rebuilds when lessons are completed.
        return ValueListenableBuilder<Set<String>>(
          valueListenable: completedLessons,
          builder: (context, done, _) {
            final total = courseLessonCount(course);
            final completed = completedInCourse(course);

            // Column = heading, progress card, then module rows.
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 26),
                _sectionHeading('Curriculum'),
                const SizedBox(height: 12),
                if (total > 0) ...[
                  ProgressCard(completed: completed, total: total),
                  const SizedBox(height: 14),
                  // Stage 1 done → the final quiz appears (never earlier).
                  if (completed >= total) ...[
                    CompletionCard(course: course),
                    const SizedBox(height: 14),
                  ],
                ],
                // Every module row (same widget as the My Learning cards).
                for (var i = 0; i < course.modules.length; i++) ...[
                  ModuleRow(
                    course: course,
                    moduleIndex: i,
                    completedLessons: done,
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            );
          },
        );
      },
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
    // Container = white bar pinned to the bottom of the page.
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
      // SafeArea = keeps the bar above the home indicator.
      child: SafeArea(
        top: false,
        // ValueListenableBuilder = rebuilds the bar on account switch.
        child: ValueListenableBuilder<String>(
          valueListenable: currentUser,
          builder: (context, user, _) {
            // ValueListenableBuilder = rebuilds when purchases change.
            return ValueListenableBuilder<Set<String>>(
              valueListenable: purchasesOf(user),
              builder: (context, bought, _) {
                final purchased = bought.contains(course.id);
                // ValueListenableBuilder = rebuilds when the cart changes.
                return ValueListenableBuilder<Set<String>>(
                  valueListenable: cartIds,
                  builder: (context, inCartIds, _) {
                    final inCart = inCartIds.contains(course.id);

                    // Column = unlocked banner above the price row.
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (purchased) ...[
                          const _UnlockedBanner(),
                          const SizedBox(height: 12),
                        ],
                        // Row = price on the left, action button on the right.
                        Row(
                          children: [
                            // Column = 'Price' label above the amount.
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
                            // Expanded = stretches the action button wide.
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
      // FilledButton = starts learning the purchased course.
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
      // FilledButton = opens the cart page.
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

    // OutlinedButton = adds this course to the cart.
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
    // Container = green "course unlocked" banner.
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE4F7EC),
        borderRadius: BorderRadius.circular(14),
      ),
      // Row = green check beside the unlocked label.
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
