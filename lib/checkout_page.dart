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
      backgroundColor: const Color(0xFFF4F1FF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            Expanded(
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
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
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
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            course.image,
            width: 44,
            height: 44,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 44,
              height: 44,
              color: const Color(0xFFEEE9FF),
            ),
          ),
        ),
        const SizedBox(width: 12),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          for (var i = 0; i < paymentMethods.length; i++) ...[
            if (i > 0) const Divider(height: 8, color: Color(0xFFEDEAF8)),
            _methodTile(paymentMethods[i]),
          ],
        ],
      ),
    );
  }

  Widget _methodTile(String method) {
    final selected = _method == method;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _method = method),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
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
              const Icon(Icons.check_circle_rounded, color: _purple, size: 18),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------- bottom bar

  Widget _bottomBar(String total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
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
          Expanded(
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
