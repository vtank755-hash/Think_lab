import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:think_lab/admin_dashboard.dart';
import 'package:think_lab/admin_orders_page.dart';

void main() {
  testWidgets('Revenue card opens Orders & Payments screen', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AdminDashboardPage()));
    await tester.ensureVisible(find.byKey(const ValueKey('stat-card-revenue')));
    await tester.tap(find.byKey(const ValueKey('stat-card-revenue')));
    await tester.pumpAndSettle();

    expect(find.byType(AdminOrdersPage), findsOneWidget);
    expect(find.text('Orders & Payments'), findsOneWidget);
  });

  testWidgets('Orders tab opens Orders & Payments screen', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AdminDashboardPage()));

    await tester.tap(find.byKey(const ValueKey('admin-nav-orders')));
    await tester.pumpAndSettle();

    expect(find.byType(AdminOrdersPage), findsOneWidget);
    expect(find.text('Orders & Payments'), findsOneWidget);
    expect(find.text('#ORD-8842'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Failed'), findsOneWidget);
  });

  testWidgets('Orders quick action opens Orders & Payments screen', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AdminDashboardPage()));
    final ordersAction = find.byKey(const ValueKey('quick-action-orders'));
    await tester.ensureVisible(ordersAction);
    await tester.tap(ordersAction);
    await tester.pumpAndSettle();

    expect(find.byType(AdminOrdersPage), findsOneWidget);
  });

  testWidgets('Orders search matches customers and payment methods', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AdminOrdersPage()));

    await tester.enterText(
      find.byKey(const ValueKey('admin-orders-search')),
      'PhonePe',
    );
    await tester.pumpAndSettle();

    expect(find.text('Digital Marketing Guide'), findsOneWidget);
    expect(find.text('Web Dev Bootcamp'), findsNothing);
  });
}
