import 'package:flutter/material.dart';
import 'categories.dart';
import 'Searches.dart';

const _purple = Color(0xFF6B45F0);
const _purpleDark = Color(0xFF5A36E0);
const _pageBg = Color(0xFFF7F6FC);
const _title = Color(0xFF1C1C28);
const _grey = Color(0xFF8E8EA9);
const _chipBg = Color(0xFFF1F0F8);
const _star = Color(0xFFF5A623);

class index extends StatefulWidget {
  const index({super.key});

  @override
  State<index> createState() => _indexState();
}

class _indexState extends State<index> {
  int _tab = 0;
  int _cat = 1;
  final Set<int> _liked = {0};

  final _cats = const [
    {'name': 'Dev', 'icon': Icons.code},
    {'name': 'Design', 'icon': Icons.layers_outlined},
    {'name': 'Marketing', 'icon': Icons.campaign_outlined},
    {'name': 'Business', 'icon': Icons.work_outline},
    {'name': 'AI & Tech', 'icon': Icons.memory_outlined},
  ];

  void _openSearches() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const Searches(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      body: SafeArea(
        child: _tab == 0 ? _home() : _otherTab(),
      ),
      bottomNavigationBar: _bottomBar(),
    );
  }

  Widget _home() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          const SizedBox(height: 18),
          _searchRow(),
          const SizedBox(height: 18),
          _offerBanner(),
          const SizedBox(height: 22),
          Row(
            children: [
              const Text(
                'Categories',
                style: TextStyle(
                  color: _title,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const categories(),
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Text(
                    'See all',
                    style: TextStyle(
                      color: _purple,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _categories(),
          const SizedBox(height: 22),
          _rowTitle('Popular Courses'),
          const SizedBox(height: 14),
          _popular(),
          const SizedBox(height: 22),
          _rowTitle('Continue Learning'),
          const SizedBox(height: 14),
          _continueCard(),
          const SizedBox(height: 22),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _openSearches,
            child: const Row(
              children: [
                Text(
                  'Recommended',
                  style: TextStyle(
                    color: _title,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Spacer(),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Text(
                    'See all',
                    style: TextStyle(
                      color: _purple,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _recoCard(
            0,
            'https://images.unsplash.com/photo-1552664730-d307ca884978?w=400',
            'Marketing',
            'Digital Marketing Complete Guide',
            'Priya Menon',
            '4.7',
            '₹999',
          ),
          const SizedBox(height: 12),
          _recoCard(
            1,
            'https://images.unsplash.com/photo-1556761175-5973dc0f32e7?w=400',
            'Management',
            'Modern Product Management 101',
            'Rohit Verma',
            '4.9',
            '₹1,199',
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Image.network(
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
            width: 48,
            height: 48,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 48,
              height: 48,
              color: _purple,
              child: const Icon(Icons.person, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good morning,',
                style: TextStyle(color: _grey, fontSize: 13),
              ),
              SizedBox(height: 2),
              Text(
                'Aarav Sharma',
                style: TextStyle(
                  color: _title,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Stack(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(Icons.notifications_none_rounded, color: _purple),
            ),
            Positioned(
              right: 11,
              top: 11,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF4D6D),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _searchRow() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _openSearches,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: _grey),
                  SizedBox(width: 8),
                  Text(
                    'Search courses, topics...',
                    style: TextStyle(color: _grey, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _purple,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.tune_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _offerBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_purple, _purpleDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -20,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -40,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'LIMITED OFFER',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Get 40% OFF on all\nDesign courses',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Explore Now  →',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _rowTitle(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _title,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        const Text(
          'See all',
          style: TextStyle(
            color: _purple,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _categories() {
    return SizedBox(
      height: 86,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _cats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, i) {
          final selected = i == _cat;
          return GestureDetector(
            onTap: () {
              setState(() {
                _cat = i;
              });
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const categories(),
                ),
              );
            },
            child: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: selected ? _purple : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: _purple.withValues(alpha: 0.28),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    _cats[i]['icon'] as IconData,
                    color: selected ? Colors.white : _purple,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _cats[i]['name'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? _title : _grey,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _popular() {
    return SizedBox(
      height: 230,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _popCard(
            'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=600',
            'Development',
            'Full-stack Web Dev Bootcamp',
            'Alex Chen',
            '4.8',
            '(2.4k)',
            '₹1,499',
          ),
          const SizedBox(width: 14),
          _popCard(
            'https://images.unsplash.com/photo-1581291518857-4d859fc9e0b5?w=600',
            'Design',
            'UI/UX Masterclass',
            'Sarah Jenkins',
            '4.9',
            '(1.8k)',
            '₹1,299',
          ),
        ],
      ),
    );
  }

  Widget _popCard(
    String img,
    String tag,
    String name,
    String teacher,
    String rating,
    String reviews,
    String price,
  ) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  img,
                  height: 112,
                  width: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 112,
                    color: const Color(0xFFE8E6F5),
                  ),
                ),
              ),
              Positioned(
                left: 10,
                top: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _title,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _title,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'By $teacher',
                  style: const TextStyle(fontSize: 11, color: _grey),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 16, color: _star),
                    const SizedBox(width: 3),
                    Text(
                      rating,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      reviews,
                      style: const TextStyle(fontSize: 11, color: _grey),
                    ),
                    const Spacer(),
                    Text(
                      price,
                      style: const TextStyle(
                        color: _purple,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _continueCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFEEE9FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.auto_awesome_mosaic_outlined, color: _purple),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Figma to Code Workflow',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: _title,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Lesson 14: Responsive Constraints',
                  style: TextStyle(fontSize: 11, color: _grey),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Course Progress',
                        style: TextStyle(fontSize: 10, color: _grey),
                      ),
                    ),
                    const Text(
                      '65%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _title,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: const LinearProgressIndicator(
                    value: 0.65,
                    minHeight: 6,
                    color: _purple,
                    backgroundColor: Color(0xFFEDEAF8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: _purple,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.play_arrow_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _recoCard(
    int id,
    String img,
    String tag,
    String name,
    String teacher,
    String rating,
    String price,
  ) {
    final liked = _liked.contains(id);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _openSearches,
      child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              img,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 72,
                height: 72,
                color: _chipBg,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEE9FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      color: _purple,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _title,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'By $teacher',
                  style: const TextStyle(fontSize: 11, color: _grey),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 14, color: _star),
                    const SizedBox(width: 2),
                    Text(
                      rating,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      price,
                      style: const TextStyle(
                        color: _purple,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                if (liked) {
                  _liked.remove(id);
                } else {
                  _liked.add(id);
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 6, bottom: 40),
              child: Icon(
                liked ? Icons.favorite : Icons.favorite_border,
                color: liked ? const Color(0xFFFF4D6D) : _grey,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _otherTab() {
    final labels = ['Home', 'Learning', 'Wishlist', 'Profile'];
    return Center(
      child: Text(
        labels[_tab],
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: _title,
        ),
      ),
    );
  }

  Widget _bottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 18),
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
          _navItem(0, Icons.home_rounded, Icons.home_outlined, 'Home'),
          _navItem(1, Icons.menu_book_rounded, Icons.menu_book_outlined, 'Learning'),
          _navItem(2, Icons.favorite_rounded, Icons.favorite_border, 'Wishlist'),
          _navItem(3, Icons.person_rounded, Icons.person_outline, 'Profile'),
        ],
      ),
    );
  }

  Widget _navItem(int i, IconData filled, IconData outline, String label) {
    final on = _tab == i;
    return GestureDetector(
      onTap: () {
        setState(() {
          _tab = i;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(on ? filled : outline, color: on ? _purple : _grey, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: on ? FontWeight.w700 : FontWeight.w500,
              color: on ? _purple : _grey,
            ),
          ),
        ],
      ),
    );
  }
}
