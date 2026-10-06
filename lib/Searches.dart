import 'package:flutter/material.dart';

import 'course.dart';
import 'course_details.dart';

const _heading = Color(0xFF2B2356);
const _muted = Color(0xFF9A96B8);
const _accent = Color(0xFF7B5CFF);
const _purple = Color(0xFF6B45F0);
const _chipBg = Color(0xFFF4F1FF);
const _star = Color(0xFFF5A623);

const _recentSearches = ['Python', 'Design', 'Marketing', 'Business'];
const _popularSearches = [
  'Development',
  'UI/UX',
  'IT & Software',
  'Productivity',
];

// =====================================================
// SEARCH PAGE
// Shows the courses that match what the user typed.
// =====================================================
class Searches extends StatefulWidget {
  const Searches({super.key});

  @override
  State<Searches> createState() => _SearchesState();
}

class _SearchesState extends State<Searches> {
  final searchBox = TextEditingController();

  @override
  void dispose() {
    searchBox.dispose();
    super.dispose();
  }

  List<Course> get _results =>
      allCourses.where((c) => c.matches(searchBox.text)).toList();

  void _runSearch(String query) {
    setState(() => searchBox.text = query);
  }

  @override
  Widget build(BuildContext context) {
    // Results are only shown for what the user actually searched for.
    final query = searchBox.text.trim();
    final searching = query.isNotEmpty;
    final results = searching ? _results : const <Course>[];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _searchBar(),
              const SizedBox(height: 22),
              _sectionTitle('Recent Searches'),
              const SizedBox(height: 10),
              _chipRow(_recentSearches),
              const SizedBox(height: 20),
              _sectionTitle('Popular Searches'),
              const SizedBox(height: 10),
              _chipRow(_popularSearches),
              const SizedBox(height: 22),
              _sectionTitle(
                searching ? 'Results (${results.length})' : 'Search Courses',
              ),
              const SizedBox(height: 14),
              if (results.isEmpty)
                _emptyState()
              else ...[
                for (var i = 0; i < results.length; i++) ...[
                  _courseCard(results[i]),
                  if (i != results.length - 1) const SizedBox(height: 12),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: _chipBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.swap_horiz, color: _heading, size: 22),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: _chipBg,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: _accent, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: searchBox,
                    onChanged: (_) => setState(() {}),
                    textInputAction: TextInputAction.search,
                    cursorColor: _accent,
                    style: const TextStyle(
                      color: _accent,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      hintText: 'Search courses, topics...',
                      hintStyle: TextStyle(color: _muted, fontSize: 14),
                    ),
                  ),
                ),
                if (searchBox.text.isNotEmpty)
                  GestureDetector(
                    onTap: () => setState(() => searchBox.clear()),
                    child: const Icon(
                      Icons.close_rounded,
                      color: _muted,
                      size: 18,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: _purple,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.tune_rounded, color: Colors.white),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: _heading,
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _chipRow(List<String> chips) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < chips.length; i++) ...[
            if (i != 0) const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _runSearch(chips[i]),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: _chipBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  chips[i],
                  style: const TextStyle(color: _accent, fontSize: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _emptyState() {
    final query = searchBox.text.trim();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 18),
      decoration: BoxDecoration(
        color: _chipBg,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded, color: _accent, size: 40),
          const SizedBox(height: 12),
          Text(
            query.isEmpty
                ? 'Start typing to find courses'
                : 'No courses found for "$query"',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _heading,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try a different keyword, tag or instructor.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _muted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _courseCard(Course course) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      // Search result tapped -> Open the Course Details page.
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CourseDetails(course: course)),
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                course.image,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 72,
                  height: 72,
                  color: _chipBg,
                  child: const Icon(Icons.play_circle_outline, color: _accent),
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
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'By ${course.instructor}',
                    style: const TextStyle(color: _muted, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 16, color: _star),
                      const SizedBox(width: 3),
                      Text(
                        course.rating,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _chipBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          course.category,
                          style: const TextStyle(
                            color: _accent,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        course.price,
                        style: const TextStyle(
                          color: _purple,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ValueListenableBuilder<Set<String>>(
              valueListenable: favoriteIds,
              builder: (context, ids, _) {
                final liked = ids.contains(course.id);
                return GestureDetector(
                  onTap: () => toggleFavorite(course),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6, bottom: 36),
                    child: Icon(
                      liked ? Icons.favorite : Icons.favorite_border,
                      color: const Color(0xFFFF4D6D),
                      size: 22,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
