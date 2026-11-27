import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'session.dart';

const _background = Color(0xFFF8FAFD);
const _heading = Color(0xFF171D31);
const _muted = Color(0xFF7886A1);
const _purple = Color(0xFF5144E8);

class _AdminProfileDetails {
  final String name;
  final String email;
  final String academy;
  final String role;
  final String title;

  const _AdminProfileDetails({
    required this.name,
    required this.email,
    required this.academy,
    required this.role,
    required this.title,
  });
}

class AdminProfilePage extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onLogout;

  const AdminProfilePage({
    super.key,
    required this.onBack,
    required this.onLogout,
  });

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  late _AdminProfileDetails _details;
  Uint8List? _photoBytes;

  @override
  void initState() {
    super.initState();
    if (isAdminSession.value) {
      final profile = userProfile.value;
      _details = _AdminProfileDetails(
        name: profile.name.isNotEmpty ? profile.name : 'Admin',
        email: profile.email,
        academy: 'Apex Learning Academy',
        role: 'Super Admin',
        title: 'Lead Instructor',
      );
    } else {
      _details = const _AdminProfileDetails(
        name: 'Dr. Evelyn Reed',
        email: 'evelyn.reed@apex.edu',
        academy: 'Apex Learning Academy',
        role: 'Super Admin',
        title: 'Lead Instructor',
      );
    }
  }

  Future<void> _editProfile() async {
    final result = await Navigator.push<_AdminProfileEditResult>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            _AdminProfileEditPage(details: _details, photoBytes: _photoBytes),
      ),
    );
    if (!mounted || result == null) return;
    setState(() {
      _details = result.details;
      _photoBytes = result.photoBytes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('admin-profile-page'),
      backgroundColor: _background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          key: const ValueKey('admin-profile-back'),
                          onPressed: widget.onBack,
                          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFFF0F3F8),
                            foregroundColor: _muted,
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            'Admin Profile',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _heading,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        IconButton(
                          key: const ValueKey('admin-profile-settings'),
                          onPressed: _editProfile,
                          icon: const Icon(Icons.tune_rounded),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFFF0F3F8),
                            foregroundColor: _muted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F9FC),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: const Color(0xFFF0F2F6)),
                      ),
                      child: Column(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE9E9F9),
                                  shape: BoxShape.circle,
                                ),
                                child: CircleAvatar(
                                  radius: 43,
                                  backgroundImage: _photoBytes == null
                                      ? const AssetImage(
                                          'assets/images/profile/avatar.jpg',
                                        )
                                      : MemoryImage(_photoBytes!)
                                            as ImageProvider,
                                ),
                              ),
                              Positioned(
                                right: -2,
                                bottom: 0,
                                child: IconButton(
                                  key: const ValueKey(
                                    'admin-profile-edit-photo',
                                  ),
                                  onPressed: _editProfile,
                                  icon: const Icon(
                                    Icons.camera_alt_outlined,
                                    size: 17,
                                  ),
                                  style: IconButton.styleFrom(
                                    fixedSize: const Size(32, 32),
                                    backgroundColor: _purple,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _details.name,
                                style: TextStyle(
                                  color: _heading,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Icon(
                                Icons.verified,
                                color: _purple,
                                size: 18,
                              ),
                            ],
                          ),
                          const SizedBox(height: 7),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              _ProfileBadge(
                                label: _details.role,
                                background: Color(0xFFEDEBFF),
                                foreground: Color(0xFF4036C8),
                              ),
                              _ProfileBadge(
                                label: _details.title,
                                background: Color(0xFFE8FBF4),
                                foreground: Color(0xFF008C68),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _details.academy,
                            style: TextStyle(color: _muted, fontSize: 12),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Divider(height: 1, color: Color(0xFFEEF0F5)),
                          ),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 16,
                            runSpacing: 8,
                            children: [
                              _ProfileContact(
                                icon: Icons.mail_outline,
                                label: _details.email,
                              ),
                              _ProfileContact(
                                icon: Icons.calendar_month_outlined,
                                label: 'Since Jan 2022',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: const [
                        Expanded(
                          child: _AdminMetricCard(
                            label: 'COURSES',
                            value: '12',
                            detail: '8 Active',
                            detailColor: Color(0xFF009B6D),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: _AdminMetricCard(
                            label: 'STUDENTS',
                            value: '3,840',
                            detail: 'Across all',
                            valueColor: _purple,
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: _AdminMetricCard(
                            label: 'QUIZZES',
                            value: '48',
                            detail: '82% Avg Pass',
                            detailColor: _purple,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  key: const ValueKey('admin-profile-logout'),
                  onPressed: widget.onLogout,
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('Log Out'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFD63845),
                    side: const BorderSide(color: Color(0xFFF2C9CD)),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminProfileEditResult {
  final _AdminProfileDetails details;
  final Uint8List? photoBytes;

  const _AdminProfileEditResult({
    required this.details,
    required this.photoBytes,
  });
}

class _AdminProfileEditPage extends StatefulWidget {
  final _AdminProfileDetails details;
  final Uint8List? photoBytes;

  const _AdminProfileEditPage({
    required this.details,
    required this.photoBytes,
  });

  @override
  State<_AdminProfileEditPage> createState() => _AdminProfileEditPageState();
}

class _AdminProfileEditPageState extends State<_AdminProfileEditPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _academyController;
  late String _role;
  late String _title;
  Uint8List? _photoBytes;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.details.name);
    _emailController = TextEditingController(text: widget.details.email);
    _academyController = TextEditingController(text: widget.details.academy);
    _role = widget.details.role;
    _title = widget.details.title;
    _photoBytes = widget.photoBytes;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _academyController.dispose();
    super.dispose();
  }

  Future<void> _changePhoto() async {
    final files = await FilePicker.pickFiles(type: FileType.image);
    if (files.isEmpty) return;
    final bytes = await files.first.readAsBytes();
    if (!mounted) return;
    setState(() => _photoBytes = bytes);
  }

  void _save() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final academy = _academyController.text.trim();
    if (name.isEmpty || !email.contains('@') || academy.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a name, valid email, and academy name.'),
        ),
      );
      return;
    }

    Navigator.pop(
      context,
      _AdminProfileEditResult(
        details: _AdminProfileDetails(
          name: name,
          email: email,
          academy: academy,
          role: _role,
          title: _title,
        ),
        photoBytes: _photoBytes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('admin-profile-edit-page'),
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _heading,
        elevation: 0,
        title: const Text(
          'Edit Admin Profile',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 54,
                  backgroundColor: const Color(0xFFE9E9F9),
                  backgroundImage: _photoBytes == null
                      ? const AssetImage('assets/images/profile/avatar.jpg')
                      : MemoryImage(_photoBytes!) as ImageProvider,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: IconButton(
                    key: const ValueKey('edit-admin-profile-photo'),
                    onPressed: _changePhoto,
                    icon: const Icon(Icons.camera_alt_outlined, size: 18),
                    style: IconButton.styleFrom(
                      fixedSize: const Size(36, 36),
                      backgroundColor: _purple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFF0F2F6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Personal Information',
                  style: TextStyle(
                    color: _heading,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                _ProfileEditField(
                  label: 'Full Name',
                  controller: _nameController,
                  key: const ValueKey('admin-profile-name'),
                  icon: Icons.badge_outlined,
                ),
                const SizedBox(height: 14),
                _ProfileEditField(
                  label: 'Email Address',
                  controller: _emailController,
                  key: const ValueKey('admin-profile-email'),
                  icon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 14),
                _ProfileEditField(
                  label: 'Academy',
                  controller: _academyController,
                  key: const ValueKey('admin-profile-academy'),
                  icon: Icons.school_outlined,
                ),
                const SizedBox(height: 14),
                _ProfileDropdown(
                  key: const ValueKey('admin-profile-role'),
                  label: 'Role',
                  value: _role,
                  items: const ['Super Admin', 'Admin'],
                  onChanged: (value) => setState(() => _role = value),
                ),
                const SizedBox(height: 14),
                _ProfileDropdown(
                  key: const ValueKey('admin-profile-title'),
                  label: 'Title',
                  value: _title,
                  items: const [
                    'Lead Instructor',
                    'Instructor',
                    'Course Manager',
                  ],
                  onChanged: (value) => setState(() => _title = value),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
          child: FilledButton.icon(
            key: const ValueKey('save-admin-profile'),
            onPressed: _save,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save Changes'),
            style: FilledButton.styleFrom(
              backgroundColor: _purple,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileEditField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType? keyboardType;

  const _ProfileEditField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: _muted, fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 19, color: _muted),
            filled: true,
            fillColor: const Color(0xFFF2F1F8),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const _ProfileDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: _muted, fontSize: 12)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: (item) {
            if (item != null) onChanged(item);
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF2F1F8),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 4,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileBadge extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;

  const _ProfileBadge({
    required this.label,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ProfileContact extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ProfileContact({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: _muted),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: _muted, fontSize: 11)),
      ],
    );
  }
}

class _AdminMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String detail;
  final Color detailColor;
  final Color valueColor;

  const _AdminMetricCard({
    required this.label,
    required this.value,
    required this.detail,
    this.detailColor = _muted,
    this.valueColor = _heading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 94,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0F2F6)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF506079),
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
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
