import 'package:flutter/material.dart';

import 'course.dart';
import 'purchases.dart';
import 'progress.dart';
import 'quiz.dart';
import 'quiz_page.dart';
import 'quiz_results.dart';
import 'session.dart';
import 'widgets/lesson_video_player.dart';

const _heading = Color(0xFF2B2356);
const _muted = Color(0xFF9A96B8);
const _purple = Color(0xFF6B45F0);
const _green = Color(0xFF25A55F);

/// The video learning screen for ONE lesson.
///
/// Receives ids only — `courseId` + `moduleId` + `lessonId` — so the same
/// screen serves every lesson of every course:
///
/// ```dart
/// LessonPage(courseId: 'c5', moduleId: 'c5-module-1', lessonId: 'c5-module-1-lesson-1')
/// ```
///
/// What it does:
/// * plays THIS lesson's own video (play / pause / seek / full screen /
///   current + total duration / progress bar);
/// * shows the lesson context, points, code example and notes;
/// * remembers the playback position and the last opened lesson;
/// * marks the lesson completed when the video finishes;
/// * Previous / Next move through the module and on into the next module.
class LessonPage extends StatefulWidget {
  final String courseId;
  final String moduleId;
  final String lessonId;

  const LessonPage({
    super.key,
    required this.courseId,
    required this.moduleId,
    required this.lessonId,
  });

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  late final Course _course;
  late final Module _module;
  late final Lesson _lesson;
  late final int _moduleIndex;
  late final int _lessonIndex;
  late final LessonVideoController _player;
  late final bool _unlocked;

  bool _fullscreen = false;
  bool _completed = false;
  late final VoidCallback _quizListener;

  @override
  void initState() {
    super.initState();
    _course = courseById(widget.courseId);
    _moduleIndex = moduleIndexOf(_course, widget.moduleId);
    _module = _moduleIndex >= 0
        ? _course.modules[_moduleIndex]
        : const Module('1. Missing', []);
    _lessonIndex = lessonIndexOf(_course, widget.moduleId, widget.lessonId);
    _lesson = _lessonIndex >= 0
        ? _module.lessons[_lessonIndex]
        : const Lesson('Lesson not found', '00:00');
    _unlocked = isPurchased(_course);
    _completed = isLessonCompleted(widget.lessonId);

    _player = LessonVideoController(
      durationSeconds: durationInSeconds(_lesson.duration),
      // Continue roughly where this user stopped last time.
      startAt: videoPositionFor(widget.lessonId),
      onCompleted: _onVideoFinished,
    );
    _player.addListener(_rememberPosition);

    // Rebuild as soon as a quiz attempt is saved, so the completion banner and
    // the "Take Quiz" button flip to "Course successfully completed".
    _quizListener = () {
      if (mounted) setState(() {});
    };
    quizAttemptsOf(currentUser.value).addListener(_quizListener);

    // Remember THIS as the course's resume point ("Continue Learning").
    // Deferred one frame: notifying listeners during the build phase would
    // mark the home screen's continue card dirty while it is being built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setResumePoint(_course, widget.moduleId, widget.lessonId);
    });
  }

  void _rememberPosition() {
    if (!_unlocked) return;
    saveVideoPosition(widget.lessonId, _player.position);
  }

  void _onVideoFinished() {
    if (!_unlocked) return;
    markLessonCompleted(widget.lessonId, completed: true);
    saveVideoPosition(widget.lessonId, _player.durationSeconds);
    if (mounted) setState(() => _completed = true);
  }

  void _toggleCompleted() {
    final next = !_completed;
    markLessonCompleted(widget.lessonId, completed: next);
    if (!next) saveVideoPosition(widget.lessonId, 0);
    setState(() => _completed = next);
  }

  void _goTo(int mIndex, int lIndex) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LessonPage(
          courseId: widget.courseId,
          moduleId: moduleIdFor(_course, mIndex),
          lessonId: lessonIdFor(_course, mIndex, lIndex),
        ),
      ),
    );
  }

  @override
  void dispose() {
    quizAttemptsOf(currentUser.value).removeListener(_quizListener);
    _player
      ..removeListener(_rememberPosition)
      ..dispose();
    super.dispose();
  }

  /// STAGE 1 of the completion rule: every lesson of this course finished.
  bool get _lessonsComplete => isCourseLessonsComplete(_course);

  /// Opens the final quiz of THIS course (offered only when the lessons are
  /// all completed).
  void _openQuiz() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => QuizPage(courseId: widget.courseId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final previous = _moduleIndex < 0 || _lessonIndex < 0
        ? null
        : previousLesson(_course, _moduleIndex, _lessonIndex);
    final next = _moduleIndex < 0 || _lessonIndex < 0
        ? null
        : nextLesson(_course, _moduleIndex, _lessonIndex);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F5FB),
      body: SafeArea(
        child: _fullscreen
            ? _fullScreenView()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(previous),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                      children: [
                        if (!_unlocked)
                          _lockedCard()
                        else ...[
                          _videoCard(),
                          const SizedBox(height: 16),
                          _title(),
                          const SizedBox(height: 18),
                          _context(),
                          if (_lesson.points.isNotEmpty) ...[
                            const SizedBox(height: 18),
                            _points(),
                          ],
                          if (_lesson.code != null) ...[
                            const SizedBox(height: 18),
                            _code(),
                          ],
                          if (_lesson.notes != null) ...[
                            const SizedBox(height: 18),
                            _notes(),
                          ],
                          const SizedBox(height: 20),
                          _completionButton(),
                          if (next == null && _lessonsComplete) ...[
                            const SizedBox(height: 16),
                            _completionBanner(),
                          ],
                          const SizedBox(height: 16),
                          _navigation(previous, next),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ------------------------------------------------------------- header

  Widget _header((int, int)? previous) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 6),
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
                  'Module ${_moduleIndex + 1}',
                  style: const TextStyle(
                    color: _purple,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  moduleTitle(_module.title),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _heading,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'Lesson ${_lessonIndex + 1} / ${_module.lessons.length}',
              style: const TextStyle(
                color: _purple,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------ locked state

  Widget _lockedCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: const BoxDecoration(
              color: Color(0xFFEEE9FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              color: _purple,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'This lesson is locked',
            style: TextStyle(
              color: _heading,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Purchase the course to watch its lessons,\ntrack progress and continue learning.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _muted, fontSize: 13.5, height: 1.5),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(
              backgroundColor: _purple,
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'View course',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------- video

  Widget _videoCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: ColoredBox(
        color: const Color(0xFF14102B),
        child: LessonVideoPlayer(
          controller: _player,
          video: lessonVideo(_course, _moduleIndex, _lessonIndex),
          poster: _course.image,
          onFullscreen: () => setState(() => _fullscreen = true),
        ),
      ),
    );
  }

  Widget _fullScreenView() {
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 8, 6, 0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => setState(() => _fullscreen = false),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Now playing',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: LessonVideoPlayer(
                  controller: _player,
                  video: lessonVideo(_course, _moduleIndex, _lessonIndex),
                  poster: _course.image,
                  showFullscreenButton: false,
                  onCloseFullscreen: () => setState(() => _fullscreen = false),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------- lesson content

  Widget _title() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _lesson.title,
          style: const TextStyle(
            color: _heading,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.schedule_rounded, color: _muted, size: 15),
            const SizedBox(width: 6),
            Text(
              '${_lesson.duration}  •  Module ${_moduleIndex + 1}',
              style: const TextStyle(color: _muted, fontSize: 12.5),
            ),
          ],
        ),
      ],
    );
  }

  Widget _context() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LessonSectionHeading('About this lesson'),
        const SizedBox(height: 8),
        Text(
          _lesson.context.isEmpty
              ? 'Open the video above — the full explanation appears here.'
              : _lesson.context,
          style: const TextStyle(color: _muted, fontSize: 14, height: 1.6),
        ),
      ],
    );
  }

  Widget _points() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LessonSectionHeading("What you'll learn"),
          const SizedBox(height: 10),
          for (final point in _lesson.points)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: _green,
                      size: 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      point,
                      style: const TextStyle(
                        color: _heading,
                        fontSize: 13.5,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _code() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LessonSectionHeading('Example'),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1B1638),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            _lesson.code!,
            style: const TextStyle(
              color: Color(0xFFB9F6D2),
              fontSize: 13,
              height: 1.6,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }

  Widget _notes() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F1FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LessonSectionHeading('Notes'),
          const SizedBox(height: 8),
          Text(
            _lesson.notes!,
            style: const TextStyle(
              color: _heading,
              fontSize: 13.5,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------ completion

  Widget _completionButton() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _toggleCompleted,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: _completed ? const Color(0xFFE4F7EC) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: _completed ? _green : const Color(0xFFE3DFF3),
            width: 1.4,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _completed
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: _completed ? _green : _muted,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              _completed ? 'Completed' : 'Mark as completed',
              style: TextStyle(
                color: _completed ? _green : _heading,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------- course completion + quiz

  /// The course completion state shown on the LAST lesson of the LAST module:
  ///
  /// * lessons finished, quiz not passed → "Course learning completed" and a
  ///   **Take Quiz** button (the quiz itself is never offered earlier);
  /// * quiz passed (>= 75%) → "Course successfully completed".
  Widget _completionBanner() {
    final passed = isQuizPassed(_course.id);
    final total = courseLessonCount(_course);
    final attempt = latestQuizAttempt(_course.id);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: passed ? const Color(0xFFE4F7EC) : const Color(0xFFEEE9FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                passed
                    ? Icons.check_circle_rounded
                    : Icons.emoji_events_rounded,
                color: passed ? _green : _purple,
                size: 20,
              ),
              const SizedBox(width: 8),
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
                ? 'All $total lessons completed · Quiz '
                      '${attempt?.score}/${attempt?.total} '
                      '(${attempt?.percentage}%) PASSED'
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
                onPressed: _openQuiz,
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

  // ------------------------------------------------ navigation

  Widget _navigation((int, int)? previous, (int, int)? next) {
    final isLast = next == null;
    final canPrevious = previous != null;
    // On the very last lesson the button becomes "Take Quiz" once the whole
    // course is learned and the final quiz has not been passed yet.
    final takeQuiz = isLast && _lessonsComplete && !isQuizPassed(_course.id);

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: canPrevious
                ? () => _goTo(previous.$1, previous.$2)
                : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: _purple,
              side: const BorderSide(color: _purple, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chevron_left_rounded, size: 18),
                SizedBox(width: 4),
                Text('Previous', style: TextStyle(fontSize: 13.5)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            onPressed: takeQuiz
                ? _openQuiz
                : next != null
                ? () => _goTo(next.$1, next.$2)
                : () => Navigator.pop(context),
            style: FilledButton.styleFrom(
              backgroundColor: _purple,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  takeQuiz
                      ? 'Take Quiz'
                      : isLast
                      ? 'Finish Course'
                      : 'Next Lesson',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
