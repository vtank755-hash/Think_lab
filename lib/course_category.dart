import 'package:flutter/material.dart';

class CourseCategory {
  static const supportedIcons = [
    Icons.terminal_rounded,
    Icons.palette_outlined,
    Icons.campaign_outlined,
    Icons.auto_awesome_outlined,
    Icons.storage_outlined,
    Icons.lightbulb_outline_rounded,
    Icons.camera_alt_outlined,
    Icons.menu_book_outlined,
    Icons.biotech_outlined,
    Icons.psychology_outlined,
    Icons.data_object_rounded,
    Icons.code_rounded,
    Icons.integration_instructions_outlined,
    Icons.schema_outlined,
    Icons.trending_up_rounded,
    Icons.dns_outlined,
  ];

  final String id;
  final String name;
  final String description;
  final int iconCodePoint;
  final int iconBackgroundValue;
  final int iconColorValue;
  final bool isActive;
  final bool isPublic;
  final List<String> tags;

  CourseCategory({
    required this.id,
    required this.name,
    this.description = '',
    required IconData icon,
    required Color iconBackground,
    required Color iconColor,
    this.isActive = true,
    this.isPublic = true,
    List<String> tags = const [],
  }) : iconCodePoint = icon.codePoint,
       iconBackgroundValue = iconBackground.toARGB32(),
       iconColorValue = iconColor.toARGB32(),
       tags = List.unmodifiable(tags);

  IconData get icon => _iconForCodePoint(iconCodePoint);

  static IconData _iconForCodePoint(int codePoint) => supportedIcons.firstWhere(
    (icon) => icon.codePoint == codePoint,
    orElse: () => throw FormatException('Unsupported category icon: $codePoint'),
  );

  Color get iconBackground => Color(iconBackgroundValue);

  Color get iconColor => Color(iconColorValue);

  Map<String, Object?> toMap() => {
    'name': name.trim(),
    'nameLowercase': name.trim().toLowerCase(),
    'description': description,
    'iconCodePoint': iconCodePoint,
    'iconBackground': iconBackgroundValue,
    'iconColor': iconColorValue,
    'isActive': isActive,
    'isPublic': isPublic,
    'tags': tags,
  };

  factory CourseCategory.fromMap(String id, Map<String, dynamic> data) =>
      CourseCategory(
        id: id,
        name: data['name'] as String,
        description: data['description'] as String? ?? '',
        icon: _iconForCodePoint(data['iconCodePoint'] as int),
        iconBackground: Color(data['iconBackground'] as int),
        iconColor: Color(data['iconColor'] as int),
        isActive: data['isActive'] as bool,
        isPublic: data['isPublic'] as bool,
        tags: List<String>.from(data['tags'] as List),
      );
}
