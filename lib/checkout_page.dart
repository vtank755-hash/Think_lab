import 'package:flutter/material.dart';

import 'cart.dart';
import 'course.dart';
import 'upi_payment_page.dart';

const _heading = Color(0xFF2B2356);
const _muted = Color(0xFF9A96B8);
const _purple = Color(0xFF6B45F0);

/// Payment methods offered at checkout. UPI is selected by default.
const paymentMethods = [
  'UPI',
  'Google Pay',
  'PhonePe',
  'Paytm',
  'Debit / Credit Card',
  'Net Banking',
];

/// Checkout page — step 2 of the payment flow.
///
/// It is reached ONLY from the cart's **Pay Now** button, never from the
/// course details page. The order summary shows the courses and the
/// **TOTAL only** — no subtotal, no discount, no coupon.
///
/// `total` is always the sum of `courses` prices calculated by the cart.
// =====================================================
// UI STRUCTURE (SCREEN VIEW)
//  1. Back button          -> GestureDetector + Icon (tap -> previous page)
//  2. Title                -> Text "Checkout"
//  3. Order Summary card   -> Container + Text "Order Summary"
//  4. Course rows          -> Row of Image.asset + title + price
//  5. Total row            -> Row "Total" + amount
//  6. Section title        -> Text "Payment Method"
//  7. Payment method tiles -> GestureDetector + circle radio (tap -> select method)
//  8. Method names         -> Text "UPI" / "Google Pay" / "PhonePe" / "Paytm" / "Debit / Credit Card" / "Net Banking"
//  9. Bottom bar           -> Total column + button row
// 10. Pay Now button       -> FilledButton (tap -> UPI payment page)
// =====================================================
// =====================================================
// CHECKOUT PAGE
// Shows cart courses, payment method and the final amount.
// =====================================================
class CheckoutPage extends StatefulWidget {
  final List<Course> courses;
  final int total;

  const CheckoutPage({super.key, required this.courses, required this.total});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  /// UPI selected by default.
  /// _method holds whichever payment method the user last tapped.
  String _method = 'UPI';

  void _pay() {
    // User taps Pay Now -> Open the UPI QR payment page.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UpiPaymentPage(
          courses: widget.courses,
          total: widget.total,
          method: _method,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = formatRupees(widget.total);

    return Scaffold(
      // Scaffold = the checkout page (light purple background + body).
      backgroundColor: const Color(0xFFF4F1FF),
      // SafeArea = keeps content away from the notch / status bar.
      body: SafeArea(
        // Column = header on top, scrollable middle, bottom total bar.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            // Expanded = lets the middle list fill the leftover height.
            Expanded(
              // ListView = scrolls the order summary and payment methods.
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                children: [
                  _orderSummary(),
                  const SizedBox(height: 18),
                  _sectionTitle('Payment Method'),
                  const SizedBox(height: 10),
                  _methodsCard(),
                ],
              ),
            ),
            _bottomBar(total),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------- header

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
      // Row = back button and "Checkout" title side by side.
      child: Row(
        children: [
          // GestureDetector = tap -> go back to the cart.
          GestureDetector(
            onTap: () => Navigator.pop(context),
            // Container = white circle behind the back arrow.
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              // Icon = the back arrow glyph.
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: _heading,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Checkout',
            style: TextStyle(
              color: _heading,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: _heading,
        fontSize: 17,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  // ----------------------------------------------------- order summary

  Widget _orderSummary() {
    // Container = white rounded Order Summary card.
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      // Column = heading, course rows and total stacked vertically.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(
              color: _heading,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          for (final course in widget.courses) ...[
            _summaryRow(course),
            const SizedBox(height: 12),
          ],
          // Divider = separates the course rows from the total row.
          const Divider(height: 8, color: Color(0xFFEDEAF8)),
          const SizedBox(height: 12),
          // TOTAL only — no subtotal, discount or coupon anywhere.
          Row(
            children: [
              const Text(
                'Total',
                style: TextStyle(color: _muted, fontSize: 14),
              ),
              const Spacer(),
              Text(
                formatRupees(widget.total),
                style: const TextStyle(
                  color: _heading,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(Course course) {
    // Row = thumbnail, course title and price in one line.
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          // Image.asset = the course thumbnail picture.
          child: Image.asset(
            course.image,
            width: 44,
            height: 44,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              width: 44,
              height: 44,
              color: const Color(0xFFEEE9FF),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Expanded = title stretches into the free middle space.
        Expanded(
          child: Text(
            course.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _heading,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          course.price,
          style: const TextStyle(
            color: _purple,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------- payment methods

  Widget _methodsCard() {
    // Container = white rounded card holding the payment methods.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      // Column = one payment method row below another.
      child: Column(
        children: [
          for (var i = 0; i < paymentMethods.length; i++) ...[
            // Divider = separates neighbouring payment method rows.
            if (i > 0) const Divider(height: 8, color: Color(0xFFEDEAF8)),
            _methodTile(paymentMethods[i]),
          ],
        ],
      ),
    );
  }

  // One row per payment method. The purple circle = the currently
  // selected method; tapping a row calls setState to move the selection.
  Widget _methodTile(String method) {
    final selected = _method == method;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _method = method),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        // Row = radio circle + method name + selected tick.
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? _purple : const Color(0xFFD8D4EA),
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                      // Container = purple dot inside the selected circle.
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: _purple,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            // Expanded = method name fills the space up to the tick.
            Expanded(
              child: Text(
                method,
                style: TextStyle(
                  color: selected ? _heading : const Color(0xFF6E6A8C),
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            if (selected)
              // Icon = purple tick shown on the chosen method.
              const Icon(Icons.check_circle_rounded, color: _purple, size: 18),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------- bottom bar

  Widget _bottomBar(String total) {
    // Container = white bottom bar with total and Pay Now.
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      // Row = total amount on the left, Pay Now button on the right.
      child: Row(
        children: [
          // Column = "Total" label stacked above the amount.
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Total',
                style: TextStyle(color: _muted, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                total,
                style: const TextStyle(
                  color: _purple,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(width: 18),
          // Expanded = button stretches across the free width.
          Expanded(
            // FilledButton = Pay Now -> opens the UPI payment page.
            child: FilledButton(
              onPressed: _pay,
              style: FilledButton.styleFrom(
                backgroundColor: _purple,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Pay Now',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
