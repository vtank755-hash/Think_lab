import 'package:flutter/material.dart';

import 'course.dart';
import 'course_details.dart';

const _heading = Color(0xFF2B2356);
const _muted = Color(0xFF9A96B8);
const _purple = Color(0xFF6B45F0);
const _star = Color(0xFFF5A623);

/// The course list for a single category.
///
/// Reusable for every category on the Categories screen:
///
/// ```dart
/// CategoryCoursesPage(category: 'Development')   // only Development courses
/// CategoryCoursesPage(category: 'Design')        // only Design courses
/// ```
///
/// The list is filtered straight from the shared [allCourses] data — nothing
/// is hardcoded — and every card opens the dynamic [CourseDetails] page with
/// that exact course (including its own price).
class CategoryCoursesPage extends StatefulWidget {
  final String category;

  const CategoryCoursesPage({super.key, required this.category});

  @override
  State<CategoryCoursesPage> createState() => _CategoryCoursesPageState();
}

class _CategoryCoursesPageState extends State<CategoryCoursesPage> {
  final _search = TextEditingController();
  bool _showSearch = false;

  /// The category's courses, optionally narrowed down by the filter field.
  List<Course> get _courses {
    final query = _search.text.trim().toLowerCase();
    return coursesInCategory(widget.category)
        .where(
          (c) =>
              query.isEmpty ||
              c.title.toLowerCase().contains(query) ||
              c.instructor.toLowerCase().contains(query),
        )
        .toList();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final courses = _courses;
    final total = coursesInCategory(widget.category).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F1FF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(total),
            if (_showSearch) _searchField(),
            Expanded(
              child: courses.isEmpty
                  ? _emptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(18, 12, 18, 22),
                      itemCount: courses.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) =>
                          _CourseCard(course: courses[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------- header

  Widget _header(int total) {
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _heading,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                // Headline total: the real number of courses in this category.
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEE9FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    courseTotalLabel(widget.category),
                    style: const TextStyle(
                      color: _purple,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() {
              _showSearch = !_showSearch;
              if (!_showSearch) _search.clear();
            }),
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _showSearch ? Icons.close_rounded : Icons.tune_rounded,
                color: _heading,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 4),
      child: TextField(
        controller: _search,
        autofocus: true,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(color: _heading, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search in ${widget.category}',
          hintStyle: const TextStyle(color: _muted, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: _muted),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------- empty state

  Widget _emptyState() {
    final filtering = _search.text.trim().isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: Color(0xFFEEE9FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                color: _purple,
                size: 40,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              filtering ? 'No matching courses' : 'No courses yet',
              style: const TextStyle(
                color: _heading,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              filtering
                  ? 'Try a different search inside ${widget.category}.'
                  : '${widget.category} has no courses at the moment.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: _muted, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------- course card

class _CourseCard extends StatelessWidget {
  final Course course;

  const _CourseCard({required this.course});

  void _openDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CourseDetails(course: course)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openDetails(context),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                course.image,
                width: 84,
                height: 84,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 84,
                  height: 84,
                  color: const Color(0xFFEEE9FF),
                  child: const Icon(Icons.play_circle_outline, color: _purple),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _heading,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'By ${course.instructor}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _muted, fontSize: 12),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: _star, size: 15),
                      const SizedBox(width: 3),
                      Text(
                        course.rating,
                        style: const TextStyle(
                          color: _heading,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.people_alt_outlined,
                        color: _muted,
                        size: 14,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        course.students,
                        style: const TextStyle(color: _muted, fontSize: 11),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.schedule_rounded,
                        color: _muted,
                        size: 14,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        course.duration,
                        style: const TextStyle(color: _muted, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        course.price,
                        style: const TextStyle(
                          color: _purple,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      _favoriteButton(context),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shared favourite state — the same heart as the home and details pages.
  Widget _favoriteButton(BuildContext context) {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: favoriteIds,
      builder: (context, ids, _) {
        final liked = ids.contains(course.id);
        return GestureDetector(
          onTap: () => toggleFavorite(course),
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Icon(
              liked ? Icons.favorite : Icons.favorite_border,
              color: liked ? const Color(0xFFFF4D6D) : _muted,
              size: 20,
            ),
          ),
        );
      },
    );
  }
}
