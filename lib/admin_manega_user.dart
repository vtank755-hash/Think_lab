import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

const _pageBackground = Color(0xFFF5F3FF);
const _headingColor = Color(0xFF1B1838);
const _mutedColor = Color(0xFF7C7A9B);
const _purple = Color(0xFF5B50F2);

class AdminManageUsersPage extends StatefulWidget {
  const AdminManageUsersPage({super.key});

  @override
  State<AdminManageUsersPage> createState() => _AdminManageUsersPageState();
}

class _ManagedUser {
  final String id;
  final String publicId;
  String name;
  String email;
  String phone;
  String joined;
  String role;
  int courseCount;
  int assessment;
  int certificates;
  int totalSpend;
  bool isBlocked;
  bool isFeatured;
  final Color avatarColor;
  final bool isProMember;
  Uint8List? photoBytes;

  _ManagedUser({
    required this.id,
    required this.publicId,
    required this.name,
    required this.email,
    required this.phone,
    required this.joined,
    required this.role,
    required this.courseCount,
    required this.assessment,
    required this.certificates,
    required this.totalSpend,
    required this.isBlocked,
    required this.avatarColor,
    this.isFeatured = false,
    this.isProMember = true,
    this.photoBytes,
  });

  String get initials => name
      .split(' ')
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part[0])
      .join()
      .toUpperCase();
}

class _AdminManageUsersPageState extends State<AdminManageUsersPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String? _statusFilter;
  final List<_ManagedUser> _users = [
    _ManagedUser(
      id: 'u1',
      publicId: 'USR-9042',
      name: 'Aarav Sharma',
      email: 'aarav@email.com',
      phone: '+91 98765 43210',
      joined: 'October 2023',
      role: 'Learner / Student',
      courseCount: 4,
      assessment: 82,
      certificates: 2,
      totalSpend: 19996,
      isBlocked: false,
      avatarColor: const Color(0xFFB7D6E8),
      isFeatured: true,
    ),
    _ManagedUser(
      id: 'u2',
      publicId: 'USR-3816',
      name: 'Sneha Patel',
      email: 'sneha@email.com',
      phone: '+91 98765 43211',
      joined: 'January 2024',
      role: 'Learner / Student',
      courseCount: 7,
      assessment: 91,
      certificates: 4,
      totalSpend: 32997,
      isBlocked: false,
      avatarColor: const Color(0xFFE9C9BD),
    ),
    _ManagedUser(
      id: 'u3',
      publicId: 'USR-7783',
      name: 'Rahul Verma',
      email: 'rahul@email.com',
      phone: '+91 98765 43212',
      joined: 'March 2024',
      role: 'Learner / Student',
      courseCount: 2,
      assessment: 68,
      certificates: 1,
      totalSpend: 9998,
      isBlocked: true,
      avatarColor: const Color(0xFFD8D4CB),
    ),
    _ManagedUser(
      id: 'u4',
      publicId: 'USR-1257',
      name: 'Kavya Reddy',
      email: 'kavya@email.com',
      phone: '+91 98765 43213',
      joined: 'June 2024',
      role: 'Learner / Student',
      courseCount: 5,
      assessment: 88,
      certificates: 3,
      totalSpend: 24995,
      isBlocked: false,
      avatarColor: const Color(0xFFD7C5B7),
    ),
    _ManagedUser(
      id: 'u5',
      publicId: 'USR-6091',
      name: 'Rohan Gupta',
      email: 'rohan.g@email.com',
      phone: '+91 98765 43214',
      joined: 'August 2024',
      role: 'Learner / Student',
      courseCount: 3,
      assessment: 76,
      certificates: 2,
      totalSpend: 14997,
      isBlocked: false,
      avatarColor: const Color(0xFFC9D6D1),
    ),
  ];

  List<_ManagedUser> get _filteredUsers {
    final query = _query.trim().toLowerCase();
    return _users.where((user) {
      final matchesQuery =
          query.isEmpty ||
          user.name.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query);
      final matchesStatus =
          _statusFilter == null ||
          (_statusFilter == 'Blocked' ? user.isBlocked : !user.isBlocked);
      return matchesQuery && matchesStatus;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectStatusFilter() async {
    final status = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter users',
                style: TextStyle(
                  color: _headingColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              for (final option in ['All', 'Active', 'Blocked'])
                ListTile(
                  key: ValueKey('user-filter-$option'),
                  contentPadding: EdgeInsets.zero,
                  title: Text(option),
                  trailing: (_statusFilter ?? 'All') == option
                      ? const Icon(Icons.check, color: _purple)
                      : null,
                  onTap: () => Navigator.pop(sheetContext, option),
                ),
            ],
          ),
        ),
      ),
    );
    if (!mounted || status == null) return;
    setState(() => _statusFilter = status == 'All' ? null : status);
  }

  Future<void> _editUser(_ManagedUser user) async {
    final updatedUser = await Navigator.push<_ManagedUser>(
      context,
      MaterialPageRoute(builder: (_) => _AdminUserEditPage(user: user)),
    );
    if (!mounted || updatedUser == null) return;
    setState(() {
      user
        ..name = updatedUser.name
        ..email = updatedUser.email
        ..phone = updatedUser.phone
        ..role = updatedUser.role
        ..photoBytes = updatedUser.photoBytes;
    });
  }

  Future<void> _viewUser(_ManagedUser user) async {
    final updatedUser = await Navigator.push<_ManagedUser>(
      context,
      MaterialPageRoute(builder: (_) => _AdminUserProfilePage(user: user)),
    );
    if (!mounted || updatedUser == null) return;
    setState(() {
      user
        ..name = updatedUser.name
        ..email = updatedUser.email
        ..phone = updatedUser.phone
        ..role = updatedUser.role
        ..photoBytes = updatedUser.photoBytes;
    });
  }

  Future<void> _deleteUser(_ManagedUser user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete user?'),
        content: Text('Remove ${user.name} from the user list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: ValueKey('confirm-delete-user-${user.id}'),
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFF04458),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    setState(() => _users.remove(user));
  }

  @override
  Widget build(BuildContext context) {
    final users = _filteredUsers;

    return Scaffold(
      key: const ValueKey('admin-manage-users-page'),
      backgroundColor: _pageBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Manage Users',
                style: TextStyle(
                  color: _headingColor,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: const ValueKey('manage-users-search'),
                      controller: _searchController,
                      onChanged: (value) => setState(() => _query = value),
                      decoration: InputDecoration(
                        hintText: 'Search users...',
                        hintStyle: const TextStyle(color: Color(0xFFA8B5FF)),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF707CFF),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: Color(0xFFE6E8F7),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: Color(0xFFE6E8F7),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    key: const ValueKey('filter-users-button'),
                    onPressed: _selectStatusFilter,
                    icon: const Icon(Icons.tune_rounded),
                    style: IconButton.styleFrom(
                      fixedSize: const Size(52, 52),
                      backgroundColor: _purple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: users.isEmpty
                    ? const Center(
                        child: Text(
                          'No users found.',
                          style: TextStyle(color: _mutedColor),
                        ),
                      )
                    : ListView.separated(
                        key: const ValueKey('manage-users-list'),
                        itemCount: users.length,
                        padding: const EdgeInsets.only(bottom: 12),
                        separatorBuilder: (_, _) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return _UserCard(
                            user: user,
                            onEdit: () => _editUser(user),
                            onView: () => _viewUser(user),
                            onDelete: () => _deleteUser(user),
                            onToggleFeatured: () => setState(
                              () => user.isFeatured = !user.isFeatured,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final _ManagedUser user;
  final VoidCallback onEdit;
  final VoidCallback onView;
  final VoidCallback onDelete;
  final VoidCallback onToggleFeatured;

  const _UserCard({
    required this.user,
    required this.onEdit,
    required this.onView,
    required this.onDelete,
    required this.onToggleFeatured,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = user.isBlocked
        ? const Color(0xFFC83C39)
        : const Color(0xFF006B4F);
    final statusBackground = user.isBlocked
        ? const Color(0xFFFFE6E4)
        : const Color(0xFFDDF7EE);

    return Container(
      key: ValueKey('manage-user-card-${user.id}'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF42339D).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _UserAvatar(user: user, radius: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            color: _headingColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusBackground,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            user.isBlocked ? 'Blocked' : 'Active',
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${user.email} · ${user.courseCount} courses',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF7580FF),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                key: ValueKey('feature-user-${user.id}'),
                onPressed: onToggleFeatured,
                icon: Icon(
                  user.isFeatured ? Icons.star_rounded : Icons.add,
                  size: 20,
                ),
                color: const Color(0xFF7C80FF),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Divider(height: 1, color: Color(0xFFF0F1F8)),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _UserActionButton(
                key: ValueKey('edit-user-${user.id}'),
                label: 'Edit',
                onPressed: onEdit,
              ),
              const SizedBox(width: 8),
              _UserActionButton(
                key: ValueKey('view-user-${user.id}'),
                label: 'View',
                onPressed: onView,
              ),
              const SizedBox(width: 8),
              _UserActionButton(
                key: ValueKey('delete-user-${user.id}'),
                label: 'Delete',
                isDestructive: true,
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UserActionButton extends StatelessWidget {
  final String label;
  final bool isDestructive;
  final VoidCallback onPressed;

  const _UserActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? const Color(0xFFD72828) : _purple;
    return SizedBox(
      height: 34,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: color,
          backgroundColor: isDestructive
              ? const Color(0xFFFFE9E8)
              : const Color(0xFFF0F2FF),
          padding: const EdgeInsets.symmetric(horizontal: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isDestructive
                ? const BorderSide(color: Color(0xFFFFD1CE))
                : BorderSide.none,
          ),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        child: Text(label),
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  final _ManagedUser user;
  final double radius;

  const _UserAvatar({required this.user, required this.radius});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: user.avatarColor,
      backgroundImage: user.photoBytes == null
          ? null
          : MemoryImage(user.photoBytes!),
      child: user.photoBytes == null
          ? Text(
              user.initials,
              style: const TextStyle(
                color: _headingColor,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            )
          : null,
    );
  }
}

class _AdminUserEditPage extends StatefulWidget {
  final _ManagedUser user;

  const _AdminUserEditPage({required this.user});

  @override
  State<_AdminUserEditPage> createState() => _AdminUserEditPageState();
}

class _AdminUserEditPageState extends State<_AdminUserEditPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late String _role;
  Uint8List? _photoBytes;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phone);
    _role = widget.user.role;
    _photoBytes = widget.user.photoBytes;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _changePhoto() async {
    final files = await FilePicker.pickFiles(type: FileType.image);
    if (files.isEmpty) return;
    final bytes = await files.first.readAsBytes();
    if (!mounted) return;
    setState(() => _photoBytes = bytes);
  }

  void _saveChanges() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    if (name.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid name and email address.')),
      );
      return;
    }

    final user = widget.user;
    Navigator.pop(
      context,
      _ManagedUser(
        id: user.id,
        publicId: user.publicId,
        name: name,
        email: email,
        phone: _phoneController.text.trim(),
        joined: user.joined,
        role: _role,
        courseCount: user.courseCount,
        assessment: user.assessment,
        certificates: user.certificates,
        totalSpend: user.totalSpend,
        isBlocked: user.isBlocked,
        avatarColor: user.avatarColor,
        isFeatured: user.isFeatured,
        isProMember: user.isProMember,
        photoBytes: _photoBytes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('edit-admin-user-page'),
      backgroundColor: _pageBackground,
      appBar: AppBar(
        backgroundColor: _pageBackground,
        foregroundColor: _headingColor,
        elevation: 0,
        title: const Text(
          'Edit User',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: _purple,
              child: Icon(Icons.person_outline, color: Colors.white, size: 19),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Row(
              children: [
                const Icon(Icons.account_circle_outlined, size: 16),
                const SizedBox(width: 6),
                const Text(
                  'User Details',
                  style: TextStyle(color: _headingColor, fontSize: 12),
                ),
                const Spacer(),
                _UserMetaChip(label: '#${widget.user.publicId}'),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
              decoration: _userCardDecoration(),
              child: Column(
                children: [
                  Stack(
                    children: [
                      _UserAvatar(user: _userWithPhoto, radius: 48),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: IconButton(
                          key: const ValueKey('change-user-photo-icon'),
                          onPressed: _changePhoto,
                          icon: const Icon(Icons.camera_alt_outlined, size: 18),
                          style: IconButton.styleFrom(
                            fixedSize: const Size(34, 34),
                            backgroundColor: _purple,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _nameController.text,
                    style: const TextStyle(
                      color: _headingColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Joined ${widget.user.joined} · '
                    '${widget.user.courseCount} Active Enrollments',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: _mutedColor, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    key: const ValueKey('change-user-photo'),
                    onPressed: _changePhoto,
                    icon: const Icon(Icons.file_upload_outlined, size: 16),
                    label: const Text('Change Photo'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _purple,
                      backgroundColor: const Color(0xFFE9E2FF),
                      side: BorderSide.none,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: _userCardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _UserSectionTitle(title: 'Personal Information'),
                  const SizedBox(height: 16),
                  _EditUserField(
                    label: 'Full Name',
                    controller: _nameController,
                    key: const ValueKey('edit-user-name'),
                    icon: Icons.badge_outlined,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  _EditUserField(
                    label: 'Email Address',
                    controller: _emailController,
                    key: const ValueKey('edit-user-email'),
                    icon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  _EditUserField(
                    label: 'Phone Number',
                    controller: _phoneController,
                    key: const ValueKey('edit-user-phone'),
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Role in Studio',
                    style: TextStyle(color: Color(0xFF4D4B5F), fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    key: const ValueKey('edit-user-role'),
                    initialValue: _role,
                    items: const [
                      DropdownMenuItem(
                        value: 'Learner / Student',
                        child: Text('Learner / Student'),
                      ),
                      DropdownMenuItem(
                        value: 'Instructor',
                        child: Text('Instructor'),
                      ),
                      DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _role = value);
                    },
                    decoration: _userFieldDecoration(
                      prefixIcon: const Icon(Icons.school_outlined),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          color: _pageBackground,
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
          child: FilledButton.icon(
            key: ValueKey('save-user-${widget.user.id}'),
            onPressed: _saveChanges,
            icon: const Icon(Icons.save_outlined, size: 18),
            label: const Text('Save Changes'),
            style: FilledButton.styleFrom(
              backgroundColor: _purple,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ),
      ),
    );
  }

  _ManagedUser get _userWithPhoto => _ManagedUser(
    id: widget.user.id,
    publicId: widget.user.publicId,
    name: _nameController.text,
    email: _emailController.text,
    phone: _phoneController.text,
    joined: widget.user.joined,
    role: _role,
    courseCount: widget.user.courseCount,
    assessment: widget.user.assessment,
    certificates: widget.user.certificates,
    totalSpend: widget.user.totalSpend,
    isBlocked: widget.user.isBlocked,
    avatarColor: widget.user.avatarColor,
    isFeatured: widget.user.isFeatured,
    isProMember: widget.user.isProMember,
    photoBytes: _photoBytes,
  );
}

class _AdminUserProfilePage extends StatefulWidget {
  final _ManagedUser user;

  const _AdminUserProfilePage({required this.user});

  @override
  State<_AdminUserProfilePage> createState() => _AdminUserProfilePageState();
}

class _AdminUserProfilePageState extends State<_AdminUserProfilePage> {
  late _ManagedUser _user;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  Future<void> _editProfile() async {
    final updatedUser = await Navigator.push<_ManagedUser>(
      context,
      MaterialPageRoute(builder: (_) => _AdminUserEditPage(user: _user)),
    );
    if (!mounted || updatedUser == null) return;
    setState(() => _user = updatedUser);
  }

  void _closeProfile() => Navigator.pop(context, _user);

  @override
  Widget build(BuildContext context) {
    final statusLabel = _user.isBlocked ? 'Blocked Learner' : 'Active Learner';

    return Scaffold(
      key: const ValueKey('view-admin-user-page'),
      backgroundColor: _pageBackground,
      appBar: AppBar(
        backgroundColor: _pageBackground,
        foregroundColor: _headingColor,
        elevation: 0,
        leading: IconButton(
          key: const ValueKey('view-user-back'),
          onPressed: _closeProfile,
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text(
          'User Profile',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        actions: [
          PopupMenuButton<String>(
            key: const ValueKey('user-profile-menu'),
            onSelected: (value) {
              if (value == 'edit') _editProfile();
              if (value == 'close') _closeProfile();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit User')),
              PopupMenuItem(value: 'close', child: Text('Close Profile')),
            ],
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            Row(
              children: [
                _UserMetaChip(
                  label: '#${_user.publicId}',
                  color: const Color(0xFFE9E8EF),
                ),
                const SizedBox(width: 8),
                _UserMetaChip(
                  label: statusLabel,
                  color: const Color(0xFFE1FAF2),
                  textColor: const Color(0xFF007A58),
                  dotColor: const Color(0xFF12B981),
                ),
                const Spacer(),
                IconButton(
                  key: const ValueKey('share-user-profile'),
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile sharing is unavailable.'),
                    ),
                  ),
                  icon: const Icon(Icons.share_outlined),
                  style: IconButton.styleFrom(backgroundColor: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
              decoration: _userCardDecoration(),
              child: Column(
                children: [
                  Stack(
                    children: [
                      _UserAvatar(user: _user, radius: 46),
                      if (!_user.isBlocked)
                        const Positioned(
                          right: 0,
                          bottom: 0,
                          child: CircleAvatar(
                            radius: 11,
                            backgroundColor: Color(0xFF13B981),
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _user.name,
                    style: const TextStyle(
                      color: _headingColor,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${_user.email} · ${_user.phone}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: _mutedColor, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    children: [
                      _UserMetaChip(
                        label: _user.isBlocked ? 'Blocked' : 'Active',
                        color: _user.isBlocked
                            ? const Color(0xFFFFE6E4)
                            : const Color(0xFFE1FAF2),
                        textColor: _user.isBlocked
                            ? const Color(0xFFC83C39)
                            : const Color(0xFF007A58),
                      ),
                      if (_user.isProMember)
                        const _UserMetaChip(
                          label: 'Pro Member',
                          color: Color(0xFFE9E2FF),
                          textColor: _purple,
                          icon: Icons.school_outlined,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Learner Analytics',
                    style: TextStyle(
                      color: _headingColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'All-time',
                    style: TextStyle(color: _purple, fontSize: 12),
                  ),
                ),
              ],
            ),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              childAspectRatio: 1.55,
              children: [
                _AnalyticsCard(
                  icon: Icons.menu_book_outlined,
                  value: '${_user.courseCount}',
                  label: 'Enrolled Courses',
                  iconColor: _purple,
                  iconBackground: const Color(0xFFE6E2FF),
                ),
                _AnalyticsCard(
                  icon: Icons.trending_up_rounded,
                  value: '${_user.assessment}%',
                  label: 'Avg Assessment',
                  iconColor: const Color(0xFF14A874),
                  iconBackground: const Color(0xFFE1FAF2),
                ),
                _AnalyticsCard(
                  icon: Icons.workspace_premium_outlined,
                  value: '${_user.certificates}',
                  label: 'Certificates Earned',
                  iconColor: _purple,
                  iconBackground: const Color(0xFFE6E2FF),
                ),
                _AnalyticsCard(
                  icon: Icons.payments_outlined,
                  value: _formatRupees(_user.totalSpend),
                  label: 'Total Spend (INR)',
                  iconColor: _purple,
                  iconBackground: const Color(0xFFE6E2FF),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _UserMetaChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final Color? dotColor;
  final IconData? icon;

  const _UserMetaChip({
    required this.label,
    this.color = const Color(0xFFE7E2FF),
    this.textColor = _headingColor,
    this.dotColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dotColor != null) ...[
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
          ],
          if (icon != null) ...[
            Icon(icon, size: 13, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;
  final Color iconBackground;

  const _AnalyticsCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
    required this.iconBackground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 19),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: _headingColor,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: _mutedColor, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _UserSectionTitle extends StatelessWidget {
  final String title;

  const _UserSectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: _purple,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: _headingColor,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _EditUserField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  const _EditUserField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF4D4B5F), fontSize: 12),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: _userFieldDecoration(
            prefixIcon: Icon(icon, color: _mutedColor, size: 19),
          ),
        ),
      ],
    );
  }
}

InputDecoration _userFieldDecoration({required Widget prefixIcon}) {
  return InputDecoration(
    prefixIcon: prefixIcon,
    filled: true,
    fillColor: const Color(0xFFF2F1F8),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
  );
}

String _formatRupees(int amount) {
  final digits = amount.abs().toString();
  if (digits.length <= 3) return '₹$digits';

  var leading = digits.substring(0, digits.length - 3);
  final groups = <String>[];
  while (leading.length > 2) {
    groups.insert(0, leading.substring(leading.length - 2));
    leading = leading.substring(0, leading.length - 2);
  }
  groups.insert(0, leading);
  groups.add(digits.substring(digits.length - 3));
  return '₹${groups.join(',')}';
}

BoxDecoration _userCardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF42339D).withValues(alpha: 0.06),
        blurRadius: 16,
        offset: const Offset(0, 7),
      ),
    ],
  );
}
