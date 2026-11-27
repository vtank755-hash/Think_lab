import 'package:flutter/foundation.dart';

import 'services/firestore_service.dart';

class AppOrder {
  final String id;
  final String course;
  final String customer;
  final String date;
  final String method;
  final String status;
  final String amount;
  final String? userId;
  final String? courseId;

  const AppOrder({
    required this.id,
    required this.course,
    required this.customer,
    required this.date,
    required this.method,
    required this.status,
    required this.amount,
    this.userId,
    this.courseId,
  });

  Map<String, dynamic> toMap() => {
    'orderNumber': id,
    'course': course,
    'customer': customer,
    'date': date,
    'method': method,
    'status': status,
    'amount': amount,
    'userId': userId,
    'courseId': courseId,
  };

  factory AppOrder.fromMap(String docId, Map<String, dynamic> map) => AppOrder(
    id: (map['orderNumber'] as String?) ?? docId,
    course: map['course'] as String? ?? '',
    customer: map['customer'] as String? ?? '',
    date: map['date'] as String? ?? '',
    method: map['method'] as String? ?? '',
    status: map['status'] as String? ?? 'Pending',
    amount: map['amount'] as String? ?? '₹0',
    userId: map['userId'] as String?,
    courseId: map['courseId'] as String?,
  );
}

abstract interface class OrderRepository {
  Stream<List<AppOrder>> watchOrders();
  Future<void> saveOrder(AppOrder order);
}

OrderRepository orderRepository = FirestoreOrderRepository();

class FirestoreOrderRepository implements OrderRepository {
  FirestoreService get _service => FirestoreService.instance;

  @override
  Stream<List<AppOrder>> watchOrders() => _service.orders
      .orderBy('updatedAt', descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => AppOrder.fromMap(doc.id, doc.data()))
            .toList(),
      )
      .handleError((Object error) {
        debugPrint('Order stream error: $error');
      });

  @override
  Future<void> saveOrder(AppOrder order) async {
    await _service.setWithTimestamps(
      _service.orders.doc(order.id),
      order.toMap(),
      isNew: true,
    );
  }
}
