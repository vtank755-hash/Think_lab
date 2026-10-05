import 'package:flutter/material.dart';

const _purple = Color(0xFF6B45F0);
const _grey = Color(0xFF8E8EA9);

/// Definition of one tab in the bottom navigation bar.
class NavItem {
  final String label;
  final IconData activeIcon;
  final IconData icon;

  const NavItem(this.label, this.activeIcon, this.icon);
}

/// The tabs shared by every screen that shows a bottom navigation bar.
const navItems = <NavItem>[
  NavItem('Home', Icons.home_rounded, Icons.home_outlined),
  NavItem('Learning', Icons.menu_book_rounded, Icons.menu_book_outlined),
  NavItem('Wishlist', Icons.favorite_rounded, Icons.favorite_border),
  NavItem('Profile', Icons.person_rounded, Icons.person_outline),
];

/// Reusable bottom navigation bar.
///
/// Every page links to this widget instead of declaring its own bar, so the
/// look and the tabs stay identical across the app:
///
/// ```dart
/// bottomNavigationBar: NavBar(
///   currentIndex: _tab,
///   onTap: (i) => setState(() => _tab = i),
/// ),
/// ```
class NavBar extends StatelessWidget {
  /// Index of the selected tab.
  final int currentIndex;

  /// Called with the index of the tapped tab.
  final ValueChanged<int> onTap;

  const NavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
          for (var i = 0; i < navItems.length; i++)
            _tab(context, i, navItems[i]),
        ],
      ),
    );
  }

  Widget _tab(BuildContext context, int index, NavItem item) {
    final selected = index == currentIndex;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? item.activeIcon : item.icon,
              color: selected ? _purple : _grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? _purple : _grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
