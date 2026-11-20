import 'package:flutter/material.dart';

import 'course.dart';

const _pageBackground = Color(0xFFF7F5FF);
const _headingColor = Color(0xFF1B1838);
const _mutedColor = Color(0xFF817D98);
const _purple = Color(0xFF6B45F0);
const _deleteColor = Color(0xFFCF202F);

class AdminCategoryPage extends StatefulWidget {
  const AdminCategoryPage({super.key});

  @override
  State<AdminCategoryPage> createState() => _AdminCategoryPageState();
}

class _AdminCategory {
  final String id;
  String name;
  String description;
  IconData icon;
  Color iconBackground;
  Color iconColor;
  bool isActive;
  bool isPublic;
  List<String> tags;

  _AdminCategory({
    required this.id,
    required this.name,
    this.description = '',
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    this.isActive = true,
    this.isPublic = true,
    List<String>? tags,
  }) : tags = tags ?? [];
}

class _AdminCategoryPageState extends State<AdminCategoryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  final List<_AdminCategory> _categories = [
    _AdminCategory(
      id: 'CAT-0192',
      name: 'Development',
      description:
          'Software engineering, web development, cloud computing, and programming languages.',
      icon: Icons.terminal_rounded,
      iconBackground: const Color(0xFFE6E2FF),
      iconColor: const Color(0xFF5144D8),
      tags: ['Python', 'TypeScript', 'Rust'],
    ),
    _AdminCategory(
      id: 'CAT-0193',
      name: 'Design',
      description: 'Design fundamentals, user experience, and creative tools.',
      icon: Icons.palette_outlined,
      iconBackground: const Color(0xFFEEDFFF),
      iconColor: const Color(0xFF7B20E8),
    ),
    _AdminCategory(
      id: 'CAT-0194',
      name: 'Marketing',
      description: 'Digital strategy, content, and audience growth.',
      icon: Icons.campaign_outlined,
      iconBackground: const Color(0xFFFFDEDA),
      iconColor: const Color(0xFFD21B1B),
    ),
    _AdminCategory(
      id: 'CAT-0195',
      name: 'Business',
      description: 'Business operations, leadership, and entrepreneurship.',
      icon: Icons.trending_up_rounded,
      iconBackground: const Color(0xFFB7F0FF),
      iconColor: const Color(0xFF006B82),
    ),
    _AdminCategory(
      id: 'CAT-0196',
      name: 'IT & Software',
      description: 'Information technology tools and software systems.',
      icon: Icons.dns_outlined,
      iconBackground: const Color(0xFFDCE2FF),
      iconColor: const Color(0xFF4020CF),
    ),
    _AdminCategory(
      id: 'CAT-0197',
      name: 'Personal Development',
      description: 'Skills and habits for personal and professional growth.',
      icon: Icons.lightbulb_outline_rounded,
      iconBackground: const Color(0xFFDCC3FF),
      iconColor: const Color(0xFF4A168B),
    ),
  ];

  List<_AdminCategory> get _filteredCategories {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _categories;
    return _categories
        .where((category) => category.name.toLowerCase().contains(query))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addCategory() async {
    final category = await Navigator.push<_AdminCategory>(
      context,
      MaterialPageRoute(builder: (_) => const _AdminCategoryFormPage()),
    );
    if (!mounted || category == null) return;
    if (_hasCategoryName(category.name)) {
      _showMessage('A category with this name already exists.');
      return;
    }
    setState(() => _categories.add(category));
  }

  Future<void> _editCategory(_AdminCategory category) async {
    final updatedCategory = await Navigator.push<_AdminCategory>(
      context,
      MaterialPageRoute(
        builder: (_) => _AdminCategoryFormPage(category: category),
      ),
    );
    if (!mounted || updatedCategory == null) return;
    if (_hasCategoryName(updatedCategory.name, except: category)) {
      _showMessage('A category with this name already exists.');
      return;
    }
    setState(() {
      final index = _categories.indexOf(category);
      if (index != -1) _categories[index] = updatedCategory;
    });
  }

  bool _hasCategoryName(String name, {_AdminCategory? except}) {
    return _categories.any(
      (item) =>
          !identical(item, except) &&
          item.name.toLowerCase() == name.trim().toLowerCase(),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _deleteCategory(_AdminCategory category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete category?'),
        content: Text('Delete "${category.name}" from the category list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: _deleteColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    setState(() => _categories.remove(category));
  }

  @override
  Widget build(BuildContext context) {
    final categories = _filteredCategories;

    return Scaffold(
      key: const ValueKey('admin-category-page'),
      backgroundColor: _pageBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    key: const ValueKey('admin-category-back-button'),
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _headingColor,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Categories',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _headingColor,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  FilledButton.icon(
                    key: const ValueKey('admin-category-add-button'),
                    onPressed: _addCategory,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add'),
                    style: FilledButton.styleFrom(
                      backgroundColor: _purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'MANAGE CATALOG',
                    style: TextStyle(
                      color: _mutedColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7E9FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_categories.length} Active Categories',
                      style: const TextStyle(
                        color: _headingColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                key: const ValueKey('admin-category-search'),
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: 'Search categories...',
                  prefixIcon: const Icon(Icons.search, color: _mutedColor),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: categories.isEmpty
                    ? const Center(
                        child: Text(
                          'No categories found.',
                          style: TextStyle(color: _mutedColor),
                        ),
                      )
                    : ListView.separated(
                        itemCount: categories.length,
                        padding: const EdgeInsets.only(bottom: 8),
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return _CategoryCard(
                            category: category,
                            countLabel: courseCountLabel(category.name),
                            onEdit: () => _editCategory(category),
                            onDelete: () => _deleteCategory(category),
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

class _AdminCategoryFormPage extends StatefulWidget {
  final _AdminCategory? category;

  const _AdminCategoryFormPage({this.category});

  @override
  State<_AdminCategoryFormPage> createState() => _AdminCategoryFormPageState();
}

class _AdminCategoryFormPageState extends State<_AdminCategoryFormPage> {
  static const _icons = [
    Icons.terminal_rounded,
    Icons.palette_outlined,
    Icons.campaign_outlined,
    Icons.auto_awesome_outlined,
    Icons.storage_outlined,
    Icons.lightbulb_outline_rounded,
    Icons.camera_alt_outlined,
    Icons.menu_book_outlined,
    Icons.biotech_outlined,
    Icons.psychology_outlined,
  ];

  static const _glyphPresets = [
    Icons.terminal_rounded,
    Icons.data_object_rounded,
    Icons.code_rounded,
    Icons.integration_instructions_outlined,
    Icons.schema_outlined,
  ];

  static const _tintBackgrounds = [
    Color(0xFFE6E2FF),
    Color(0xFFEEDFFF),
    Color(0xFFB7F0FF),
    Color(0xFFDCE2FF),
    Color(0xFFFFDEDA),
  ];

  static const _tintColors = [
    Color(0xFF5144D8),
    Color(0xFF7B20E8),
    Color(0xFF006B82),
    Color(0xFF4020CF),
    Color(0xFFD21B1B),
  ];

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final ScrollController _scrollController;
  late IconData _selectedIcon;
  late Color _selectedBackground;
  late Color _selectedColor;
  late bool _isActive;
  late bool _isPublic;
  late List<String> _tags;

  bool get _isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    final category = widget.category;
    _nameController = TextEditingController(text: category?.name ?? '');
    _descriptionController = TextEditingController(
      text: category?.description ?? '',
    );
    _scrollController = ScrollController();
    _selectedIcon = category?.icon ?? _icons.first;
    _selectedBackground = category?.iconBackground ?? _tintBackgrounds.first;
    _selectedColor = category?.iconColor ?? _tintColors.first;
    _isActive = category?.isActive ?? true;
    _isPublic = category?.isPublic ?? true;
    _tags = List.of(category?.tags ?? const []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _saveCategory() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a category name to continue.')),
      );
      return;
    }

    final category = widget.category;
    Navigator.pop(
      context,
      _AdminCategory(
        id:
            category?.id ??
            'CAT-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
        name: name,
        description: _descriptionController.text.trim(),
        icon: _selectedIcon,
        iconBackground: _selectedBackground,
        iconColor: _selectedColor,
        isActive: _isActive,
        isPublic: _isPublic,
        tags: _tags,
      ),
    );
  }

  Future<void> _addTag() async {
    var value = '';
    final tag = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add subtopic'),
        content: TextField(
          autofocus: true,
          onChanged: (text) => value = text,
          decoration: const InputDecoration(
            hintText: 'Subtopic name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, value.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (!mounted || tag == null || tag.isEmpty) return;
    if (_tags.any((item) => item.toLowerCase() == tag.toLowerCase())) return;
    setState(() => _tags.add(tag));
  }

  @override
  Widget build(BuildContext context) {
    final category = widget.category;

    return Scaffold(
      backgroundColor: _pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 20, 8),
              child: Row(
                children: [
                  IconButton(
                    key: const ValueKey('category-form-back'),
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _headingColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isEditing ? 'Edit Category' : 'Add Category',
                    style: const TextStyle(
                      color: _headingColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            if (_isEditing) _buildEditMetadata(category!),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildAppearanceCard(category),
                    const SizedBox(height: 20),
                    _buildDetailsCard(category),
                    const SizedBox(height: 24),
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6900D8), Color(0xFF743DEB)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: _purple.withValues(alpha: 0.22),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: TextButton.icon(
                        key: ValueKey(
                          _isEditing
                              ? 'save-category-changes'
                              : 'create-category-button',
                        ),
                        onPressed: _saveCategory,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        icon: Icon(
                          _isEditing
                              ? Icons.done_all_rounded
                              : Icons.check_circle_outline_rounded,
                          size: 19,
                        ),
                        label: Text(
                          _isEditing ? 'Save Changes' : 'Create Category',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 48,
                      child: TextButton(
                        key: const ValueKey('cancel-category-form'),
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF4F4A5E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditMetadata(_AdminCategory category) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
      child: Row(
        children: [
          _statusChip(
            _isActive ? 'Active Status' : 'Inactive',
            _isActive,
            onTap: () => setState(() => _isActive = !_isActive),
          ),
          const SizedBox(width: 6),
          _statusChip(
            _isPublic ? 'Publicly Visible' : 'Private',
            _isPublic,
            onTap: () => setState(() => _isPublic = !_isPublic),
          ),
          const Spacer(),
          Text(
            'ID: ${category.id}',
            style: const TextStyle(color: _mutedColor, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(
    String label,
    bool selected, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE6E6FF) : const Color(0xFFEDECF2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF5144D8) : _mutedColor,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildAppearanceCard(_AdminCategory? category) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF39268C).withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 56,
                decoration: BoxDecoration(
                  color: _selectedColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _selectedColor.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(_selectedIcon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isEditing ? 'Category Badge' : 'Category Preview',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _headingColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${category == null ? '0 Courses' : courseCountLabel(category.name)}'
                      ' • ${_isActive ? 'Active' : 'Inactive'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: _mutedColor, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (!_isEditing)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEADFFF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'Live',
                    style: TextStyle(
                      color: _purple,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              if (_isEditing)
                IconButton(
                  key: const ValueKey('edit-category-look'),
                  onPressed: () => _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                  ),
                  icon: const Icon(Icons.palette_outlined),
                  color: _purple,
                )
              else
                IconButton(
                  onPressed: () => setState(() => _isPublic = !_isPublic),
                  icon: Icon(
                    _isPublic
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 19,
                  ),
                  color: _mutedColor,
                ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            _isEditing ? 'BADGE TINT' : 'Select Icon',
            style: const TextStyle(
              color: _headingColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (_isEditing) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_tintBackgrounds.length, (index) {
                final selected = _selectedBackground == _tintBackgrounds[index];
                return InkWell(
                  key: ValueKey('category-tint-$index'),
                  onTap: () => setState(() {
                    _selectedBackground = _tintBackgrounds[index];
                    _selectedColor = _tintColors[index];
                  }),
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: _tintBackgrounds[index],
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(color: _tintColors[index], width: 2)
                          : null,
                    ),
                    child: selected
                        ? Icon(Icons.check, color: _tintColors[index], size: 17)
                        : null,
                  ),
                );
              }),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'GLYPH PRESET',
                  style: TextStyle(
                    color: _headingColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Selected: ${_selectedIcon == _icons.first ? 'Terminal' : 'Custom'}',
                  style: const TextStyle(color: _mutedColor, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_glyphPresets.length, (index) {
                final icon = _glyphPresets[index];
                final selected = _selectedIcon == icon;
                return _IconChoice(
                  key: ValueKey('category-glyph-$index'),
                  icon: icon,
                  selected: selected,
                  color: _selectedColor,
                  onTap: () => setState(() => _selectedIcon = icon),
                );
              }),
            ),
          ] else ...[
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _icons.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final icon = _icons[index];
                return _IconChoice(
                  key: ValueKey('category-icon-$index'),
                  icon: icon,
                  selected: _selectedIcon == icon,
                  color: _selectedColor,
                  onTap: () => setState(() => _selectedIcon = icon),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailsCard(_AdminCategory? category) {
    final maxDescriptionLength = _isEditing ? 240 : 180;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF39268C).withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _isEditing ? Icons.lock_outline : Icons.edit_note_rounded,
                color: _purple,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _isEditing ? 'General Details' : 'Category Details',
                  style: const TextStyle(
                    color: _headingColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (_isEditing)
                const Text(
                  'Editable',
                  style: TextStyle(
                    color: _purple,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            _isEditing ? 'Category Title' : 'Category Name *',
            style: const TextStyle(
              color: _headingColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            key: const ValueKey('category-name-input'),
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            maxLength: 48,
            decoration: InputDecoration(
              hintText: 'e.g., Artificial Intelligence',
              counterText: '',
              filled: true,
              fillColor: _isEditing ? Colors.white : const Color(0xFFF3F2FC),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              suffixIcon: _isEditing ? const Icon(Icons.edit_outlined) : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Description',
                style: TextStyle(
                  color: _headingColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _descriptionController,
                builder: (context, value, _) => Text(
                  '${value.text.length}/$maxDescriptionLength',
                  style: const TextStyle(
                    color: _mutedColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            key: const ValueKey('category-description-input'),
            controller: _descriptionController,
            maxLength: maxDescriptionLength,
            maxLines: _isEditing ? 3 : 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText:
                  'Brief overview of topics and learning paths included in this category...',
              counterText: '',
              filled: true,
              fillColor: _isEditing ? Colors.white : const Color(0xFFF3F2FC),
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          if (_isEditing) ...[
            const SizedBox(height: 14),
            const Text(
              'INDEXED SUBTOPICS',
              style: TextStyle(
                color: _mutedColor,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                for (final tag in _tags)
                  InputChip(
                    key: ValueKey('category-tag-$tag'),
                    label: Text(tag),
                    onDeleted: () => setState(() => _tags.remove(tag)),
                    backgroundColor: const Color(0xFFE7E9FF),
                    deleteIconColor: _mutedColor,
                    labelStyle: const TextStyle(
                      color: _headingColor,
                      fontSize: 11,
                    ),
                  ),
                ActionChip(
                  key: const ValueKey('add-category-tag'),
                  avatar: const Icon(Icons.add, size: 15, color: _purple),
                  label: const Text('Tag'),
                  onPressed: _addTag,
                  backgroundColor: const Color(0xFFEDE1FF),
                  labelStyle: const TextStyle(
                    color: _purple,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _IconChoice extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _IconChoice({
    super.key,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        decoration: BoxDecoration(
          color: selected ? color : const Color(0xFFF1F2FF),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: selected ? Colors.white : _headingColor,
          size: 20,
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final _AdminCategory category;
  final String countLabel;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryCard({
    required this.category,
    required this.countLabel,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: category.iconBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(category.icon, color: category.iconColor, size: 23),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _headingColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  countLabel,
                  style: TextStyle(
                    color: category.iconColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            key: ValueKey('edit-category-${category.name}'),
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 19),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFF1F1FF),
              foregroundColor: const Color(0xFF55516B),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            key: ValueKey('delete-category-${category.name}'),
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, size: 19),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFFFE9E7),
              foregroundColor: _deleteColor,
            ),
          ),
        ],
      ),
    );
  }
}
