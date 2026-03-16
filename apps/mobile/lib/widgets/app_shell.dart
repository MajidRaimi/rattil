import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/router/app_router.dart';
import '../core/theme/typography_ext.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/search')) return 1;
    if (location.startsWith('/bookmarks')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedIndex(context);
    final colors = context.colors;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 8),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(
            top: BorderSide(color: colors.divider, width: 0.5),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItem(
                icon: Icons.menu_book_outlined,
                selectedIcon: Icons.menu_book,
                isSelected: selected == 0,
                onTap: () => context.go(AppRouter.home),
              ),
              _NavItem(
                icon: Icons.search_outlined,
                selectedIcon: Icons.search,
                isSelected: selected == 1,
                onTap: () => context.go(AppRouter.search),
              ),
              _NavItem(
                icon: Icons.bookmark_border,
                selectedIcon: Icons.bookmark,
                isSelected: selected == 2,
                onTap: () => context.go(AppRouter.bookmarks),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final activeColor = colors.gold;
    final inactiveColor =
        Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF94A3B8) // slate-400
            : const Color(0xFF64748B); // slate-500

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.12)
              : inactiveColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? activeColor.withValues(alpha: 0.4)
                : inactiveColor.withValues(alpha: 0.7),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: isSelected ? activeColor : inactiveColor,
          size: 24,
        ),
      ),
    );
  }
}
