import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:think_lab/cart.dart';
import 'package:think_lab/cart_page.dart';
import 'package:think_lab/checkout_page.dart';
import 'package:think_lab/course.dart';
import 'package:think_lab/course_details.dart';
import 'package:think_lab/index.dart';
import 'package:think_lab/login_user.dart';
import 'package:think_lab/purchases.dart';
import 'package:think_lab/session.dart';
import 'package:think_lab/upi_payment_page.dart';
import 'package:think_lab/widgets/nav_bar.dart';
import 'package:think_lab/wishlist_page.dart';

import 'test_utils.dart';

void main() {
  // Wishlist, cart and enrolment are app-wide state: reset for every test.
  setUp(() {
    clearCart();
    resetPurchases();
    resetFavorites();
    signIn('guest');
  });

  Future<void> openWishlist(WidgetTester tester) async {
    ignoreOverflowErrors();
    await tester.pumpWidget(const MaterialApp(home: index()));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Wishlist'));
    await tester.pumpAndSettle();
    expect(find.byType(WishlistPage), findsOneWidget);
  }

  testWidgets('Wishlist shows the saved courses of the current user', (
    tester,
  ) async {
    await openWishlist(tester);

    // Header count comes from the data.
    expect(find.text('2 saved courses'), findsOneWidget);

    // The two courses that start out saved (c1 and c3) — by course id.
    expect(find.text('Complete Web Development Bootcamp'), findsOneWidget);
    expect(find.text('Rohan Gupta'), findsOneWidget);
    expect(find.text('₹1,999'), findsOneWidget);
    expect(find.text('Digital Marketing Fundamentals'), findsOneWidget);
    expect(find.text('Priya Menon'), findsOneWidget);
    expect(find.text('₹999'), findsOneWidget);

    // Nothing else leaks into the list.
    expect(find.text('Python Programming'), findsNothing);
    expect(find.text('UI/UX Design Masterclass'), findsNothing);

    // Existing card controls: star rating, filled heart, Add to Cart pill.
    expect(find.byIcon(Icons.star_rounded), findsNWidgets(2));
    expect(find.byIcon(Icons.favorite), findsNWidgets(2));
    expect(find.text('Add to Cart'), findsNWidgets(2));

    // The bottom navigation is untouched.
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Learning'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    // 'Wishlist' is both the page title and the selected tab label.
    expect(find.text('Wishlist'), findsWidgets);
    expect(navItems.length, 4);
  });

  testWidgets('The heart removes a course from the wishlist', (tester) async {
    await openWishlist(tester);

    await tester.tap(find.byIcon(Icons.favorite).first);
    await tester.pumpAndSettle();

    expect(find.text('1 saved course'), findsOneWidget);
    expect(find.text('Complete Web Development Bootcamp'), findsNothing);
    expect(find.text('Digital Marketing Fundamentals'), findsOneWidget);

    // Saving it again brings it back.
    expect(isFavorite(courseById('c1')), isFalse);
    toggleFavorite(courseById('c1'));
    await tester.pumpAndSettle();
    expect(find.text('2 saved courses'), findsOneWidget);
  });

  testWidgets('Add to Cart saves the id, confirms and starts no payment', (
    tester,
  ) async {
    await openWishlist(tester);

    await tester.tap(find.text('Add to Cart').first);
    await tester.pump();

    // Standard confirmation — nothing else happens.
    expect(find.text('Course added to cart'), findsOneWidget);
    expect(find.byType(CartPage), findsNothing);
    expect(find.byType(CheckoutPage), findsNothing);
    expect(find.byType(UpiPaymentPage), findsNothing);
    expect(find.byType(CourseDetails), findsNothing);

    expect(isInCart(courseById('c1')), isTrue, reason: 'saved by course id');
    expect(isPurchased(courseById('c1')), isFalse, reason: 'no enrolment');
    expect(cartCourses.length, 1);

    // The same course can no longer be added twice: the existing pill now
    // reads "Go to Cart" (existing wording, same design).
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Add to Cart'), findsOneWidget);
    expect(find.text('Go to Cart'), findsOneWidget);

    await tester.tap(find.text('Go to Cart'));
    await tester.pumpAndSettle();
    expect(find.byType(CartPage), findsOneWidget);
    expect(cartCourses.length, 1, reason: 'never a duplicate item');
  });

  testWidgets('A purchased course cannot be bought again from the wishlist', (
    tester,
  ) async {
    // The current user already owns c1.
    unlockCourses([courseById('c1')]);

    await openWishlist(tester);

    // Owned → the existing "Start Learning" state, no Add to Cart.
    expect(find.text('Start Learning'), findsOneWidget);
    expect(find.text('Add to Cart'), findsOneWidget); // only c3
    expect(find.byIcon(Icons.favorite), findsNWidgets(2)); // still saved

    await tester.tap(find.text('Start Learning'));
    await tester.pumpAndSettle();

    // Opens the course so the user can continue learning.
    expect(find.byType(CourseDetails), findsOneWidget);
    expect(find.text('Complete Web Development Bootcamp'), findsOneWidget);
    expect(find.text('Course Unlocked'), findsOneWidget);
    expect(find.text('Start Learning'), findsOneWidget);
    expect(find.text('Add to Cart'), findsNothing);
    expect(find.text('Pay Now'), findsNothing);
    expect(find.text('Buy Now'), findsNothing);
  });

  test('Enrolment is stored per user id, never globally', () {
    signIn('usera@learnhub.app');
    unlockCourses([courseById('c1')]);

    expect(isPurchased(courseById('c1')), isTrue, reason: 'user A owns c1');
    expect(
      isPurchased(courseById('c1'), userId: 'userb@learnhub.app'),
      isFalse,
      reason: 'user B does not',
    );

    // Signing in as B shows the course as buyable again.
    signIn('userb@learnhub.app');
    expect(isPurchased(courseById('c1')), isFalse);
    expect(isPurchased(courseById('c3')), isFalse);

    // Back as A, the purchase is still there.
    signIn('usera@learnhub.app');
    expect(isPurchased(courseById('c1')), isTrue);
    expect(isPurchased(courseById('c3')), isFalse);
  });

  testWidgets('Login stores the typed e-mail as the current user id', (
    tester,
  ) async {
    ignoreOverflowErrors();
    await tester.pumpWidget(const MaterialApp(home: login_user()));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).first,
      'usera@learnhub.app',
    );
    await tester.enterText(find.byType(TextFormField).last, 'secret123');
    await tester.ensureVisible(find.text('Login'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(currentUser.value, 'usera@learnhub.app');
    expect(find.byType(index), findsOneWidget);
  });

  testWidgets('Wishlist → cart → Pay Now → UPI unlocks for this user', (
    tester,
  ) async {
    await openWishlist(tester);

    // Both saved courses go into the existing cart: ₹1,999 + ₹999 = ₹2,998.
    await tester.tap(find.text('Add to Cart').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add to Cart').first);
    await tester.pumpAndSettle();
    expect(cartCourses.length, 2);
    expect(find.text('Go to Cart'), findsNWidgets(2));

    // Let the "Course added to cart" confirmation disappear before scrolling
    // on — it floats above the bottom of the screen.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Go to Cart').first);
    await tester.pumpAndSettle();
    expect(find.byType(CartPage), findsOneWidget);
    expect(find.text('₹2,998'), findsWidgets);
    expect(find.text('Discount'), findsNothing);
    expect(find.text('Subtotal'), findsNothing);
    expect(find.text('Coupon'), findsNothing);

    await tester.tap(find.text('Pay Now'));
    await tester.pumpAndSettle();
    expect(find.byType(CheckoutPage), findsOneWidget);

    await tester.tap(find.text('Pay Now'));
    await tester.pumpAndSettle();
    expect(find.byType(UpiPaymentPage), findsOneWidget);
    expect(upiPaymentUrl(2998), contains('am=2998.00'), reason: 'QR = total');

    await tester.tap(find.text('I Have Paid'));
    await tester.pump();
    expect(find.text('Verifying Payment...'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();

    // Demo payment succeeded for the CURRENT user.
    expect(find.byType(PaymentSuccessPage), findsOneWidget);
    expect(find.text('₹2,998'), findsWidgets);
    expect(isPurchased(courseById('c1')), isTrue);
    expect(isPurchased(courseById('c3')), isTrue);
    expect(isPurchased(courseById('c5')), isFalse, reason: 'not in the cart');
    expect(cartCourses, isEmpty, reason: 'paid courses left the cart');
    expect(
      wishlistOf(currentUser.value).value,
      containsAll(<String>['c1', 'c3']),
      reason: 'the wishlist keeps saved courses',
    );

    // "Start Learning" takes the user back to the app — the wishlist has
    // refreshed and now offers learning instead of buying.
    await tester.tap(find.text('Start Learning'));
    await tester.pumpAndSettle();

    expect(find.byType(index), findsOneWidget);
    expect(find.byType(WishlistPage), findsOneWidget);
    expect(find.text('Start Learning'), findsNWidgets(2));
    expect(find.text('Add to Cart'), findsNothing);
    expect(find.text('2 saved courses'), findsOneWidget);
  });
}
