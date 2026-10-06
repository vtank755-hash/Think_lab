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
  bool _verifying = false;

  /// The UPI deep link encoded in the QR — amount = cart total.
  String get _upiUrl => upiPaymentUrl(widget.total);

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
      backgroundColor: const Color(0xFFF4F1FF),
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4DE),
        borderRadius: BorderRadius.circular(16),
      ),
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
            'Courses',
            style: TextStyle(
              color: _heading,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          for (final course in widget.courses) ...[
            Row(
              children: [
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
          const Divider(height: 8, color: Color(0xFFEDEAF8)),
          const SizedBox(height: 10),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
      decoration: const BoxDecoration(color: Colors.white),
      child: _verifying
          ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
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
      backgroundColor: const Color(0xFFF4F1FF),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 24, 18, 18),
                children: [
                  const Center(
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _detailRow('Transaction ID', transactionId),
          const Divider(height: 16, color: Color(0xFFEDEAF8)),
          _detailRow('Amount', formatRupees(total)),
          const Divider(height: 16, color: Color(0xFFEDEAF8)),
          _detailRow('Payment Method', method),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
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
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: _green,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
      decoration: const BoxDecoration(color: Colors.white),
      child: FilledButton(
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
