import 'package:flutter/material.dart';

import 'course.dart';
import 'quiz.dart';
import 'quiz_results.dart';

const _purple = Color(0xFF6B45F0);
const _heading = Color(0xFF1B1838);
const _muted = Color(0xFF8E8EA9);
const _pageBg = Color(0xFFF7F8FE);

class AdminQuizManagementPage extends StatefulWidget {
  const AdminQuizManagementPage({super.key});

  @override
  State<AdminQuizManagementPage> createState() =>
      _AdminQuizManagementPageState();
}

class _AdminQuizManagementPageState extends State<AdminQuizManagementPage> {
  String _courseId = allCourses.first.id;
  String _query = '';

  Course get _course =>
      allCourses.firstWhere((course) => course.id == _courseId);

  Future<void> _openEditor({CourseQuiz? quiz}) async {
    final saved = await Navigator.push<CourseQuiz>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AdminQuizEditorPage(courseId: quiz?.courseId, quiz: quiz),
      ),
    );
    if (saved == null || !mounted) return;
    try {
      await saveCourseQuiz(saved);
      if (quiz != null) {
        resetQuizAttemptsForCourse(
          quiz.courseId,
          quizId: quiz.isFinal ? null : quiz.id,
        );
      }
      if (saved.isFinal) {
        resetQuizAttemptsForCourse(saved.courseId);
      }
      if (mounted) {
        final course = allCourses.firstWhere(
          (item) => item.id == saved.courseId,
        );
        _showMessage('Quiz saved to ${course.title}.');
      }
    } catch (error) {
      if (mounted) _showMessage('Quiz was not saved: $error');
    }
  }

  Future<void> _deleteQuiz(CourseQuiz quiz) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete quiz?'),
        content: Text(
          'Delete "${quiz.title}" from ${_course.title}? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete Quiz'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await deleteCourseQuiz(_courseId, quiz.id);
      resetQuizAttemptsForCourse(
        _courseId,
        quizId: quiz.isFinal ? null : quiz.id,
      );
      if (mounted) _showMessage('Quiz deleted from ${_course.title}.');
    } catch (error) {
      if (mounted) _showMessage('Quiz was not deleted: $error');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _pageBg,
    appBar: AppBar(
      backgroundColor: _pageBg,
      title: const Text(
        'Course Quizzes',
        style: TextStyle(color: _heading, fontWeight: FontWeight.w800),
      ),
    ),
    body: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: DropdownButtonFormField<String>(
              key: const ValueKey('quiz-course-select'),
              initialValue: _courseId,
              decoration: InputDecoration(
                labelText: 'Select course',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              items: [
                for (final course in allCourses)
                  DropdownMenuItem(
                    value: course.id,
                    child: Text(course.title, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _courseId = value);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: TextField(
              key: const ValueKey('admin-quiz-search'),
              onChanged: (value) =>
                  setState(() => _query = value.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search quiz title...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Text(
              'Quizzes for ${_course.title}',
              style: const TextStyle(
                color: _heading,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<Map<String, List<CourseQuiz>>>(
              valueListenable: courseQuizzes,
              builder: (context, quizzesByCourse, _) {
                final quizzes =
                    (quizzesByCourse[_courseId] ?? const <CourseQuiz>[])
                        .where(
                          (quiz) =>
                              _query.isEmpty ||
                              quiz.title.toLowerCase().contains(_query),
                        )
                        .toList();
                if (quizzes.isEmpty) {
                  return const Center(
                    child: Text(
                      'No quizzes yet. Create the first quiz for this course.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _muted),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  itemCount: quizzes.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final quiz = quizzes[index];
                    return Card(
                      key: ValueKey('admin-quiz-card-${quiz.id}'),
                      color: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: BorderSide(
                          color: quiz.isPublished
                              ? const Color(0xFFEDECF5)
                              : const Color(0xFFFFE7B3),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _StatusChip(
                                  label: quiz.isPublished
                                      ? 'Published'
                                      : 'Draft',
                                  color: quiz.isPublished
                                      ? const Color(0xFF0AA66A)
                                      : const Color(0xFFE29A00),
                                ),
                                if (quiz.isFinal)
                                  const _StatusChip(
                                    label: 'Final quiz',
                                    color: _purple,
                                  ),
                                _StatusChip(
                                  label: '${quiz.questions.length} questions',
                                  color: _muted,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    quiz.title,
                                    style: const TextStyle(
                                      color: _heading,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  key: ValueKey('edit-quiz-${quiz.id}'),
                                  tooltip: 'Edit quiz',
                                  onPressed: () => _openEditor(quiz: quiz),
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    color: _purple,
                                  ),
                                ),
                                IconButton(
                                  key: ValueKey('delete-quiz-${quiz.id}'),
                                  tooltip: 'Delete quiz',
                                  onPressed: () => _deleteQuiz(quiz),
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                            if (quiz.description.isNotEmpty)
                              Text(
                                quiz.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: _muted,
                                  fontSize: 13,
                                ),
                              ),
                            const SizedBox(height: 12),
                            Text(
                              '${quiz.timeLimitMinutes > 0 ? '${quiz.timeLimitMinutes} min' : 'No time limit'}'
                              '  •  Passing ${quiz.passingPercentage}%'
                              '  •  ${quiz.maxAttempts > 0 ? '${quiz.maxAttempts} attempts' : 'Unlimited attempts'}',
                              style: const TextStyle(
                                color: _muted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    ),
    bottomNavigationBar: SafeArea(
      minimum: const EdgeInsets.fromLTRB(20, 8, 20, 14),
      child: FilledButton.icon(
        key: const ValueKey('create-course-quiz'),
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add),
        label: const Text('Create New Quiz'),
        style: FilledButton.styleFrom(
          backgroundColor: _purple,
          minimumSize: const Size.fromHeight(52),
        ),
      ),
    ),
  );
}

class AdminQuizEditorPage extends StatefulWidget {
  final String? courseId;
  final CourseQuiz? quiz;

  const AdminQuizEditorPage({super.key, this.courseId, this.quiz});

  @override
  State<AdminQuizEditorPage> createState() => _AdminQuizEditorPageState();
}

class _AdminQuizEditorPageState extends State<AdminQuizEditorPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _timeController;
  late final TextEditingController _passingController;
  late final TextEditingController _attemptsController;
  late final List<_QuestionDraft> _questions;
  String? _selectedCourseId;
  late bool _isPublished;
  late bool _isFinal;

  @override
  void initState() {
    super.initState();
    final quiz = widget.quiz;
    _selectedCourseId = quiz?.courseId ?? widget.courseId;
    _titleController = TextEditingController(text: quiz?.title ?? '');
    _descriptionController = TextEditingController(
      text: quiz?.description ?? '',
    );
    _timeController = TextEditingController(
      text: '${quiz?.timeLimitMinutes ?? 15}',
    );
    _passingController = TextEditingController(
      text: '${quiz?.passingPercentage ?? 70}',
    );
    _attemptsController = TextEditingController(
      text: '${quiz?.maxAttempts ?? 3}',
    );
    _isPublished = quiz?.isPublished ?? true;
    _isFinal = quiz?.isFinal ?? false;
    _questions = quiz == null
        ? [_QuestionDraft()]
        : quiz.questions.map(_QuestionDraft.fromQuestion).toList();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _timeController.dispose();
    _passingController.dispose();
    _attemptsController.dispose();
    for (final question in _questions) {
      question.dispose();
    }
    super.dispose();
  }

  String? _requiredText(String? value, String field) =>
      value == null || value.trim().isEmpty ? 'Enter $field' : null;

  String? _numberValidator(String? value, {required int minimum}) {
    final number = int.tryParse(value ?? '');
    return number == null || number < minimum
        ? 'Enter a number of at least $minimum'
        : null;
  }

  void _addQuestion() => setState(() => _questions.add(_QuestionDraft()));

  void _removeQuestion(int index) {
    if (_questions.length == 1) return;
    setState(() => _questions.removeAt(index).dispose());
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final courseId = _selectedCourseId;
    if (courseId == null) return;
    final questions = <QuizQuestion>[];
    for (var index = 0; index < _questions.length; index++) {
      final draft = _questions[index];
      final options = draft.options
          .map((controller) => controller.text.trim())
          .toList();
      if (options.any((option) => option.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fill in every answer for question ${index + 1}.'),
          ),
        );
        return;
      }
      questions.add(
        QuizQuestion(
          topic: 'Question ${index + 1}',
          text: draft.text.text.trim(),
          options: options,
          correctIndex: draft.correctIndex,
        ),
      );
    }
    Navigator.pop(
      context,
      CourseQuiz(
        id:
            widget.quiz?.id ??
            '${courseId}_quiz_${DateTime.now().microsecondsSinceEpoch}',
        courseId: courseId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        timeLimitMinutes: int.parse(_timeController.text),
        passingPercentage: int.parse(_passingController.text),
        maxAttempts: int.parse(_attemptsController.text),
        isPublished: _isPublished,
        isFinal: _isFinal,
        questions: questions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.quiz != null;
    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AppBar(
        backgroundColor: _pageBg,
        title: Text(
          isEditing ? 'Edit Quiz' : 'Add Quiz',
          style: const TextStyle(color: _heading, fontWeight: FontWeight.w800),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            DropdownButtonFormField<String>(
              key: const ValueKey('quiz-course-dropdown'),
              initialValue: _selectedCourseId,
              validator: (value) =>
                  value == null ? 'Please select a course' : null,
              decoration: InputDecoration(
                labelText: 'COURSE',
                filled: true,
                fillColor: const Color(0xFFEEF1FC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              hint: const Text('Select course'),
              items: [
                for (final course in allCourses)
                  DropdownMenuItem(
                    value: course.id,
                    child: Text(course.title, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (courseId) =>
                  setState(() => _selectedCourseId = courseId),
            ),
            const SizedBox(height: 16),
            _field(
              key: const ValueKey('quiz-title-field'),
              label: 'QUIZ TITLE',
              controller: _titleController,
              validator: (value) => _requiredText(value, 'a quiz title'),
            ),
            const SizedBox(height: 14),
            _field(
              label: 'DESCRIPTION',
              controller: _descriptionController,
              maxLines: 3,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _field(
                    label: 'TIME LIMIT (MIN)',
                    controller: _timeController,
                    keyboardType: TextInputType.number,
                    validator: (value) => _numberValidator(value, minimum: 0),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _field(
                    label: 'PASSING SCORE (%)',
                    controller: _passingController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final error = _numberValidator(value, minimum: 1);
                      if (error != null) return error;
                      return int.parse(value!) <= 100
                          ? null
                          : 'Maximum is 100%';
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _field(
                    label: 'MAX ATTEMPTS',
                    controller: _attemptsController,
                    keyboardType: TextInputType.number,
                    validator: (value) => _numberValidator(value, minimum: 0),
                  ),
                ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Published'),
              value: _isPublished,
              onChanged: (value) => setState(() => _isPublished = value),
              activeTrackColor: _purple,
            ),
            SwitchListTile(
              key: const ValueKey('quiz-final-switch'),
              contentPadding: EdgeInsets.zero,
              title: const Text('Use as the course completion quiz'),
              value: _isFinal,
              onChanged: (value) => setState(() => _isFinal = value),
              activeTrackColor: _purple,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Questions (${_questions.length})',
                    style: const TextStyle(
                      color: _heading,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                TextButton.icon(
                  key: const ValueKey('add-quiz-question'),
                  onPressed: _addQuestion,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add question'),
                ),
              ],
            ),
            for (var i = 0; i < _questions.length; i++) ...[
              const SizedBox(height: 8),
              _questionEditor(i, _questions[i]),
            ],
            const SizedBox(height: 20),
            FilledButton(
              key: const ValueKey('save-course-quiz'),
              onPressed: _save,
              style: FilledButton.styleFrom(
                backgroundColor: _purple,
                minimumSize: const Size.fromHeight(52),
              ),
              child: Text(isEditing ? 'Update Quiz' : 'Save Quiz'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _questionEditor(int index, _QuestionDraft draft) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFEEF1FC),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text('QUESTION ${index + 1}', style: _labelStyle)),
            if (_questions.length > 1)
              IconButton(
                tooltip: 'Remove question',
                onPressed: () => _removeQuestion(index),
                icon: const Icon(Icons.close, size: 18),
              ),
          ],
        ),
        TextFormField(
          key: ValueKey('quiz-question-$index'),
          controller: draft.text,
          validator: (value) => _requiredText(value, 'question ${index + 1}'),
          decoration: const InputDecoration(
            hintText: 'Type question here...',
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        RadioGroup<int>(
          groupValue: draft.correctIndex,
          onChanged: (value) {
            if (value != null) setState(() => draft.correctIndex = value);
          },
          child: Column(
            children: [
              for (
                var optionIndex = 0;
                optionIndex < draft.options.length;
                optionIndex++
              )
                Row(
                  children: [
                    Radio<int>(
                      key: ValueKey('correct-$index-$optionIndex'),
                      value: optionIndex,
                    ),
                    Expanded(
                      child: TextFormField(
                        key: ValueKey('quiz-option-$index-$optionIndex'),
                        controller: draft.options[optionIndex],
                        validator: (value) =>
                            _requiredText(value, 'answer option'),
                        decoration: InputDecoration(
                          hintText:
                              'Option ${String.fromCharCode(65 + optionIndex)}',
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _field({
    Key? key,
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: _labelStyle),
      const SizedBox(height: 6),
      TextFormField(
        key: key,
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: label == 'DESCRIPTION'
              ? 'Provide context for students...'
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    ],
  );

  TextStyle get _labelStyle => const TextStyle(
    color: _muted,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.6,
  );
}

class _QuestionDraft {
  final TextEditingController text;
  final List<TextEditingController> options;
  int correctIndex;

  _QuestionDraft({
    String question = '',
    List<String> answers = const ['', '', '', ''],
    this.correctIndex = 0,
  }) : text = TextEditingController(text: question),
       options = answers
           .map((answer) => TextEditingController(text: answer))
           .toList();

  factory _QuestionDraft.fromQuestion(QuizQuestion question) => _QuestionDraft(
    question: question.text,
    answers: question.options,
    correctIndex: question.correctIndex,
  );

  void dispose() {
    text.dispose();
    for (final option in options) {
      option.dispose();
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.09),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
    ),
  );
}
