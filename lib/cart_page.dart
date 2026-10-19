import 'package:flutter/material.dart';

import 'cart.dart';
import 'checkout_page.dart';
import 'course.dart';

const _heading = Color(0xFF2B2356);
const _muted = Color(0xFF9A96B8);
const _purple = Color(0xFF6B45F0);
const _star = Color(0xFFF5A623);

// =====================================================
// UI STRUCTURE (SCREEN VIEW)
//  1. Back button          -> GestureDetector + Icon (tap -> previous page)
//  2. Title                -> Text "Course Cart"
//  3. Clear all button     -> TextButton (tap -> empty the cart)
//  4. Course cards         -> ListView.separated of cart cards
//  5. Cart card            -> Container + Image.asset + title + rating + price
//  6. Remove button        -> GestureDetector + Icon (tap -> remove from cart)
//  7. Empty cart view      -> Icon + Text "Your cart is empty" + Browse courses button
//  8. Summary sheet        -> Container + Text "Summary" + Total row
//  9. Pay Now button       -> FilledButton (tap -> Checkout page)
// =====================================================
// =====================================================
// CART PAGE
// Shows the selected courses and the total cart amount.
// =====================================================

/// CART PAGE (StatelessWidget)
/// A StatelessWidget is enough here: ValueListenableBuilder rebuilds the page
/// by itself whenever the cart changes (item removed, total changes).
/// Layout: Scaffold -> SafeArea -> Column (title bar, course list, price summary, Pay Now button).
class CartPage extends StatelessWidget {
  const CartPage({super.key});

  // Shows a small floating message (SnackBar), e.g. "removed" / "cleared".
  void _snack(BuildContext context, String message) {
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

  @override
  Widget build(BuildContext context) {
    // Scaffold = the whole cart page (background colour + body).
    return Scaffold(
      backgroundColor: const Color(0xFFF6F5FB),
      // SafeArea = keeps the cart content away from the notch / status bar.
      body: SafeArea(
        // Listens to the shared cart: the page rebuilds on every cart change.
        child: ValueListenableBuilder<Set<String>>(
          valueListenable: cartIds,
          builder: (context, ids, _) {
            // Course ids -> actual course objects, from the shared cart file.
            final courses = cartCourses;

            // Column -> title bar + scrollable course list + bottom price summary.
            return Column(
              children: [
                _header(context, courses.isNotEmpty),
                if (courses.isEmpty)
                  // Expanded = empty-cart view takes all leftover height.
                  const Expanded(child: _EmptyCart())
                else
                  // Expanded = scrollable cart list fills the rest.
                  Expanded(
                    // Draws one cart card per course, with a gap between cards.
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(18, 6, 18, 18),
                      itemCount: courses.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) => _CartCard(
                        course: courses[index],
                        onRemove: () {
                          removeFromCart(courses[index]);
                          _snack(context, '${courses[index].title} removed');
                        },
                      ),
                    ),
                  ),
                if (courses.isNotEmpty)
                  _summary(context, courses, formatRupees(cartTotal)),
              ],
            );
          },
        ),
      ),
    );
  }

  // ------------------------------------------------------------- header

  Widget _header(BuildContext context, bool hasItems) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
      // Row = back button, page title, then "Clear all" on the right.
      child: Row(
        children: [
          _roundButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          // Expanded = title stretches, pushing "Clear all" to the right.
          const Expanded(
            child: Text(
              'Course Cart',
              style: TextStyle(
                color: _heading,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (hasItems)
            TextButton(
              // "Clear all" removes every course from this user's cart.
              onPressed: () {
                clearCart();
                _snack(context, 'Cart cleared');
              },
              child: const Text(
                'Clear all',
                style: TextStyle(
                  color: _purple,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _roundButton({required IconData icon, required VoidCallback onTap}) {
    // GestureDetector = makes the round icon button tappable.
    return GestureDetector(
      onTap: onTap,
      // Container = white circular button background.
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

  // ----------------------------------------------------------- summary

  // Bottom white sheet: total amount + the Pay Now button.
  Widget _summary(BuildContext context, List<Course> courses, String total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      // Column = "Summary" heading, total row, then the Pay Now button.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Summary',
            style: TextStyle(
              color: _heading,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          // No discount row: the total price is all there is to pay.
          Row(
            children: [
              const Text(
                'Total',
                style: TextStyle(color: _muted, fontSize: 14),
              ),
              const Spacer(),
              Text(
                total,
                style: const TextStyle(
                  color: _heading,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            // FilledButton = purple "Pay Now" button that opens Checkout.
            child: FilledButton(
              // The ONLY entry point to payment in the whole app.
              // User taps Pay Now -> Open the Checkout page.
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      CheckoutPage(courses: courses, total: cartTotal),
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: _purple,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              // Row = "Pay Now" label with the forward arrow icon.
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Pay Now',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------- item card

/// One row in the cart list: course image, details, price and a remove button.
class _CartCard extends StatelessWidget {
  final Course course;
  final VoidCallback onRemove;

  const _CartCard({required this.course, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    // Container gives each card the white rounded look.
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      // Row -> course image on the left, details in the middle, price on the right.
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            // Image.asset = the course thumbnail.
            child: Image.asset(
              course.image,
              width: 68,
              height: 68,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 68,
                height: 68,
                color: const Color(0xFFEEE9FF),
                child: const Icon(Icons.play_circle_outline, color: _purple),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Expanded = course details fill the middle of the card.
          Expanded(
            // Column = title, meta line, then the rating row.
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _heading,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${course.category} · ${course.duration}',
                  style: const TextStyle(color: _muted, fontSize: 12),
                ),
                const SizedBox(height: 7),
                // Row = star + rating and student count.
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: _star, size: 15),
                    const SizedBox(width: 3),
                    Text(
                      '${course.rating} (${course.students})',
                      style: const TextStyle(
                        color: _heading,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Right column: the price, then the remove (delete) button.
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                course.price,
                style: const TextStyle(
                  color: _purple,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              // Tap delete -> remove this course from the cart.
              GestureDetector(
                onTap: onRemove,
                // Container = round delete-button background.
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF4F1FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: _purple,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------- empty

/// Shown in the middle of the page when the cart has no courses at all.
class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        // Column = icon, empty message, then the browse button.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Container = big pale circle behind the cart icon.
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: Color(0xFFEEE9FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: _purple,
                size: 44,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Your cart is empty',
              style: TextStyle(
                color: _heading,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Open any course and tap "Add to Cart"\nto see it here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _muted, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 22),
            // FilledButton = "Browse courses" closes the empty cart view.
            FilledButton(
              onPressed: () => Navigator.pop(context),
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
