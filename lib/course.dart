/// Shared course data for the whole app.
///
/// Every list on the home page and the search results page points at the
/// same [courseCatalog], so a course always shows the same title, price and
/// details wherever the user opens it from.
class Course {
  final String title;
  final String author;
  final String authorRole;
  final String tag;
  final String rating;
  final String reviews;
  final String students;
  final String duration;
  final String price;
  final String image;
  final String description;
  final List<Lesson> curriculum;

  const Course({
    required this.title,
    required this.author,
    required this.authorRole,
    required this.tag,
    required this.rating,
    required this.reviews,
    required this.students,
    required this.duration,
    required this.price,
    required this.image,
    required this.description,
    required this.curriculum,
  });

  /// Case-insensitive match against the title, tag, author or lesson names.
  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return title.toLowerCase().contains(q) ||
        tag.toLowerCase().contains(q) ||
        author.toLowerCase().contains(q) ||
        curriculum.any((lesson) => lesson.title.toLowerCase().contains(q));
  }
}

/// One chapter of a course, e.g. `1. Introduction to HTML`.
class Lesson {
  final String title;
  final String meta;

  const Lesson(this.title, this.meta);
}

/// All courses the app knows about.
const List<Course> courseCatalog = [
  Course(
    title: 'Complete Web Development Bootcamp',
    author: 'Rohan Gupta',
    authorRole: 'Senior Full-Stack Developer',
    tag: 'Development',
    rating: '4.8',
    reviews: '(2.4k)',
    students: '12.4k',
    duration: '42h',
    price: '₹1,999',
    image: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=600',
    description:
        'Master HTML, CSS, JavaScript, React and Node.js. Build 15 '
        'real-world projects and become a job-ready full-stack developer.',
    curriculum: [
      Lesson('1. Introduction to HTML', '12 lessons · 3h 20m'),
      Lesson('2. Styling Pages with CSS', '14 lessons · 4h 10m'),
      Lesson('3. JavaScript Fundamentals', '18 lessons · 6h 30m'),
      Lesson('4. Building Apps with React', '16 lessons · 7h 15m'),
    ],
  ),
  Course(
    title: 'Advanced JavaScript & ES6',
    author: 'Neha Kapoor',
    authorRole: 'Frontend Engineer',
    tag: 'Development',
    rating: '4.6',
    reviews: '(1.2k)',
    students: '8.6k',
    duration: '18h',
    price: '₹799',
    image: 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=600',
    description:
        'Go deep into closures, async/await, modules and the modern ES6+ '
        'features you use every day in production code.',
    curriculum: [
      Lesson('1. Closures & Scope', '9 lessons · 2h 45m'),
      Lesson('2. Async JavaScript', '11 lessons · 3h 30m'),
      Lesson('3. ES6+ in Practice', '13 lessons · 4h 10m'),
    ],
  ),
  Course(
    title: 'React JS from Zero to Hero',
    author: 'Arjun Rao',
    authorRole: 'Product Engineer',
    tag: 'Development',
    rating: '4.9',
    reviews: '(3.1k)',
    students: '15.2k',
    duration: '28h',
    price: '₹2,499',
    image: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=600',
    description:
        'Learn React by building real interfaces: components, hooks, state '
        'management and deployment, one project at a time.',
    curriculum: [
      Lesson('1. Your First Component', '10 lessons · 2h 50m'),
      Lesson('2. State, Hooks & Events', '15 lessons · 5h 05m'),
      Lesson('3. Routing & Data Fetching', '12 lessons · 4h 40m'),
    ],
  ),
  Course(
    title: 'Python for Data Science',
    author: 'Priya Menon',
    authorRole: 'Data Scientist',
    tag: 'Data Science',
    rating: '4.7',
    reviews: '(1.9k)',
    students: '10.8k',
    duration: '32h',
    price: '₹1,499',
    image: 'https://images.unsplash.com/photo-1526379095098-d400fd0bf935?w=600',
    description:
        'From Python basics to pandas, visualisation and machine learning '
        'basics — with datasets you can re-use in your portfolio.',
    curriculum: [
      Lesson('1. Python Refresher', '11 lessons · 3h 10m'),
      Lesson('2. Pandas & Data Cleaning', '14 lessons · 5h 25m'),
      Lesson('3. Visualisation & ML Basics', '16 lessons · 6h 45m'),
    ],
  ),
  Course(
    title: 'UI/UX Design Masterclass',
    author: 'Sarah Jenkins',
    authorRole: 'Lead Product Designer',
    tag: 'Design',
    rating: '4.9',
    reviews: '(1.8k)',
    students: '9.4k',
    duration: '26h',
    price: '₹1,299',
    image: 'https://images.unsplash.com/photo-1581291518857-4d859fc9e0b5?w=600',
    description:
        'Research, wireframe, prototype and test. Ship interfaces people '
        'understand, using the same process studios follow.',
    curriculum: [
      Lesson('1. Design Principles', '8 lessons · 2h 20m'),
      Lesson('2. Wireframes & Prototypes', '12 lessons · 4h 05m'),
      Lesson('3. Usability Testing', '10 lessons · 3h 35m'),
    ],
  ),
  Course(
    title: 'Figma for Beginners',
    author: 'Sarah Jenkins',
    authorRole: 'Lead Product Designer',
    tag: 'Design',
    rating: '4.8',
    reviews: '(950)',
    students: '7.1k',
    duration: '12h',
    price: '₹899',
    image: 'https://images.unsplash.com/photo-1559028012-481c04fa702d?w=600',
    description:
        'Master frames, auto layout, components and hand-off so you can '
        'design a full app screen in an afternoon.',
    curriculum: [
      Lesson('1. Frames & Auto Layout', '9 lessons · 2h 15m'),
      Lesson('2. Components & Styles', '11 lessons · 3h 20m'),
      Lesson('3. Prototyping & Hand-off', '8 lessons · 2h 45m'),
    ],
  ),
  Course(
    title: 'Digital Marketing Complete Guide',
    author: 'Priya Menon',
    authorRole: 'Growth Marketer',
    tag: 'Marketing',
    rating: '4.7',
    reviews: '(1.5k)',
    students: '8.9k',
    duration: '22h',
    price: '₹999',
    image: 'https://images.unsplash.com/photo-1552664730-d307ca884978?w=600',
    description:
        'SEO, ads, email and analytics in one practical path — plan a '
        'campaign, launch it and read the numbers that matter.',
    curriculum: [
      Lesson('1. Search Engine Optimisation', '12 lessons · 3h 40m'),
      Lesson('2. Paid Campaigns', '10 lessons · 3h 15m'),
      Lesson('3. Email & Analytics', '13 lessons · 4h 05m'),
    ],
  ),
  Course(
    title: 'SEO Foundations',
    author: 'Rohit Verma',
    authorRole: 'SEO Specialist',
    tag: 'Marketing',
    rating: '4.5',
    reviews: '(760)',
    students: '5.6k',
    duration: '10h',
    price: '₹699',
    image: 'https://images.unsplash.com/photo-1562577309-4932fdd64cd1?w=600',
    description:
        'Keyword research, technical audits and content structure that '
        'actually move rankings — with a checklist you can reuse.',
    curriculum: [
      Lesson('1. Keyword Research', '7 lessons · 1h 50m'),
      Lesson('2. Technical SEO', '9 lessons · 2h 40m'),
      Lesson('3. Content That Ranks', '8 lessons · 2h 30m'),
    ],
  ),
  Course(
    title: 'Advanced Excel for Business',
    author: 'Rohit Verma',
    authorRole: 'Business Analyst',
    tag: 'Business',
    rating: '4.6',
    reviews: '(1.1k)',
    students: '6.7k',
    duration: '14h',
    price: '₹749',
    image: 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=600',
    description:
        'Pivot tables, lookups, dashboards and the formulas analysts use '
        'daily to turn raw sheets into decisions.',
    curriculum: [
      Lesson('1. Lookups & Formulas', '10 lessons · 2h 35m'),
      Lesson('2. Pivot Tables', '8 lessons · 2h 10m'),
      Lesson('3. Dashboards', '9 lessons · 3h 00m'),
    ],
  ),
  Course(
    title: 'Marketing Analytics with Python',
    author: 'Neha Kapoor',
    authorRole: 'Growth Analyst',
    tag: 'Marketing',
    rating: '4.4',
    reviews: '(620)',
    students: '4.3k',
    duration: '16h',
    price: '₹1,099',
    image: 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=600',
    description:
        'Measure campaigns properly: attribution, cohorts and reporting '
        'automated with pandas and a little bit of SQL.',
    curriculum: [
      Lesson('1. Metrics & Attribution', '9 lessons · 2h 30m'),
      Lesson('2. Cohorts with Pandas', '11 lessons · 3h 45m'),
      Lesson('3. Automated Reporting', '10 lessons · 3h 20m'),
    ],
  ),
];

/// Finds a course by its title, so pages can be opened from a plain id.
Course? courseByTitle(String title) {
  for (final course in courseCatalog) {
    if (course.title == title) return course;
  }
  return null;
}
