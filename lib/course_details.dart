import 'package:flutter/material.dart';

import 'cart.dart';
import 'cart_page.dart';
import 'course.dart';

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

  /// Adds THIS course to the cart and opens the cart page straight away —
  /// no notification/snackbar in between (addToCart ignores duplicates).
  void _addToCart() {
    addToCart(course);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CartPage()),
    );
  }

  void _enroll() => _snack('Enrolled in ${course.title} — ${course.price}');

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
                        if (course.lessons.isNotEmpty) ...[
                          const SizedBox(height: 26),
                          _sectionHeading('Curriculum'),
                          const SizedBox(height: 14),
                          for (final lesson in course.lessons) ...[
                            _lesson(lesson),
                            const SizedBox(height: 12),
                          ],
                        ],
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

  Widget _lesson(Lesson lesson) {
    return Container(
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
                  lesson.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _heading,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  lesson.meta,
                  style: const TextStyle(color: _muted, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: _muted),
        ],
      ),
    );
  }

  // ---------------------------------------------------------- bottom bar

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
        child: Row(
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
              child: OutlinedButton(
                onPressed: _addToCart,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _purple,
                  side: const BorderSide(color: _purple, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  'Add to Cart',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                onPressed: _enroll,
                style: FilledButton.styleFrom(
                  backgroundColor: _purple,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  'Enroll Now',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
