import 'package:flutter/material.dart';

import 'quiz.dart';
import 'quiz_results.dart';

const _heading = Color(0xFF2B2356);
const _muted = Color(0xFF9A96B8);
const _purple = Color(0xFF6B45F0);
const _green = Color(0xFF25A55F);
const _red = Color(0xFFF04438);
const _track = Color(0xFFEDEAF8);
const _pageBg = Color(0xFFF6F5FB);
const _border = Color(0xFFE7E3F6);

/// Background of the SELECTED answer option (exported for tests).
const Color quizSelectedOptionBg = Color(0xFFF1EDFF);

/// Key of answer option [index] (A = 0 … D = 3) — exported for tests.
ValueKey<String> quizOptionKey(int index) => ValueKey('quiz-option-$index');

/// The **Module Quiz** screen — the final 20-question quiz of ONE course.
///
/// ```dart
/// QuizPage(courseId: 'c5')   // → 20 Python questions of c5_final_quiz
/// ```
///
/// * questions are loaded by COURSE ID from `quiz.dart` (never written in the
///   UI, never shared between courses);
/// * `Question N of 20` and the `N%` progress bar are calculated from the
///   current index and the real question count;
/// * one answer per question, kept when moving Previous / Next;
/// * `Submit` calculates the real score; **75% or above passes**, below that
///   the result screen offers `Retry Quiz` (attempt restarted from question 1);
/// * every attempt is stored per user + course in `quiz_results.dart`.
// =====================================================
// COURSE QUIZ PAGE
// Shows 20 questions for the selected course.
// =====================================================
class QuizPage extends StatefulWidget {
  /// The course whose quiz should be loaded.
  final String courseId;

  const QuizPage({super.key, required this.courseId});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  CourseQuiz? _quiz;
  late List<int?> _answers;
  int _index = 0;
  QuizAttempt? _result;
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    // Loaded dynamically from the CURRENT course id.
    _quiz = quizForCourse(widget.courseId);
    _answers = List<int?>.filled(_quiz?.questions.length ?? 0, null);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  int get _total => _quiz?.questions.length ?? 0;

  /// `5%` on question 1, `50%` on question 10, `100%` on question 20.
  int get _percent => _total == 0 ? 0 : ((_index + 1) * 100) ~/ _total;

  bool get _isLast => _index == _total - 1;

  // ------------------------------------------------------------- actions

  void _goTo(int index) {
    setState(() => _index = index);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  void _select(int optionIndex) {
    setState(() => _answers[_index] = optionIndex);
  }

  /// Calculates the real score and stores this attempt for the user.
  /// Quiz submitted -> Show the score/result page.
  void _submit() {
    final quiz = _quiz;
    if (quiz == null) return;
    var score = 0;
    for (var i = 0; i < quiz.questions.length; i++) {
      if (_answers[i] == quiz.questions[i].correctIndex) score++;
    }
    saveQuizAttempt(quiz.courseId, score: score, total: quiz.questions.length);
    setState(() => _result = latestQuizAttempt(quiz.courseId));
  }

  /// Retry: question 1, fresh (empty) answers, same course quiz.
  /// Score is below 75% -> the user must retry the quiz.
  void _retry() {
    setState(() {
      _index = 0;
      _answers = List<int?>.filled(_total, null);
      _result = null;
    });
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  // --------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    if (_quiz == null) return _missing();
    if (_result != null) return _resultView();
    return _quizView();
  }

  /// Course without quiz data — never another course's questions.
  Widget _missing() {
    return Scaffold(
      backgroundColor: _pageBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'No quiz is available for this course yet.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _muted, fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 6),
      child: Row(
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
          const Expanded(
            child: Text(
              'Module Quiz',
              style: TextStyle(
                color: _heading,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The main quiz screen: counter + progress bar + question + answers +
  /// Previous / Next / Submit.
  Widget _quizView() {
    final quiz = _quiz!;
    final question = quiz.questions[_index];

    return Scaffold(
      backgroundColor: _pageBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Row(
                children: [
                  Text(
                    'Question ${_index + 1} of $_total',
                    style: const TextStyle(
                      color: _heading,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$_percent%',
                    style: const TextStyle(
                      color: _purple,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _total == 0 ? 0 : (_index + 1) / _total,
                  minHeight: 8,
                  color: _purple,
                  backgroundColor: _track,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                children: [
                  _questionCard(question.topic, question.text),
                  const SizedBox(height: 18),
                  for (var i = 0; i < question.options.length; i++)
                    _option(i, question.options[i]),
                ],
              ),
            ),
            _buttons(),
          ],
        ),
      ),
    );
  }

  Widget _questionCard(String topic, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFEFEAFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              topic,
              style: const TextStyle(
                color: _purple,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: const TextStyle(
              color: _heading,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  /// One answer option — highlighted when this is the saved selection.
  Widget _option(int optionIndex, String label) {
    final selected = _answers[_index] == optionIndex;
    final letter = String.fromCharCode(65 + optionIndex); // A, B, C, D

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        key: quizOptionKey(optionIndex),
        behavior: HitTestBehavior.opaque,
        onTap: () => _select(optionIndex),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: selected ? quizSelectedOptionBg : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? _purple : _border,
              width: selected ? 1.6 : 1.3,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? _purple : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? _purple : _purple.withValues(alpha: 0.45),
                    width: 1.4,
                  ),
                ),
                child: Text(
                  letter,
                  style: TextStyle(
                    color: selected ? Colors.white : _purple,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: _heading,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Previous (disabled on question 1) + Next / Submit on the last question.
  Widget _buttons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _index == 0 ? null : () => _goTo(_index - 1),
              style: OutlinedButton.styleFrom(
                foregroundColor: _purple,
                side: const BorderSide(color: _purple, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Previous',
                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: _isLast ? _submit : () => _goTo(_index + 1),
              style: FilledButton.styleFrom(
                backgroundColor: _purple,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                _isLast ? 'Submit' : 'Next',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------ results

  Widget _resultView() {
    final result = _result!;
    final passed = result.passed;

    return Scaffold(
      backgroundColor: _pageBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
          child: Column(
            children: [
              _header(),
              const SizedBox(height: 24),
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: passed
                      ? const Color(0xFFE4F7EC)
                      : const Color(0xFFFDECEA),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  passed ? Icons.check_rounded : Icons.close_rounded,
                  color: passed ? _green : _red,
                  size: 46,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                passed ? 'Quiz Completed' : 'Quiz Not Passed',
                style: const TextStyle(
                  color: _heading,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                passed
                    ? 'Congratulations! You completed the final quiz.'
                    : 'You need $quizPassingPercentage% or higher to complete this course.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _resultRow(
                      passed ? 'Score' : 'Your Score',
                      '${result.score} / ${result.total}',
                      emphasize: true,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Divider(height: 1, color: _border),
                    ),
                    _resultRow('Percentage', '${result.percentage}%'),
                    if (!passed) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Divider(height: 1, color: _border),
                      ),
                      _resultRow(
                        'Minimum Passing Score',
                        '$quizPassingPercentage%',
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: passed
                      ? const Color(0xFFE4F7EC)
                      : const Color(0xFFFDECEA),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  passed ? 'PASSED' : 'NOT PASSED',
                  style: TextStyle(
                    color: passed ? _green : _red,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  // Passed (75%+) -> Go back to the course.
                  // Failed (< 75%) -> Restart the quiz from question 1.
                  onPressed: passed ? () => Navigator.pop(context) : _retry,
                  style: FilledButton.styleFrom(
                    backgroundColor: _purple,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    passed ? 'Continue' : 'Retry Quiz',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resultRow(String label, String value, {bool emphasize = false}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: _muted, fontSize: 13.5),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: emphasize ? _purple : _heading,
            fontSize: emphasize ? 24 : 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
