import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'admin_courses_page.dart';

// ─── Shared palette ──────────────────────────────────────────────────────────
const _purple = Color(0xFF6B45F0);
const _heading = Color(0xFF1B1838);
const _muted = Color(0xFF8E8EA9);
const _pageBg = Color(0xFFF7F8FE);
const _cardBg = Colors.white;

// ─── Upload-file model ───────────────────────────────────────────────────────

/// Represents a file that has been (simulated) uploaded for a course.
class UploadedFile {
  final String fileName;
  final String fileSize;
  final bool isVideo; // true → shows video icon; false → document icon
  final String status; // e.g. '100% Uploaded', 'Ready'
  final bool isDone; // drives green vs amber dot

  const UploadedFile({
    required this.fileName,
    required this.fileSize,
    required this.isVideo,
    required this.status,
    required this.isDone,
  });
}

// ─── Main page ───────────────────────────────────────────────────────────────

/// **Create Course & Quiz** — multi-step form for creating or editing a course.
///
/// • [course] — when non-null the form pre-fills for editing.
/// • On **Save Draft** the callback [onSaved] is invoked with the mutated
///   [AdminCourse] so the calling list can update itself.
class AdminCreateCoursePage extends StatefulWidget {
  /// Existing course to edit; null when creating a brand-new course.
  final AdminCourse? course;

  /// Called when the user taps "Save Draft" (or "Publish" in a future step).
  final void Function(AdminCourse saved)? onSaved;

  const AdminCreateCoursePage({super.key, this.course, this.onSaved});

  @override
  State<AdminCreateCoursePage> createState() => _AdminCreateCoursePageState();
}

class _AdminCreateCoursePageState extends State<AdminCreateCoursePage> {
  // ── Controllers ─────────────────────────────────────────────────────────
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _instructorCtrl;

  // ── Dropdown values ──────────────────────────────────────────────────────
  String _category = 'Design & UI';
  String _level = 'Intermediate';
  String _visibility = 'Public (Catalog)';

  // ── Status ───────────────────────────────────────────────────────────────
  CourseStatus _status = CourseStatus.active;

  // ── Simulated uploaded files ─────────────────────────────────────────────
  final List<UploadedFile> _uploads = [
    const UploadedFile(
      fileName: 'Lesson_01_Intro_Design_Systems.mp4',
      fileSize: '142 MB',
      isVideo: true,
      status: '100% Uploaded',
      isDone: true,
    ),
    const UploadedFile(
      fileName: 'Syllabus_Tokens_Framework.pdf',
      fileSize: '3.4 MB',
      isVideo: false,
      status: 'Ready',
      isDone: false,
    ),
  ];

  // ── Dropdown option lists ────────────────────────────────────────────────
  static const _categories = [
    'Design & UI',
    'Web Development',
    'Mobile Development',
    'Digital Marketing',
    'Data Science',
    'Programming',
  ];

  static const _levels = [
    'Beginner',
    'Intermediate',
    'Advanced',
  ];

  static const _visibilities = [
    'Public (Catalog)',
    'Private',
    'Unlisted',
  ];

  @override
  void initState() {
    super.initState();
    final c = widget.course;
    // Pre-fill from existing course when editing.
    _titleCtrl = TextEditingController(text: c?.title ?? '');
    _instructorCtrl = TextEditingController(text: c?.instructor ?? '');
    _priceCtrl = TextEditingController(
      text: c != null ? c.price.replaceAll(RegExp(r'[₹,]'), '') : '',
    );
    _descCtrl = TextEditingController();
    if (c != null) {
      _status = c.status;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _instructorCtrl.dispose();
    super.dispose();
  }

  // ── Save ─────────────────────────────────────────────────────────────────

  void _saveDraft() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      _showSnack('Please enter a course title.');
      return;
    }

    final priceRaw = _priceCtrl.text.trim();
    final priceStr = priceRaw.isEmpty ? '₹0' : '₹${_fmt(priceRaw)}';

    final saved = widget.course != null
        // Editing → mutate existing object
        ? (widget.course!
          ..title = title
          ..instructor = _instructorCtrl.text.trim().isEmpty
              ? widget.course!.instructor
              : _instructorCtrl.text.trim()
          ..price = priceStr
          ..status = _status)
        // Creating → build new course
        : AdminCourse(
            id: 'c_new_${DateTime.now().millisecondsSinceEpoch}',
            title: title,
            instructor: _instructorCtrl.text.trim().isEmpty
                ? 'Unknown Instructor'
                : _instructorCtrl.text.trim(),
            students: '0 students',
            price: priceStr,
            imageAsset: 'assets/images/courses/web_dev.jpg',
            status: _status,
          );

    widget.onSaved?.call(saved);
    Navigator.pop(context);
    _showParentSnack(
      widget.course != null
          ? '"$title" updated successfully.'
          : '"$title" saved as draft.',
    );
  }

  /// Formats a raw numeric string with comma thousands-separators.
  String _fmt(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '0';
    final n = int.tryParse(digits) ?? 0;
    // Simple comma formatting for Indian locale style.
    return n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _heading,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(msg),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showParentSnack(String msg) {
    // Brief delay so parent context is active after pop.
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: _heading,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Text(msg),
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  // ── Simulate "browse files" ───────────────────────────────────────────────
  void _browseFiles() {
    _showSnack('File picker would open here (demo).');
  }

  void _removeUpload(int index) {
    setState(() => _uploads.removeAt(index));
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.course != null;

    return Scaffold(
      backgroundColor: _pageBg,
      // ── App bar ──────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: _pageBg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leadingWidth: 48,
        leading: GestureDetector(
          key: const ValueKey('back-button'),
          onTap: () => Navigator.pop(context),
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: _heading,
              ),
            ),
          ),
        ),
        title: Column(
          children: [
            const Text(
              'THINKE LAB',
              style: TextStyle(
                color: _purple,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              isEdit ? 'Edit Course' : 'Create Course & Quiz',
              style: const TextStyle(
                color: _heading,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(
                Icons.more_vert_rounded,
                size: 20,
                color: _heading,
              ),
            ),
          ),
        ],
      ),

      // ── Body (scrollable form) ────────────────────────────────────────────
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        child: Column(
          children: [
            _buildStep1Card(),
            const SizedBox(height: 16),
            _buildStep2Card(),
          ],
        ),
      ),

      // ── Bottom action bar ─────────────────────────────────────────────────
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ── Step 1: Course Details card ───────────────────────────────────────────

  Widget _buildStep1Card() {
    return _SectionCard(
      stepNumber: 1,
      stepLabel: 'COURSE DETAILS',
      stepBadge: 'STEP 1 OF 3',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Course Title ───────────────────────────────────────────────
          _FieldLabel(text: 'COURSE TITLE'),
          const SizedBox(height: 6),
          _StyledTextField(
            key: const ValueKey('course-title-field'),
            controller: _titleCtrl,
            hint: 'e.g. UX Design Systems & Motion Mastery',
          ),
          const SizedBox(height: 16),

          // ── Category + Level ───────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel(text: 'CATEGORY'),
                    const SizedBox(height: 6),
                    _StyledDropdown(
                      key: const ValueKey('category-dropdown'),
                      value: _category,
                      items: _categories,
                      onChanged: (v) => setState(() => _category = v!),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel(text: 'LEVEL'),
                    const SizedBox(height: 6),
                    _StyledDropdown(
                      key: const ValueKey('level-dropdown'),
                      value: _level,
                      items: _levels,
                      onChanged: (v) => setState(() => _level = v!),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Course Description ─────────────────────────────────────────
          _FieldLabel(text: 'COURSE DESCRIPTION'),
          const SizedBox(height: 6),
          _StyledTextField(
            key: const ValueKey('course-desc-field'),
            controller: _descCtrl,
            hint:
                'Master comprehensive design systems from token management to multi-brand components...',
            maxLines: 4,
          ),
          const SizedBox(height: 16),

          // ── Price + Visibility ─────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel(text: 'PRICE (INR / ₹)'),
                    const SizedBox(height: 6),
                    _StyledTextField(
                      key: const ValueKey('course-price-field'),
                      controller: _priceCtrl,
                      hint: '4,999',
                      prefix: const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Text(
                          '₹',
                          style: TextStyle(
                            color: _muted,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel(text: 'VISIBILITY'),
                    const SizedBox(height: 6),
                    _StyledDropdown(
                      key: const ValueKey('visibility-dropdown'),
                      value: _visibility,
                      items: _visibilities,
                      onChanged: (v) => setState(() => _visibility = v!),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Instructor ─────────────────────────────────────────────────
          _FieldLabel(text: 'INSTRUCTOR NAME'),
          const SizedBox(height: 6),
          _StyledTextField(
            key: const ValueKey('course-instructor-field'),
            controller: _instructorCtrl,
            hint: 'e.g. Rohan Gupta',
          ),
          const SizedBox(height: 16),

          // ── Status toggle ──────────────────────────────────────────────
          _FieldLabel(text: 'STATUS'),
          const SizedBox(height: 8),
          Row(
            children: [
              _StatusChip(
                label: 'Active',
                selected: _status == CourseStatus.active,
                activeColor: const Color(0xFF25A55F),
                activeBg: const Color(0xFFE5F8EE),
                onTap: () => setState(() => _status = CourseStatus.active),
              ),
              const SizedBox(width: 10),
              _StatusChip(
                label: 'Draft',
                selected: _status == CourseStatus.draft,
                activeColor: const Color(0xFFF59E0B),
                activeBg: const Color(0xFFFFF8E6),
                onTap: () => setState(() => _status = CourseStatus.draft),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Step 2: Course Media & Lessons card ──────────────────────────────────

  Widget _buildStep2Card() {
    return _SectionCard(
      stepNumber: 2,
      stepLabel: 'COURSE MEDIA & LESSONS',
      stepBadge: 'STEP 2 OF 3',
      subtitle: 'Upload lectures & materials',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Upload drop zone ───────────────────────────────────────────
          GestureDetector(
            key: const ValueKey('upload-zone'),
            onTap: _browseFiles,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F0FE),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _purple.withValues(alpha: 0.35),
                  width: 1.5,
                  // Dashed border is simulated via a stack + custom painter.
                ),
              ),
              child: Column(
                children: [
                  // Upload icon circle
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: _purple.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.cloud_upload_outlined,
                      color: _purple,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Upload Course Video / Syllabus',
                    style: TextStyle(
                      color: _heading,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Drag & drop MP4, PDF, or click to browse (Max 500MB)',
                    style: TextStyle(
                      color: _muted.withValues(alpha: 0.85),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: _browseFiles,
                    icon: const Icon(
                      Icons.add_rounded,
                      size: 16,
                      color: _purple,
                    ),
                    label: const Text(
                      'Browse Files',
                      style: TextStyle(
                        color: _purple,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: _purple,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Uploaded items header ──────────────────────────────────────
          Row(
            children: [
              Text(
                'UPLOADED ITEMS (${_uploads.length})',
                style: const TextStyle(
                  color: _muted,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEECFA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_uploads.length} Files Active',
                  style: const TextStyle(
                    color: _purple,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Uploaded file rows ─────────────────────────────────────────
          ..._uploads.asMap().entries.map(
            (e) => _UploadedFileRow(
              key: ValueKey('upload-file-${e.key}'),
              file: e.value,
              onRemove: () => _removeUpload(e.key),
            ),
          ),
          const SizedBox(height: 4),

          // ── Upload additional resource button ─────────────────────────
          GestureDetector(
            key: const ValueKey('upload-additional-button'),
            onTap: _browseFiles,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FE),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFE2E0F4),
                  width: 1.2,
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded, color: _purple, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Upload Additional Resource',
                    style: TextStyle(
                      color: _purple,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom bar ────────────────────────────────────────────────────────────

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Cancel
          Expanded(
            child: OutlinedButton(
              key: const ValueKey('cancel-button'),
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFE2E0F4), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: _muted,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Save Draft
          Expanded(
            flex: 2,
            child: GestureDetector(
              key: const ValueKey('save-draft-button'),
              onTap: _saveDraft,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF6B45F0)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: _purple.withValues(alpha: 0.28),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Save Draft',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared section-card wrapper ─────────────────────────────────────────────

/// White card wrapping each numbered step in the multi-step form.
class _SectionCard extends StatelessWidget {
  final int stepNumber;
  final String stepLabel;
  final String stepBadge;
  final String? subtitle;
  final Widget child;

  const _SectionCard({
    required this.stepNumber,
    required this.stepLabel,
    required this.stepBadge,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Step header ──────────────────────────────────────────────
          Row(
            children: [
              // Coloured vertical bar
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: _purple,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$stepNumber. $stepLabel',
                style: const TextStyle(
                  color: _heading,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEECFA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  stepBadge,
                  style: const TextStyle(
                    color: _purple,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(
                subtitle!,
                style: TextStyle(
                  color: _muted.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ─── Field label ─────────────────────────────────────────────────────────────

/// Small all-caps label above a form field.
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: _muted,
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
      ),
    );
  }
}

// ─── Styled text field ────────────────────────────────────────────────────────

/// Consistently styled text-input box used throughout the form.
class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final Widget? prefix;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const _StyledTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.prefix,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E0F4), width: 1.2),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: const TextStyle(
          color: _heading,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: _muted.withValues(alpha: 0.6),
            fontSize: 13.5,
          ),
          prefixIcon: prefix != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 14, right: 2),
                  child: prefix,
                )
              : null,
          prefixIconConstraints: const BoxConstraints(minWidth: 0),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
        ),
      ),
    );
  }
}

// ─── Styled dropdown ──────────────────────────────────────────────────────────

/// Consistently styled dropdown selector used throughout the form.
class _StyledDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _StyledDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E0F4), width: 1.2),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: _muted,
            size: 20,
          ),
          style: const TextStyle(
            color: _heading,
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(14),
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(item),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ─── Status chip ─────────────────────────────────────────────────────────────

/// Pill-shaped toggle chip for Active / Draft status selection.
class _StatusChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color activeColor;
  final Color activeBg;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    required this.selected,
    required this.activeColor,
    required this.activeBg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? activeBg : const Color(0xFFF7F8FE),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? activeColor.withValues(alpha: 0.4)
                : const Color(0xFFE2E0F4),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? activeColor : _muted,
            fontWeight: FontWeight.w700,
            fontSize: 13.5,
          ),
        ),
      ),
    );
  }
}

// ─── Uploaded file row ────────────────────────────────────────────────────────

/// A single row in the uploaded-items list, showing icon, name, size, status.
class _UploadedFileRow extends StatelessWidget {
  final UploadedFile file;
  final VoidCallback onRemove;

  const _UploadedFileRow({
    super.key,
    required this.file,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E0F4), width: 1),
      ),
      child: Row(
        children: [
          // ── File type icon ───────────────────────────────────────────
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _purple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              file.isVideo
                  ? Icons.video_library_outlined
                  : Icons.picture_as_pdf_outlined,
              color: _purple,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),

          // ── Name + size + status ─────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.fileName,
                  style: const TextStyle(
                    color: _heading,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      file.fileSize,
                      style: TextStyle(
                        color: _muted.withValues(alpha: 0.8),
                        fontSize: 11.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Status dot
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: file.isDone
                            ? const Color(0xFF25A55F)
                            : const Color(0xFFF59E0B),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      file.status,
                      style: TextStyle(
                        color: file.isDone
                            ? const Color(0xFF25A55F)
                            : const Color(0xFFF59E0B),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Remove button ────────────────────────────────────────────
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFFEECEB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFF04438),
                size: 17,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
