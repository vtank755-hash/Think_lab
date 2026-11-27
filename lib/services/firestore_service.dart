import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Central Firestore access point for the ThinkLab app.
///
/// Use this service to keep collection names and common database behavior in one
/// place so the app can connect to Firestore dynamically.
class FirestoreService {
  FirestoreService._();

  static final FirestoreService instance = FirestoreService._();

  FirebaseFirestore get db => FirebaseFirestore.instance;
  FirebaseAuth get auth => FirebaseAuth.instance;

  // Core collections
  CollectionReference<Map<String, dynamic>> get users => db.collection('users');
  CollectionReference<Map<String, dynamic>> get admins => db.collection('admins');
  CollectionReference<Map<String, dynamic>> get courses => db.collection('courses');
  CollectionReference<Map<String, dynamic>> get categories => db.collection('categories');
  CollectionReference<Map<String, dynamic>> get courseQuizzes =>
      db.collection('course_quizzes');
  CollectionReference<Map<String, dynamic>> get orders => db.collection('orders');
  CollectionReference<Map<String, dynamic>> get enrollments =>
      db.collection('enrollments');
  CollectionReference<Map<String, dynamic>> get activityLogs =>
      db.collection('activity_logs');

  // User-scoped subcollections
  CollectionReference<Map<String, dynamic>> userProgress(String userId) =>
      users.doc(userId).collection('progress');

  CollectionReference<Map<String, dynamic>> userWishlist(String userId) =>
      users.doc(userId).collection('wishlist');

  CollectionReference<Map<String, dynamic>> userCart(String userId) =>
      users.doc(userId).collection('cart');

  /// Creates or merges a document with server timestamps.
  Future<void> setWithTimestamps(
    DocumentReference<Map<String, dynamic>> ref,
    Map<String, dynamic> data, {
    bool merge = true,
    bool isNew = false,
  }) {
    final payload = <String, dynamic>{
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
      if (isNew) 'createdAt': FieldValue.serverTimestamp(),
    };
    return ref.set(payload, SetOptions(merge: merge));
  }

  /// Deletes a document if it exists.
  Future<void> deleteIfExists(DocumentReference<Map<String, dynamic>> ref) async {
    final snapshot = await ref.get();
    if (snapshot.exists) await ref.delete();
  }
}
