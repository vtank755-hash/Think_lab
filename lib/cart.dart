import 'package:flutter/foundation.dart';

import 'course.dart';

/// Course ids currently in the cart, shared by every screen so that
/// "Add to Cart" on the details page and the cart page always agree.
final cartIds = ValueNotifier<Set<String>>(<String>{});

/// Whether [course] is already in the cart.
bool isInCart(Course course) => cartIds.value.contains(course.id);

/// Adds [course] to the cart (no-op when it is already there).
void addToCart(Course course) {
  if (cartIds.value.contains(course.id)) return;
  final next = Set<String>.of(cartIds.value);
  next.add(course.id);
  cartIds.value = next;
}

/// Removes [course] from the cart.
void removeFromCart(Course course) {
  final next = Set<String>.of(cartIds.value);
  next.remove(course.id);
  cartIds.value = next;
}

/// Empties the cart ("Clear all").
void clearCart() => cartIds.value = const <String>{};

/// The cart contents, in catalogue order.
List<Course> get cartCourses =>
    allCourses.where((c) => cartIds.value.contains(c.id)).toList();

/// Turns a price string into whole rupees, e.g. `₹1,999` -> `1999`.
int priceInRupees(String price) =>
    int.tryParse(price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

/// The cart has no discount: the total IS the price of every item added up.
int get cartTotal =>
    cartCourses.fold(0, (sum, course) => sum + priceInRupees(course.price));

/// Formats rupees with thousands separators: `1898` -> `₹1,898`.
String formatRupees(int amount) {
  final digits = amount.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return '₹$buffer';
}
