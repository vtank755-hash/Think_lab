import 'package:flutter/foundation.dart';

import 'services/firestore_service.dart';

class AppEnrollment {
  final String id;
  final String name;
  final String email;
  final String initials;
  final int avatarBackground;
  final String status;
  final int completion;
  final String progressText;
  final String enrolledDate;
  final String scoreLabel;
  final String score;
  final String? note;
  final String? courseId;
  final String? userId;

  const AppEnrollment({
    required this.id,
    required this.name,
    required this.email,
    required this.initials,
    required this.avatarBackground,
    required this.status,
    required this.completion,
    required this.progressText,
    required this.enrolledDate,
    required this.scoreLabel,
    required this.score,
    this.note,
    this.courseId,
    this.userId,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'email': email,
    'initials': initials,
    'avatarBackground': avatarBackground,
    'status': status,
    'completion': completion,
    'progressText': progressText,
    'enrolledDate': enrolledDate,
    'scoreLabel': scoreLabel,
    'score': score,
    'note': note,
    'courseId': courseId,
    'userId': userId,
  };

  factory AppEnrollment.fromMap(String docId, Map<String, dynamic> map) =>
      AppEnrollment(
        id: docId,
        name: map['name'] as String? ?? '',
        email: map['email'] as String? ?? '',
        initials: map['initials'] as String? ?? '',
        avatarBackground:
            (map['avatarBackground'] as num?)?.toInt() ?? 0xFFE9EDFF,
        status: map['status'] as String? ?? 'Active',
        completion: (map['completion'] as num?)?.toInt() ?? 0,
        progressText: map['progressText'] as String? ?? '',
        enrolledDate: map['enrolledDate'] as String? ?? '',
        scoreLabel: map['scoreLabel'] as String? ?? 'Avg.',
        score: map['score'] as String? ?? '0%',
        note: map['note'] as String?,
        courseId: map['courseId'] as String?,
        userId: map['userId'] as String?,
      );
}

abstract interface class EnrollmentRepository {
  Stream<List<AppEnrollment>> watchEnrollments();
  Future<void> saveEnrollment(AppEnrollment enrollment);
}

EnrollmentRepository enrollmentRepository = FirestoreEnrollmentRepository();

class FirestoreEnrollmentRepository implements EnrollmentRepository {
  FirestoreService get _service => FirestoreService.instance;

  @override
  Stream<List<AppEnrollment>> watchEnrollments() => _service.enrollments
      .orderBy('updatedAt', descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => AppEnrollment.fromMap(doc.id, doc.data()))
            .toList(),
      )
      .handleError((Object error) {
        debugPrint('Enrollment stream error: $error');
      });

  @override
  Future<void> saveEnrollment(AppEnrollment enrollment) async {
    await _service.setWithTimestamps(
      _service.enrollments.doc(enrollment.id),
      enrollment.toMap(),
      isNew: true,
    );
  }
}
