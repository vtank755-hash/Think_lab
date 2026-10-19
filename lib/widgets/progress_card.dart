import 'package:flutter/material.dart';

import '../progress.dart';

const _muted = Color(0xFF9A96B8);
const _purple = Color(0xFF6B45F0);
const _chipBg = Color(0xFFF4F1FF);

// =====================================================
// PROGRESS CARD
// Shows "9 / 43 lessons completed", the percentage and
// the progress bar. Used on the Course Details page and
// inside the My Learning cards, so both look the same.
// =====================================================
class ProgressCard extends StatelessWidget {
  /// Lessons finished so far (e.g. 9).
  final int completed;

  /// Total lessons of the course (e.g. 43).
  final int total;

  const ProgressCard({super.key, required this.completed, required this.total});

  @override
  Widget build(BuildContext context) {
    // Percentage is always calculated from the real lesson data.
    final percent = progressPercent(completed, total);

    // Container = purple progress card background.
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _chipBg,
        borderRadius: BorderRadius.circular(18),
      ),
      // Column = label row above the progress bar.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row = lesson label left, percent right.
          Row(
            children: [
              // Expanded = label fills space, percent stays right.
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
            // LinearProgressIndicator = purple lesson progress bar.
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : completed / total,
              minHeight: 8,
              color: _purple,
              backgroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
