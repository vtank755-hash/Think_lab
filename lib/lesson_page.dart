import 'package:flutter/material.dart';

import 'course.dart';
import 'purchases.dart';
import 'progress.dart';
import 'quiz_page.dart';
import 'quiz_results.dart';
import 'session.dart';
import 'widgets/completion_card.dart';
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
// =====================================================
// UI STRUCTURE (SCREEN VIEW)
//  1. Back button              -> GestureDetector + Icon (tap -> previous page)
//  2. Module header            -> Text 'Module N' + module title
//  3. Lesson counter           -> Text 'Lesson 1 / 5'
//  4. Locked card              -> Container + 'View course' button (not bought)
//  5. Video player             -> LessonVideoPlayer (tap -> fullscreen)
//  6. Lesson title + duration  -> Text + Row with clock Icon
//  7. About this lesson        -> Text
//  8. What you'll learn        -> Container + check Icon rows
//  9. Example code             -> Container + Text (monospace)
// 10. Notes                    -> Container + Text
// 11. Mark as completed        -> GestureDetector + Text (tap -> toggle)
// 12. Completion card          -> CompletionCard (all lessons done)
// 13. Previous / Next bar      -> OutlinedButton + FilledButton (-> lesson / Take Quiz)
// =====================================================
// LESSON PAGE (VIDEO LEARNING PAGE)
// StatefulWidget is used here because the page rebuilds when the lesson is
// marked completed, the video goes fullscreen, or a quiz attempt is saved.
// Shows the lesson video, notes and Previous/Next navigation.
// Layout: Scaffold -> Column (header + scrollable lesson content).
// =====================================================
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
  // Video player controller for THIS lesson's own video.
  late final LessonVideoController _player;
  late final bool _unlocked;

  // True while the video is shown in fullscreen.
  bool _fullscreen = false;
  // True once this lesson is marked completed.
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

  // Remember the video position, so the user can resume later.
  void _rememberPosition() {
    if (!_unlocked) return;
    saveVideoPosition(widget.lessonId, _player.position);
  }

  void _onVideoFinished() {
    // Video finished -> Mark the lesson as completed automatically.
    if (!_unlocked) return;
    markLessonCompleted(widget.lessonId, completed: true);
    saveVideoPosition(widget.lessonId, _player.durationSeconds);
    if (mounted) setState(() => _completed = true);
  }

  void _toggleCompleted() {
    // Mark the lesson as completed (and clear the video position if undone).
    final next = !_completed;
    markLessonCompleted(widget.lessonId, completed: next);
    if (!next) saveVideoPosition(widget.lessonId, 0);
    setState(() => _completed = next);
  }

  void _goTo(int mIndex, int lIndex) {
    // Move the user to the next (or previous) lesson.
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
    // Last lesson completed -> Open the final course quiz.
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

    // Scaffold = the whole lesson page.
    return Scaffold(
      backgroundColor: const Color(0xFFF6F5FB),
      // SafeArea = keeps lesson content away from the notch.
      body: SafeArea(
        // Normal mode: header + scrollable content. Fullscreen mode: just video.
        child: _fullscreen
            ? _fullScreenView()
            // Column = header on top, scrollable lesson body below.
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(previous),
                  // Expanded = fills remaining space with the scrolling list.
                  Expanded(
                    // ListView = scrolls the lesson sections vertically.
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
                            CompletionCard(course: _course),
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
      // Row = back button, module title, lesson counter.
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // GestureDetector = tap returns to the previous page.
          GestureDetector(
            onTap: () => Navigator.pop(context),
            // Container = white circle behind the back arrow.
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              // Icon = back arrow glyph.
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: _heading,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Expanded = title column fills the leftover width.
          Expanded(
            // Column = module label above the module title.
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
          // Container = white pill showing the lesson counter.
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

  // Shown when this course has not been purchased yet.
  Widget _lockedCard() {
    // Container = white card shown for locked lessons.
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      // Column = lock icon, message and view-course button.
      child: Column(
        children: [
          // Container = purple circle behind the lock icon.
          Container(
            width: 76,
            height: 76,
            decoration: const BoxDecoration(
              color: Color(0xFFEEE9FF),
              shape: BoxShape.circle,
            ),
            // Icon = padlock glyph for the locked state.
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
          // FilledButton = returns to the course details page.
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
        // LessonVideoPlayer = plays this lesson's own video.
        child: LessonVideoPlayer(
          controller: _player,
          video: lessonVideo(_course, _moduleIndex, _lessonIndex),
          poster: _course.image,
          onFullscreen: () => setState(() => _fullscreen = true),
        ),
      ),
    );
  }

  // Fullscreen video: black screen with a close button on top.
  Widget _fullScreenView() {
    return Container(
      color: Colors.black,
      // Column = top close bar above the fullscreen video.
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 8, 6, 0),
            // Row = close button, "Now playing" title, spacer.
            child: Row(
              children: [
                // IconButton = exits fullscreen mode.
                IconButton(
                  onPressed: () => setState(() => _fullscreen = false),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                // Expanded = centres the "Now playing" title.
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
          // Expanded = fills the rest of the screen with video.
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                // LessonVideoPlayer = same player in fullscreen layout.
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
    // Column = lesson title above the duration row.
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
        // Row = clock icon beside the lesson duration.
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
    // Column = heading above the lesson description.
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
    // Container = white card listing the learning points.
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      // Column = heading plus each learning point.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LessonSectionHeading("What you'll learn"),
          const SizedBox(height: 10),
          for (final point in _lesson.points)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              // Row = green check beside one learning point.
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
                  // Expanded = point text wraps in remaining width.
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
    // Column = heading above the example code box.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LessonSectionHeading('Example'),
        const SizedBox(height: 8),
        // Container = dark box showing the sample code.
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
    // Container = light purple card holding the lesson notes.
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F1FF),
        borderRadius: BorderRadius.circular(18),
      ),
      // Column = "Notes" heading above the note text.
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

  // Tap to mark this lesson completed (or undo it again).
  Widget _completionButton() {
    // GestureDetector = tap toggles the lesson's completed state.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _toggleCompleted,
      // Container = pill button to mark the lesson completed.
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
        // Row = status icon beside the completion label.
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon = check or empty circle for the state.
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

  // ------------------------------------------------ navigation

  Widget _navigation((int, int)? previous, (int, int)? next) {
    final isLast = next == null;
    final canPrevious = previous != null;
    // On the very last lesson the button becomes "Take Quiz" once the whole
    // course is learned and the final quiz has not been passed yet.
    final takeQuiz = isLast && _lessonsComplete && !isQuizPassed(_course.id);

    // Row = previous and next buttons side by side.
    return Row(
      children: [
        // Expanded = stretches Previous button to half width.
        Expanded(
          // OutlinedButton = moves to the previous lesson.
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
        // Expanded = stretches Next button to half width.
        Expanded(
          // FilledButton = next lesson, finish, or open the quiz.
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
