import 'package:flutter/foundation.dart';

import 'course.dart';

// -----------------------------------------------------------------------------
// FINAL QUIZ — the user-side quiz data source.
//
// The quiz UI never contains a single question. It only asks this file for the
// quiz of the course the user is viewing:
//
// ```dart
// final quiz = quizForCourse(course.id);   // 'c5' → 20 Python questions
// ```
//
// Every course owns its OWN quiz (`c5` → `c5_final_quiz` with 20 Python
// questions, `c1` → `c1_final_quiz` with 20 web-development questions), so
// questions can never leak between courses.
// -----------------------------------------------------------------------------

/// One multiple-choice question of a course quiz.
class QuizQuestion {
  /// Small chip shown above the question, e.g. `Python Basics`.
  final String topic;

  /// The question text itself.
  final String text;

  /// The four answer options — shown as A, B, C, D.
  final List<String> options;

  /// Index of the correct option. NEVER revealed before submission.
  final int correctIndex;

  const QuizQuestion({
    required this.topic,
    required this.text,
    required this.options,
    required this.correctIndex,
  });
}

/// The final quiz of ONE course.
class CourseQuiz {
  /// `<courseId>_final_quiz`, e.g. `c5_final_quiz`.
  final String id;

  /// The course this quiz belongs to — used to pick the right questions.
  final String courseId;

  final String title;

  /// Exactly [quizQuestionCount] questions of THIS course.
  final List<QuizQuestion> questions;

  const CourseQuiz({
    required this.id,
    required this.courseId,
    required this.title,
    required this.questions,
  });
}

/// Every course quiz has exactly 20 questions.
const int quizQuestionCount = 20;

/// 75% or higher passes; 74% does not.
const int quizPassingPercentage = 75;

/// `c5` → `c5_final_quiz`.
String quizIdFor(String courseId) => '${courseId}_final_quiz';

/// `c5_final_quiz` + index 0 → `c5_final_quiz_q1`.
String questionIdFor(CourseQuiz quiz, int index) => '${quiz.id}_q${index + 1}';

/// Shorthand so the data below stays one line per question.
QuizQuestion _q(
  String topic,
  String text,
  List<String> options,
  int correctIndex,
) => QuizQuestion(
  topic: topic,
  text: text,
  options: options,
  correctIndex: correctIndex,
);

/// All quizzes, keyed by COURSE ID — the single source of truth for quizzes,
/// exactly like `allCourses` is for courses.
final Map<String, CourseQuiz> _quizByCourse = <String, CourseQuiz>{
  'c1': CourseQuiz(
    id: quizIdFor('c1'),
    courseId: 'c1',
    title: 'Complete Web Development Bootcamp — Final Quiz',
    questions: [
      _q('HTML & CSS', 'Which HTML tag defines an unordered list?', [
        '<ol>',
        '<ul>',
        '<li>',
        '<list>',
      ], 1),
      _q('HTML & CSS', 'Which heading tag renders the largest text?', [
        '<h6>',
        '<h1>',
        '<head>',
        '<title>',
      ], 1),
      _q('HTML & CSS', 'What does CSS stand for?', [
        'Creative Style System',
        'Cascading Style Sheets',
        'Computer Styled Sections',
        'Colorful Style Syntax',
      ], 1),
      _q('HTML & CSS', 'Which CSS property changes the text color?', [
        'text-color',
        'font-color',
        'color',
        'background',
      ], 2),
      _q('HTML & CSS', 'Which selector targets an element with id="nav"?', [
        '#nav',
        '.nav',
        'nav',
        '*nav',
      ], 0),
      _q('HTML & CSS', 'The CSS box model is made of…', [
        'Content, padding, border and margin',
        'Color, font and size',
        'HTML, body and div',
        'Position and z-index',
      ], 0),
      _q('HTML & CSS', 'Which layout system is one-dimensional?', [
        'CSS Grid',
        'Flexbox',
        'HTML tables',
        'Position: absolute',
      ], 1),
      _q(
        'HTML & CSS',
        'Which attribute stores an image description for accessibility?',
        ['alt', 'title', 'desc', 'href'],
        0,
      ),
      _q('JavaScript', 'Which keyword declares a block-scoped variable?', [
        'var',
        'let',
        'dim',
        'define',
      ], 1),
      _q('JavaScript', 'Which operator checks strict equality?', [
        '==',
        '===',
        '=',
        '!=',
      ], 1),
      _q('JavaScript', 'Which method selects an element by id?', [
        'getElementById()',
        'select()',
        'find()',
        'byId()',
      ], 0),
      _q('JavaScript', 'Which event fires when a button is clicked?', [
        'click',
        'hover',
        'scroll',
        'load',
      ], 0),
      _q('JavaScript', 'What does array.push() do?', [
        'Removes the last item',
        'Adds an item at the end',
        'Sorts the array',
        'Reverses the array',
      ], 1),
      _q('JavaScript', 'The === operator compares…', [
        'Value and type strictly',
        'Value only',
        'Type only',
        'References only',
      ], 0),
      _q('React', 'Which hook adds state to a component?', [
        'useState()',
        'stateOf()',
        'createState()',
        'setState() only',
      ], 0),
      _q('React', 'A React component is…', [
        'A reusable piece of UI',
        'A database table',
        'A server route',
        'A CSS file',
      ], 0),
      _q('React', 'JSX is best described as…', [
        'A database language',
        'HTML-like syntax that compiles to JavaScript',
        'A CSS framework',
        'A testing tool',
      ], 1),
      _q('Node.js', 'Which HTTP method typically creates a resource?', [
        'GET',
        'POST',
        'HEAD',
        'TRACE',
      ], 1),
      _q('Node.js', 'What does JSON stand for?', [
        'JavaScript Object Notation',
        'Java Serialized Object Notation',
        'Joined Output Numeric Graph',
        'JSON Object Network',
      ], 0),
      _q(
        'Node.js',
        'Which package is commonly used to build a REST API in Node?',
        ['express', 'bootstrap', 'jquery', 'moment'],
        0,
      ),
    ],
  ),
  'c2': CourseQuiz(
    id: quizIdFor('c2'),
    courseId: 'c2',
    title: 'UI/UX Design Masterclass — Final Quiz',
    questions: [
      _q('Design Thinking', 'What does UX stand for?', [
        'User Experience',
        'User Xchange',
        'Universal X Interface',
        'User XML',
      ], 0),
      _q(
        'Design Thinking',
        'Which Design Thinking stage defines the problem?',
        ['Ideate', 'Empathise', 'Define', 'Prototype'],
        2,
      ),
      _q('Design Thinking', 'A persona represents…', [
        'A real named customer',
        'A typical user archetype',
        'A developer role',
        'A stakeholder list',
      ], 1),
      _q('Design Thinking', 'Affinity mapping is used to…', [
        'Group research insights',
        'Pick fonts',
        'Draw icons',
        'Export code',
      ], 0),
      _q('Wireframes', 'A low-fidelity wireframe focuses on…', [
        'Final brand colors',
        'Layout and structure',
        'Animations',
        'Logo placement',
      ], 1),
      _q('Wireframes', 'A user flow maps…', [
        'Database tables',
        'The steps to complete a task',
        'Colour palettes',
        'Code structure',
      ], 1),
      _q('Wireframes', 'Information architecture is about…', [
        'Organising content clearly',
        'Writing JavaScript',
        'Choosing photos',
        'Drawing buttons',
      ], 0),
      _q('Wireframes', 'A component library mainly provides…', [
        'Reusable consistent elements',
        'Meeting notes',
        'Server config',
        'User research',
      ], 0),
      _q('Figma', 'Which Figma feature keeps spacing consistent?', [
        'Auto Layout',
        'Smart Match',
        'Frame Lock',
        'Pixel Grid',
      ], 0),
      _q('Figma', 'Figma frames are equivalent to…', [
        'Artboards or screens',
        'Comments',
        'Plugins',
        'Developer handoffs',
      ], 0),
      _q('Figma', 'A design system exists to…', [
        'Store only the fonts',
        'Provide reusable, consistent components',
        'Replace user research',
        'Write the backend',
      ], 1),
      _q('Figma', 'Prototype connections are used to…', [
        'Simulate navigation between screens',
        'Change font size',
        'Group layers',
        'Publish code',
      ], 0),
      _q('Figma', 'White space means…', [
        'Empty area that improves readability',
        'Only white coloured blocks',
        'Unused pixels',
        'Hidden layers',
      ], 0),
      _q('Figma', 'A comfortable body font size for mobile is about…', [
        '6 px',
        '8 px',
        '14–16 px',
        '32 px',
      ], 2),
      _q('Usability Testing', 'A usability test measures…', [
        'Code execution speed',
        'How easily users complete tasks',
        'Server cost',
        'Team velocity',
      ], 1),
      _q(
        'Usability Testing',
        'A minimum tap target on touch screens is about…',
        ['8 px', '44–48 px', '4 px', '100 px'],
        1,
      ),
      _q('Usability Testing', 'A/B testing compares…', [
        'Two variants with one change',
        'Two designers',
        'Two fonts',
        'Two devices',
      ], 0),
      _q('Usability Testing', 'Facilitating a test means…', [
        'Leading users to the right answer',
        'Observing without leading',
        'Rewriting the UI live',
        'Skipping notes',
      ], 1),
      _q('Usability Testing', 'Severity of a finding is based on…', [
        'Impact and frequency',
        'Colour contrast only',
        'Delivery date',
        'Team preference',
      ], 0),
      _q('Usability Testing', 'A good loading state should…', [
        'Give feedback while waiting',
        'Freeze the app silently',
        'Hide content forever',
        'Play sound',
      ], 0),
    ],
  ),
  'c3': CourseQuiz(
    id: quizIdFor('c3'),
    courseId: 'c3',
    title: 'Digital Marketing Fundamentals — Final Quiz',
    questions: [
      _q('SEO & Content', 'What does SEO stand for?', [
        'Search Engine Optimization',
        'Social Engagement Options',
        'Site Efficiency Order',
        'Search Economy Org',
      ], 0),
      _q('SEO & Content', 'A target audience is defined by…', [
        'A random group',
        'Demographics, interests and behaviour',
        'Age only',
        'Location only',
      ], 1),
      _q('SEO & Content', 'What does CTR measure?', [
        'Clicks per 100 impressions',
        'Cost per rank',
        'Content to revenue',
        'Channel time ratio',
      ], 0),
      _q('SEO & Content', 'Long-tail keywords are…', [
        'One common word',
        'Specific three-or-more word phrases',
        'Misspellings',
        'Brand names only',
      ], 1),
      _q('SEO & Content', 'Duplicate content mainly…', [
        'Hurts search rankings',
        'Boosts rankings',
        'Brings free traffic',
        'Has no effect',
      ], 0),
      _q('Content & Social', 'A content calendar helps you…', [
        'Buy ads',
        'Manage DNS',
        'Plan and publish consistently',
        'Write backend code',
      ], 2),
      _q('Content & Social', 'Social proof means…', [
        'Posting often',
        'Reviews and numbers that build trust',
        'Paid followers',
        'Blue branding',
      ], 1),
      _q(
        'Content & Social',
        'The first seconds of a short video matter because of…',
        ['Watch-time hooks', 'Video resolution', 'Music volume', 'File size'],
        0,
      ),
      _q('Content & Social', 'The best time to post is…', [
        '9 AM every day',
        'When your audience is active',
        'Randomly',
        'Only at night',
      ], 1),
      _q('Email & Funnels', 'A lead magnet is…', [
        'A paid advertisement',
        'A free valuable offer for an email',
        'A CRM bug',
        'A popup design',
      ], 1),
      _q('Email & Funnels', 'A strong subject line is…', [
        'Long and spammy',
        'Clear with curiosity',
        'All uppercase only',
        'Full of symbols',
      ], 1),
      _q('Email & Funnels', 'An automation sequence sends…', [
        'One email per year',
        'Triggered emails based on behaviour',
        'Manual posts',
        'SMS only',
      ], 1),
      _q('Email & Funnels', 'A landing page should have…', [
        'One clear goal',
        'Ten navigation links',
        'Auto-play video',
        'A full blog',
      ], 0),
      _q('Email & Funnels', 'Poor deliverability is usually caused by…', [
        'Sending to invalid or unengaged lists',
        'Using HTML',
        'Short subject lines',
        'Daily sending',
      ], 0),
      _q('Paid Campaigns', 'What does ROAS stand for?', [
        'Return On Ad Spend',
        'Rate Of Active Users',
        'Reach Of All Sites',
        'Revenue Of Ads',
      ], 0),
      _q('Paid Campaigns', 'Retargeting shows ads to…', [
        'Everyone online',
        'People who already interacted with you',
        'Only employees',
        'Brand new visitors',
      ], 1),
      _q('Paid Campaigns', 'Conversion rate is calculated as…', [
        'conversions ÷ visitors × 100',
        'visitors ÷ conversions',
        'clicks × 100',
        'budget ÷ visitors',
      ], 0),
      _q('Paid Campaigns', 'A valid A/B test changes…', [
        'One variable at a time',
        'Two brands',
        'Nothing',
        'Several things',
      ], 0),
      _q('Paid Campaigns', 'Bounce rate is the share of visitors who…', [
        'Leave after viewing one page',
        'Click twice',
        'Open an email',
        'Return daily',
      ], 0),
      _q('Paid Campaigns', 'What does CAC stand for?', [
        'Customer Acquisition Cost',
        'Content And Creative',
        'Channel Activity Cost',
        'Cost Around Clicks',
      ], 0),
    ],
  ),
  'c4': CourseQuiz(
    id: quizIdFor('c4'),
    courseId: 'c4',
    title: 'Business Management Essentials — Final Quiz',
    questions: [
      _q('Fundamentals', 'The four functions of management are…', [
        'Planning, Organising, Leading, Controlling',
        'Hiring, paying, firing, training',
        'Selling, marketing, producing, shipping',
        'Designing, building, testing, shipping',
      ], 0),
      _q('Fundamentals', 'Delegation means…', [
        'Assigning a task together with the authority to decide',
        'Doing everything yourself',
        'Avoiding decisions',
        'Adding more meetings',
      ], 0),
      _q('Fundamentals', 'A SMART goal is…', [
        'Specific, Measurable, Achievable, Relevant, Time-bound',
        'Short, Manual, Active, Real, Tight',
        'Simple, Measured, Adaptive, Related, Timed',
        'Strategic, Minimal, Actionable, Rapid, Timed',
      ], 0),
      _q('Fundamentals', 'The Eisenhower matrix sorts work by…', [
        'Urgency and importance',
        'Salary and grade',
        'Team size',
        'Cost',
      ], 0),
      _q('Fundamentals', 'What does KPI mean?', [
        'Key Performance Indicator',
        'Known Process Issue',
        'Key Project Item',
        'Kill Process Immediately',
      ], 0),
      _q('Teams & Leadership', 'The healthiest way to handle conflict is to…', [
        'Ignore it until it passes',
        'Address it early, focused on the issue',
        'Escalate it publicly',
        'Make it personal',
      ], 1),
      _q('Teams & Leadership', 'Autonomy motivates people because it…', [
        'Removes all accountability',
        'Gives them choice over how they work',
        'Removes deadlines',
        'Requires overtime',
      ], 1),
      _q('Teams & Leadership', 'Effective feedback is…', [
        'Specific and timely',
        'Vague and yearly',
        'Only positive',
        'Given publicly to shame',
      ], 0),
      _q('Teams & Leadership', 'A RACI matrix clarifies…', [
        'Who is Responsible, Accountable, Consulted, Informed',
        'Salaries',
        'Office layout',
        'Bug lists',
      ], 0),
      _q('Teams & Leadership', 'Remote teams rely most on…', [
        'Async writing and documentation',
        'Long daily meetings',
        'Office presence',
        'Paper memos',
      ], 0),
      _q('Budgets & Operations', 'Budget variance compares…', [
        'Planned against actual numbers',
        'Team morale',
        'Marketing reach',
        'Only revenue',
      ], 0),
      _q('Budgets & Operations', 'Cash flow tracks…', [
        'Money in versus money out over time',
        'Only profit',
        'Employee count',
        'Share price',
      ], 0),
      _q('Budgets & Operations', 'A vendor SLA defines…', [
        'Service levels the supplier must meet',
        'Office lease terms',
        'Salary bands',
        'Marketing budget',
      ], 0),
      _q('Budgets & Operations', 'Process improvement starts by…', [
        'Mapping the current process',
        'Buying software',
        'Hiring more people',
        'Adding steps',
      ], 0),
      _q('Budgets & Operations', 'A useful KPI dashboard shows…', [
        'Every metric that exists',
        'A few decision-driving numbers',
        'Team photos',
        'Raw log files',
      ], 1),
      _q('Decision Making', 'Risk severity is likelihood…', [
        'multiplied by impact',
        'plus impact',
        'divided by impact',
        'minus impact',
      ], 0),
      _q('Decision Making', 'The RICE framework ranks work by…', [
        'Colour, size and shape',
        'Reach, Impact, Confidence, Effort',
        'Cost only',
        'A random guess',
      ], 1),
      _q('Decision Making', 'A stakeholder is…', [
        'Only the CEO',
        'Only customers',
        'Anyone affected by the project',
        'Only the delivery team',
      ], 2),
      _q('Decision Making', 'Benchmarking means…', [
        'Firing staff',
        'Cutting budgets',
        'Working weekends',
        'Comparing performance to a standard or rival',
      ], 3),
      _q('Decision Making', 'A good negotiation focuses on…', [
        'Who speaks loudest',
        'Winning at any cost',
        'Threats',
        'The interests behind the positions',
      ], 3),
    ],
  ),
  'c5': CourseQuiz(
    id: quizIdFor('c5'),
    courseId: 'c5',
    title: 'Python Programming — Final Quiz',
    questions: [
      _q('Python Basics', 'Which keyword is used to define a function?', [
        'function',
        'def',
        'method',
        'define',
      ], 1),
      _q('Python Basics', 'What does print() do?', [
        'Deletes data',
        'Outputs text',
        'Imports a module',
        'Starts a loop',
      ], 1),
      _q('Python Basics', 'Which symbol starts a single-line comment?', [
        '#',
        '//',
        '<!--',
        '--',
      ], 0),
      _q('Python Basics', 'What is the result of 7 // 2?', [
        '3.5',
        '4',
        '3',
        '1',
      ], 2),
      _q('Python Basics', 'Which type is created by "Hello"?', [
        'int',
        'bool',
        'str',
        'list',
      ], 2),
      _q('Loops & Functions', 'Which collection keeps only unique items?', [
        'list',
        'set',
        'tuple',
        'dict',
      ], 1),
      _q(
        'Loops & Functions',
        'What is the index of the first item in a list?',
        ['1', '0', '-1', '2'],
        1,
      ),
      _q(
        'Loops & Functions',
        'Which keyword starts a loop that runs while a condition is true?',
        ['for', 'loop', 'while', 'do'],
        2,
      ),
      _q('Loops & Functions', 'What does break do inside a loop?', [
        'Skips one turn',
        'Exits the loop',
        'Restarts the program',
        'Raises an error',
      ], 1),
      _q('Loops & Functions', 'Which of these is a valid variable name?', [
        '2name',
        'my-var',
        'class',
        'my_var',
      ], 3),
      _q('Loops & Functions', 'Which function reads input from the user?', [
        'read()',
        'scan()',
        'input()',
        'get()',
      ], 2),
      _q('Loops & Functions', 'What does an f-string provide?', [
        'File writing',
        'String formatting',
        'Fast sorting',
        'Forced typing',
      ], 1),
      _q(
        'Loops & Functions',
        'Which keyword sends a value back from a function?',
        ['print', 'yield only', 'output', 'return'],
        3,
      ),
      _q('Files & Errors', 'Errors are handled with which pair of blocks?', [
        'try / except',
        'catch / throw',
        'onError / end',
        'handle / stop',
      ], 0),
      _q(
        'Files & Errors',
        'Which statement guarantees a file is closed after use?',
        ['with open(...)', 'open() alone', 'import open', 'print open'],
        0,
      ),
      _q('Files & Errors', 'What does len([1, 2, 3]) return?', [
        '2',
        '6',
        '3',
        '1',
      ], 2),
      _q('Files & Errors', 'Which method adds an item to the END of a list?', [
        'add()',
        'push()',
        'append()',
        'insertAll()',
      ], 2),
      _q('Files & Errors', 'How do you read a value from a dictionary?', [
        'dict(key)',
        '[key] or .get(key)',
        'dict.read',
        'key.fetch()',
      ], 1),
      _q('Projects', 'Which module generates random numbers?', [
        'math',
        'os',
        'time',
        'random',
      ], 3),
      _q('Projects', 'What does type(9) print?', [
        "<class 'int'>",
        "<class 'str'>",
        'int',
        'number',
      ], 0),
    ],
  ),
  'c6': CourseQuiz(
    id: quizIdFor('c6'),
    courseId: 'c6',
    title: 'Personal Development & Productivity — Final Quiz',
    questions: [
      _q('Habits & Focus', 'The habit loop consists of…', [
        'Cue, routine, reward',
        'Plan, act, repeat',
        'Goal, tool, result',
        'Wake, work, sleep',
      ], 0),
      _q('Habits & Focus', 'A tiny habit should be…', [
        'Very small and easy to start',
        'Two hours long',
        'Secret from others',
        'Extremely ambitious',
      ], 0),
      _q('Habits & Focus', 'Habit stacking means…', [
        'Attaching a new habit to an existing routine',
        'Buying more apps',
        'Doing everything at once',
        'Skipping rest days',
      ], 0),
      _q('Habits & Focus', 'To break a bad habit you should…', [
        'Reward it regularly',
        'Add friction to the cue and action',
        'Hide it from others',
        'Ignore it completely',
      ], 1),
      _q('Time Management', 'The Two-Minute Rule says…', [
        'Wait two minutes before starting',
        'Do it now if it takes under two minutes',
        'Work only two minutes a day',
        'Set a two-minute timer for meetings',
      ], 1),
      _q('Time Management', 'Time blocking means…', [
        'Blocking websites',
        'Scheduling tasks into calendar slots',
        'Working overtime',
        'Random working',
      ], 1),
      _q('Time Management', 'The Eisenhower matrix prioritises…', [
        'Cheap versus expensive work',
        'Fast versus slow work',
        'Important versus urgent work',
        'Long versus short tasks',
      ], 2),
      _q('Time Management', 'Eat the frog means…', [
        'Skip meals while working',
        'Delegate everything',
        'Procrastinate first',
        'Do the hardest task first',
      ], 3),
      _q('Time Management', 'A weekly review is best done…', [
        'At a set time once a week',
        'Once a month',
        'Only in January',
        'Never',
      ], 0),
      _q('Time Management', 'Energy management means…', [
        'Matching hard work to your peak energy',
        'Sleeping less',
        'Working non-stop',
        'Relying on caffeine',
      ], 0),
      _q('Beating Procrastination', 'Procrastination is mostly…', [
        'Mood management, not laziness',
        'A permanent character flaw',
        'A sign of low intelligence',
        'Avoidable by willpower alone',
      ], 0),
      _q('Beating Procrastination', 'Deep work means…', [
        'Distraction-free focused sessions',
        'Multitasking with music',
        'Attending meetings',
        'Answering emails',
      ], 0),
      _q(
        'Beating Procrastination',
        'Accountability improves follow-through because…',
        [
          'Others notice your commitments',
          'It is more fun',
          'It removes deadlines',
          'It pays more money',
        ],
        0,
      ),
      _q('Beating Procrastination', 'A streak tracker helps because…', [
        'It replaces your goals',
        'Visible progress motivates consistency',
        'It looks nice on a wall',
        'It has no effect',
      ], 1),
      _q('Goals & Review', 'A SMART goal must include…', [
        'A deadline',
        'A slogan',
        'A large team',
        'A big budget',
      ], 0),
      _q('Goals & Review', 'Quarterly planning means…', [
        'Writing daily lists',
        'Choosing three outcomes per quarter',
        'Planning only in December',
        'Avoiding planning',
      ], 1),
      _q('Goals & Review', 'A reflection journal captures…', [
        'Passwords',
        'Meeting recordings',
        'Lessons and wins of the day',
        'Only unfinished tasks',
      ], 2),
      _q('Goals & Review', 'Environment design works because…', [
        'Cues around you drive behaviour',
        'It saves money',
        'It looks modern',
        'It has no effect',
      ], 0),
      _q('Goals & Review', 'Celebrating small wins…', [
        'Wastes time',
        'Hurts your focus',
        'Reinforces the behaviour',
        'Is unprofessional',
      ], 2),
      _q('Goals & Review', 'When a plan breaks down you should…', [
        'Abandon the goal',
        'Adjust the plan and continue',
        'Blame the team',
        'Double the workload',
      ], 1),
    ],
  ),
};

/// Loads the quiz that belongs to [courseId] — the ONLY way the UI gets
/// questions. Returns `null` when that course has no quiz yet.
CourseQuiz? quizForCourse(String courseId) => _quizByCourse[courseId];

/// Every quiz in the app (used by data-integrity tests).
@visibleForTesting
List<CourseQuiz> get allQuizzes => _quizByCourse.values.toList();

/// The quiz of a course, throwing when it is missing — handy in screens that
/// already checked with [quizForCourse].
CourseQuiz quizForCourseOrThrow(String courseId) {
  final quiz = _quizByCourse[courseId];
  if (quiz == null) throw StateError('No quiz for course $courseId');
  return quiz;
}

/// Convenience: the quiz of the course object itself.
CourseQuiz? quizOf(Course course) => quizForCourse(course.id);
