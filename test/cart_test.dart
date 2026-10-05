import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:think_lab/Searches.dart';
import 'package:think_lab/cart.dart';
import 'package:think_lab/cart_page.dart';
import 'package:think_lab/course.dart';
import 'package:think_lab/index.dart';

import 'test_utils.dart';

void main() {
  // The cart is app-wide state: start every test with an empty cart.
  setUp(clearCart);

  testWidgets('"Add to Cart" adds exactly the selected course', (tester) async {
    ignoreOverflowErrors();

    await tester.pumpWidget(const MaterialApp(home: Searches()));
    await tester.pump(const Duration(seconds: 1));

    await tester.enterText(find.byType(TextField), 'Python Programming');
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Python Programming').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add to Cart'));
    await tester.pumpAndSettle();

    // No notification: the cart page opens directly.
    expect(find.byType(SnackBar), findsNothing);
    expect(find.byType(CartPage), findsOneWidget);
    expect(find.text('Course Cart'), findsOneWidget);
    expect(find.text('Python Programming'), findsOneWidget);
    expect(find.text('₹1,799'), findsWidgets);

    // Tapping "Add to Cart" again must not add a duplicate.
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add to Cart'));
    await tester.pumpAndSettle();

    expect(cartCourses.length, 1);
    expect(find.byType(CartPage), findsOneWidget);

    // Summary shows the total price only — never a discount.
    expect(find.text('Total'), findsOneWidget);
    expect(find.text('Discount'), findsNothing);
    expect(find.text('Checkout'), findsOneWidget);
  });

  testWidgets('Cart total = sum of item prices, and items can be deleted', (
    tester,
  ) async {
    addToCart(courseById('c1')); // Complete Web Development Bootcamp — ₹1,999
    addToCart(courseById('c2')); // UI/UX Design Masterclass — ₹1,499

    await tester.pumpWidget(const MaterialApp(home: CartPage()));
    await tester.pump();

    expect(find.text('Complete Web Development Bootcamp'), findsOneWidget);
    expect(find.text('UI/UX Design Masterclass'), findsOneWidget);
    expect(find.text('₹3,498'), findsWidgets); // total + checkout
    expect(find.text('Discount'), findsNothing);

    // Delete the first course → its price leaves the total.
    await tester.tap(find.byIcon(Icons.delete_outline_rounded).first);
    await tester.pumpAndSettle();

    expect(find.text('Complete Web Development Bootcamp'), findsNothing);
    expect(find.text('UI/UX Design Masterclass'), findsOneWidget);
    expect(find.text('₹3,498'), findsNothing);
    expect(find.text('₹1,499'), findsWidgets);
    expect(find.text('Discount'), findsNothing);
  });

  testWidgets('"Clear all" empties the cart', (tester) async {
    addToCart(courseById('c1')); // ₹1,999
    addToCart(courseById('c4')); // ₹1,299

    await tester.pumpWidget(const MaterialApp(home: CartPage()));
    await tester.pump();

    expect(find.text('₹3,298'), findsWidgets);
    expect(find.text('Discount'), findsNothing);

    await tester.tap(find.text('Clear all'));
    await tester.pumpAndSettle();

    expect(find.text('Your cart is empty'), findsOneWidget);
    expect(find.text('Total'), findsNothing);
    expect(find.text('Discount'), findsNothing);
    expect(isInCart(courseById('c1')), isFalse);
  });

  testWidgets('Home header cart icon opens the cart', (tester) async {
    ignoreOverflowErrors();

    await tester.pumpWidget(const MaterialApp(home: index()));
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.byIcon(Icons.shopping_bag_outlined));
    await tester.pumpAndSettle();

    expect(find.byType(CartPage), findsOneWidget);
    expect(find.text('Your cart is empty'), findsOneWidget);
  });
}
