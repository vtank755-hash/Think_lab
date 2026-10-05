import 'package:flutter/material.dart';

import 'category_courses.dart';
import 'course.dart';
import 'widgets/nav_bar.dart';

class categories extends StatefulWidget {
  const categories({super.key});

  @override
  State<categories> createState() => _categoriesState();
}

/// One entry of the Categories grid: how it looks and which course list it
/// opens. The course count is always calculated from the shared data.
class _CategoryInfo {
  final String name;
  final IconData icon;
  final Color bg;
  final Color fg;

  const _CategoryInfo(this.name, this.icon, this.bg, this.fg);
}

const List<_CategoryInfo> _categoryInfos = [
  _CategoryInfo(
    'Development',
    Icons.laptop_mac,
    Color(0xFFE7F0FF),
    Color(0xFF5B8DEF),
  ),
  _CategoryInfo(
    'Design',
    Icons.palette_outlined,
    Color(0xFFEEE8FF),
    Color(0xFF7B5CFF),
  ),
  _CategoryInfo(
    'Marketing',
    Icons.campaign_outlined,
    Color(0xFFFDE8EE),
    Color(0xFFE86B8A),
  ),
  _CategoryInfo(
    'Business',
    Icons.work_outline,
    Color(0xFFDFF6F6),
    Color(0xFF4DB8C4),
  ),
  _CategoryInfo(
    'IT & Software',
    Icons.layers_outlined,
    Color(0xFFE2F6EC),
    Color(0xFF5BC49A),
  ),
  _CategoryInfo(
    'Personal Development',
    Icons.hub_outlined,
    Color(0xFFFFF3D4),
    Color(0xFFE8C44A),
  ),
];

class _categoriesState extends State<categories> {
  void _openCategory(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryCoursesPage(category: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F1FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // top bar
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.swap_horiz,
                        color: Color(0xFF2B2356),
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Categories',
                    style: TextStyle(
                      color: Color(0xFF2B2356),
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // category cards — same style, real course counts, all clickable
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.only(bottom: 18),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.07,
                  ),
                  itemCount: _categoryInfos.length,
                  itemBuilder: (context, index) {
                    final info = _categoryInfos[index];
                    return _CategoryCard(
                      info: info,
                      countLabel: courseCountLabel(info.name),
                      onTap: () => _openCategory(info.name),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) Navigator.pop(context);
        },
      ),
    );
  }
}

/// Reusable category card (identical layout for every category).
class _CategoryCard extends StatelessWidget {
  final _CategoryInfo info;
  final String countLabel;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.info,
    required this.countLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: info.bg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(info.icon, color: info.fg, size: 24),
            ),
            const Spacer(),
            Text(
              info.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF2B2356),
                fontSize: 16,
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 4),
            // Real number of courses in this category — never a fake figure.
            Text(
              countLabel,
              style: const TextStyle(color: Color(0xFF9A96B8), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
