import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'course.dart';
import 'services/firestore_service.dart';

abstract interface class CourseRepository {
  Stream<List<Course>> watchCourses();
  Stream<List<Course>> watchPublishedCourses();
  Future<void> saveCourse(Course course);
  Future<void> deleteCourse(String id);
  Future<void> seedBuiltInCoursesIfEmpty();
}

CourseRepository courseRepository = FirestoreCourseRepository();

class FirestoreCourseRepository implements CourseRepository {
  FirestoreService get _service => FirestoreService.instance;

  CollectionReference<Map<String, dynamic>> get _courses => _service.courses;

  @override
  Stream<List<Course>> watchCourses() => _courses.snapshots().map((snapshot) {
    final courses = snapshot.docs
        .map((doc) => Course.fromMap(doc.data(), id: doc.id))
        .toList();
    courses.sort((a, b) => a.title.compareTo(b.title));
    return courses;
  });

  @override
  Stream<List<Course>> watchPublishedCourses() =>
      _courses.where('isPublished', isEqualTo: true).snapshots().map((snapshot) {
        final courses = snapshot.docs
            .map((doc) => Course.fromMap(doc.data(), id: doc.id))
            .toList();
        courses.sort((a, b) => a.title.compareTo(b.title));
        return courses;
      });

  @override
  Future<void> saveCourse(Course course) async {
    final ref = _courses.doc(course.id);
    final existing = await ref.get();
    await ref.set({
      ...course.toMap(),
      'isPublished': true,
      'updatedAt': FieldValue.serverTimestamp(),
      if (!existing.exists) 'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> deleteCourse(String id) => _courses.doc(id).delete();

  @override
  Future<void> seedBuiltInCoursesIfEmpty() async {
    final existing = await _courses.limit(1).get();
    if (existing.docs.isNotEmpty) return;
    final batch = _service.db.batch();
    for (final course in allCourses) {
      batch.set(_courses.doc(course.id), {
        ...course.toMap(),
        'isPublished': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    await batch.commit();
    debugPrint('Seeded ${allCourses.length} built-in courses to Firestore.');
  }
}
