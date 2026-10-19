import 'package:flutter/material.dart';

import '../course.dart';
import '../module_detail_page.dart';

const _heading = Color(0xFF2B2356);
const _muted = Color(0xFF9A96B8);
const _purple = Color(0xFF6B45F0);
const _chipBg = Color(0xFFF4F1FF);

// =====================================================
// CURRICULUM MODULE ROW
// One module of the curriculum list. Used on the Course
// Details page and inside the My Learning cards, so both
// screens always look exactly the same.
// =====================================================
class ModuleRow extends StatelessWidget {
  /// The course this module belongs to.
  final Course course;

  /// Position of the module inside the course (0 = module 1).
  final int moduleIndex;

  /// Lesson ids the current user has already completed.
  final Set<String> completedLessons;

  const ModuleRow({
    super.key,
    required this.course,
    required this.moduleIndex,
    required this.completedLessons,
  });

  @override
  Widget build(BuildContext context) {
    final module = course.modules[moduleIndex];
    final total = module.lessons.length;

    // How many lessons of THIS module are finished (calculated, not fixed).
    var completed = 0;
    for (var i = 0; i < total; i++) {
      if (completedLessons.contains(lessonIdFor(course, moduleIndex, i))) {
        completed++;
      }
    }

    // GestureDetector = makes the whole module row tappable.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      // User taps a module -> Open the lesson list for that module.
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ModuleDetailPage(
            courseId: course.id,
            moduleId: moduleIdFor(course, moduleIndex),
          ),
        ),
      ),
      // Container = light purple module row card.
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _chipBg,
          borderRadius: BorderRadius.circular(18),
        ),
        // Row = icon tile, module details, chevron.
        child: Row(
          children: [
            // Container = purple rounded square icon tile.
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _purple,
                borderRadius: BorderRadius.circular(13),
              ),
              // Icon = monitor glyph for the module.
              child: const Icon(
                Icons.desktop_mac_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // Expanded = text column fills the leftover row width.
            Expanded(
              // Column = module title, meta and progress text.
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    module.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _heading,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  // Calculated: '9 lessons · 1h 45m'.
                  Text(
                    moduleMeta(module),
                    style: const TextStyle(color: _muted, fontSize: 12),
                  ),
                  // Shown only when at least one lesson of this module is done.
                  if (completed > 0) ...[
                    const SizedBox(height: 3),
                    Text(
                      '$completed / $total lessons completed',
                      style: const TextStyle(
                        color: _purple,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Icon = chevron showing the row can be opened.
            const Icon(Icons.chevron_right_rounded, color: _muted),
          ],
        ),
      ),
    );
  }
}
