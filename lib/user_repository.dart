import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'services/firestore_service.dart';

class ManagedUserRecord {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String bio;
  final String avatar;
  final String role;
  final bool isBlocked;
  final bool isFeatured;
  final DateTime? createdAt;

  const ManagedUserRecord({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.bio,
    required this.avatar,
    required this.role,
    required this.isBlocked,
    required this.isFeatured,
    this.createdAt,
  });

  factory ManagedUserRecord.fromMap(String id, Map<String, dynamic> data) {
    final created = data['createdAt'];
    return ManagedUserRecord(
      id: id,
      name: (data['name'] as String?) ?? '',
      email: (data['email'] as String?) ?? '',
      phone: (data['phone'] as String?) ?? '',
      bio: (data['bio'] as String?) ?? '',
      avatar: (data['avatar'] as String?) ?? 'assets/images/profile/avatar.jpg',
      role: (data['role'] as String?) ?? 'Learner / Student',
      isBlocked: data['isBlocked'] as bool? ?? false,
      isFeatured: data['isFeatured'] as bool? ?? false,
      createdAt: created is Timestamp ? created.toDate() : null,
    );
  }

  String get publicId {
    final short = id.length > 6 ? id.substring(0, 6).toUpperCase() : id.toUpperCase();
    return 'USR-$short';
  }

  String get joinedLabel {
    final dt = createdAt;
    if (dt == null) return 'Recently';
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[dt.month - 1]} ${dt.year}';
  }
}

abstract interface class UserRepository {
  Stream<List<ManagedUserRecord>> watchUsers();
  Future<String> addUser({
    required String name,
    required String email,
    required String phone,
    required String role,
  });
  Future<void> updateUser(String id, Map<String, dynamic> data);
  Future<void> deleteUser(String id);
}

UserRepository userRepository = FirestoreUserRepository();

class FirestoreUserRepository implements UserRepository {
  FirestoreService get _service => FirestoreService.instance;

  @override
  Stream<List<ManagedUserRecord>> watchUsers() {
    return _service.users.snapshots().map((snapshot) {
      final users = snapshot.docs
          .map((doc) => ManagedUserRecord.fromMap(doc.id, doc.data()))
          .toList();
      users.sort((a, b) {
        final ad = a.createdAt;
        final bd = b.createdAt;
        if (ad == null && bd == null) return a.name.compareTo(b.name);
        if (ad == null) return 1;
        if (bd == null) return -1;
        return bd.compareTo(ad);
      });
      return users;
    }).handleError((Object error) {
      debugPrint('User stream error: $error');
    });
  }

  @override
  Future<String> addUser({
    required String name,
    required String email,
    required String phone,
    required String role,
  }) async {
    final ref = _service.users.doc();
    await ref.set({
      'name': name,
      'email': email,
      'phone': phone,
      'bio': '',
      'avatar': 'assets/images/profile/avatar.jpg',
      'role': role,
      'isBlocked': false,
      'isFeatured': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  @override
  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    await _service.users.doc(id).set({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> deleteUser(String id) => _service.users.doc(id).delete();
}
