import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:think_lab/cart.dart';
import 'package:think_lab/cart_page.dart';
import 'package:think_lab/checkout_page.dart';
import 'package:think_lab/course.dart';
import 'package:think_lab/course_details.dart';
import 'package:think_lab/purchases.dart';
import 'package:think_lab/upi_payment_page.dart';

import 'test_utils.dart';

void main() {
  // Cart and purchase status are app-wide state: reset before every test.
  setUp(() {
    clearCart();
    resetPurchases();
  });

  testWidgets('Course details has no direct payment entry', (tester) async {
    ignoreOverflowErrors();

    await tester.pumpWidget(
      MaterialApp(home: CourseDetails(course: courseById('c1'))),
    );
    await tester.pump(const Duration(seconds: 1));

    // Only "Add to Cart" — no Buy Now / Pay Now / checkout from here.
    expect(find.text('Add to Cart'), findsOneWidget);
    expect(find.text('Buy Now'), findsNothing);
    expect(find.text('Pay Now'), findsNothing);
    expect(find.text('Go to Cart'), findsNothing);
    expect(find.byType(CheckoutPage), findsNothing);

    // Details → Add to Cart → Cart (no snackbar on the way).
    await tester.tap(find.text('Add to Cart'));
    await tester.pumpAndSettle();

    expect(find.byType(CartPage), findsOneWidget);
    expect(find.byType(CheckoutPage), findsNothing);
    expect(find.text('Pay Now'), findsOneWidget); // payment lives HERE only
  });

  testWidgets('Details button follows the course state', (tester) async {
    ignoreOverflowErrors();

    await tester.pumpWidget(
      MaterialApp(home: CourseDetails(course: courseById('c5'))),
    );
    await tester.pump(const Duration(seconds: 1));

    // 1. Not in the cart yet.
    expect(find.text('Add to Cart'), findsOneWidget);

    // 2. Added → "Go to Cart".
    await tester.tap(find.text('Add to Cart'));
    await tester.pumpAndSettle();
    expect(find.byType(CartPage), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Go to Cart'), findsOneWidget);
    expect(find.text('Add to Cart'), findsNothing);

    // 3. Purchased → unlocked + "Start Learning", never a payment button.
    unlockCourses([courseById('c5')]);
    await tester.pumpAndSettle();

    expect(find.text('Course Unlocked'), findsOneWidget);
    expect(find.text('Start Learning'), findsOneWidget);
    expect(find.text('Go to Cart'), findsNothing);
    expect(find.text('Add to Cart'), findsNothing);
    expect(find.text('Buy Now'), findsNothing);
    expect(find.text('Pay Now'), findsNothing);
  });

  testWidgets('Cart → Pay Now → Checkout → UPI QR → success', (tester) async {
    ignoreOverflowErrors();

    addToCart(courseById('c1')); // ₹1,999
    addToCart(courseById('c2')); // ₹1,499

    await tester.pumpWidget(const MaterialApp(home: CartPage()));
    await tester.pump();

    // Cart: items + TOTAL only (no discount/subtotal/coupon).
    expect(find.text('Complete Web Development Bootcamp'), findsOneWidget);
    expect(find.text('UI/UX Design Masterclass'), findsOneWidget);
    expect(find.text('₹3,498'), findsWidgets);
    expect(find.text('Discount'), findsNothing);
    expect(find.text('Subtotal'), findsNothing);
    expect(find.text('Coupon'), findsNothing);
    expect(find.byType(CheckoutPage), findsNothing);

    // The only payment entry point in the app.
    await tester.tap(find.text('Pay Now'));
    await tester.pumpAndSettle();

    expect(find.byType(CheckoutPage), findsOneWidget);
    expect(find.text('Order Summary'), findsOneWidget);
    expect(find.text('₹3,498'), findsWidgets); // total in summary + bottom bar
    expect(find.text('Discount'), findsNothing);
    expect(find.text('Subtotal'), findsNothing);
    expect(find.text('Coupon'), findsNothing);

    // Every payment method, UPI selected by default.
    for (final method in paymentMethods) {
      expect(find.text(method), findsOneWidget, reason: method);
    }

    await tester.tap(find.text('Pay Now'));
    await tester.pumpAndSettle();

    expect(find.byType(UpiPaymentPage), findsOneWidget);
    final upi = tester.widget<UpiPaymentPage>(find.byType(UpiPaymentPage));
    expect(upi.method, 'UPI', reason: 'UPI must be selected by default');
    expect(upi.total, 3498);
    expect(upi.courses.map((c) => c.id), ['c1', 'c2']);

    // QR amount = CART TOTAL, generated dynamically.
    expect(find.byType(QrImageView), findsOneWidget);
    final upiUrl = upiPaymentUrl(upi.total);
    expect(upiUrl, startsWith('upi://pay'));
    expect(upiUrl, contains('am=3498.00'));
    expect(upiUrl, contains('cu=INR'));

    // The banner sits below the QR — scroll it into view (lazy ListView).
    final banner = find.text(
      'DEMO PAYMENT — No real payment is being processed.',
    );
    await tester.scrollUntilVisible(banner, 300);
    await tester.pumpAndSettle();
    expect(banner, findsOneWidget);
    expect(find.text('I Have Paid'), findsOneWidget);

    // I Have Paid → verifying → success.
    await tester.tap(find.text('I Have Paid'));
    await tester.pump();
    expect(find.text('Verifying Payment...'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();

    expect(find.byType(PaymentSuccessPage), findsOneWidget);
    expect(find.text('Payment Successful'), findsOneWidget);
    expect(find.text('Payment is a DEMO payment only.'), findsOneWidget);
    expect(find.text('Transaction ID'), findsOneWidget);
    expect(find.text('₹3,498'), findsWidgets);
    expect(find.text('Payment Method'), findsOneWidget);
    expect(find.text('UPI'), findsOneWidget);

    final tx = tester
        .widgetList<Text>(find.textContaining('DEMOUPI'))
        .map((t) => t.data ?? '');
    expect(tx, isNotEmpty);
    expect(tx.first, startsWith('DEMOUPI'));

    // Both paid courses are unlocked — and only those.
    expect(isPurchased(courseById('c1')), isTrue);
    expect(isPurchased(courseById('c2')), isTrue);
    expect(isPurchased(courseById('c6')), isFalse);

    // The paid courses left the cart.
    expect(cartCourses, isEmpty);
    expect(
      find.text('Complete Web Development Bootcamp'),
      findsOneWidget,
      reason: 'success page lists the purchased course',
    );
  });

  testWidgets('Multiple courses are paid in one transaction', (tester) async {
    ignoreOverflowErrors();

    addToCart(courseById('c1')); // ₹1,999
    addToCart(courseById('c2')); // ₹1,499
    addToCart(courseById('c5')); // ₹1,799 → ₹5,297

    await tester.pumpWidget(const MaterialApp(home: CartPage()));
    await tester.pump();
    expect(find.text('₹5,297'), findsWidgets);

    await tester.tap(find.text('Pay Now'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pay Now'));
    await tester.pumpAndSettle();

    expect(upiPaymentUrl(5297), contains('am=5297.00'), reason: 'QR = total');
    expect(find.byType(QrImageView), findsOneWidget);

    await tester.tap(find.text('I Have Paid'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();

    expect(find.text('₹5,297'), findsWidgets);
    for (final id in ['c1', 'c2', 'c5']) {
      expect(isPurchased(courseById(id)), isTrue, reason: '$id unlocked');
    }
    expect(isPurchased(courseById('c6')), isFalse);
    expect(cartCourses, isEmpty);
  });

  test('Only the courses in the paid cart are unlocked and removed', () {
    addToCart(courseById('c1'));
    addToCart(courseById('c2'));

    // Simulate a payment that covered c1 only.
    final paid = [courseById('c1')];
    unlockCourses(paid);
    for (final course in paid) {
      removeFromCart(course);
    }

    expect(isPurchased(courseById('c1')), isTrue);
    expect(isPurchased(courseById('c2')), isFalse, reason: 'not paid yet');
    expect(isInCart(courseById('c1')), isFalse, reason: 'paid → removed');
    expect(isInCart(courseById('c2')), isTrue, reason: 'unpaid → kept');
    expect(cartCourses.map((c) => c.id), ['c2']);
  });
}
