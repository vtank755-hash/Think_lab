import 'package:flutter/material.dart';

import 'admin_course_delete.dart';
import 'create_course_quiz_page.dart';

// ─── Shared palette (kept in sync with admin_dashboard.dart) ───────────────
const _purple = Color(0xFF6B45F0);
const _heading = Color(0xFF1B1838);
const _muted = Color(0xFF8E8EA9);
const _pageBg = Color(0xFFF7F8FE);

// ─── Course status enum ─────────────────────────────────────────────────────

/// Status of an admin-managed course.
enum CourseStatus { active, draft }

// ─── In-memory course model ─────────────────────────────────────────────────

/// Represents a course entry in the admin's manage-courses list.
class AdminCourse {
  final String id;
  String title;
  String instructor;
  String students;
  String price;
  String imageAsset;
  CourseStatus status;
  String? category;
  String? level;
  String? description;
  String? visibility;

  AdminCourse({
    required this.id,
    required this.title,
    required this.instructor,
    required this.students,
    required this.price,
    required this.imageAsset,
    required this.status,
    this.category = 'Design & UI',
    this.level = 'Intermediate',
    this.description =
        'Master comprehensive design systems from token management to multi-brand components and interactive micro-interactions.',
    this.visibility = 'Public (Catalog)',
  });
}

// ─── Seed data for the demo list ────────────────────────────────────────────

/// Default list of courses shown in the admin panel.
/// Wrapped in a function so tests can reset it easily.
List<AdminCourse> buildDefaultCourses() => [
  AdminCourse(
    id: 'c1',
    title: 'Web Dev Bootcamp',
    instructor: 'Rohan Gupta',
    students: '12.4k students',
    price: '₹1,999',
    imageAsset: 'assets/images/courses/web_dev.jpg',
    status: CourseStatus.active,
  ),
  AdminCourse(
    id: 'c2',
    title: 'UI/UX Masterclass',
    instructor: 'Ananya Iyer',
    students: '8.1k students',
    price: '₹1,499',
    imageAsset: 'assets/images/courses/uiux.jpg',
    status: CourseStatus.active,
  ),
  AdminCourse(
    id: 'c3',
    title: 'Digital Marketing',
    instructor: 'Priya Menon',
    students: '5.6k students',
    price: '₹999',
    imageAsset: 'assets/images/courses/digital_marketing.jpg',
    status: CourseStatus.draft,
  ),
];

// ─── Page widget ────────────────────────────────────────────────────────────

/// **Admin Manage Courses** screen.
///
/// Lists all courses with search, status badge, edit & delete actions.
/// Accessible from the Admin Dashboard bottom nav (Courses tab, index 1).
class AdminCoursesPage extends StatefulWidget {
  const AdminCoursesPage({super.key});

  @override
  State<AdminCoursesPage> createState() => _AdminCoursesPageState();
}

class _AdminCoursesPageState extends State<AdminCoursesPage> {
  /// Full course list (mutated by add / delete).
  final List<AdminCourse> _allCourses = buildDefaultCourses();

  /// Live search query typed into the search bar.
  String _query = '';

  /// Controller for the search text field.
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Derived list (filtered by search query) ───────────────────────────────

  /// Returns [_allCourses] filtered by [_query] (case-insensitive).
  List<AdminCourse> get _filtered {
    if (_query.isEmpty) return _allCourses;
    final q = _query.toLowerCase();
    return _allCourses
        .where(
          (c) =>
              c.title.toLowerCase().contains(q) ||
              c.instructor.toLowerCase().contains(q),
        )
        .toList();
  }

  // ── Delete course ─────────────────────────────────────────────────────────

  /// Shows a confirmation dialog, then removes [course] from [_allCourses].
  Future<void> _confirmDelete(AdminCourse course) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const AdminCourseDeleteDialog(),
    );
    if (!mounted || confirmed != true) return;

    setState(() => _allCourses.remove(course));
    _showSnack('${course.title} deleted.');
  }

  // ── Edit course ───────────────────────────────────────────────────────────

  /// Opens the CreateCourseQuizPage to edit [course].
  void _openEditSheet(AdminCourse course) async {
    final updated = await Navigator.push<AdminCourse>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateCourseQuizPage(initialCourse: course),
      ),
    );
    if (updated != null) {
      setState(() {
        course.title = updated.title;
        course.price = updated.price;
        course.status = updated.status;
        course.category = updated.category;
        course.level = updated.level;
        course.description = updated.description;
        course.visibility = updated.visibility;
      });
      _showSnack('${course.title} updated.');
    }
  }

  // ── Add course ────────────────────────────────────────────────────────────

  /// Opens the CreateCourseQuizPage as a full-screen page to create a new course.
  void _openCreateCoursePage() async {
    final newCourse = await Navigator.push<AdminCourse>(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateCourseQuizPage(),
      ),
    );
    if (newCourse != null) {
      setState(() => _allCourses.add(newCourse));
      _showSnack('"${newCourse.title}" added successfully.');
    }
  }

  // ── Snack helper ──────────────────────────────────────────────────────────

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

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final courses = _filtered;

    return Column(
      children: [
        // ── Page header ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Manage Courses',
                  style: TextStyle(
                    color: _heading,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
              // ── Add button ───────────────────────────────────────────
              Material(
                color: Colors.transparent,
                child: InkWell(
                  key: const ValueKey('add-course-button'),
                  borderRadius: BorderRadius.circular(20),
                  onTap: _openCreateCoursePage,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFF6B45F0)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: _purple.withValues(alpha: 0.28),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Add',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Search bar ───────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              key: const ValueKey('course-search-field'),
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              style: const TextStyle(color: _heading, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search courses...',
                hintStyle: TextStyle(
                  color: _muted.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: _muted.withValues(alpha: 0.7),
                  size: 22,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),

        // ── Course list ──────────────────────────────────────────────────
        Expanded(
          child: courses.isEmpty
              ? Center(
                  child: Text(
                    'No courses found.',
                    style: TextStyle(
                      color: _muted.withValues(alpha: 0.7),
                      fontSize: 15,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  itemCount: courses.length,
                  itemBuilder: (ctx, i) => _CourseCard(
                    key: ValueKey('course-card-${courses[i].id}'),
                    course: courses[i],
                    onEdit: () => _openEditSheet(courses[i]),
                    onDelete: () => _confirmDelete(courses[i]),
                  ),
                ),
        ),
      ],
    );
  }

  // ── Shared sheet helpers ──────────────────────────────────────────────────

  /// Labelled text field for bottom-sheet forms.
  Widget _sheetField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _muted,
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8FE),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E0F4)),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(color: _heading, fontSize: 14),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Pill-shaped status toggle button for the bottom-sheet form.
  Widget _statusToggle({
    required String label,
    required bool selected,
    required Color activeColor,
    required Color activeBg,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? activeBg : const Color(0xFFF7F8FE),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? activeColor.withValues(alpha: 0.4) : const Color(0xFFE2E0F4),
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

// ─── Course card widget ──────────────────────────────────────────────────────

/// A single card in the course list showing thumbnail, title, instructor,
/// students, price, status badge, and edit/delete action buttons.
class _CourseCard extends StatelessWidget {
  final AdminCourse course;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CourseCard({
    super.key,
    required this.course,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = course.status == CourseStatus.active;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Course thumbnail ───────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: _CourseThumbnail(assetPath: course.imageAsset),
          ),
          const SizedBox(width: 14),

          // ── Course details ─────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + status badge in the same row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        course.title,
                        style: const TextStyle(
                          color: _heading,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFFE5F8EE)
                            : const Color(0xFFFFF8E6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        isActive ? 'Active' : 'Draft',
                        style: TextStyle(
                          color: isActive
                              ? const Color(0xFF25A55F)
                              : const Color(0xFFF59E0B),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Instructor · Students
                Text(
                  '${course.instructor} · ${course.students}',
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),

                // Price + action buttons
                Row(
                  children: [
                    Text(
                      course.price,
                      style: const TextStyle(
                        color: _purple,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),

                    // Edit button
                    _ActionButton(
                      key: ValueKey('edit-${course.id}'),
                      icon: Icons.edit_outlined,
                      iconColor: const Color(0xFF6B45F0),
                      bgColor: const Color(0xFFEEECFA),
                      onTap: onEdit,
                    ),
                    const SizedBox(width: 8),

                    // Delete button
                    _ActionButton(
                      key: ValueKey('delete-${course.id}'),
                      icon: Icons.delete_outline_rounded,
                      iconColor: const Color(0xFFF04438),
                      bgColor: const Color(0xFFFEECEB),
                      onTap: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Thumbnail helper ─────────────────────────────────────────────────────────

/// Shows the course thumbnail from assets, falling back gracefully if missing.
class _CourseThumbnail extends StatelessWidget {
  final String assetPath;
  const _CourseThumbnail({required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: Image.asset(
        assetPath,
        fit: BoxFit.cover,
        // Graceful fallback when the asset is missing (e.g., in tests).
        errorBuilder: (_, __, ___) => Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFFEEECFA),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.menu_book_outlined,
            color: _purple,
            size: 32,
          ),
        ),
      ),
    );
  }
}

// ─── Circular action button ───────────────────────────────────────────────────

/// Small circular icon button used for edit and delete actions on a course card.
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final VoidCallback onTap;

  const _ActionButton({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 18),
      ),
    );
  }
}
