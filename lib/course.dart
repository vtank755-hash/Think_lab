import 'package:flutter/foundation.dart';

import 'session.dart';

/// A single lesson inside a module — its OWN video, duration and content.
///
/// ```dart
/// Lesson(
///   '1. What is Python?',
///   '08:25',
///   context: 'Python is a high-level, interpreted language…',
///   points: ['What Python is used for', 'Running your first line'],
///   code: 'print("Hello, Python!")',
/// )
/// ```
class Lesson {
  /// Numbered title, e.g. `1. What is Python?`.
  final String title;

  /// Playback length of this lesson's video, `mm:ss`.
  final String duration;

  /// "About this lesson" text.
  final String context;

  /// Important points / learning objectives.
  final List<String> points;

  /// Optional code example shown on the lesson page.
  final String? code;

  /// Optional extra notes.
  final String? notes;

  const Lesson(
    this.title,
    this.duration, {
    this.context = '',
    this.points = const [],
    this.code,
    this.notes,
  });
}

/// One module of a course curriculum, e.g. `1. Getting Started with Python`.
///
/// The lesson count and the duration of a module are always CALCULATED from
/// [lessons] — never hardcoded.
class Module {
  final String title;
  final List<Lesson> lessons;

  const Module(this.title, this.lessons);
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
  /// Unique identifier, also the key for cart, wishlist and progress state.
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

  /// The curriculum: modules → lessons → video + context.
  final List<Module> modules;

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
    this.modules = const [],
  });

  /// Case-insensitive match against title, category and instructor.
  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return title.toLowerCase().contains(q) ||
        category.toLowerCase().contains(q) ||
        instructor.toLowerCase().contains(q);
  }
}

/// Every user's wishlist: `userId -> the ids of their saved courses`.
///
/// The wishlist is scoped to the signed-in user, so two accounts saved on the
/// same device keep separate lists.f
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
    modules: [
      Module('1. Introduction to HTML', [
        Lesson(
          '1. How the Web Works',
          '10:20',
          context:
              'Browsers, servers, DNS and HTTP — what actually happens '
              'between a click and a page appearing on screen.',
        ),
        Lesson(
          '2. Your First HTML Page',
          '11:45',
          context:
              'Create an HTML file, learn the document skeleton and open '
              'it in the browser for the first time.',
          code: '<!DOCTYPE html>\n<html>\n  <body>Hello web</body>\n</html>',
        ),
        Lesson(
          '3. Headings, Paragraphs & Links',
          '12:10',
          context:
              'Structure content with headings and paragraphs, then link '
              'pages together with anchors.',
        ),
        Lesson(
          '4. Images and Attributes',
          '10:55',
          context:
              'Add images, alt text and titles — and why accessibility '
              'attributes matter from day one.',
        ),
        Lesson(
          '5. Lists & Tables',
          '11:30',
          context:
              'Ordered lists, unordered lists and clean, semantic tables '
              'for tabular data.',
        ),
        Lesson(
          '6. Semantic HTML',
          '09:50',
          context:
              'header, nav, main, section and footer: markup that describes '
              'itself for browsers and screen readers.',
        ),
      ]),
      Module('2. Styling with CSS', [
        Lesson(
          '1. Selectors & The Box Model',
          '11:15',
          context:
              'Every element is a box: content, padding, border and margin '
              'explained with practical selectors.',
        ),
        Lesson(
          '2. Colors, Fonts & Units',
          '10:35',
          context:
              'Hex and rgb colors, web fonts and the difference between px, '
              '%, rem and vw.',
        ),
        Lesson(
          '3. Flexbox Layout',
          '13:05',
          context:
              'One-dimensional layouts: rows, columns, alignment and '
              'spacing with the flex shorthand.',
        ),
        Lesson(
          '4. CSS Grid',
          '12:40',
          context:
              'Two-dimensional page layouts with grid tracks, areas and '
              'responsive auto-fit.',
        ),
        Lesson(
          '5. Responsive Design',
          '11:50',
          context:
              'Media queries, mobile-first thinking and layouts that adapt '
              'from phone to desktop.',
        ),
        Lesson(
          '6. Transitions & Effects',
          '10:10',
          context:
              'Smooth hover states, transform and the performance-friendly '
              'use of transitions.',
        ),
      ]),
      Module('3. JavaScript Fundamentals', [
        Lesson(
          '1. Variables & Data Types',
          '11:20',
          context:
              'let, const and the primitives you will use every day: '
              'strings, numbers, booleans and null.',
        ),
        Lesson(
          '2. Conditionals',
          '10:45',
          context:
              'if / else / switch and comparison operators to make your '
              'programs choose a path.',
        ),
        Lesson(
          '3. Loops in JavaScript',
          '11:35',
          context:
              'for, while and for…of loops for repeating work without '
              'copying code.',
        ),
        Lesson(
          '4. Functions & Scope',
          '12:15',
          context:
              'Declaring functions, parameters, returns and how scope '
              'decides what a function can see.',
        ),
        Lesson(
          '5. Arrays & Objects',
          '13:20',
          context:
              'Store lists and records, then transform them with map, '
              'filter and reduce.',
        ),
        Lesson(
          '6. DOM Events',
          '12:05',
          context:
              'Select elements, listen for clicks and change the page from '
              'JavaScript.',
        ),
      ]),
      Module('4. React in Practice', [
        Lesson(
          '1. Components & JSX',
          '12:25',
          context:
              'Think in components: small reusable pieces of UI described '
              'with JSX.',
        ),
        Lesson(
          '2. Props & State',
          '13:10',
          context:
              'Pass data down with props and manage changing data with '
              'useState.',
        ),
        Lesson(
          '3. Handling Events',
          '11:05',
          context:
              'Clicks, forms and input changes wired up to component '
              'logic.',
        ),
        Lesson(
          '4. Lists & Keys',
          '10:40',
          context:
              'Render arrays of data efficiently and why React needs keys.',
        ),
        Lesson(
          '5. React Router',
          '12:50',
          context:
              'Multi-page apps inside a single-page app: routes, params '
              'and navigation.',
        ),
        Lesson(
          '6. Building an App',
          '14:15',
          context:
              'Put it all together: structure a small but complete '
              'application from scratch.',
        ),
      ]),
      Module('5. Node.js & APIs', [
        Lesson(
          '1. Node.js Basics',
          '11:40',
          context:
              'Run JavaScript on the server: modules, the event loop and '
              'the file system.',
        ),
        Lesson(
          '2. Express Server',
          '12:30',
          context:
              'Spin up a web server with routes, middleware and static '
              'files.',
        ),
        Lesson(
          '3. REST APIs',
          '13:15',
          context:
              'Design resource endpoints, status codes and predictable '
              'JSON responses.',
        ),
        Lesson(
          '4. Working with JSON',
          '10:25',
          context:
              'Parse and send JSON payloads and connect a database-less '
              'data layer.',
        ),
        Lesson(
          '5. Frontend + Backend',
          '12:55',
          context:
              'Call your API from React and handle loading and error '
              'states like a pro.',
        ),
        Lesson(
          '6. Deploy Your App',
          '11:50',
          context:
              'Ship the project: environment variables, build steps and a '
              'public URL.',
        ),
      ]),
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
    modules: [
      Module('1. Design Thinking', [
        Lesson(
          '1. What is UX?',
          '10:15',
          context:
              'How usability, desirability and value combine into a '
              'product people want to use.',
        ),
        Lesson(
          '2. The Design Thinking Process',
          '12:05',
          context:
              'Empathise, define, ideate, prototype and test — the loop '
              'used by real product teams.',
        ),
        Lesson(
          '3. User Empathy',
          '11:20',
          context:
              'Interview techniques and observation habits that surface '
              'what users really need.',
        ),
        Lesson(
          '4. Defining the Problem',
          '10:40',
          context:
              'Turn messy research into a sharp problem statement everyone '
              'can align on.',
        ),
        Lesson(
          '5. Ideation Techniques',
          '11:55',
          context:
              'Crazy 8s, sketching and how to generate many ideas before '
              'judging any of them.',
        ),
        Lesson(
          '6. From Ideas to Concepts',
          '10:30',
          context:
              'Pick the strongest concepts and shape them into directions '
              'worth testing.',
        ),
      ]),
      Module('2. Wireframes & Flows', [
        Lesson(
          '1. Information Architecture',
          '11:45',
          context:
              'Organise content so users always know where they are and '
              'where to go next.',
        ),
        Lesson(
          '2. User Flows',
          '12:20',
          context:
              'Map the happy path and the edge cases before drawing a '
              'single screen.',
        ),
        Lesson(
          '3. Low-Fidelity Wireframes',
          '13:00',
          context:
              'Grey-box layouts that keep the conversation on structure, '
              'not colors.',
        ),
        Lesson(
          '4. Screen Layouts',
          '11:10',
          context:
              'Hierarchy, spacing and grouping so the eye lands where it '
              'should.',
        ),
        Lesson(
          '5. Component Libraries',
          '12:35',
          context:
              'Reusable buttons, fields and cards that keep a product '
              'consistent.',
        ),
        Lesson(
          '6. Handoff Basics',
          '10:05',
          context:
              'What developers need from a design: specs, states and '
              'tokens.',
        ),
      ]),
      Module('3. Prototyping in Figma', [
        Lesson(
          '1. The Figma Interface',
          '10:50',
          context:
              'Layers, frames, tools and shortcuts to move quickly around '
              'the canvas.',
        ),
        Lesson(
          '2. Frames & Layers',
          '11:35',
          context: 'Structure files so anything can be found in seconds.',
        ),
        Lesson(
          '3. Auto Layout',
          '13:25',
          context:
              'Build components that resize like real code with padding '
              'and gaps.',
        ),
        Lesson(
          '4. Interactive Prototypes',
          '12:45',
          context:
              'Wire screens together with transitions and clickable '
              'flows.',
        ),
        Lesson(
          '5. Design Systems',
          '13:40',
          context:
              'Colors, type styles and variants that scale across a '
              'product.',
        ),
        Lesson(
          '6. Sharing & Comments',
          '10:20',
          context:
              'Share links, collect feedback and iterate without version '
              'chaos.',
        ),
      ]),
      Module('4. Usability Testing', [
        Lesson(
          '1. Planning a Test',
          '11:05',
          context: 'Write tasks and success criteria before recruiting anyone.',
        ),
        Lesson(
          '2. Recruiting Participants',
          '10:25',
          context:
              'Find the right users and screen them so sessions stay '
              'useful.',
        ),
        Lesson(
          '3. Running Sessions',
          '12:30',
          context:
              'Facilitate without leading, and keep silent while users '
              'think.',
        ),
        Lesson(
          '4. Recording Insights',
          '11:50',
          context: 'Capture quotes, clips and severity so findings stick.',
        ),
        Lesson(
          '5. Prioritising Fixes',
          '10:45',
          context:
              'Sort problems by impact and effort into an actionable '
              'backlog.',
        ),
        Lesson(
          '6. Measuring Success',
          '11:15',
          context:
              'Define metrics and re-test to prove the redesign actually '
              'worked.',
        ),
      ]),
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
    modules: [
      Module('1. Positioning & Audience', [
        Lesson(
          '1. Market Research',
          '11:30',
          context:
              'Size the market, spot the trends and find the gap your '
              'product can own.',
        ),
        Lesson(
          '2. Building Personas',
          '12:15',
          context:
              'Turn research into two or three believable customers you '
              'can design for.',
        ),
        Lesson(
          '3. Value Proposition',
          '10:50',
          context:
              'Say exactly why someone should choose you, in one clear '
              'sentence.',
        ),
        Lesson(
          '4. Competitive Analysis',
          '11:40',
          context:
              'Audit competitors’ channels, messaging and offers '
              'systematically.',
        ),
        Lesson(
          '5. Brand Messaging',
          '10:35',
          context:
              'Tone of voice, key messages and the story that ties every '
              'campaign together.',
        ),
        Lesson(
          '6. Goal Setting',
          '10:10',
          context:
              'Set SMART goals and choose the metrics that actually prove '
              'progress.',
        ),
      ]),
      Module('2. Content & Social', [
        Lesson(
          '1. Content Strategy',
          '12:05',
          context:
              'Pick topics by intent and map them to the stages of the '
              'customer journey.',
        ),
        Lesson(
          '2. Blogging Basics',
          '11:20',
          context:
              'Write posts that read well and rank: structure, headings '
              'and internal links.',
        ),
        Lesson(
          '3. Social Media Plans',
          '12:45',
          context: 'A weekly posting rhythm you can actually keep up with.',
        ),
        Lesson(
          '4. Reels & Short Video',
          '11:05',
          context:
              'Hooks, scripts and edits that survive the first three '
              'seconds.',
        ),
        Lesson(
          '5. Community Building',
          '10:55',
          context:
              'Grow an audience that replies, shares and defends your '
              'brand.',
        ),
        Lesson(
          '6. Content Calendar',
          '10:30',
          context:
              'Plan a month of content in one sitting and never post in '
              'panic again.',
        ),
      ]),
      Module('3. Email & Funnels', [
        Lesson(
          '1. Email Lists',
          '11:15',
          context:
              'Grow a clean, permission-based list that stays out of the '
              'spam folder.',
        ),
        Lesson(
          '2. Newsletters',
          '10:45',
          context:
              'Subject lines, layout and cadence that earn opens and '
              'clicks.',
        ),
        Lesson(
          '3. Automation Sequences',
          '12:25',
          context:
              'Welcome, nurture and re-engagement flows that run while you '
              'sleep.',
        ),
        Lesson(
          '4. Landing Pages',
          '11:50',
          context: 'One page, one job: match message and remove friction.',
        ),
        Lesson(
          '5. Lead Magnets',
          '10:40',
          context:
              'Freebies worth an e-mail address — checklists, templates '
              'and mini-courses.',
        ),
        Lesson(
          '6. Funnel Analytics',
          '11:35',
          context: 'Find the exact step where your funnel leaks and fix it.',
        ),
      ]),
      Module('4. Paid Campaigns', [
        Lesson(
          '1. Campaign Structure',
          '12:10',
          context:
              'Accounts, campaigns, ad groups and how structure decides '
              'your results.',
        ),
        Lesson(
          '2. Bidding & Budgets',
          '11:25',
          context: 'Spend safely: bids, daily budgets and when to raise them.',
        ),
        Lesson(
          '3. Ad Creatives',
          '10:55',
          context: 'Copy and visuals built for attention, not awards.',
        ),
        Lesson(
          '4. Targeting & Retargeting',
          '12:30',
          context: 'Reach the right people, then bring the ones who left back.',
        ),
        Lesson(
          '5. A/B Testing',
          '11:10',
          context: 'Test one variable at a time and let the data decide.',
        ),
        Lesson(
          '6. Measuring ROI',
          '11:45',
          context:
              'Attribution, CAC and ROAS — the numbers a budget owner '
              'cares about.',
        ),
      ]),
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
    modules: [
      Module('1. Management Fundamentals', [
        Lesson(
          '1. The Role of a Manager',
          '10:55',
          context:
              'From individual contributor to multiplier: what changes when '
              'you become responsible for others.',
        ),
        Lesson(
          '2. Planning & Goals',
          '11:40',
          context:
              'Break a yearly vision into quarterly plans and weekly '
              'actions.',
        ),
        Lesson(
          '3. Organising Work',
          '10:30',
          context:
              'Roles, responsibilities and handoffs that remove '
              'bottlenecks.',
        ),
        Lesson(
          '4. Delegation',
          '11:15',
          context:
              'Hand over work with clarity — outcomes, constraints and '
              'check-ins.',
        ),
        Lesson(
          '5. Decision Making',
          '12:05',
          context: 'Frameworks for deciding fast with incomplete information.',
        ),
        Lesson(
          '6. Ethics at Work',
          '10:20',
          context:
              'Build trust through transparency, fairness and consistent '
              'standards.',
        ),
      ]),
      Module('2. Teams & Leadership', [
        Lesson(
          '1. Building Teams',
          '11:50',
          context:
              'Hire for complementarity and create the conditions for '
              'psychological safety.',
        ),
        Lesson(
          '2. Leadership Styles',
          '12:20',
          context:
              'Coach, visionary, democratic — flex your style to the '
              'situation.',
        ),
        Lesson(
          '3. Motivation',
          '11:05',
          context:
              'Autonomy, mastery and purpose: what actually keeps people '
              'engaged.',
        ),
        Lesson(
          '4. Feedback & 1:1s',
          '11:35',
          context:
              'Run one-to-ones that people look forward to, and give '
              'feedback that lands.',
        ),
        Lesson(
          '5. Conflict Resolution',
          '12:40',
          context:
              'Surface tension early and turn disagreement into better '
              'decisions.',
        ),
        Lesson(
          '6. Remote Teams',
          '10:50',
          context:
              'Async habits, documentation and rituals for distributed '
              'teams.',
        ),
      ]),
      Module('3. Budgets & Operations', [
        Lesson(
          '1. Reading a Budget',
          '12:15',
          context:
              'Understand line items, variances and where the money '
              'actually goes.',
        ),
        Lesson(
          '2. Cost Control',
          '11:20',
          context: 'Cut waste without cutting the work that matters.',
        ),
        Lesson(
          '3. Forecasting',
          '10:45',
          context:
              'Simple models that predict next quarter from this quarter’s '
              'numbers.',
        ),
        Lesson(
          '4. Process Improvement',
          '11:55',
          context:
              'Map a process, find the waste, remove it and measure the '
              'gain.',
        ),
        Lesson(
          '5. KPIs & Dashboards',
          '11:30',
          context:
              'Choose a handful of numbers worth watching and visualise '
              'them well.',
        ),
        Lesson(
          '6. Vendor Management',
          '10:40',
          context:
              'Negotiate contracts and hold suppliers to clear service '
              'levels.',
        ),
      ]),
      Module('4. Decision Making', [
        Lesson(
          '1. Data-Driven Decisions',
          '11:25',
          context:
              'Ask better questions first, then let evidence narrow the '
              'options.',
        ),
        Lesson(
          '2. Risk Assessment',
          '11:50',
          context:
              'Map impact against likelihood and prepare sensible '
              'contingencies.',
        ),
        Lesson(
          '3. Prioritisation Frameworks',
          '10:35',
          context: 'Value vs effort, RICE and how to say no to good ideas.',
        ),
        Lesson(
          '4. Stakeholder Buy-In',
          '11:10',
          context:
              'Present decisions so the room can commit, not just '
              'listen.',
        ),
        Lesson(
          '5. Negotiation Basics',
          '12:00',
          context: 'Interests vs positions and reaching agreements that hold.',
        ),
        Lesson(
          '6. Scaling Decisions',
          '10:55',
          context:
              'What to standardise, what to keep local and when to '
              'revisit.',
        ),
      ]),
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
    modules: [
      Module('1. Getting Started with Python', [
        Lesson(
          '1. What is Python?',
          '08:25',
          context:
              'Python is a high-level, interpreted programming language '
              'known for readable syntax. In this lesson you meet the '
              'language, see where it is used and run your very first line '
              'of code.',
          points: [
            'What Python is used for',
            'Interpreted vs compiled languages',
            'Running code in the REPL',
          ],
          code: 'print("Hello, Python!")',
          notes:
              'Focus on readability: Python uses indentation to group '
              'code, so keep your spacing clean from the start.',
        ),
        Lesson(
          '2. Installing Python',
          '12:10',
          context:
              'Download and install Python on Windows, macOS or Linux, '
              'choose the right version and check that the interpreter '
              'runs from your terminal.',
          points: [
            'Installing Python 3.x',
            'Adding Python to PATH',
            'Verifying with python --version',
          ],
          code: 'python --version\npip --version',
        ),
        Lesson(
          '3. Python Syntax',
          '11:35',
          context:
              'Indentation defines blocks in Python. Learn comments, '
              'simple statements and the rules the interpreter follows '
              'when it reads your file.',
          points: [
            'Indentation instead of braces',
            'Comments and docstrings',
            'Line continuation',
          ],
          code:
              '# Indentation defines the block\nif True:\n'
              '    print("Python uses indentation")',
        ),
        Lesson(
          '4. Variables',
          '10:50',
          context:
              'Variables are names that point to values. Python creates '
              'them the moment you assign, and you can reuse them anywhere '
              'in their scope.',
          points: ['Assignment with =', 'Dynamic typing', 'Naming rules'],
          code: 'name = "Ada"\nage = 30\nprint(name, age)',
        ),
        Lesson(
          '5. Data Types',
          '13:20',
          context:
              'int, float, str, bool, list, tuple, dict and set — the core '
              'types you will use in every Python program.',
          points: [
            'Numbers, strings and booleans',
            'Collections: list, tuple, dict, set',
            'Checking types with type()',
          ],
          code:
              'score = 95.5\nname = "LearnHub"\nis_active = True\n'
              'print(type(score))',
        ),
        Lesson(
          '6. Input and Output',
          '12:45',
          context:
              'Make your programs interactive with input() and format '
              'everything you print with f-strings.',
          points: [
            'Reading user input',
            'f-strings and formatting',
            'Converting input types',
          ],
          code:
              'age = int(input("Your age: "))\n'
              'print(f"You are {age} years old")',
        ),
        Lesson(
          '7. Operators',
          '14:05',
          context:
              'Arithmetic, comparison, assignment and logical operators — '
              'how Python combines values into expressions.',
          points: [
            'Arithmetic and floor division',
            'Comparison operators',
            'and / or / not',
          ],
          code:
              'total = 1799 * 3\ndiscounted = total * 0.9\n'
              'print(total, discounted)',
        ),
        Lesson(
          '8. Basic Python Program',
          '11:20',
          context:
              'Put the pieces together and write a small program that '
              'reads input, calculates a result and prints it clearly.',
          points: [
            'Plan before you code',
            'Step-by-step logic',
            'Testing your output',
          ],
          code:
              'price = int(input("Price: "))\nqty = int(input("Qty: "))\n'
              'print(f"Total: ₹{price * qty}")',
        ),
        Lesson(
          '9. Practice Exercise',
          '10:30',
          context:
              'Six short exercises to lock in variables, types, input and '
              'operators before you move on to loops.',
          points: [
            'Temperature converter',
            'Simple calculator',
            'Personal profile printer',
          ],
          code:
              'celsius = float(input("Celsius: "))\n'
              'print(f"Fahrenheit: {celsius * 9 / 5 + 32}")',
        ),
      ]),
      Module('2. Loops, Functions & Collections', [
        Lesson(
          '1. The for Loop',
          '16:20',
          context:
              'Iterate over sequences with for and stop repeating yourself '
              'with range().',
          points: ['for with range()', 'Looping over strings and lists'],
          code: 'for i in range(1, 6):\n    print(f"Lesson {i}")',
        ),
        Lesson(
          '2. The while Loop',
          '16:55',
          context:
              'Repeat while a condition is true — and make sure it always '
              'becomes false.',
          points: ['Condition-driven loops', 'Avoiding infinite loops'],
          code: 'n = 3\nwhile n > 0:\n    print(n)\n    n -= 1',
        ),
        Lesson(
          '3. break and continue',
          '15:45',
          context:
              'Control the flow inside loops: skip an iteration or exit '
              'early when you find what you need.',
          points: ['Skipping with continue', 'Exiting with break'],
          code:
              'for n in range(10):\n    if n % 2 == 0:\n        continue\n'
              '    print(n)',
        ),
        Lesson(
          '4. Nested Loops',
          '17:10',
          context:
              'Loops inside loops for tables, grids and multi-dimensional '
              'data.',
          points: ['Reading nested indentation', 'When to refactor'],
          code:
              'for row in range(1, 4):\n    for col in range(1, 4):\n'
              '        print(row, col)',
        ),
        Lesson(
          '5. Defining Functions',
          '17:40',
          context:
              'Package logic into named functions so your code is '
              'reusable, testable and easy to read.',
          points: ['def and return', 'Docstrings', 'Function naming'],
          code:
              'def greet(name):\n    return f"Hi, {name}!"\n'
              'print(greet("Ada"))',
        ),
        Lesson(
          '6. Parameters & Arguments',
          '16:35',
          context:
              'Default values, keyword arguments and *args for flexible '
              'function signatures.',
          points: ['Positional vs keyword', 'Default parameters'],
          code: 'def area(w, h=1):\n    return w * h\nprint(area(5, 3))',
        ),
        Lesson(
          '7. Return Values',
          '16:10',
          context:
              'Functions can hand results back, return several values at '
              'once or return nothing at all.',
          points: ['Returning tuples', 'None as a default return'],
          code:
              'def stats(xs):\n    return min(xs), max(xs), sum(xs) // len(xs)',
        ),
        Lesson(
          '8. Scope & Local Variables',
          '15:25',
          context:
              'What a function can see: locals, globals and why shadowing '
              'causes confusing bugs.',
          points: ['LEGB rule', 'Avoiding global state'],
          code: 'count = 0\ndef add():\n    global count\n    count += 1',
        ),
        Lesson(
          '9. Lambda Functions',
          '16:45',
          context: 'Small anonymous functions for sorting and short callbacks.',
          points: ['lambda syntax', 'Using lambda with sorted()'],
          code:
              'users = [("Ann", 30), ("Bob", 25)]\n'
              'users.sort(key=lambda u: u[1])',
        ),
        Lesson(
          '10. Lists in Depth',
          '17:20',
          context:
              'Slicing, appending, sorting and the methods you will use '
              'every day.',
          points: ['Slicing [start:stop:step]', 'List methods', 'Copying'],
          code: 'xs = [4, 1, 3]\nxs.sort()\nprint(xs[::1], xs[::-1])',
        ),
        Lesson(
          '11. Tuples & Ranges',
          '16:00',
          context:
              'Immutable sequences: when to use a tuple instead of a list, '
              'and lazy ranges.',
          points: ['Immutability', 'Unpacking', 'range() patterns'],
          code: 'point = (3, 4)\nx, y = point',
        ),
        Lesson(
          '12. Dictionaries',
          '18:05',
          context:
              'Key/value data: the workhorse structure for records, '
              'counters and JSON.',
          points: ['Access with .get()', 'Iterating items()', 'Nested dicts'],
          code:
              'course = {"title": "Python", "lessons": 43}\n'
              'print(course.get("price", "free"))',
        ),
        Lesson(
          '13. Sets & Comprehensions',
          '15:35',
          context:
              'Unique values with set() and one-line transformations with '
              'list, dict and set comprehensions.',
          points: ['Removing duplicates', 'Comprehension syntax'],
          code: 'nums = {1, 2, 2, 3}\nsquares = [n * n for n in nums]',
        ),
        Lesson(
          '14. Modules & Imports',
          '17:00',
          context:
              'Split code across files and use the standard library with '
              'import, from and packages.',
          points: ['import styles', '__name__ guard', 'Your own modules'],
          code:
              'import math\nfrom random import randint\n'
              'print(math.sqrt(16))',
        ),
        Lesson(
          '15. Practice Challenges',
          '17:15',
          context:
              'Five problems that combine loops, functions and collections '
              '— the real test of module 2.',
          points: ['FizzBuzz variants', 'Word frequency counter', 'Sorting'],
          code: 'def top_word(text):\n    return max(text.split(), key=len)',
        ),
      ]),
      Module('3. Files & Error Handling', [
        Lesson(
          '1. Reading Files',
          '17:30',
          context:
              'Open, read and close text files safely and iterate over '
              'them line by line.',
          points: ['open() modes', 'Reading lines', 'Encoding'],
          code:
              'with open("notes.txt") as f:\n    for line in f:\n'
              '        print(line.strip())',
        ),
        Lesson(
          '2. Writing Files',
          '16:35',
          context:
              'Create and overwrite files, append to them and write '
              'structured data.',
          points: ['Write vs append', 'Flush and close'],
          code: 'with open("log.txt", "a") as f:\n    f.write("done\\n")',
        ),
        Lesson(
          '3. File Paths & With',
          '17:00',
          context:
              'The with statement guarantees cleanup — no more leaked file '
              'handles.',
          points: ['Context managers', 'pathlib basics'],
          code:
              'from pathlib import Path\np = Path("data/notes.txt")\n'
              'print(p.exists())',
        ),
        Lesson(
          '4. CSV Files',
          '16:00',
          context:
              'Read and write tabular data with the csv module without '
              'hand-splitting strings.',
          points: ['csv.reader', 'csv.DictReader'],
          code:
              'import csv\nwith open("marks.csv") as f:\n'
              '    for row in csv.DictReader(f):\n        print(row)',
        ),
        Lesson(
          '5. Handling Errors',
          '18:05',
          context:
              'Understand tracebacks and stop one bad line from crashing '
              'the whole program.',
          points: ['Reading a traceback', 'Common exceptions'],
          code: 'value = int("abc")  # ValueError',
        ),
        Lesson(
          '6. Try, Except, Finally',
          '16:45',
          context:
              'Guard risky code, handle each failure specifically and always '
              'run cleanup.',
          points: ['Catching by type', 'else and finally'],
          code:
              'try:\n    n = int(input())\nexcept ValueError:\n'
              '    print("Numbers only")\nfinally:\n    print("Done")',
        ),
        Lesson(
          '7. Raising Exceptions',
          '15:40',
          context:
              'Signal problems with raise and design functions that fail '
              'loudly instead of silently.',
          points: ['raise', 'Re-raising', 'Exception messages'],
          code: 'if age < 0:\n    raise ValueError("age cannot be negative")',
        ),
        Lesson(
          '8. Custom Exceptions',
          '17:10',
          context:
              'Create domain-specific errors so calling code can react '
              'precisely.',
          points: ['Subclassing Exception', 'Meaningful names'],
          code: 'class CourseLockedError(Exception):\n    pass',
        ),
        Lesson(
          '9. Debugging Techniques',
          '16:15',
          context:
              'Print debugging, the pdb breakpoint and reading stack traces '
              'like a detective.',
          points: ['Breakpoints', 'Bisecting the problem'],
          code: 'breakpoint()',
        ),
        Lesson(
          '10. Logging Basics',
          '16:55',
          context:
              'Replace print statements with logging levels that survive '
              'production.',
          points: ['logging levels', 'Configuring output'],
          code: 'import logging\nlogging.basicConfig(level=logging.INFO)',
        ),
        Lesson(
          '11. Practice Exercise',
          '17:05',
          context:
              'Build a small log analyser that reads a file, handles bad '
              'lines and writes a report.',
          points: ['Read safely', 'Count by level', 'Write a summary'],
          code: 'errors = [l for l in lines if "ERROR" in l]',
        ),
      ]),
      Module('4. Mini Projects', [
        Lesson(
          '1. Project 1: Number Guessing Game',
          '19:10',
          context:
              'Combine loops, input and conditionals into a complete game '
              'with scoring.',
          points: ['Game loop', 'Random module', 'Win/lose states'],
          code: 'import random\ntarget = random.randint(1, 100)',
        ),
        Lesson(
          '2. Project 1: Full Walkthrough',
          '20:25',
          context:
              'Refactor the game into functions, add replay support and '
              'clean up the code.',
          points: ['Refactoring', 'Replay loop', 'Code review'],
          code: 'def play_round():\n    ...\nwhile play_round():\n    pass',
        ),
        Lesson(
          '3. Project 2: To-Do List CLI',
          '19:40',
          context:
              'A command-line to-do app: add, list, complete and delete '
              'tasks from the terminal.',
          points: ['Command parsing', 'Task storage in a list'],
          code:
              'tasks = []\ntasks.append({"title": "Learn Python", '
              '"done": False})',
        ),
        Lesson(
          '4. Project 2: Saving Data',
          '20:40',
          context:
              'Persist tasks to a file so the list survives a restart, and '
              'load it on startup.',
          points: ['Writing JSON', 'Loading with defaults', 'Error safety'],
          code: 'import json\njson.dump(tasks, open("tasks.json", "w"))',
        ),
        Lesson(
          '5. Project 3: Quiz App',
          '19:25',
          context:
              'Store questions and answers as structured data and run a '
              'timed quiz.',
          points: ['Data modelling', 'Shuffling questions'],
          code:
              'quiz = [{"q": "2 + 2?", "options": ["3", "4"], '
              '"answer": "4"}]',
        ),
        Lesson(
          '6. Project 3: Scoring & Retry',
          '20:10',
          context:
              'Add scoring, feedback after every answer and a retry flow '
              'that feels satisfying.',
          points: ['Scoring logic', 'Immediate feedback', 'High scores'],
          code: 'score += 1 if chosen == q["answer"] else 0',
        ),
        Lesson(
          '7. Code Review & Cleanup',
          '19:55',
          context:
              'Read your own projects critically: naming, structure, dead '
              'code and small helper functions.',
          points: ['Naming', 'DRY', 'Removing dead code'],
          code: 'def load_tasks(path="tasks.json"): ...',
        ),
        Lesson(
          '8. Where to Go Next',
          '20:35',
          context:
              'A roadmap after Python basics: web frameworks, automation, '
              'data science and how to keep practising.',
          points: ['Project ideas', 'Learning resources', 'Portfolio tips'],
          code: 'pip install flask  # your next step',
        ),
      ]),
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
    modules: [
      Module('1. Habits & Focus', [
        Lesson(
          '1. The Habit Loop',
          '11:20',
          context:
              'Cue, routine, reward — understand the loop so you can design '
              'better ones on purpose.',
        ),
        Lesson(
          '2. Building Tiny Habits',
          '12:05',
          context:
              'Start absurdly small so the habit sticks before motivation '
              'fades.',
        ),
        Lesson(
          '3. Deep Focus',
          '11:45',
          context:
              'Protect long, uninterrupted blocks for the work that truly '
              'moves things forward.',
        ),
        Lesson(
          '4. Beating Distractions',
          '10:50',
          context:
              'Remove friction from good habits and add friction to bad '
              'ones.',
        ),
        Lesson(
          '5. Environment Design',
          '11:10',
          context:
              'Shape your desk, phone and calendar so focus becomes the '
              'default.',
        ),
        Lesson(
          '6. Tracking Progress',
          '10:25',
          context: 'Simple streaks and checklists that keep momentum visible.',
        ),
      ]),
      Module('2. Time Management', [
        Lesson(
          '1. Prioritising Tasks',
          '11:55',
          context:
              'Sort tasks by impact, not urgency, and stop confusing '
              'motion with progress.',
        ),
        Lesson(
          '2. Time Blocking',
          '12:30',
          context:
              'Give every important task a home on the calendar and defend '
              'those blocks.',
        ),
        Lesson(
          '3. The Eisenhower Matrix',
          '11:15',
          context:
              'Four quadrants that instantly show what to do, schedule, '
              'delegate or drop.',
        ),
        Lesson(
          '4. Avoiding Procrastination',
          '11:40',
          context:
              'Understand the emotion behind delay and start with two '
              'minute openers.',
        ),
        Lesson(
          '5. Energy Management',
          '10:45',
          context:
              'Schedule hard work at your biological peak and recharge '
              'deliberately.',
        ),
        Lesson(
          '6. Weekly Reviews',
          '10:30',
          context:
              'A 30-minute ritual that resets priorities every Sunday '
              'evening.',
        ),
      ]),
      Module('3. Beating Procrastination', [
        Lesson(
          '1. Why We Procrastinate',
          '11:05',
          context:
              'Procrastination is mood management, not laziness — name the '
              'real emotion.',
        ),
        Lesson(
          '2. The Two-Minute Rule',
          '10:20',
          context:
              'If it takes under two minutes, do it now; here is how to '
              'apply it honestly.',
        ),
        Lesson(
          '3. Eat the Frog',
          '10:55',
          context:
              'Do the most dreaded task first and let the rest of the day '
              'feel easy.',
        ),
        Lesson(
          '4. Accountability',
          '11:25',
          context:
              'Partners, public commitments and deadlines that actually '
              'hold.',
        ),
        Lesson(
          '5. Reward Systems',
          '10:40',
          context:
              'Pair completion with immediate rewards so your brain starts '
              'wanting the work.',
        ),
        Lesson(
          '6. Getting Back on Track',
          '11:10',
          context:
              'Recover from a broken streak without spiralling into guilt.',
        ),
      ]),
      Module('4. Goals & Review', [
        Lesson(
          '1. SMART Goals',
          '11:35',
          context: 'Turn vague wishes into specific, measurable commitments.',
        ),
        Lesson(
          '2. Quarterly Planning',
          '12:10',
          context:
              'Choose three outcomes per quarter and let them drive weekly '
              'plans.',
        ),
        Lesson(
          '3. Measuring Habits',
          '11:00',
          context:
              'Track consistency rather than perfection, and review the '
              'trend.',
        ),
        Lesson(
          '4. Reflection Journals',
          '10:35',
          context: 'Five prompts that turn each day into usable feedback.',
        ),
        Lesson(
          '5. Course Corrections',
          '10:50',
          context: 'Adjust goals without abandoning them when life changes.',
        ),
        Lesson(
          '6. Celebrating Wins',
          '10:15',
          context: 'Acknowledge progress on purpose — it is fuel, not vanity.',
        ),
      ]),
    ],
  ),
];

// ---------------------------------------------------------------------------
// Curriculum helpers — ids, lookups and calculated durations.
// ---------------------------------------------------------------------------

/// `c5` + module 1 → `c5-module-1`.
String moduleIdFor(Course course, int moduleIndex) =>
    '${course.id}-module-${moduleIndex + 1}';

/// `c5` + module 1 + lesson 1 → `c5-module-1-lesson-1`.
String lessonIdFor(Course course, int moduleIndex, int lessonIndex) =>
    '${moduleIdFor(course, moduleIndex)}-lesson-${lessonIndex + 1}';

/// Index of the module with [id], or `-1`.
int moduleIndexOf(Course course, String id) {
  for (var i = 0; i < course.modules.length; i++) {
    if (moduleIdFor(course, i) == id) return i;
  }
  return -1;
}

/// Module lookup by its id (throws when the id does not exist).
Module moduleById(Course course, String id) {
  final index = moduleIndexOf(course, id);
  if (index < 0) throw ArgumentError('Unknown module id: $id');
  return course.modules[index];
}

/// Index of the lesson with [id] inside `moduleId`, or `-1`.
int lessonIndexOf(Course course, String moduleId_, String lessonId_) {
  final mIndex = moduleIndexOf(course, moduleId_);
  if (mIndex < 0) return -1;
  final module = course.modules[mIndex];
  for (var i = 0; i < module.lessons.length; i++) {
    if (lessonIdFor(course, mIndex, i) == lessonId_) return i;
  }
  return -1;
}

/// Lesson lookup by ids (throws when either id does not exist).
Lesson lessonById(Course course, String moduleId_, String lessonId_) {
  final mIndex = moduleIndexOf(course, moduleId_);
  final lIndex = lessonIndexOf(course, moduleId_, lessonId_);
  if (mIndex < 0 || lIndex < 0) {
    throw ArgumentError('Unknown lesson id: $lessonId_');
  }
  return course.modules[mIndex].lessons[lIndex];
}

/// The next lesson in the course, or `null` after the last one.
(int, int)? nextLesson(Course course, int moduleIndex, int lessonIndex) {
  final module = course.modules[moduleIndex];
  if (lessonIndex + 1 < module.lessons.length) {
    return (moduleIndex, lessonIndex + 1);
  }
  if (moduleIndex + 1 < course.modules.length) return (moduleIndex + 1, 0);
  return null;
}

/// The previous lesson, or `null` before the first one.
(int, int)? previousLesson(Course course, int moduleIndex, int lessonIndex) {
  if (lessonIndex > 0) return (moduleIndex, lessonIndex - 1);
  if (moduleIndex > 0) {
    return (
      moduleIndex - 1,
      course.modules[moduleIndex - 1].lessons.length - 1,
    );
  }
  return null;
}

/// The video that belongs to THIS lesson — every lesson gets its own file.
String lessonVideo(Course course, int moduleIndex, int lessonIndex) {
  final mId = moduleIdFor(course, moduleIndex);
  final lId = lessonIdFor(course, moduleIndex, lessonIndex);
  return 'https://cdn.learnhub.app/videos/${course.id}/$mId/$lId.mp4';
}

/// `'1. Getting Started with Python'` → `'Getting Started with Python'`.
String moduleTitle(String title) =>
    title.replaceFirst(RegExp(r'^\d+\.\s*'), '');

/// `'08:25'` → `505`.
int durationInSeconds(String clock) {
  final parts = clock.split(':');
  if (parts.length != 2) return 0;
  return (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
}

/// `505` → `'08:25'`.
String formatClock(int seconds) {
  final s = seconds.clamp(0, 99 * 3600);
  final minutes = s ~/ 60;
  final rest = s % 60;
  return '${minutes.toString().padLeft(2, '0')}:'
      '${rest.toString().padLeft(2, '0')}';
}

/// `6300` → `'1h 45m'`, `2700` → `'45m'`.
String formatDuration(int seconds) {
  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  return hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
}

/// Total length of a module in seconds, calculated from its lessons.
int moduleSeconds(Module module) =>
    module.lessons.fold(0, (sum, l) => sum + durationInSeconds(l.duration));

/// Row label for a module, e.g. `9 lessons · 1h 45m` — always calculated.
String moduleMeta(Module module) =>
    '${module.lessons.length} lessons · ${formatDuration(moduleSeconds(module))}';

/// Header label used on the module page, e.g. `9 Lessons • 1h 45m`.
String moduleHeadline(Module module) =>
    '${module.lessons.length} Lessons • ${formatDuration(moduleSeconds(module))}';

/// Total number of lessons in a course.
int courseLessonCount(Course course) =>
    course.modules.fold(0, (sum, module) => sum + module.lessons.length);

/// Total length of a course in seconds, calculated from every lesson.
int courseSeconds(Course course) =>
    course.modules.fold(0, (sum, module) => sum + moduleSeconds(module));

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
