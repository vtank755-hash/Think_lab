import 'package:flutter/material.dart';

import '../course.dart';
import '../quiz.dart';
import '../quiz_page.dart';
import '../quiz_results.dart';

const _heading = Color(0xFF2B2356);
const _muted = Color(0xFF9A96B8);
const _purple = Color(0xFF6B45F0);
const _green = Color(0xFF25A55F);

// =====================================================
// COMPLETION CARD
// Shown when every lesson of the course is finished:
// - quiz not passed yet -> "Course learning completed" + Take Quiz button
// - quiz passed (75%+)  -> "Course successfully completed"
// Used on Course Details and on the last lesson page.
// =====================================================
class CompletionCard extends StatelessWidget {
  /// The course this card reports on (checks its lessons and quiz result).
  final Course course;

  const CompletionCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final passed = isQuizPassed(course.id);
    final attempt = latestQuizAttempt(course.id);
    final total = courseLessonCount(course);

    // Container = card shown when all lessons are finished.
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: passed ? const Color(0xFFE4F7EC) : const Color(0xFFEEE9FF),
        borderRadius: BorderRadius.circular(18),
      ),
      // Column = title row, message, then the quiz button.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row = status icon beside the completion title.
          Row(
            children: [
              // Icon = trophy before passing, check after.
              Icon(
                passed
                    ? Icons.check_circle_rounded
                    : Icons.emoji_events_rounded,
                color: passed ? _green : _purple,
                size: 20,
              ),
              const SizedBox(width: 8),
              // Expanded = title text fills the remaining width.
              Expanded(
                child: Text(
                  passed
                      ? 'Course successfully completed'
                      : 'Course learning completed',
                  style: const TextStyle(
                    color: _heading,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            passed
                ? 'Final quiz passed with ${attempt?.percentage}% '
                      '(${attempt?.score}/${attempt?.total}).'
                : 'All $total lessons completed. Take the final quiz — '
                      '$quizQuestionCount questions, $quizPassingPercentage% '
                      'or higher completes the course.',
            style: TextStyle(
              color: passed ? _green : _muted,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          if (!passed) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                // Course learning completed -> Open the final course quiz.
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuizPage(courseId: course.id),
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: _purple,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Take Quiz',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
