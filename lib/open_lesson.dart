import 'package:flutter/material.dart';

import 'course.dart';
import 'lesson_page.dart';
import 'progress.dart';
import 'purchases.dart';

/// Opens THIS user's learning content for [course]:
///
/// * the lesson they stopped at (`resumePoint`, e.g. "Module 2 → Lesson 5"),
/// * or — when nothing was watched yet — the very first lesson.
///
/// The course must be purchased (and actually have lessons); otherwise
/// nothing is pushed and `false` is returned so the caller can keep its
/// existing fallback (usually opening the course details page).
///
/// One helper for every entry point — the home "Continue Learning" card, the
/// details page's "Start Learning" and My Learning's "Continue" — so resume
/// behaves identically everywhere.
bool openCourseLesson(BuildContext context, Course course) {
  String? targetModule;
  String? targetLesson;

  final point = resumePoint(course);
  if (point != null &&
      moduleIndexOf(course, point.$1) >= 0 &&
      lessonIndexOf(course, point.$1, point.$2) >= 0) {
    // Remembered lesson — "Module 2 → Lesson 5".
    targetModule = point.$1;
    targetLesson = point.$2;
  } else if (course.modules.isNotEmpty &&
      course.modules.first.lessons.isNotEmpty) {
    // Nothing watched yet → start at the first lesson.
    targetModule = moduleIdFor(course, 0);
    targetLesson = lessonIdFor(course, 0, 0);
  }

  if (targetModule == null || targetLesson == null || !isPurchased(course)) {
    return false;
  }

  // Open the lesson the user stopped at (or the first one if new).
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => LessonPage(
        courseId: course.id,
        moduleId: targetModule!,
        lessonId: targetLesson!,
      ),
    ),
  );
  return true;
}
