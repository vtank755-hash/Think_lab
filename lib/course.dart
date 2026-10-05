import 'package:flutter/foundation.dart';

import 'session.dart';

/// A single lesson/module inside a course curriculum.
class Lesson {
  final String title;
  final String meta;

  const Lesson(this.title, this.meta);
}

/// The complete data for one course.
///
/// Every screen renders from this object and the details page receives it
/// whole — there is no fixed/hardcoded course content anywhere else:
///
/// ```dart
/// CourseCard(course: course, onTap: () => CourseDetails(course: course))
/// ```
class Course {
  /// Unique identifier, also the key for the shared favourite state.
  final String id;
  final String title;
  final String category;
  final String image;
  final String instructor;
  final String instructorRole;
  final String rating;
  final String students;
  final String duration;
  final String description;

  /// Price of THIS course, e.g. `₹999`. Never shared between courses.
  final String price;

  /// Whether this course starts out as a favourite.
  final bool isFavorite;
  final List<Lesson> lessons;

  const Course({
    required this.id,
    required this.title,
    required this.category,
    required this.image,
    required this.instructor,
    required this.instructorRole,
    required this.rating,
    required this.students,
    required this.duration,
    required this.description,
    required this.price,
    this.isFavorite = false,
    this.lessons = const [],
  });

  /// Case-insensitive match against title, category and instructor.
  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return title.toLowerCase().contains(q) ||
        category.toLowerCase().contains(q) ||
        instructor.toLowerCase().contains(q);
  }

  Course copyWith({bool? isFavorite}) => Course(
    id: id,
    title: title,
    category: category,
    image: image,
    instructor: instructor,
    instructorRole: instructorRole,
    rating: rating,
    students: students,
    duration: duration,
    description: description,
    price: price,
    isFavorite: isFavorite ?? this.isFavorite,
    lessons: lessons,
  );
}

/// Every user's wishlist: `userId -> the ids of their saved courses`.
///
/// The wishlist is scoped to the signed-in user, so two accounts saved on the
/// same device keep separate lists.
final _wishlistByUser = <String, ValueNotifier<Set<String>>>{};

/// The wishlist of [userId], keyed by course id (never by title).
///
/// A user's wishlist starts out with the courses flagged `isFavorite: true`
/// in the data.
ValueNotifier<Set<String>> wishlistOf(String userId) =>
    _wishlistByUser.putIfAbsent(
      userId,
      () => ValueNotifier<Set<String>>(
        Set.of(allCourses.where((c) => c.isFavorite).map((c) => c.id)),
      ),
    );

/// The current user's wishlist.
///
/// The name is unchanged, so every screen that already listens to it keeps
/// working as-is:
///
/// ```dart
/// ValueListenableBuilder<Set<String>>(valueListenable: favoriteIds, ...)
/// ```
ValueNotifier<Set<String>> get favoriteIds => wishlistOf(currentUser.value);

/// Live favourite flag for a course of the CURRENT user.
bool isFavorite(Course course) => favoriteIds.value.contains(course.id);

/// Saves / unsaves a course in the current user's wishlist (by course id).
void toggleFavorite(Course course) {
  final wishlist = favoriteIds;
  final next = Set<String>.of(wishlist.value);
  if (!next.remove(course.id)) next.add(course.id);
  wishlist.value = next;
}

/// Restores the default wishlist of every user — tests only.
void resetFavorites() => _wishlistByUser.clear();

/// Every course in the app — the single source of truth.
/// Exactly six courses, distributed across the six categories.
const allCourses = <Course>[
  Course(
    id: 'c1',
    title: 'Complete Web Development Bootcamp',
    category: 'Development',
    image: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=400',
    instructor: 'Rohan Gupta',
    instructorRole: 'Senior Full-Stack Developer',
    rating: '4.8',
    students: '12.4k',
    duration: '42h',
    description:
        'Master HTML, CSS, JavaScript, React and Node.js. Build 15 real-world '
        'projects and become a job-ready full-stack developer.',
    price: '₹1,999',
    isFavorite: true,
    lessons: [
      Lesson('1. Introduction to HTML', '12 lessons · 3h 20m'),
      Lesson('2. Styling with CSS', '14 lessons · 4h 05m'),
      Lesson('3. JavaScript Fundamentals', '18 lessons · 5h 40m'),
      Lesson('4. React in Practice', '16 lessons · 6h 15m'),
      Lesson('5. Node.js & APIs', '12 lessons · 4h 30m'),
    ],
  ),
  Course(
    id: 'c2',
    title: 'UI/UX Design Masterclass',
    category: 'Design',
    image: 'https://images.unsplash.com/photo-1581291518857-4d859fc9e0b5?w=400',
    instructor: 'Sarah Jenkins',
    instructorRole: 'Product Designer',
    rating: '4.9',
    students: '11.3k',
    duration: '22h',
    description:
        'Research, wireframe, prototype and test interfaces that people '
        'actually enjoy using — with Figma throughout.',
    price: '₹1,499',
    lessons: [
      Lesson('1. Design Thinking', '9 lessons · 2h 10m'),
      Lesson('2. Wireframes & Flows', '12 lessons · 3h 30m'),
      Lesson('3. Prototyping in Figma', '15 lessons · 4h 45m'),
      Lesson('4. Usability Testing', '8 lessons · 2h 20m'),
    ],
  ),
  Course(
    id: 'c3',
    title: 'Digital Marketing Fundamentals',
    category: 'Marketing',
    image: 'https://images.unsplash.com/photo-1552664730-d307ca884978?w=400',
    instructor: 'Priya Menon',
    instructorRole: 'Marketing Strategist',
    rating: '4.7',
    students: '6.9k',
    duration: '20h',
    description:
        'SEO, social, email and paid campaigns in one practical roadmap, '
        'with real budgets and measurable growth experiments.',
    price: '₹999',
    isFavorite: true,
    lessons: [
      Lesson('1. Positioning & Audience', '10 lessons · 2h 30m'),
      Lesson('2. Content & Social', '13 lessons · 3h 40m'),
      Lesson('3. Email & Funnels', '12 lessons · 3h 25m'),
      Lesson('4. Paid Campaigns', '11 lessons · 3h 10m'),
    ],
  ),
  Course(
    id: 'c4',
    title: 'Business Management Essentials',
    category: 'Business',
    image: 'https://images.unsplash.com/photo-1556761175-5973dc0f32e7?w=400',
    instructor: 'Rohit Verma',
    instructorRole: 'Business Consultant',
    rating: '4.8',
    students: '5.4k',
    duration: '16h',
    description:
        'Plan, lead and deliver — the core management skills covering '
        'operations, teams, budgets and confident decision making.',
    price: '₹1,299',
    lessons: [
      Lesson('1. Management Fundamentals', '10 lessons · 2h 45m'),
      Lesson('2. Teams & Leadership', '12 lessons · 3h 30m'),
      Lesson('3. Budgets & Operations', '11 lessons · 3h 10m'),
      Lesson('4. Decision Making', '9 lessons · 2h 25m'),
    ],
  ),
  Course(
    id: 'c5',
    title: 'Python Programming',
    category: 'IT & Software',
    image: 'https://images.unsplash.com/photo-1526379095098-d400fd0bf935?w=400',
    instructor: 'Arjun Rao',
    instructorRole: 'Python Developer & Educator',
    rating: '4.7',
    students: '9.1k',
    duration: '18h',
    description:
        'Start from zero and learn Python step by step: variables, loops, '
        'functions, files and your first automation scripts.',
    price: '₹1,799',
    lessons: [
      Lesson('1. Getting Started with Python', '9 lessons · 1h 45m'),
      Lesson('2. Loops, Functions & Collections', '15 lessons · 4h 10m'),
      Lesson('3. Files & Error Handling', '11 lessons · 3h 05m'),
      Lesson('4. Mini Projects', '8 lessons · 2h 40m'),
    ],
  ),
  Course(
    id: 'c6',
    title: 'Personal Development & Productivity',
    category: 'Personal Development',
    image: 'https://images.unsplash.com/photo-1475721027785-f74eccf877e2?w=400',
    instructor: 'Meera Nair',
    instructorRole: 'Communication Coach',
    rating: '4.7',
    students: '4.2k',
    duration: '9h',
    description:
        'Build focus, beat procrastination and manage your time with simple '
        'systems you can actually keep up every day.',
    price: '₹799',
    lessons: [
      Lesson('1. Habits & Focus', '8 lessons · 1h 50m'),
      Lesson('2. Time Management', '9 lessons · 2h 10m'),
      Lesson('3. Beating Procrastination', '7 lessons · 1h 45m'),
      Lesson('4. Goals & Review', '8 lessons · 2h 05m'),
    ],
  ),
];

/// Looks a course up by its id.
Course courseById(String id) =>
    allCourses.firstWhere((c) => c.id == id, orElse: () => allCourses.first);

/// Every course that belongs to [category] — used by the category pages so
/// the lists are filtered from the data, never hardcoded.
List<Course> coursesInCategory(String category) =>
    allCourses.where((c) => c.category == category).toList();

/// Label for a category card, calculated from the data:
/// `1 course` / `5 courses`.
String courseCountLabel(String category) {
  final count = coursesInCategory(category).length;
  return count == 1 ? '1 course' : '$count courses';
}

/// Headline count for a category page, calculated from the data:
/// `15 Courses` / `1 Course`. Never a fixed figure.
String courseTotalLabel(String category) {
  final count = coursesInCategory(category).length;
  return count == 1 ? '1 Course' : '$count Courses';
}
