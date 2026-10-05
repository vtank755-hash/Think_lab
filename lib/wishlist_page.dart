import 'package:flutter/material.dart';

import 'cart.dart';
import 'cart_page.dart';
import 'course.dart';
import 'course_details.dart';
import 'purchases.dart';
import 'session.dart';

const _heading = Color(0xFF2B2356);
const _muted = Color(0xFF9A96B8);
const _purple = Color(0xFF6B45F0);
const _star = Color(0xFFF5A623);
const _heart = Color(0xFFFF4D6D);

/// The existing Wishlist screen — header, course cards (image, title,
/// instructor, rating, price, heart, "Add to Cart" pill) and the bottom
/// navigation stay exactly as designed; only the behaviour is wired up:
///
/// * the list is the **signed-in user's** wishlist, keyed by course id;
/// * the heart saves / removes a course from that wishlist;
/// * "Add to Cart" adds the course to the EXISTING cart (no payment starts
///   here) and confirms with the standard SnackBar;
/// * a course the current user already owns can never be bought again — the
///   card switches to the existing "Go to Cart" / "Start Learning" states.
class WishlistPage extends StatelessWidget {
  /// Leaves the Wishlist tab (back to Home).
  final VoidCallback? onBack;

  const WishlistPage({super.key, this.onBack});

  void _openCourse(BuildContext context, Course course) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CourseDetails(course: course)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Wishlist of the CURRENT user — changes with the signed-in account.
    return ValueListenableBuilder<String>(
      valueListenable: currentUser,
      builder: (context, user, _) {
        return ValueListenableBuilder<Set<String>>(
          valueListenable: wishlistOf(user),
          builder: (context, savedIds, _) {
            // Ids → course objects, straight from the shared dataset.
            final courses = savedIds.map(courseById).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(courses.length),
                if (courses.isEmpty)
                  Expanded(child: _EmptyWishlist(onBrowse: onBack))
                else
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      itemCount: courses.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (context, index) => _WishlistCard(
                        course: courses[index],
                        onOpen: () => _openCourse(context, courses[index]),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  // ------------------------------------------------------------- header

  Widget _header(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: Row(
        children: [
          _roundButton(icon: Icons.swap_horiz, onTap: onBack),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Wishlist',
                  style: TextStyle(
                    color: _heading,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  count == 1 ? '1 saved course' : '$count saved courses',
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
    );
  }

  Widget _roundButton({required IconData icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: _heading, size: 20),
      ),
    );
  }
}

// --------------------------------------------------------------- card

/// One saved course. The design (image, title, instructor, star rating,
/// price, filled heart, purple pill) is unchanged — only the pill's action
/// depends on the course state.
class _WishlistCard extends StatelessWidget {
  final Course course;
  final VoidCallback onOpen;

  const _WishlistCard({required this.course, required this.onOpen});

  /// Adds the course to the EXISTING cart — never a payment, never an
  /// enrolment. `addToCart` keys by course id, so it cannot duplicate.
  void _addToCart(BuildContext context) {
    addToCart(course);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Course added to cart'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _heading,
          duration: Duration(seconds: 2),
        ),
      );
  }

  void _openCart(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CartPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onOpen,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                course.image,
                width: 74,
                height: 74,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 74,
                  height: 74,
                  color: const Color(0xFFEEE9FF),
                  child: const Icon(
                    Icons.play_circle_outline_rounded,
                    color: _purple,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          course.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _heading,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      _heartButton(context),
                    ],
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
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: _star, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        course.rating,
                        style: const TextStyle(
                          color: _heading,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        course.price,
                        style: const TextStyle(
                          color: _purple,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      _action(context),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Filled heart → removes the course from this user's wishlist.
  Widget _heartButton(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => toggleFavorite(course),
      child: const Padding(
        padding: EdgeInsets.only(left: 6, bottom: 4),
        child: Icon(Icons.favorite, color: _heart, size: 22),
      ),
    );
  }

  /// The pill button — the same design in every state, using the wording the
  /// app already has ("Add to Cart" / "Go to Cart" / "Start Learning").
  Widget _action(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: currentUser,
      builder: (context, user, _) {
        return ValueListenableBuilder<Set<String>>(
          // ONE source of truth: this user id + this course id.
          valueListenable: purchasesOf(user),
          builder: (context, bought, _) {
            return ValueListenableBuilder<Set<String>>(
              valueListenable: cartIds,
              builder: (context, cart, _) {
                if (bought.contains(course.id)) {
                  // Already owned → it can never be bought again.
                  return _pill(label: 'Start Learning', onTap: onOpen);
                }
                if (cart.contains(course.id)) {
                  // Already in the cart → no duplicate item.
                  return _pill(
                    label: 'Go to Cart',
                    onTap: () => _openCart(context),
                  );
                }
                return _pill(
                  label: 'Add to Cart',
                  onTap: () => _addToCart(context),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _pill({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: _purple,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------- empty

class _EmptyWishlist extends StatelessWidget {
  final VoidCallback? onBrowse;

  const _EmptyWishlist({this.onBrowse});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: Color(0xFFEEE9FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                color: _purple,
                size: 44,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No saved courses yet',
              style: TextStyle(
                color: _heading,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap the heart on any course\nto save it here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _muted, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 22),
            FilledButton(
              onPressed: onBrowse,
              style: FilledButton.styleFrom(
                backgroundColor: _purple,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 13,
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
        ),
      ),
    );
  }
}
