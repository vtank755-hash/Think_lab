import 'package:flutter/material.dart';

import 'certificate_page.dart';
import 'edit_profile_page.dart';
import 'login_user.dart';
import 'session.dart';

const _heading = Color(0xFF1B1838);
const _purple = Color(0xFF6C35E8);
const _indigo = Color(0xFF4846D9);
const _pageBg = Color(0xFFF6F5FB);

/// The Profile tab screen showing user details, learning links, certificates,
/// and logout options.
class ProfilePage extends StatelessWidget {
  final ValueChanged<int> onSelectTab;

  const ProfilePage({super.key, required this.onSelectTab});

  void _openCertificates(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CertificatePage(courseId: 'c3'),
      ),
    );
  }

  void _openEditProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfilePage(onSelectTab: onSelectTab),
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Logout',
          style: TextStyle(color: _heading, fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'Are you sure you want to log out of your LearnHub account?',
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
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        children: [
          _buildUserCard(context),
          const SizedBox(height: 20),
          _buildMenuItem(
            key: const ValueKey('profile-menu-learning'),
            icon: Icons.menu_book_rounded,
            iconColor: const Color(0xFF4C30DE),
            boxColor: const Color(0xFFE8EEFE),
            title: 'My Learning',
            onTap: () => onSelectTab(1),
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            key: const ValueKey('profile-menu-certificates'),
            icon: Icons.military_tech_outlined,
            iconColor: const Color(0xFFE5A116),
            boxColor: const Color(0xFFFEF3D6),
            title: 'Certificates',
            onTap: () => _openCertificates(context),
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            key: const ValueKey('profile-menu-wishlist'),
            icon: Icons.favorite_outline,
            iconColor: const Color(0xFFF04461),
            boxColor: const Color(0xFFFEE6EA),
            title: 'Wishlist',
            onTap: () => onSelectTab(2),
          ),
          const SizedBox(height: 36),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildUserCard(BuildContext context) {
    return ValueListenableBuilder<UserProfile>(
      valueListenable: userProfile,
      builder: (context, profile, _) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_purple, _indigo],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: _purple.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.8),
                    width: 3,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    profile.avatar,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                profile.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                profile.email,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                key: const ValueKey('profile-edit-button'),
                onTap: () => _openEditProfile(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Text(
                    'Edit Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItem({
    Key? key,
    required IconData icon,
    required Color iconColor,
    required Color boxColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      key: key,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: boxColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: _heading,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFDCD8EE),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF6C6898),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      key: const ValueKey('profile-logout-button'),
      onTap: () => _logout(context),
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFFEECEE),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.logout_rounded,
              color: Color(0xFFF04438),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Logout',
            style: TextStyle(
              color: Color(0xFFF04438),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
