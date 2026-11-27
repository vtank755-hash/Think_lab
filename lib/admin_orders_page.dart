import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'order_repository.dart';
import 'services/firestore_service.dart';

const _pageBackground = Color(0xFFF3F0FF);
const _headingColor = Color(0xFF211B50);
const _mutedColor = Color(0xFF8586B5);
const _purple = Color(0xFF4F42E8);

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  static const _demoOrders = [
    AppOrder(
      id: 'ORD-8842',
      course: 'Web Dev Bootcamp',
      customer: 'Aarav Sharma',
      date: '12 Jun 2024',
      method: 'UPI',
      status: 'Paid',
      amount: '₹1,999',
    ),
    AppOrder(
      id: 'ORD-8841',
      course: 'UI/UX Masterclass',
      customer: 'Sneha Patel',
      date: '11 Jun 2024',
      method: 'Google Pay',
      status: 'Pending',
      amount: '₹1,499',
    ),
    AppOrder(
      id: 'ORD-8840',
      course: 'React JS Zero to Hero',
      customer: 'Rahul Verma',
      date: '10 Jun 2024',
      method: 'Card',
      status: 'Failed',
      amount: '₹2,499',
    ),
    AppOrder(
      id: 'ORD-8839',
      course: 'Digital Marketing Guide',
      customer: 'Kavya Reddy',
      date: '09 Jun 2024',
      method: 'PhonePe',
      status: 'Paid',
      amount: '₹999',
    ),
  ];

  Stream<List<AppOrder>>? _ordersStream;

  @override
  void initState() {
    super.initState();
    _ordersStream = _tryCreateOrdersStream();
  }

  Stream<List<AppOrder>>? _tryCreateOrdersStream() {
    try {
      FirebaseFirestore.instance;
      return FirestoreService.instance.orders
          .orderBy('updatedAt', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => AppOrder.fromMap(doc.id, doc.data()))
                .toList(),
          );
    } catch (_) {
      return null;
    }
  }

  List<AppOrder> _filteredOrders(List<AppOrder> orders) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return orders;
    return orders.where((order) {
      return order.id.toLowerCase().contains(query) ||
          order.course.toLowerCase().contains(query) ||
          order.customer.toLowerCase().contains(query) ||
          order.status.toLowerCase().contains(query) ||
          order.method.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('admin-orders-page'),
      backgroundColor: _pageBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Orders & Payments',
                style: TextStyle(
                  color: _headingColor,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                key: const ValueKey('admin-orders-search'),
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: 'Search orders...',
                  hintStyle: const TextStyle(
                    color: Color(0xFF8186BF),
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: _mutedColor,
                    size: 21,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: _ordersStream == null
                    ? _buildList(_filteredOrders(_demoOrders))
                    : StreamBuilder<List<AppOrder>>(
                        stream: _ordersStream,
                        builder: (context, snapshot) {
                          final source = (snapshot.hasData &&
                                  snapshot.data!.isNotEmpty)
                              ? snapshot.data!
                              : (snapshot.connectionState ==
                                          ConnectionState.waiting ||
                                      snapshot.hasError ||
                                      !snapshot.hasData)
                                  ? _demoOrders
                                  : _demoOrders;
                          final orders = _filteredOrders(source);
                          return _buildList(orders);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(List<AppOrder> orders) {
    if (orders.isEmpty) {
      return const Center(
        child: Text(
          'No orders found.',
          style: TextStyle(color: _mutedColor),
        ),
      );
    }
    return ListView.separated(
      key: const ValueKey('admin-orders-list'),
      padding: const EdgeInsets.only(bottom: 12),
      itemCount: orders.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) => _OrderCard(order: orders[index]),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final AppOrder order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (order.status) {
      'Paid' => const Color(0xFF087E59),
      'Pending' => const Color(0xFFB36B00),
      _ => const Color(0xFFC63848),
    };
    final statusBackground = switch (order.status) {
      'Paid' => const Color(0xFFD8F8EA),
      'Pending' => const Color(0xFFFFF1C9),
      _ => const Color(0xFFFFE3E5),
    };
    final methodIcon = switch (order.method) {
      'UPI' => Icons.qr_code_2_rounded,
      'Google Pay' => Icons.account_balance_wallet_outlined,
      'PhonePe' => Icons.account_balance_wallet_outlined,
      _ => Icons.credit_card_outlined,
    };

    return Container(
      key: ValueKey('admin-order-${order.id}'),
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF40348A).withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '#${order.id}',
                  style: const TextStyle(
                    color: _mutedColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  order.status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            order.course,
            style: const TextStyle(
              color: _headingColor,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '${order.customer} · ${order.date}',
            style: const TextStyle(color: _mutedColor, fontSize: 12),
          ),
          const SizedBox(height: 9),
          const Divider(height: 1, color: Color(0xFFF0EFF8)),
          const SizedBox(height: 7),
          Row(
            children: [
              Icon(methodIcon, size: 15, color: _purple),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  order.method,
                  style: const TextStyle(color: _mutedColor, fontSize: 12),
                ),
              ),
              Text(
                order.amount,
                style: const TextStyle(
                  color: _purple,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
