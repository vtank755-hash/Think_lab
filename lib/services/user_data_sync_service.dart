import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../course.dart';
import '../progress.dart';
import '../purchases.dart';
import '../session.dart';
import 'firestore_service.dart';

/// Syncs user-scoped app state with Firestore.
///
/// This keeps the local ValueNotifier-based state working while persisting data
/// dynamically in Firestore.
class UserDataSyncService {
  UserDataSyncService._();

  static final UserDataSyncService instance = UserDataSyncService._();
  final FirestoreService _service = FirestoreService.instance;
  bool _hooksInstalled = false;

  void init() {
    if (_hooksInstalled) return;
    _hooksInstalled = true;
    onWishlistChanged = (userId, courseIds) {
      if (userId.trim().isEmpty || userId == 'guest') return;
      saveWishlist(userId, courseIds);
    };
    onCoursePurchased = (userId, courseId) {
      if (userId.trim().isEmpty || userId == 'guest') return;
      savePurchase(userId, courseId);
    };
    onProgressChanged = (userId, courseId) {
      if (userId.trim().isEmpty || userId == 'guest') return;
      final course = courseById(courseId);
      if (course.id != courseId) return;
      saveProgress(userId, course);
    };
  }

  String? get _uid {
    final id = currentUser.value.trim();
    if (id.isEmpty || id == 'guest') return null;
    return id;
  }

  Future<void> syncCurrentUser() async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await Future.wait([
        _loadWishlist(uid),
        _loadPurchases(uid),
        _loadProgress(uid),
      ]);
    } catch (e) {
      debugPrint('User data sync failed: $e');
    }
  }

  Future<void> _loadWishlist(String uid) async {
    final snapshot = await _service.userWishlist(uid).get();
    if (snapshot.docs.isEmpty) return;
    final ids = snapshot.docs.map((d) => d.id).toSet();
    wishlistOf(uid).value = ids;
  }

  Future<void> _loadPurchases(String uid) async {
    final snapshot = await _service.userProgress(uid).get();
    // Purchases are stored as enrolled course IDs in progress docs with enrolled=true,
    // and also in enrollments collection. We'll also check top-level enrollments by userId.
    final enrolledIds = <String>{};
    for (final doc in snapshot.docs) {
      final data = doc.data();
      if (data['enrolled'] == true || data['purchased'] == true) {
        enrolledIds.add(doc.id);
      }
    }
    final enrollments = await _service.enrollments
        .where('userId', isEqualTo: uid)
        .get();
    for (final doc in enrollments.docs) {
      final courseId = doc.data()['courseId'] as String?;
      if (courseId != null && courseId.isNotEmpty) enrolledIds.add(courseId);
    }
    if (enrolledIds.isNotEmpty) {
      purchasesOf(uid).value = enrolledIds;
    }
  }

  Future<void> _loadProgress(String uid) async {
    final snapshot = await _service.userProgress(uid).get();
    final completed = <String>{};
    final resume = <String, String>{};
    final video = <String, int>{};

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final completedLessons = List<String>.from(
        data['completedLessons'] as List? ?? const [],
      );
      completed.addAll(completedLessons);
      final resumePoint = data['resumePoint'] as String?;
      if (resumePoint != null && resumePoint.isNotEmpty) {
        resume[doc.id] = resumePoint;
      }
      final positions = Map<String, dynamic>.from(
        data['videoPositions'] as Map? ?? const {},
      );
      for (final entry in positions.entries) {
        final seconds = entry.value;
        if (seconds is num) video[entry.key] = seconds.toInt();
      }
    }

    if (completed.isNotEmpty) completedOf(uid).value = completed;
    if (resume.isNotEmpty) resumeOf(uid).value = resume;
    if (video.isNotEmpty) videoPositionsOf(uid).value = video;
  }

  Future<void> saveWishlist(String userId, Set<String> courseIds) async {
    try {
      final col = _service.userWishlist(userId);
      final existing = await col.get();
      final batch = _service.db.batch();
      for (final doc in existing.docs) {
        if (!courseIds.contains(doc.id)) batch.delete(doc.reference);
      }
      for (final id in courseIds) {
        batch.set(col.doc(id), {
          'courseId': id,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Wishlist save failed: $e');
    }
  }

  Future<void> savePurchase(String userId, String courseId) async {
    try {
      await _service.setWithTimestamps(
        _service.userProgress(userId).doc(courseId),
        {'enrolled': true, 'purchased': true, 'courseId': courseId},
        isNew: true,
      );
      await _service.setWithTimestamps(
        _service.enrollments.doc('${userId}_$courseId'),
        {
          'userId': userId,
          'courseId': courseId,
          'status': 'Active',
          'completion': 0,
          'progressText': 'Enrolled',
          'enrolledDate': DateTime.now().toIso8601String(),
          'scoreLabel': 'Avg.',
          'score': '0%',
          'name': userProfile.value.name,
          'email': userProfile.value.email,
          'initials': _initials(userProfile.value.name),
          'avatarBackground': 0xFFE9EDFF,
        },
        isNew: true,
      );
    } catch (e) {
      debugPrint('Purchase save failed: $e');
    }
  }

  Future<void> saveProgress(String userId, Course course) async {
    try {
      final completed = <String>[];
      for (var m = 0; m < course.modules.length; m++) {
        for (var l = 0; l < course.modules[m].lessons.length; l++) {
          final lid = lessonIdFor(course, m, l);
          if (isLessonCompleted(lid, userId: userId)) completed.add(lid);
        }
      }
      final resume = resumePoint(course, userId: userId);
      final videoPositions = <String, int>{};
      for (var m = 0; m < course.modules.length; m++) {
        for (var l = 0; l < course.modules[m].lessons.length; l++) {
          final lid = lessonIdFor(course, m, l);
          final pos = videoPositionFor(lid, userId: userId);
          if (pos > 0) videoPositions[lid] = pos;
        }
      }
      final done = completedInCourse(course, userId: userId);
      final total = courseLessonCount(course);
      await _service.setWithTimestamps(
        _service.userProgress(userId).doc(course.id),
        {
          'courseId': course.id,
          'completedLessons': completed,
          'resumePoint': resume == null ? null : '${resume.$1}/${resume.$2}',
          'videoPositions': videoPositions,
          'completion': progressPercent(done, total),
          'progressText': progressLabel(done, total),
        },
        isNew: true,
      );
    } catch (e) {
      debugPrint('Progress save failed: $e');
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    final chars = parts.take(2).map((p) => p[0].toUpperCase()).join();
    return chars.isEmpty ? 'U' : chars;
  }
}
