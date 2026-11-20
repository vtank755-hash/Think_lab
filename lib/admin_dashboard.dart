import 'package:flutter/material.dart';

import 'admin_category.dart';
import 'admin_courses_page.dart';
import 'admin_manega_user.dart';
import 'admin_login.dart';
import 'create_course_quiz_page.dart';
import 'login_user.dart';
import 'session.dart';

const _purple = Color(0xFF6B45F0);
const _heading = Color(0xFF1B1838);
const _muted = Color(0xFF8E8EA9);
const _pageBg = Color(0xFFF7F8FE);
const _green = Color(0xFF25A55F);

/// The **Admin Panel Dashboard** screen.
///
/// Opened immediately after successful admin login from [AdminLoginPage].
class AdminDashboardPage extends StatefulWidget {
  final int initialTab;
  const AdminDashboardPage({super.key, this.initialTab = 0});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  late int _currentTab;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
  }

  void _showActionFeedback(String actionName) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _heading,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text('$actionName clicked (Admin Action)'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Admin Logout',
          style: TextStyle(color: _heading, fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'Do you want to log out of the Admin Panel?',
          style: TextStyle(color: Color(0xFF6F6B92), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: _purple)),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFF04438),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      body: SafeArea(child: _buildBody()),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  /// Returns the page body for the currently selected admin nav tab.
  Widget _buildBody() {
    switch (_currentTab) {
      // ── Tab 1: Manage Courses ────────────────────────────────────────────
      case 1:
        return const AdminCoursesPage();

      // ── Tab 2: Manage Users ──────────────────────────────────────────────
      case 2:
        return const AdminManageUsersPage();

      // ── Tab 0: Dashboard (default) ───────────────────────────────────────
      default:
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildStatsGrid(),
              const SizedBox(height: 28),
              _buildQuickActions(),
            ],
          ),
        );
    }
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'WELCOME BACK,',
              style: TextStyle(
                color: _purple,
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Admin Panel',
              style: TextStyle(
                color: _heading,
                fontSize: 27,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: _showLogoutDialog,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE2E0F4), width: 2),
                  color: Colors.white,
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/profile/avatar.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.person_outline_rounded,
                iconColor: const Color(0xFF6C35E8),
                iconBg: const Color(0xFFEDEAFE),
                badgeText: '+12%',
                badgeTextColor: _green,
                badgeBg: const Color(0xFFE5F8EE),
                value: '24.8k',
                label: 'Total Users',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                key: const ValueKey('stat-card-courses'),
                icon: Icons.menu_book_outlined,
                iconColor: const Color(0xFF4C30DE),
                iconBg: const Color(0xFFE8EEFE),
                badgeText: '+8 new',
                badgeTextColor: const Color(0xFF4C30DE),
                badgeBg: const Color(0xFFEEF0FE),
                value: '342',
                label: 'Total Courses',
                onTap: () => setState(() => _currentTab = 1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.bar_chart_rounded,
                iconColor: const Color(0xFF009688),
                iconBg: const Color(0xFFE0F5F2),
                badgeText: 'Active',
                badgeTextColor: const Color(0xFF00897B),
                badgeBg: const Color(0xFFE0F7F4),
                value: '18.2k',
                label: 'Enrollments',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                icon: Icons.currency_rupee_rounded,
                iconColor: _green,
                iconBg: const Color(0xFFE4F7EC),
                badgeText: '+18.4%',
                badgeTextColor: _green,
                badgeBg: const Color(0xFFE5F8EE),
                value: '₹12.8M',
                label: 'Total Revenue',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String badgeText,
    required Color badgeTextColor,
    required Color badgeBg,
    required String value,
    required String label,
    VoidCallback? onTap,
    Key? key,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      color: badgeTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              value,
              style: const TextStyle(
                color: _heading,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: _muted,
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            color: _heading,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          key: const ValueKey('admin-quick-actions'),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildActionItem(
              key: const ValueKey('quick-action-add'),
              icon: Icons.add_rounded,
              iconColor: const Color(0xFF4C30DE),
              bgColor: const Color(0xFFEEECFA),
              label: 'Add',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateCourseQuizPage(),
                  ),
                );
              },
            ),
            _buildActionItem(
              key: const ValueKey('quick-action-categories'),
              icon: Icons.category_outlined,
              iconColor: const Color(0xFF6B45F0),
              bgColor: const Color(0xFFEDEAFE),
              label: 'Category',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminCategoryPage()),
                );
              },
            ),
            _buildActionItem(
              icon: Icons.receipt_long_outlined,
              iconColor: const Color(0xFF009688),
              bgColor: const Color(0xFFE2F6F3),
              label: 'Orders',
              onTap: () => _showActionFeedback('View Orders'),
            ),
            _buildActionItem(
              icon: Icons.pie_chart_outline_rounded,
              iconColor: const Color(0xFFE02424),
              bgColor: const Color(0xFFFDECEE),
              label: 'Quiz',
              onTap: () => _showActionFeedback('Manage Quizzes'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionItem({
    Key? key,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: _heading,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final navs = [
      {'label': 'Dashboard', 'icon': Icons.grid_view_rounded},
      {'label': 'Courses', 'icon': Icons.menu_book_outlined},
      {'label': 'Users', 'icon': Icons.person_outline_rounded},
      {'label': 'Orders', 'icon': Icons.receipt_outlined},
      {'label': 'Profile', 'icon': Icons.settings_outlined},
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (var i = 0; i < navs.length; i++)
            Expanded(
              child: InkWell(
                key: ValueKey(
                  'admin-nav-${(navs[i]['label'] as String).toLowerCase()}',
                ),
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  if (i == 4) {
                    _showLogoutDialog();
                  } else {
                    setState(() => _currentTab = i);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        navs[i]['icon'] as IconData,
                        color: _currentTab == i ? _purple : _muted,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        navs[i]['label'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          color: _currentTab == i ? _purple : _muted,
                          fontWeight: _currentTab == i
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
