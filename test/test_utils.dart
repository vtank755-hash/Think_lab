import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:think_lab/category_repository.dart';
import 'package:think_lab/course_category.dart';

class FakeCategoryRepository implements CategoryRepository {
  FakeCategoryRepository([List<CourseCategory>? categories])
    : _categories = List.of(categories ?? testCategories);

  List<CourseCategory> _categories;
  final StreamController<List<CourseCategory>> _updates =
      StreamController<List<CourseCategory>>.broadcast();

  @override
  Stream<List<CourseCategory>> watchPublicCategories() =>
      _watch(publicOnly: true);

  @override
  Stream<List<CourseCategory>> watchAdminCategories() => _watch();

  Stream<List<CourseCategory>> _watch({bool publicOnly = false}) =>
      Stream.multi((controller) {
        List<CourseCategory> visible() => _categories
            .where(
              (category) =>
                  !publicOnly || (category.isPublic && category.isActive),
            )
            .toList();

        controller.add(visible());
        final subscription = _updates.stream.listen(
          (_) => controller.add(visible()),
          onError: (Object error, StackTrace stackTrace) =>
              controller.addError(error, stackTrace),
        );
        controller.onCancel = subscription.cancel;
      });

  @override
  Future<bool> isNameAvailable(String name, {String? excludingId}) async =>
      !_categories.any(
        (category) =>
            category.id != excludingId &&
            category.name.trim().toLowerCase() == name.trim().toLowerCase(),
      );

  @override
  Future<void> save(CourseCategory category) async {
    if (!await isNameAvailable(category.name, excludingId: category.id)) {
      throw const DuplicateCategoryException();
    }
    _categories = [
      for (final existing in _categories)
        if (existing.id != category.id) existing,
      category,
    ];
    _updates.add(_categories);
  }

  @override
  Future<void> delete(String id) async {
    _categories = _categories.where((category) => category.id != id).toList();
    _updates.add(_categories);
  }

  Future<void> dispose() => _updates.close();
}

final testCategories = [
  CourseCategory(
    id: 'CAT-0192',
    name: 'Development',
    description:
        'Software engineering, web development, cloud computing, and programming languages.',
    icon: Icons.terminal_rounded,
    iconBackground: const Color(0xFFE6E2FF),
    iconColor: const Color(0xFF5144D8),
    tags: ['Python', 'TypeScript', 'Rust'],
  ),
  CourseCategory(
    id: 'CAT-0193',
    name: 'Design',
    icon: Icons.palette_outlined,
    iconBackground: const Color(0xFFEEDFFF),
    iconColor: const Color(0xFF7B20E8),
  ),
  CourseCategory(
    id: 'CAT-0194',
    name: 'Marketing',
    icon: Icons.campaign_outlined,
    iconBackground: const Color(0xFFFFDEDA),
    iconColor: const Color(0xFFD21B1B),
  ),
  CourseCategory(
    id: 'CAT-0195',
    name: 'Business',
    icon: Icons.trending_up_rounded,
    iconBackground: const Color(0xFFB7F0FF),
    iconColor: const Color(0xFF006B82),
  ),
  CourseCategory(
    id: 'CAT-0196',
    name: 'IT & Software',
    icon: Icons.dns_outlined,
    iconBackground: const Color(0xFFDCE2FF),
    iconColor: const Color(0xFF4020CF),
  ),
  CourseCategory(
    id: 'CAT-0197',
    name: 'Personal Development',
    icon: Icons.lightbulb_outline_rounded,
    iconBackground: const Color(0xFFDCC3FF),
    iconColor: const Color(0xFF4A168B),
  ),
];

/// The fixed-width course cards overflow a little under the test font's
/// metrics; that is unrelated to the behaviour being checked here.
void ignoreOverflowErrors() {
  final previousOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.exception.toString().contains('overflowed')) return;
    previousOnError?.call(details);
  };
  addTearDown(() => FlutterError.onError = previousOnError);
}
