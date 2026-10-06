import 'package:flutter/material.dart';

import 'course.dart';
import 'lesson_page.dart';
import 'purchases.dart';
import 'progress.dart';

const _heading = Color(0xFF2B2356);
const _muted = Color(0xFF9A96B8);
const _purple = Color(0xFF6B45F0);
const _green = Color(0xFF25A55F);

/// The module learning screen: the COMPLETE lesson list of one module.
///
/// The page only receives ids — `courseId` + `moduleId` — so the same screen
/// works for every module of every course:
///
/// ```dart
/// ModuleDetailPage(courseId: 'c5', moduleId: 'c5-module-1')
/// ```
///
/// Lesson names, counts, durations and progress are all read from the course
/// data; nothing here is hardcoded.
// =====================================================
// MODULE PAGE
// Shows the lesson list of one module with its progress.
// =====================================================
class ModuleDetailPage extends StatelessWidget {
  final String courseId;
  final String moduleId;

  const ModuleDetailPage({
    super.key,
    required this.courseId,
    required this.moduleId,
  });

  void _openLesson(BuildContext context, String lessonId) {
    // User taps a lesson -> Open the video learning page.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LessonPage(
          courseId: courseId,
          moduleId: moduleId,
          lessonId: lessonId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final course = courseById(courseId);
    final mIndex = moduleIndexOf(course, moduleId);

    if (mIndex < 0) {
      return const Scaffold(
        backgroundColor: Color(0xFFF6F5FB),
        body: Center(child: Text('Module not found')),
      );
    }

    final module = course.modules[mIndex];
    final unlocked = isPurchased(course);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F5FB),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(context, mIndex, module),
            if (!unlocked) _lockBanner(),
            Expanded(
              child: ValueListenableBuilder<Set<String>>(
                // Rebuilds whenever a lesson is completed in this module.
                valueListenable: completedLessons,
                builder: (context, done, _) {
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    children: [
                      _progressCard(mIndex, done),
                      const SizedBox(height: 14),
                      if (module.lessons.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 30),
                          child: Text(
                            'No lessons in this module yet.',
                            style: TextStyle(color: _muted, fontSize: 14),
                          ),
                        )
                      else
                        for (var i = 0; i < module.lessons.length; i++)
                          _lessonCard(context, course, mIndex, i, done),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------- header

  Widget _header(BuildContext context, int mIndex, Module module) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: _heading,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Module ${mIndex + 1}',
                  style: const TextStyle(
                    color: _purple,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  moduleTitle(module.title),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _heading,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                // Calculated: '9 Lessons • 1h 45m'.
                Text(
                  moduleHeadline(module),
                  style: const TextStyle(color: _muted, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _lockBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4DE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.lock_outline_rounded, color: Color(0xFF8A6412), size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Purchase this course to watch its lessons.',
              style: TextStyle(
                color: Color(0xFF8A6412),
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------- progress

  /// Module progress — `3 / 9 lessons completed` + `33%`, calculated live.
  Widget _progressCard(int mIndex, Set<String> done) {
    final module = courseById(courseId).modules[mIndex];
    final total = module.lessons.length;
    var completed = 0;
    for (var i = 0; i < total; i++) {
      if (done.contains(lessonIdFor(courseById(courseId), mIndex, i))) {
        completed++;
      }
    }
    final percent = progressPercent(completed, total);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  progressLabel(completed, total),
                  style: const TextStyle(color: _muted, fontSize: 13),
                ),
              ),
              Text(
                '$percent%',
                style: const TextStyle(
                  color: _purple,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : completed / total,
              minHeight: 8,
              color: _purple,
              backgroundColor: const Color(0xFFEDEAF8),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------ lesson rows

  Widget _lessonCard(
    BuildContext context,
    Course course,
    int mIndex,
    int lessonIndex,
    Set<String> done,
  ) {
    final module = course.modules[mIndex];
    final lesson = module.lessons[lessonIndex];
    final id = lessonIdFor(course, mIndex, lessonIndex);
    final completed = done.contains(id);
    final watched = videoPositionFor(id);
    final duration = durationInSeconds(lesson.duration);
    final watchedPercent = duration > 0
        ? progressPercent(watched, duration)
        : 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _openLesson(context, id),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: completed
                      ? const Color(0xFFE4F7EC)
                      : _purple.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  completed ? Icons.check_rounded : Icons.play_arrow_rounded,
                  color: completed ? _green : _purple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: completed ? _muted : _heading,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          lesson.duration,
                          style: const TextStyle(color: _muted, fontSize: 12),
                        ),
                        if (watched > 0 && !completed) ...[
                          const SizedBox(width: 6),
                          Text(
                            '• $watchedPercent% watched',
                            style: const TextStyle(
                              color: _purple,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, color: _muted, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
