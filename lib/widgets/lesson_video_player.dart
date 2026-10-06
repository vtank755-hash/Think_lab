import 'dart:async';

import 'package:flutter/material.dart';

import '../course.dart';

const _purple = Color(0xFF6B45F0);
const _heading = Color(0xFF2B2356);
const _muted = Color(0xFF9A96B8);

/// Drives ONE lesson's video: play / pause / seek plus the saved position.
///
/// Every lesson gets its own controller instance with its own duration, so
/// two lessons never share playback state. The page owns the controller, so
/// entering fullscreen (or coming back from it) keeps the position intact.
class LessonVideoController extends ChangeNotifier {
  LessonVideoController({
    required this.durationSeconds,
    int startAt = 0,
    this.onCompleted,
  }) : _position = startAt.clamp(0, durationSeconds < 0 ? 0 : durationSeconds);

  /// Length of THIS lesson's video, in seconds.
  final int durationSeconds;

  /// Called once when playback reaches the end (lesson finished).
  final VoidCallback? onCompleted;

  int _position;
  bool _playing = false;
  Timer? _timer;

  /// Current position in seconds.
  int get position => _position;

  /// Whether the video is playing right now.
  bool get playing => _playing;

  /// Whether playback already reached the end.
  bool get finished => durationSeconds > 0 && _position >= durationSeconds;

  /// 0.0 – 1.0.
  double get progress =>
      durationSeconds <= 0 ? 0 : (_position / durationSeconds).clamp(0.0, 1.0);

  void play() {
    if (_playing) return;
    if (finished) _position = 0; // replay from the start
    _playing = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    notifyListeners();
  }

  void pause() {
    _timer?.cancel();
    _timer = null;
    if (!_playing) return;
    _playing = false;
    notifyListeners();
  }

  void toggle() => _playing ? pause() : play();

  /// Seek to [seconds] (progress bar / full screen scrubbing).
  ///
  /// Scrubbing all the way to the end counts as finishing the lesson.
  void seek(int seconds) {
    final clamped = seconds.clamp(0, durationSeconds);
    final reachedEnd = durationSeconds > 0 && clamped >= durationSeconds;
    _position = clamped;
    notifyListeners();
    if (reachedEnd) onCompleted?.call();
  }

  void _tick() {
    _position += 1;
    if (_position >= durationSeconds) {
      _position = durationSeconds;
      pause();
      onCompleted?.call();
      return;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }
}

/// The video surface + controls: play/pause, seekable progress bar,
/// current/total duration and a full screen toggle.
class LessonVideoPlayer extends StatelessWidget {
  final LessonVideoController controller;

  /// The lesson's OWN video source (never shared between lessons).
  final String video;

  /// Poster shown while paused (the course image).
  final String poster;

  final bool showFullscreenButton;
  final VoidCallback? onFullscreen;
  final VoidCallback? onCloseFullscreen;

  const LessonVideoPlayer({
    super.key,
    required this.controller,
    required this.video,
    required this.poster,
    this.showFullscreenButton = true,
    this.onFullscreen,
    this.onCloseFullscreen,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF241C4A), Color(0xFF14102B)],
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _poster(),
                Center(child: _playButton()),
                Positioned(left: 0, right: 0, bottom: 0, child: _controls()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _poster() {
    return Opacity(
      opacity: 0.35,
      child: Image.asset(
        poster,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const ColoredBox(color: Color(0xFF1B1638)),
      ),
    );
  }

  Widget _playButton() {
    final finished = controller.finished;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: controller.toggle,
      child: Container(
        width: 62,
        height: 62,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 18,
            ),
          ],
        ),
        child: Icon(
          finished
              ? Icons.replay_rounded
              : controller.playing
              ? Icons.pause_rounded
              : Icons.play_arrow_rounded,
          color: _purple,
          size: 34,
        ),
      ),
    );
  }

  Widget _controls() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.0),
            Colors.black.withValues(alpha: 0.55),
          ],
        ),
      ),
      child: Row(
        children: [
          Text(
            formatClock(controller.position),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 4,
                activeTrackColor: _purple,
                inactiveTrackColor: Colors.white38,
                thumbColor: Colors.white,
                overlayColor: _purple.withValues(alpha: 0.25),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              ),
              child: Slider(
                value: controller.progress,
                onChanged: (value) => controller.seek(
                  (value * controller.durationSeconds).round(),
                ),
              ),
            ),
          ),
          Text(
            formatClock(controller.durationSeconds),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (showFullscreenButton)
            IconButton(
              onPressed: onFullscreen,
              tooltip: 'Full screen',
              icon: const Icon(
                Icons.fullscreen_rounded,
                color: Colors.white,
                size: 22,
              ),
            )
          else
            IconButton(
              onPressed: onCloseFullscreen,
              tooltip: 'Close full screen',
              icon: const Icon(
                Icons.fullscreen_exit_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
        ],
      ),
    );
  }
}

/// Small styled block used for lesson notes / meta lines.
class LessonMetaRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const LessonMetaRow({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: _muted, size: 15),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: _muted, fontSize: 12.5),
          ),
        ),
      ],
    );
  }
}

/// Section heading used on the lesson page (same weight as the app's others).
class LessonSectionHeading extends StatelessWidget {
  final String text;

  const LessonSectionHeading(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: _heading,
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
