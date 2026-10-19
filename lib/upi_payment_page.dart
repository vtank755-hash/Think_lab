import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'cart.dart';
import 'course.dart';
import 'purchases.dart';

const _heading = Color(0xFF2B2356);
const _muted = Color(0xFF9A96B8);
const _purple = Color(0xFF6B45F0);
const _green = Color(0xFF25A55F);

/// The UPI deep link encoded in the payment QR code.
///
/// [totalRupees] is ALWAYS the cart total — never a single course price:
///
/// ```
/// upi://pay?pa=demo@upi&pn=ThinkLab&am=3797.00&cu=INR&tn=Course%20Payment
/// ```
String upiPaymentUrl(int totalRupees) =>
    'upi://pay'
    '?pa=demo@upi'
    '&pn=ThinkLab'
    '&am=${totalRupees.toStringAsFixed(2)}'
    '&cu=INR'
    '&tn=Course%20Payment';

/// Step 3: the UPI payment page with a dynamically generated demo QR code.
///
/// The QR always encodes the CART TOTAL (never a single course price):
///
/// `upi://pay?pa=demo@upi&pn=ThinkLab&am=3797.00&cu=INR&tn=Course%20Payment`
// =====================================================
// UI STRUCTURE (SCREEN VIEW)
//  1. Back button           -> GestureDetector + Icon (tap -> previous page)
//  2. Title                 -> Text "UPI Payment"
//  3. Amount row            -> Text "Pay" + Text amount (cart total)
//  4. QR code               -> QrImageView (UPI link, amount = cart total)
//  5. Scan hint             -> Text "Scan this QR code using any UPI application."
//  6. UPI apps row          -> Container chips "Google Pay" / "PhonePe" / "Paytm"
//  7. Demo banner           -> Icon + Text "DEMO PAYMENT ..."
//  8. Courses card          -> Text "Courses" + title/price rows + Total row
//  9. Payment method row    -> Text "Payment Method" + chosen method
// 10. I Have Paid button    -> FilledButton (tap -> fake 1.5s verification)
// 11. Verifying state       -> CircularProgressIndicator + Text "Verifying Payment..."
// 12. Success page          -> check Icon + transaction ID + purchased courses
// 13. Start Learning button -> FilledButton (tap -> back to Home page)
// =====================================================
// =====================================================
// UPI PAYMENT PAGE
// Shows the demo UPI QR code for the cart amount.
// =====================================================
class UpiPaymentPage extends StatefulWidget {
  final List<Course> courses;
  final int total;
  final String method;

  const UpiPaymentPage({
    super.key,
    required this.courses,
    required this.total,
    required this.method,
  });

  @override
  State<UpiPaymentPage> createState() => _UpiPaymentPageState();
}

class _UpiPaymentPageState extends State<UpiPaymentPage> {
  // true while the fake "Verifying Payment..." spinner is showing.
  bool _verifying = false;

  /// The UPI deep link encoded in the QR — amount = cart total.
  String get _upiUrl => upiPaymentUrl(widget.total);

  // Builds a fake transaction id like "DEMOUPI20251012143055" from the
  // current date + time, so each demo payment gets a unique-looking id.
  String _transactionId() {
    final now = DateTime.now();
    String p2(int n) => n.toString().padLeft(2, '0');
    return 'DEMOUPI${now.year}${p2(now.month)}${p2(now.day)}'
        '${p2(now.hour)}${p2(now.minute)}${p2(now.second)}';
  }

  /// "I Have Paid" → verify (simulated delay) → unlock exactly the courses
  /// that were in this paid cart and remove them from the cart.
  Future<void> _paid() async {
    setState(() => _verifying = true);
    // Fake 1.5s wait so it feels like a real bank verification.
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    final paidCourses = List<Course>.of(widget.courses);
    // Payment successful -> Unlock the purchased courses and remove them
    // from the cart, then show the success page.
    unlockCourses(paidCourses);
    for (final course in paidCourses) {
      removeFromCart(course);
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentSuccessPage(
          transactionId: _transactionId(),
          total: widget.total,
          method: widget.method,
          courses: paidCourses,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final amount = formatRupees(widget.total);

    return Scaffold(
      // Scaffold = the UPI payment page (light purple background).
      backgroundColor: const Color(0xFFF4F1FF),
      // SafeArea = keeps content away from the notch / status bar.
      body: SafeArea(
        // Column = header, scrollable cards, bottom I-Have-Paid bar.
        child: Column(
          children: [
            _header(),
            // Expanded = lets the middle list fill the leftover height.
            Expanded(
              // ListView = scrolls the QR card, demo banner and courses.
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 6, 18, 18),
                children: [
                  _payCard(amount),
                  const SizedBox(height: 14),
                  _demoBanner(),
                  const SizedBox(height: 16),
                  _coursesCard(),
                ],
              ),
            ),
            _paidButton(),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------- header

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 4),
      // Row = back button and "UPI Payment" title side by side.
      child: Row(
        children: [
          // GestureDetector = tap -> go back to checkout.
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
            'UPI Payment',
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

  // --------------------------------------------------------- pay + QR

  Widget _payCard(String amount) {
    // Container = white rounded card holding amount + QR + chips.
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      // Column = "Pay", amount, QR, hint and app chips stacked.
      child: Column(
        children: [
          const Text('Pay', style: TextStyle(color: _muted, fontSize: 14)),
          const SizedBox(height: 4),
          Text(
            amount,
            style: const TextStyle(
              color: _heading,
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          // Container = white bordered frame around the QR code.
          // QrImageView draws the QR from the UPI link (amount = cart total).
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFEDEAF8)),
            ),
            child: QrImageView(
              data: _upiUrl,
              size: 240,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Scan this QR code using\nany UPI application.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _muted, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 14),
          // Row = Google Pay, PhonePe and Paytm chips in a line.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _appChip('Google Pay'),
              const SizedBox(width: 8),
              _appChip('PhonePe'),
              const SizedBox(width: 8),
              _appChip('Paytm'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _appChip(String label) {
    // Container = the UPI app chip (small rounded label).
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F1FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: _purple,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _demoBanner() {
    // Container = yellow demo-payment warning banner.
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4DE),
        borderRadius: BorderRadius.circular(16),
      ),
      // Row = info icon next to the demo warning text.
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFFB8860B), size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'DEMO PAYMENT — No real payment is being processed.',
              style: TextStyle(
                color: Color(0xFF8A6412),
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------- courses

  Widget _coursesCard() {
    final amount = formatRupees(widget.total);
    // Container = white card listing the courses being bought.
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      // Column = course rows, then Total and Payment Method rows.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Courses',
            style: TextStyle(
              color: _heading,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          for (final course in widget.courses) ...[
            // Row = one course title beside its price.
            Row(
              children: [
                // Expanded = title fills space, price stays on the right.
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
            ),
            const SizedBox(height: 10),
          ],
          // Divider = separates the course rows from the total row.
          const Divider(height: 8, color: Color(0xFFEDEAF8)),
          const SizedBox(height: 10),
          // Row = "Total" label beside the final amount.
          Row(
            children: [
              const Text(
                'Total',
                style: TextStyle(color: _muted, fontSize: 14),
              ),
              const Spacer(),
              Text(
                amount,
                style: const TextStyle(
                  color: _heading,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Row = "Payment Method" label beside the chosen method.
          Row(
            children: [
              const Text(
                'Payment Method',
                style: TextStyle(color: _muted, fontSize: 14),
              ),
              const Spacer(),
              Text(
                widget.method,
                style: const TextStyle(
                  color: _heading,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------- I have paid

  Widget _paidButton() {
    // Container = white bottom bar holding the pay action.
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
      decoration: const BoxDecoration(color: Colors.white),
      child: _verifying
          // Row = verifying spinner shown beside the status text.
          ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  // CircularProgressIndicator = small fake verifying spinner.
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: _purple,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Verifying Payment...',
                  style: TextStyle(
                    color: _heading,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            )
          // FilledButton = I Have Paid -> starts the fake verification.
          : FilledButton(
              onPressed: _paid,
              style: FilledButton.styleFrom(
                backgroundColor: _purple,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'I Have Paid',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
    );
  }
}

// ============================================================ success

/// Shown after the demo payment is verified: transaction details and the
/// courses that were unlocked by THIS payment.
class PaymentSuccessPage extends StatelessWidget {
  final String transactionId;
  final int total;
  final String method;
  final List<Course> courses;

  const PaymentSuccessPage({
    super.key,
    required this.transactionId,
    required this.total,
    required this.method,
    required this.courses,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Scaffold = payment success page (light purple background).
      backgroundColor: const Color(0xFFF4F1FF),
      // SafeArea = keeps content away from the notch / status bar.
      body: SafeArea(
        // Column = scrollable results above the Start Learning bar.
        child: Column(
          children: [
            // Expanded = lets the list fill the leftover height.
            Expanded(
              // ListView = scrolls the success message and course cards.
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 24, 18, 18),
                children: [
                  const Center(
                    // Icon = big green check mark for success.
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: _green,
                      size: 76,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Payment Successful',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _heading,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Payment is a DEMO payment only.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _muted, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  _detailsCard(),
                  const SizedBox(height: 16),
                  _coursesCard(),
                ],
              ),
            ),
            _startLearning(context),
          ],
        ),
      ),
    );
  }

  Widget _detailsCard() {
    // Container = white card with the payment details.
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      // Column = the three detail rows stacked vertically.
      child: Column(
        children: [
          _detailRow('Transaction ID', transactionId),
          // Divider = separates one detail row from the next.
          const Divider(height: 16, color: Color(0xFFEDEAF8)),
          _detailRow('Amount', formatRupees(total)),
          const Divider(height: 16, color: Color(0xFFEDEAF8)),
          _detailRow('Payment Method', method),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    // Row = label on the left, its value on the right.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(color: _muted, fontSize: 13),
          ),
        ),
        // Expanded = value takes the rest of the row width.
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: _heading,
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _coursesCard() {
    // Container = white card listing the purchased courses.
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      // Column = one purchased course row under another.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Purchased Courses',
            style: TextStyle(
              color: _heading,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          for (final course in courses)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              // Row = green tick, course title and its price.
              child: Row(
                children: [
                  // Icon = small green tick for each purchased course.
                  const Icon(
                    Icons.check_circle_rounded,
                    color: _green,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  // Expanded = title fills space, price stays right.
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
                    style: const TextStyle(color: _muted, fontSize: 13),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _startLearning(BuildContext context) {
    // Container = white bottom bar for the Start Learning button.
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
      decoration: const BoxDecoration(color: Colors.white),
      // FilledButton = Start Learning -> back to the Home page.
      child: FilledButton(
        // Payment successful -> Start Learning pops every page off the
        // stack, so the user lands back on the Home page.
        onPressed: () =>
            Navigator.of(context).popUntil((route) => route.isFirst),
        style: FilledButton.styleFrom(
          backgroundColor: _purple,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text(
          'Start Learning',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
