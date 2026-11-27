fimport 'package:cloud_firestore/cloud_firestore.dart';

import 'course_category.dart';

abstract interface class CategoryRepository {
  Stream<List<CourseCategory>> watchPublicCategories();

  Stream<List<CourseCategory>> watchAdminCategories();

  Future<bool> isNameAvailable(String name, {String? excludingId});

  Future<void> save(CourseCategory category);

  Future<void> delete(String id);
}

CategoryRepository categoryRepository = FirestoreCategoryRepository();

class FirestoreCategoryRepository implements CategoryRepository {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _categories =>
      _firestore.collection('categories');

  @override
  Stream<List<CourseCategory>> watchPublicCategories() => _categories
      .where('isPublic', isEqualTo: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((document) => CourseCategory.fromMap(
              document.id,
              document.data(),
            ))
            .where((category) => category.isActive)
            .toList()
          ..sort((left, right) => left.name.compareTo(right.name)),
      );

  @override
  Stream<List<CourseCategory>> watchAdminCategories() => _categories
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((document) => CourseCategory.fromMap(
              document.id,
              document.data(),
            ))
            .toList()
          ..sort((left, right) => left.name.compareTo(right.name)),
      );

  @override
  Future<bool> isNameAvailable(String name, {String? excludingId}) async {
    final matches = await _categories
        .where('nameLowercase', isEqualTo: name.trim().toLowerCase())
        .get();
    return matches.docs.every((document) => document.id == excludingId);
  }

  @override
  Future<void> save(CourseCategory category) async {
    if (!await isNameAvailable(category.name, excludingId: category.id)) {
      throw const DuplicateCategoryException();
    }
    await _categories.doc(category.id).set({
      ...category.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> delete(String id) => _categories.doc(id).delete();
}

class DuplicateCategoryException implements Exception {
  const DuplicateCategoryException();
}
