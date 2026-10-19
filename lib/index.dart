import 'package:flutter/material.dart';
import 'categories.dart';
import 'cart.dart';
import 'cart_page.dart';
import 'course.dart';
import 'course_details.dart';
import 'searches.dart';
import 'my_learning_page.dart';
import 'open_lesson.dart';
import 'progress.dart';
import 'session.dart';
import 'widgets/nav_bar.dart';
import 'wishlist_page.dart';

const _purple = Color(0xFF6B45F0);
const _purpleDark = Color(0xFF5A36E0);
const _pageBg = Color(0xFFF7F6FC);
const _title = Color(0xFF1C1C28);
const _grey = Color(0xFF8E8EA9);
const _chipBg = Color(0xFFF1F0F8);
const _star = Color(0xFFF5A623);

// =====================================================
// UI STRUCTURE (SCREEN VIEW)
//  1. Header                -> Row + Image.asset + Text + cart badge + bell icon
//  2. Search bar            -> GestureDetector + Container + Icon + Text, tap -> Search
//  3. Offer banner          -> Container + Stack + Text "LIMITED OFFER"
//  4. Categories header     -> Row + Text "Categories" + "See all", tap -> Categories
//  5. Category chips        -> ListView + Container + Icon + Text, tap -> Categories
//  6. Popular Courses       -> Row title + horizontal ListView of course cards
//  7. Course card           -> Container + Image.asset + rating row, tap -> Course Details
//  8. Continue Learning     -> ValueListenableBuilder + LinearProgressIndicator
//  9. Recommended           -> Row title + course cards, tap -> Course Details
// 10. Bottom navigation     -> NavBar tabs: Home, My Learning, Wishlist, Profile
// =====================================================
// HOME PAGE
// Shows banner, categories, popular courses and the
// course the user can continue learning.
// =====================================================

/// HOME SHELL PAGE (StatefulWidget) - class HomePage
/// StatefulWidget is used here because this page is the main shell of the
/// app: it holds the bottom navigation, so the body rebuilds on every tab
/// tap. The cart icon also listens to the cart, so its badge count updates
/// by itself.
/// Tabs: 0 = Home, 1 = My Learning, 2 = Wishlist, 3 = Profile (placeholder).
/// Layout: Scaffold -> SafeArea -> tab body + NavBar at the bottom.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Which bottom tab is open: 0 = Home, 1 = Learning, 2 = Wishlist, 3 = Profile.
  int _tab = 0;
  // Which category icon is highlighted (purple) in the category row.
  int _cat = 1;

  // The 5 category icons shown in the horizontal list on the Home tab.
  final _cats = const [
    {'name': 'Dev', 'icon': Icons.code},
    {'name': 'Design', 'icon': Icons.layers_outlined},
    {'name': 'Marketing', 'icon': Icons.campaign_outlined},
    {'name': 'Business', 'icon': Icons.work_outline},
    {'name': 'AI & Tech', 'icon': Icons.memory_outlined},
  ];

  void _openSearches() {
    // Search icon tapped -> Open the Search page.
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SearchPage()),
    );
  }

  /// Opens the full details page for a course card.
  void _openCourse(Course course) {
    // Course card tapped -> Open the Course Details page.
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CourseDetails(course: course)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold -> SafeArea -> body of the open tab, NavBar pinned at the bottom.
    return Scaffold(
      backgroundColor: _pageBg,
      body: SafeArea(child: _body()),
      bottomNavigationBar: NavBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
      ),
    );
  }

  /// Tab 0 = home, tab 1 = My Learning, tab 2 = the Wishlist screen, tab 3
  /// still shows its placeholder.
  Widget _body() {
    if (_tab == 0) return _home();
    if (_tab == 1) {
      return MyLearningPage(onBack: () => setState(() => _tab = 0));
    }
    if (_tab == 2) {
      return WishlistPage(onBack: () => setState(() => _tab = 0));
    }
    return _otherTab();
  }

  // The Home tab: one scrolling Column with all home sections inside it.
  Widget _home() {
    // SingleChildScrollView = makes the whole Home tab scroll vertically.
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      // Column = stacks every home section top to bottom.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          const SizedBox(height: 18),
          _searchRow(),
          const SizedBox(height: 18),
          _offerBanner(),
          const SizedBox(height: 22),
          // Row = "Categories" title, spacer, then the "See all" link.
          Row(
            children: [
              const Text(
                'Categories',
                style: TextStyle(
                  color: _title,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              // GestureDetector = makes "See all" tappable.
              GestureDetector(
                onTap: () {
                  // Categories "See all" tapped -> Open Categories page.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CategoriesPage(),
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Text(
                    'See all',
                    style: TextStyle(
                      color: _purple,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _categories(),
          const SizedBox(height: 22),
          _rowTitle('Popular Courses', onSeeAll: _openSearches),
          const SizedBox(height: 14),
          _popular(),
          const SizedBox(height: 22),
          _rowTitle('Continue Learning', onSeeAll: _openSearches),
          const SizedBox(height: 14),
          _continueCard(courseById('c5')),
          const SizedBox(height: 22),
          // GestureDetector = makes the whole "Recommended" header tappable.
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _openSearches,
            child: const Row(
              children: [
                Text(
                  'Recommended',
                  style: TextStyle(
                    color: _title,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Spacer(),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Text(
                    'See all',
                    style: TextStyle(
                      color: _purple,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _recoCard(courseById('c3')),
          const SizedBox(height: 12),
          _recoCard(courseById('c4')),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // Top row: avatar, greeting, cart icon with live count, notification icon.
  Widget _header() {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(28),
          // Image.asset = the user's round profile photo.
          child: Image.asset(
            'assets/images/profile/avatar.jpg',
            width: 48,
            height: 48,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              width: 48,
              height: 48,
              color: _purple,
              child: const Icon(Icons.person, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Expanded = greeting fills the free space between avatar and icons.
        const Expanded(
          // Column = "Good morning," line above the user's name.
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good morning,',
                style: TextStyle(color: _grey, fontSize: 13),
              ),
              SizedBox(height: 2),
              Text(
                'Aarav Sharma',
                style: TextStyle(
                  color: _title,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        // Shopping cart with a live count of the courses inside it.
        ValueListenableBuilder<Set<String>>(
          valueListenable: cartIds,
          builder: (context, ids, _) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              // Cart icon tapped -> Open the Cart page.
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartPage()),
              ),
              // Stack = red count badge overlaps the cart icon.
              child: Stack(
                children: [
                  // Container = white circle holding the cart icon.
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      color: _purple,
                    ),
                  ),
                  if (ids.isNotEmpty)
                    // Positioned = pins the count badge to the top-right.
                    Positioned(
                      right: 2,
                      top: 2,
                      // Container = red circle behind the item count.
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF4D6D),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${ids.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        const SizedBox(width: 10),
        // Stack = unread dot overlaps the bell icon.
        Stack(
          children: [
            // Container = white circle holding the bell icon.
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: _purple,
              ),
            ),
            // Positioned = pins the red dot onto the bell.
            Positioned(
              right: 11,
              top: 11,
              // Container = tiny red "new notification" dot.
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF4D6D),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Search bar row. Tapping it opens the Searches page.
  Widget _searchRow() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _openSearches,
      child: Row(
        children: [
          // Expanded = search box takes the free width.
          Expanded(
            // Container = white rounded search field box.
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              // Row = search icon + placeholder text side by side.
              child: const Row(
                children: [
                  Icon(Icons.search, color: _grey),
                  SizedBox(width: 8),
                  Text(
                    'Search courses, topics...',
                    style: TextStyle(color: _grey, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Container = purple filter (tune) button.
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _purple,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.tune_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // Purple "LIMITED OFFER" banner. A Stack puts decorative circles behind the text.
  Widget _offerBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_purple, _purpleDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          // Positioned = decorative circle behind the banner text.
          Positioned(
            right: -10,
            top: -20,
            // Container = translucent white circle decoration.
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -40,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Column = offer badge, headline and call to action.
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Container = pill behind the "LIMITED OFFER" text.
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'LIMITED OFFER',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Get 40% OFF on all\nDesign courses',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Explore Now  →',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Reusable "section title + See all" row, used by every home section.
  Widget _rowTitle(String title, {VoidCallback? onSeeAll}) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _title,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onSeeAll,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Text(
              'See all',
              style: TextStyle(
                color: _purple,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Horizontal ListView of category icons; tapping one opens the Categories page.
  Widget _categories() {
    return SizedBox(
      height: 86,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _cats.length,
        separatorBuilder: (_, _) => const SizedBox(width: 16),
        itemBuilder: (context, i) {
          final selected = i == _cat;
          // GestureDetector = makes one category chip tappable.
          return GestureDetector(
            onTap: () {
              setState(() {
                _cat = i;
              });
              // Category icon tapped -> Open the course list of that category.
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CategoriesPage()),
              );
            },
            // Column = icon circle stacked above the category name.
            child: Column(
              children: [
                // Container = circular background for the category icon.
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: selected ? _purple : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: _purple.withValues(alpha: 0.28),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  // Icon = the category symbol (white when selected).
                  child: Icon(
                    _cats[i]['icon'] as IconData,
                    color: selected ? Colors.white : _purple,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _cats[i]['name'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? _title : _grey,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Horizontal ListView with the two Popular Courses cards.
  Widget _popular() {
    return SizedBox(
      height: 230,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _popCard(courseById('c1')),

          const SizedBox(width: 14),
          _popCard(courseById('c2')),
        ],
      ),
    );
  }

  /// Popular Courses card: renders [course] and opens that course's page.
  Widget _popCard(Course course) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openCourse(course),
      // Container = white rounded Popular Course card.
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        // Column = course image stacked above the course details.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stack = category badge overlaps the course image.
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  // Image.asset = the course cover photo.
                  child: Image.asset(
                    course.image,
                    height: 112,
                    width: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        Container(height: 112, color: const Color(0xFFE8E6F5)),
                  ),
                ),
                // Positioned = pins the category badge top-left on the image.
                Positioned(
                  left: 10,
                  top: 10,
                  // Container = small white category badge.
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      course.category,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _title,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              // Column = title, instructor, then the rating/price row.
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _title,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'By ${course.instructor}',
                    style: const TextStyle(fontSize: 11, color: _grey),
                  ),
                  const SizedBox(height: 8),
                  // Row = star rating + students, then price on the right.
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 16, color: _star),
                      const SizedBox(width: 3),
                      Text(
                        course.rating,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '(${course.students})',
                        style: const TextStyle(fontSize: 11, color: _grey),
                      ),
                      const Spacer(),
                      Text(
                        course.price,
                        style: const TextStyle(
                          color: _purple,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
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

  /// Continue Learning card: the course the user is working through.
  /// Continue Learning card.
  ///
  /// Shows this user's REAL course progress (never a fixed 65%) and opens
  /// the lesson they stopped at — "Module 2 → Lesson 5" — for a purchased
  /// course. Without a resume point it falls back to the course details.
  Widget _continueCard(Course course) {
    return ValueListenableBuilder<Map<String, String>>(
      valueListenable: resumeOf(currentUser.value),
      builder: (context, resume, _) {
        return ValueListenableBuilder<Set<String>>(
          valueListenable: completedLessons,
          builder: (context, done, _) {
            final total = courseLessonCount(course);
            final completed = completedInCourse(course);
            final percent = progressPercent(completed, total);
            final point = resumePoint(course);

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _continueCourse(course),
              // Container = white rounded Continue Learning card.
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                // Row = course icon, progress details, then play button.
                child: Row(
                  children: [
                    // Container = rounded square holding the course icon.
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEE9FF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.auto_awesome_mosaic_outlined,
                        color: _purple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Expanded = progress details take the middle space.
                    Expanded(
                      // Column = title, resume label, then progress bar.
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: _title,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _resumeLabel(course, point),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11, color: _grey),
                          ),
                          const SizedBox(height: 10),
                          // Row = "Course Progress" label with the percent.
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Course Progress',
                                  style: TextStyle(fontSize: 10, color: _grey),
                                ),
                              ),
                              Text(
                                '$percent%',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _title,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            // LinearProgressIndicator = lessons completed bar.
                            child: LinearProgressIndicator(
                              value: total == 0 ? 0 : completed / total,
                              minHeight: 6,
                              color: _purple,
                              backgroundColor: const Color(0xFFEDEAF8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Container = round purple play / resume button.
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: _purple,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Subtitle of the Continue Learning card, e.g.
  /// `Module 2 · 5. Dictionaries` — read from the real learning data.
  String _resumeLabel(Course course, (String, String)? point) {
    if (point == null) return 'Not started yet';
    final mIndex = moduleIndexOf(course, point.$1);
    final lIndex = lessonIndexOf(course, point.$1, point.$2);
    if (mIndex < 0 || lIndex < 0) return 'Not started yet';
    return 'Module ${mIndex + 1} · '
        '${course.modules[mIndex].lessons[lIndex].title}';
  }

  /// Continue → the user's last watched lesson (or the first one) via the
  /// shared helper; locked or empty courses still open their details page.
  void _continueCourse(Course course) {
    if (openCourseLesson(context, course)) return;
    _openCourse(course);
  }

  /// Recommended course card: renders [course] and opens that course's page.
  Widget _recoCard(Course course) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openCourse(course),
      // Container = white rounded recommended-course card.
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        // Row = thumbnail, details, then the favourite heart.
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              // Image.asset = the small course thumbnail.
              child: Image.asset(
                course.image,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    Container(width: 72, height: 72, color: _chipBg),
              ),
            ),
            const SizedBox(width: 12),
            // Expanded = course text takes the middle of the card.
            Expanded(
              // Column = category tag, title, instructor, rating row.
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Container = light purple category tag background.
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEE9FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      course.category,
                      style: const TextStyle(
                        color: _purple,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    course.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _title,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'By ${course.instructor}',
                    style: const TextStyle(fontSize: 11, color: _grey),
                  ),
                  const SizedBox(height: 4),
                  // Row = star rating on the left, price on the right.
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: _star),
                      const SizedBox(width: 2),
                      Text(
                        course.rating,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        course.price,
                        style: const TextStyle(
                          color: _purple,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _favoriteIcon(course),
          ],
        ),
      ),
    );
  }

  /// Favourite heart shared with the details page and the search results.
  Widget _favoriteIcon(Course course) {
    // ValueListenableBuilder = redraws the heart when favourites change.
    return ValueListenableBuilder<Set<String>>(
      valueListenable: favoriteIds,
      builder: (context, ids, _) {
        final liked = ids.contains(course.id);
        // GestureDetector = tapping the heart toggles the favourite.
        return GestureDetector(
          onTap: () => toggleFavorite(course),
          child: Padding(
            padding: const EdgeInsets.only(left: 6, bottom: 40),
            child: Icon(
              liked ? Icons.favorite : Icons.favorite_border,
              color: liked ? const Color(0xFFFF4D6D) : _grey,
              size: 20,
            ),
          ),
        );
      },
    );
  }

  /// Placeholder screens for the tabs that are not built yet.
  Widget _otherTab() {
    final labels = ['Home', 'Learning', 'Wishlist', 'Profile'];
    return Center(
      child: Text(
        labels[_tab],
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: _title,
        ),
      ),
    );
  }
}
