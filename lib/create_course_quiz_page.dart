import 'package:flutter/material.dart';

import 'admin_courses_page.dart';

// ─── Color Palette ──────────────────────────────────────────────────────────
const _purple = Color(0xFF6B45F0);
const _purpleLight = Color(0xFFEDEAFE);
const _purpleAccent = Color(0xFF8B5CF6);
const _heading = Color(0xFF1B1838);
const _muted = Color(0xFF8E8EA9);
const _pageBg = Color(0xFFF4F5FB);
const _inputBg = Color(0xFFF7F8FE);
const _borderColor = Color(0xFFE6E5F5);
const _green = Color(0xFF25A55F);

// ─── Resource item model ────────────────────────────────────────────────────
class UploadedResource {
  final String id;
  String name;
  String size;
  String statusText;
  bool isVideo;

  UploadedResource({
    required this.id,
    required this.name,
    required this.size,
    required this.statusText,
    required this.isVideo,
  });
}

/// **Create Course & Quiz Screen** (`CreateCourseQuizPage`)
///
/// Implements the full-screen "Create Course & Quiz" admin design.
/// Opened when admin taps the "+ Add" button on the Manage Courses page.
class CreateCourseQuizPage extends StatefulWidget {
  final AdminCourse? initialCourse;

  const CreateCourseQuizPage({super.key, this.initialCourse});

  @override
  State<CreateCourseQuizPage> createState() => _CreateCourseQuizPageState();
}

class _CreateCourseQuizPageState extends State<CreateCourseQuizPage> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;

  String _category = 'Design & UI';
  String _level = 'Intermediate';
  String _visibility = 'Public (Catalog)';

  final List<String> _categories = [
    'Design & UI',
    'Web Development',
    'Mobile Development',
    'Data Science',
    'Digital Marketing',
    'Business',
  ];

  final List<String> _levels = [
    'Beginner',
    'Intermediate',
    'Advanced',
    'All Levels',
  ];

  final List<String> _visibilities = [
    'Public (Catalog)',
    'Private (Draft)',
    'Unlisted',
  ];

  late final List<UploadedResource> _resources;

  @override
  void initState() {
    super.initState();
    final c = widget.initialCourse;
    // For new course (c == null), all fields start empty.
    // For edit (c != null), pre-fill from the selected course.
    _titleCtrl = TextEditingController(text: c?.title ?? '');
    _descCtrl = TextEditingController(text: c?.description ?? '');
    _priceCtrl = TextEditingController(text: c?.price ?? '');

    if (c?.category != null && _categories.contains(c!.category)) {
      _category = c.category!;
    }
    if (c?.level != null && _levels.contains(c!.level)) {
      _level = c.level!;
    }
    if (c?.visibility != null && _visibilities.contains(c!.visibility)) {
      _visibility = c.visibility!;
    }

    // Show demo uploaded files only when editing an existing course.
    // New course starts with no uploaded resources.
    _resources =
        c != null
            ? [
              UploadedResource(
                id: 'res_1',
                name: 'Lesson_01_Intro_Design_Systems.mp4',
                size: '142 MB',
                statusText: '100% Uploaded',
                isVideo: true,
              ),
              UploadedResource(
                id: 'res_2',
                name: 'Syllabus_Tokens_Framework.pdf',
                size: '3.4 MB',
                statusText: 'Ready',
                isVideo: false,
              ),
            ]
            : [];
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  void _saveCourse() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a course title'),
          backgroundColor: Color(0xFFF04438),
        ),
      );
      return;
    }

    final price = _priceCtrl.text.trim().isEmpty ? '₹0' : _priceCtrl.text.trim();
    final isDraft = _visibility.contains('Draft');

    final updatedCourse = AdminCourse(
      id: widget.initialCourse?.id ?? 'c_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      instructor: widget.initialCourse?.instructor ?? 'Admin Instructor',
      students: widget.initialCourse?.students ?? '0 students',
      price: price,
      imageAsset: widget.initialCourse?.imageAsset ?? 'assets/images/courses/web_dev.jpg',
      status: isDraft ? CourseStatus.draft : CourseStatus.active,
      category: _category,
      level: _level,
      description: _descCtrl.text.trim(),
      visibility: _visibility,
    );

    Navigator.pop(context, updatedCourse);
  }

  void _addMockResource() {
    setState(() {
      final index = _resources.length + 1;
      _resources.add(
        UploadedResource(
          id: 'res_${DateTime.now().millisecondsSinceEpoch}',
          name: 'Resource_Module_${index}_Guide.pdf',
          size: '5.2 MB',
          statusText: 'Ready',
          isVideo: false,
        ),
      );
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Resource uploaded successfully.'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _removeResource(String id) {
    setState(() {
      _resources.removeWhere((r) => r.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialCourse != null;

    return Scaffold(
      backgroundColor: _pageBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(isEditing),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                child: Column(
                  children: [
                    _buildStep1Details(),
                    const SizedBox(height: 20),
                    _buildStep2Media(),
                  ],
                ),
              ),
            ),
            _buildBottomBar(isEditing),
          ],
        ),
      ),
    );
  }

  // ── Top Navigation Bar ─────────────────────────────────────────────────────
  Widget _buildAppBar(bool isEditing) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          GestureDetector(
            key: const ValueKey('create-course-back-btn'),
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: _borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
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

          // Center Title
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'THINKE LAB',
                style: TextStyle(
                  color: _purple,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isEditing ? 'Edit Course & Quiz' : 'Create Course & Quiz',
                style: const TextStyle(
                  color: _heading,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),

          // 3-dots Menu Button
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: _borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.more_vert_rounded,
              size: 20,
              color: _heading,
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 1: Course Details Card ───────────────────────────────────────────
  Widget _buildStep1Details() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Step Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      color: _purple,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '1. COURSE DETAILS',
                    style: TextStyle(
                      color: _heading,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
              _buildStepBadge('STEP 1 OF 3'),
            ],
          ),
          const SizedBox(height: 20),

          // Course Title
          _buildFieldLabel('COURSE TITLE'),
          const SizedBox(height: 8),
          _buildTextField(
            key: const ValueKey('course-title-input'),
            controller: _titleCtrl,
            hint: 'UX Design Systems & Motion Mastery',
          ),
          const SizedBox(height: 16),

          // Category & Level (Two Columns)
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('CATEGORY'),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      value: _category,
                      items: _categories,
                      onChanged: (val) {
                        if (val != null) setState(() => _category = val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('LEVEL'),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      value: _level,
                      items: _levels,
                      onChanged: (val) {
                        if (val != null) setState(() => _level = val);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Course Description
          _buildFieldLabel('COURSE DESCRIPTION'),
          const SizedBox(height: 8),
          _buildTextField(
            key: const ValueKey('course-desc-input'),
            controller: _descCtrl,
            maxLines: 3,
            hint: 'Master comprehensive design systems...',
          ),
          const SizedBox(height: 16),

          // Price & Visibility (Two Columns)
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('PRICE (INR / ₹)'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      key: const ValueKey('course-price-input'),
                      controller: _priceCtrl,
                      hint: '₹ 4,999',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('VISIBILITY'),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      value: _visibility,
                      items: _visibilities,
                      onChanged: (val) {
                        if (val != null) setState(() => _visibility = val);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Step 2: Course Media & Lessons Card ───────────────────────────────────
  Widget _buildStep2Media() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Step Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      color: _purple,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        '2. COURSE MEDIA & LESSONS',
                        style: TextStyle(
                          color: _heading,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.2,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Upload lectures & materials',
                        style: TextStyle(
                          color: _muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              _buildStepBadge('STEP 2 OF 3'),
            ],
          ),
          const SizedBox(height: 18),

          // Upload Course Video / Syllabus Dotted Drop Zone
          CustomPaint(
            painter: _DottedBorderPainter(
              color: const Color(0xFFC7BFF8),
              strokeWidth: 1.5,
              gap: 4.0,
              radius: 18,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9FE),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: _purpleLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.cloud_upload_outlined,
                      color: _purple,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Upload Course Video / Syllabus',
                    style: TextStyle(
                      color: _heading,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Drag & drop MP4, PDF, or click to browse (Max 500MB)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _muted,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    key: const ValueKey('browse-files-btn'),
                    onTap: _addMockResource,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFDCDAF4)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.add, color: _purple, size: 16),
                          SizedBox(width: 4),
                          Text(
                            '+ Browse Files',
                            style: TextStyle(
                              color: _purple,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Uploaded Items Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'UPLOADED ITEMS (${_resources.length})',
                style: const TextStyle(
                  color: _heading,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9E5FD),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_resources.length} Files Active',
                  style: const TextStyle(
                    color: _purple,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Uploaded Items List
          for (final res in _resources)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _borderColor),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1EEFD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      res.isVideo
                          ? Icons.videocam_outlined
                          : Icons.insert_drive_file_outlined,
                      color: _purple,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          res.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _heading,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Text(
                              res.size,
                              style: const TextStyle(
                                color: _muted,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              res.isVideo ? Icons.check : Icons.circle,
                              size: res.isVideo ? 12 : 7,
                              color: _green,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              res.statusText,
                              style: const TextStyle(
                                color: _green,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    key: ValueKey('delete-resource-${res.id}'),
                    onTap: () => _removeResource(res.id),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: Color(0xFFB0AFC7),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 6),

          // Upload Additional Resource Button
          GestureDetector(
            key: const ValueKey('upload-additional-btn'),
            onTap: _addMockResource,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F5FD),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFDCDAF4),
                  style: BorderStyle.solid,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.add, color: _purple, size: 18),
                  SizedBox(width: 6),
                  Text(
                    '+ Upload Additional Resource',
                    style: TextStyle(
                      color: _heading,
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

  // ── Bottom Fixed Bar ──────────────────────────────────────────────────────
  Widget _buildBottomBar(bool isEditing) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: _borderColor)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Cancel Button
          GestureDetector(
            key: const ValueKey('cancel-btn'),
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFDCDAF4)),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF5B5975),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const Spacer(),

          // Save / Draft Button
          GestureDetector(
            key: const ValueKey('save-course-btn'),
            onTap: _saveCourse,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_purpleAccent, _purple],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _purple.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                isEditing ? 'Update Course' : 'Create Course',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _buildStepBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEAFE),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: _purple,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: _muted,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildTextField({
    Key? key,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _inputBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        key: key,
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(
          color: _heading,
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: _muted.withValues(alpha: 0.6),
            fontSize: 13,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: _inputBg,
        borderRadius: BorderRadius.circular(14),
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
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(14),
          items: items.map((e) {
            return DropdownMenuItem<String>(
              value: e,
              child: Text(
                e,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ─── Custom Painter for Dashed Rounded Border ────────────────────────────────
class _DottedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double radius;

  _DottedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final length = 6.0;
        final extract = metric.extractPath(distance, distance + length);
        canvas.drawPath(extract, paint);
        distance += length + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
