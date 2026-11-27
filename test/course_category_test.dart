import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:think_lab/course_category.dart';

void main() {
  test(
    'category Firestore fields round-trip with the selected icon and style',
    () {
      final category = CourseCategory(
        id: 'category-1',
        name: ' Photography ',
        description: 'Photo editing and camera skills',
        icon: Icons.camera_alt_outlined,
        iconBackground: const Color(0xFFE6E2FF),
        iconColor: const Color(0xFF5144D8),
        isActive: false,
        isPublic: false,
        tags: const ['Editing', 'Lighting'],
      );

      final restored = CourseCategory.fromMap(category.id, category.toMap());

      expect(restored.id, 'category-1');
      expect(restored.name, 'Photography');
      expect(restored.description, category.description);
      expect(restored.icon, Icons.camera_alt_outlined);
      expect(restored.iconBackground, const Color(0xFFE6E2FF));
      expect(restored.iconColor, const Color(0xFF5144D8));
      expect(restored.isActive, isFalse);
      expect(restored.isPublic, isFalse);
      expect(restored.tags, ['Editing', 'Lighting']);
      expect(category.toMap()['nameLowercase'], 'photography');
    },
  );
}
