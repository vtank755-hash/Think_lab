import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'enrollment_repository.dart';
import 'services/firestore_service.dart';

const _background = Color(0xFFF8FAFD);
const _ink = Color(0xFF182238);
const _muted = Color(0xFF8A9AB5);
const _purple = Color(0xFF5042F5);
const _green = Color(0xFF00A879);

class AdminEnrollmentsPage extends StatefulWidget {
  const AdminEnrollmentsPage({super.key});

  @override
  State<AdminEnrollmentsPage> createState() => _AdminEnrollmentsPageState();
}

class _AdminEnrollmentsPageState extends State<AdminEnrollmentsPage> {
  static const _courseTotals = {
    'Web Development Bootcamp': (1420, 1180, 240),
    'UI/UX Masterclass': (860, 710, 150),
    'Digital Marketing Guide': (540, 420, 120),
    'Business Management': (720, 580, 140),
  };

  static const _demoEnrollments = [
    AppEnrollment(
      id: 'demo-1',
      name: 'Sarah Jenkins',
      email: 'sarah.j@example.com',
      initials: 'SJ',
      avatarBackground: 0xFFE9EDFF,
      status: 'Active',
      completion: 78,
      progressText: '9/12 Modules • 3/4 Quizzes',
      enrolledDate: 'Oct 12, 2023',
      scoreLabel: 'Avg.',
      score: '84%',
    ),
    AppEnrollment(
      id: 'demo-2',
      name: 'Marcus Vance',
      email: 'm.vance@techmail.io',
      initials: 'MV',
      avatarBackground: 0xFFE6FAF3,
      status: 'Completed',
      completion: 100,
      progressText: 'Certified',
      enrolledDate: 'Aug 04, 2023',
      scoreLabel: 'Grade:',
      score: '94%',
    ),
    AppEnrollment(
      id: 'demo-3',
      name: 'Elena Rostova',
      email: 'elena.rostova@gmail.com',
      initials: 'ER',
      avatarBackground: 0xFFE8F1FF,
      status: 'In Progress',
      completion: 45,
      progressText: '5/12 Modules Completed',
      enrolledDate: 'Nov 01, 2023',
      scoreLabel: 'Avg.',
      score: '88%',
    ),
    AppEnrollment(
      id: 'demo-4',
      name: 'David Kim',
      email: 'dkim@develop.net',
      initials: 'DK',
      avatarBackground: 0xFFFFF6E4,
      status: 'Needs Attention',
      completion: 25,
      progressText: 'Inactive 14 days',
      enrolledDate: 'Sep 15, 2023',
      scoreLabel: 'Avg.',
      score: '62%',
      note: 'Inactive 14 days',
    ),
  ];

  final TextEditingController _searchController = TextEditingController();
  String _course = _courseTotals.keys.first;
  String _filter = 'All';
  String _query = '';
  Stream<List<AppEnrollment>>? _enrollmentsStream;

  @override
  void initState() {
    super.initState();
    _enrollmentsStream = _tryCreateEnrollmentsStream();
  }

  Stream<List<AppEnrollment>>? _tryCreateEnrollmentsStream() {
    try {
      FirebaseFirestore.instance;
      return FirestoreService.instance.enrollments
          .orderBy('updatedAt', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => AppEnrollment.fromMap(doc.id, doc.data()))
                .toList(),
          );
    } catch (_) {
      return null;
    }
  }

  List<AppEnrollment> _filteredEnrollments(List<AppEnrollment> enrollments) {
    final query = _query.trim().toLowerCase();
    return enrollments.where((enrollment) {
      final matchesQuery =
          query.isEmpty ||
          enrollment.name.toLowerCase().contains(query) ||
          enrollment.email.toLowerCase().contains(query);
      final matchesFilter = switch (_filter) {
        'In Progress' => enrollment.status == 'In Progress',
        'Completed' => enrollment.status == 'Completed',
        'At Risk' => enrollment.status == 'Needs Attention',
        _ => true,
      };
      return matchesQuery && matchesFilter;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totals = _courseTotals[_course]!;

    Widget body(List<AppEnrollment> source) {
      final enrollments = _filteredEnrollments(source);
      return Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                Row(
                  children: [
                    IconButton(
                      key: const ValueKey('enrollments-back'),
                      onPressed: () => Navigator.maybePop(context),
                      icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: _ink,
                        side: const BorderSide(color: Color(0xFFE7ECF5)),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Total Enrollments',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _ink,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'SELECT COURSE',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4FD),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      key: const ValueKey('enrollment-course-select'),
                      value: _course,
                      isExpanded: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Color(0xFF7182FF),
                      ),
                      items: _courseTotals.keys
                          .map(
                            (course) => DropdownMenuItem(
                              value: course,
                              child: Text(
                                course,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: _ink,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _course = value);
                      },
                      selectedItemBuilder: (context) => _courseTotals.keys
                          .map(
                            (course) => Align(
                              alignment: Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    course,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: _ink,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    'Total Students: ${_formatNumber(_courseTotals[course]!.$1)}'
                                    ' • Active: ${_formatNumber(_courseTotals[course]!.$2)}'
                                    ' • Done: ${_formatNumber(_courseTotals[course]!.$3)}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFF667994),
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        label: 'TOTAL ENROLLED',
                        value: _formatNumber(totals.$1),
                        detail: '+12% mo',
                        detailColor: _green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SummaryCard(
                        label: 'COMPLETION',
                        value: '${((totals.$3 / totals.$1) * 100).round()}%',
                        detail: '${_formatNumber(totals.$3)} certified',
                        detailColor: _purple,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: _SummaryCard(
                        label: 'AVG SCORE',
                        value: '81%',
                        detail: 'Above target',
                        detailColor: _green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                TextField(
                  key: const ValueKey('enrollment-search'),
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    hintText: 'Search student name, email, or ID...',
                    hintStyle: const TextStyle(color: _muted, fontSize: 12),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: _muted,
                      size: 19,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE5EAF3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE5EAF3)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'All (${_formatNumber(totals.$1)})',
                        value: 'All',
                        selected: _filter == 'All',
                        onTap: () => setState(() => _filter = 'All'),
                      ),
                      _FilterChip(
                        label: 'In Progress (980)',
                        value: 'In Progress',
                        selected: _filter == 'In Progress',
                        onTap: () => setState(() => _filter = 'In Progress'),
                      ),
                      _FilterChip(
                        label: 'Completed (${_formatNumber(totals.$3)})',
                        value: 'Completed',
                        selected: _filter == 'Completed',
                        onTap: () => setState(() => _filter = 'Completed'),
                      ),
                      _FilterChip(
                        label: 'At Risk (42)',
                        value: 'At Risk',
                        selected: _filter == 'At Risk',
                        onTap: () => setState(() => _filter = 'At Risk'),
                        color: const Color(0xFFE43F55),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (enrollments.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                      child: Text(
                        'No learners found.',
                        style: TextStyle(color: _muted),
                      ),
                    ),
                  )
                else
                  for (final enrollment in enrollments) ...[
                    _EnrollmentCard(enrollment: enrollment),
                    const SizedBox(height: 12),
                  ],
              ],
            ),
          ),
        ],
      );
    }

    return Scaffold(
      key: const ValueKey('admin-enrollments-page'),
      backgroundColor: _background,
      body: SafeArea(
        child: _enrollmentsStream == null
            ? body(_demoEnrollments)
            : StreamBuilder<List<AppEnrollment>>(
                stream: _enrollmentsStream,
                builder: (context, snapshot) {
                  final source =
                      (snapshot.hasData && snapshot.data!.isNotEmpty)
                      ? snapshot.data!
                      : _demoEnrollments;
                  return body(source);
                },
              ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final String detail;
  final Color detailColor;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.detail,
    required this.detailColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 108,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        border: Border.all(color: const Color(0xFFEDF1F7)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _muted,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: _ink,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            detail,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: detailColor,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
    this.color = _ink,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        key: ValueKey('enrollment-filter-$value'),
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        labelStyle: TextStyle(
          color: selected ? Colors.white : color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: Colors.white,
        selectedColor: _ink,
        side: BorderSide(color: selected ? _ink : const Color(0xFFE3E9F2)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      ),
    );
  }
}

class _EnrollmentCard extends StatelessWidget {
  final AppEnrollment enrollment;

  const _EnrollmentCard({required this.enrollment});

  @override
  Widget build(BuildContext context) {
    final color = switch (enrollment.status) {
      'Completed' => _green,
      'Needs Attention' => const Color(0xFFFF9200),
      'In Progress' => const Color(0xFF2F6BF6),
      _ => _purple,
    };
    return Container(
      key: ValueKey('enrollment-${enrollment.email}'),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE9EEF5)),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF314978).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Color(enrollment.avatarBackground),
                child: Text(
                  enrollment.initials,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      enrollment.name,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      enrollment.email,
                      style: const TextStyle(color: _muted, fontSize: 10),
                    ),
                  ],
                ),
              ),
              _EnrollmentStatus(status: enrollment.status, color: color),
              PopupMenuButton<String>(
                key: ValueKey('enrollment-menu-${enrollment.email}'),
                icon: const Icon(Icons.more_vert, color: _muted, size: 18),
                padding: EdgeInsets.zero,
                onSelected: (value) {
                  if (value == 'details') {
                    showDialog<void>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(enrollment.name),
                        content: Text(
                          '${enrollment.email}\n'
                          '${enrollment.completion}% completed\n'
                          'Enrolled ${enrollment.enrolledDate}',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'details',
                    child: Text('View enrollment details'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                '${enrollment.completion}% completed',
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  enrollment.progressText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: _muted, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: enrollment.completion / 100,
              minHeight: 5,
              backgroundColor: const Color(0xFFEEF2F7),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 9),
            child: Divider(height: 1, color: Color(0xFFF0F2F7)),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Enrolled ${enrollment.enrolledDate}',
                  style: const TextStyle(color: _muted, fontSize: 10),
                ),
              ),
              if (enrollment.note != null) ...[
                Text(
                  enrollment.note!,
                  style: const TextStyle(
                    color: Color(0xFFE34355),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9FBF4),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${enrollment.scoreLabel} ${enrollment.score}',
                  style: const TextStyle(
                    color: Color(0xFF008461),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EnrollmentStatus extends StatelessWidget {
  final String status;
  final Color color;

  const _EnrollmentStatus({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    final background = switch (status) {
      'Completed' => const Color(0xFFDDF8EF),
      'In Progress' => const Color(0xFFEAF1FF),
      'Needs Attention' => const Color(0xFFFFF3DB),
      _ => const Color(0xFFE3FCF3),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

String _formatNumber(int value) {
  final digits = value.toString();
  final result = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) result.write(',');
    result.write(digits[index]);
  }
  return result.toString();
}
