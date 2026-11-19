import 'package:flutter/material.dart';

import 'session.dart';
import 'widgets/nav_bar.dart';

const _heading = Color(0xFF2B2356);
const _muted = Color(0xFF8E8DBE);
const _purple = Color(0xFF6C35E8);
const _indigo = Color(0xFF4846D9);
const _pageBg = Color(0xFFF6F5FB);

/// Screen for editing the user's profile details.
class EditProfilePage extends StatefulWidget {
  final ValueChanged<int>? onSelectTab;

  const EditProfilePage({super.key, this.onSelectTab});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _bio;

  @override
  void initState() {
    super.initState();
    final profile = userProfile.value;
    _name = TextEditingController(text: profile.name);
    _email = TextEditingController(text: profile.email);
    _phone = TextEditingController(text: profile.phone);
    _bio = TextEditingController(text: profile.bio);
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _bio.dispose();
    super.dispose();
  }

  void _saveChanges() {
    updateProfile(
      name: _name.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      bio: _bio.text.trim(),
    );
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: _heading,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Color(0xFF25A55F), size: 22),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Profile updated successfully!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    Navigator.pop(context);
  }

  void _changePhoto() {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: _heading,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: const Text('Profile photo updated!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildAvatarSection(),
              const SizedBox(height: 24),
              _buildTextField('FULL NAME', _name),
              const SizedBox(height: 18),
              _buildTextField('EMAIL', _email),
              const SizedBox(height: 18),
              _buildTextField('PHONE NUMBER', _phone),
              const SizedBox(height: 18),
              _buildTextField('BIO', _bio, maxLines: 3),
              const SizedBox(height: 28),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavBar(
        currentIndex: 3,
        onTap: (tabIndex) {
          Navigator.pop(context);
          widget.onSelectTab?.call(tabIndex);
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.chevron_left_rounded,
              color: _heading,
              size: 26,
            ),
          ),
        ),
        const SizedBox(width: 14),
        const Text(
          'Edit Profile',
          style: TextStyle(
            color: _heading,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _purple, width: 3),
          ),
          child: ClipOval(
            child: Image.asset(
              userProfile.value.avatar,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _changePhoto,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1EDFE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.camera_alt_outlined, color: _purple, size: 16),
                SizedBox(width: 6),
                Text(
                  'Change Photo',
                  style: TextStyle(
                    color: _purple,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _muted,
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E2F6), width: 1.2),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(
              color: Color(0xFF1B1838),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_purple, _indigo],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _purple.withValues(alpha: 0.3),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _saveChanges,
            child: const Center(
              child: Text(
                'Save Changes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
