import 'package:flutter/material.dart';

import 'course.dart';
import 'course_details.dart';

const _heading = Color(0xFF2B2356);
const _muted = Color(0xFF9A96B8);
const _accent = Color(0xFF7B5CFF);
const _purple = Color(0xFF6B45F0);
const _chipBg = Color(0xFFF4F1FF);
const _star = Color(0xFFF5A623);

// Suggested search words, shown on the page as tappable chips.
const _recentSearches = ['Python', 'Design', 'Marketing', 'Business'];
const _popularSearches = [
  'Development',
  'UI/UX',
  'IT & Software',
  'Productivity',
];

// =====================================================
// UI STRUCTURE (SCREEN VIEW)
//  1. Back button           -> GestureDetector + Container + Icon, tap -> back
//  2. Search field          -> TextField + controller + clear Icon, live results
//  3. Filter button         -> Container + Icon (tune)
//  4. Recent title          -> Text "Recent Searches"
//  5. Recent chips          -> Row of Container + Text, tap -> runs search
//  6. Popular title         -> Text "Popular Searches"
//  7. Popular chips         -> Row of Container + Text, tap -> runs search
//  8. Results title         -> Text "Results (n)" or "Search Courses"
//  9. Result card           -> Container + Image.asset + rating row, tap -> Course Details
// 10. Empty state           -> Icon + Text "Start typing to find courses"
// =====================================================
// SEARCH PAGE
// Shows the courses that match what the user typed.
// =====================================================
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // TextEditingController stores what the user types in the search box.
  final searchBox = TextEditingController();

  // Free the controller when this page is closed.
  @override
  void dispose() {
    searchBox.dispose();
    super.dispose();
  }

  // Keep only the courses that match the typed text.
  List<Course> get _results =>
      allCourses.where((c) => c.matches(searchBox.text)).toList();

  // Put the tapped chip word into the search box and rebuild the page.
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
      // Scaffold = the whole Search page (white background + body).
      backgroundColor: Colors.white,
      // SafeArea = keeps content away from the notch / status bar.
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
          // Column -> search bar, chips, then the result list.
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

  // Row -> back button, search field, and the filter button.
  Widget _searchBar() {
    return Row(
      children: [
        // GestureDetector = taps return to the previous page.
        GestureDetector(
          onTap: () => Navigator.pop(context),
          // Container = circle behind the back icon.
          child: Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: _chipBg,
              shape: BoxShape.circle,
            ),
            // Icon = the arrow symbol inside the circle.
            child: const Icon(Icons.swap_horiz, color: _heading, size: 22),
          ),
        ),
        const SizedBox(width: 10),
        // Expanded = stretches the search box to fill the row.
        Expanded(
          // Container = the rounded pill around the search input.
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: _chipBg,
              borderRadius: BorderRadius.circular(24),
            ),
            // Row = search icon, text field and clear cross side by side.
            child: Row(
              children: [
                // Icon = magnifier symbol at the start of the search box.
                const Icon(Icons.search, color: _accent, size: 22),
                const SizedBox(width: 8),
                // TextField = where the user types the search words.
                Expanded(
                  child: TextField(
                    controller: searchBox,
                    // Rebuild the page on every keystroke so results update live.
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
                  // Small cross that clears the search box.
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
        // Container = purple rounded filter button.
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: _purple,
            borderRadius: BorderRadius.circular(16),
          ),
          // Icon = filter (tune) symbol on the button.
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

  // Horizontal row of tappable chips. Tapping one runs a search.
  Widget _chipRow(List<String> chips) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      // Row = the chip words placed side by side.
      child: Row(
        children: [
          for (var i = 0; i < chips.length; i++) ...[
            if (i != 0) const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _runSearch(chips[i]),
              // Container = rounded pill behind each chip word.
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

  // Shown when the box is empty or no course matched the search.
  Widget _emptyState() {
    final query = searchBox.text.trim();
    // Container = light rounded box holding the empty message.
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 18),
      decoration: BoxDecoration(
        color: _chipBg,
        borderRadius: BorderRadius.circular(22),
      ),
      // Column = stacks the icon and the two message lines.
      child: Column(
        children: [
          // Icon = "no results" magnifier symbol.
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

  // One white card for a single search result.
  Widget _courseCard(Course course) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      // Search result tapped -> Open the Course Details page.
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CourseDetails(course: course)),
      ),
      // Container = the white rounded result card.
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
        // Row = thumbnail, course info and favourite heart on one line.
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              // Image.asset = the course's thumbnail picture.
              child: Image.asset(
                course.image,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                // Container = fallback box when the image fails to load.
                errorBuilder: (_, _, _) => Container(
                  width: 72,
                  height: 72,
                  color: _chipBg,
                  child: const Icon(Icons.play_circle_outline, color: _accent),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Expanded = gives the course text the remaining width.
            Expanded(
              // Column = stacks title, instructor and rating row.
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
                  // Row = star, rating, category tag and price on one line.
                  Row(
                    children: [
                      // Icon = the rating star.
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
                      // Container = small rounded tag for the course category.
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
            // ValueListenableBuilder = rebuilds the heart when favourites change.
            ValueListenableBuilder<Set<String>>(
              valueListenable: favoriteIds,
              builder: (context, ids, _) {
                final liked = ids.contains(course.id);
                // GestureDetector = taps toggle this course as a favourite.
                return GestureDetector(
                  onTap: () => toggleFavorite(course),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6, bottom: 36),
                    // Icon = filled or outline heart showing the liked state.
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
