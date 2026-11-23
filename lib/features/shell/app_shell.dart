import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/press_scale.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: _CapsuleNavBar(
        currentIndex: navigationShell.currentIndex,
        onSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}

class _CapsuleNavBar extends StatelessWidget {
  const _CapsuleNavBar({
    required this.currentIndex,
    required this.onSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onSelected;

  static const _items = [
    _NavItem(
      label: 'Home',
      icon: Icons.favorite_border_rounded,
      selectedIcon: Icons.favorite_rounded,
    ),
    _NavItem(
      label: 'Connect',
      icon: Icons.forum_outlined,
      selectedIcon: Icons.forum_rounded,
    ),
    _NavItem(
      label: 'More',
      icon: Icons.grid_view_outlined,
      selectedIcon: Icons.grid_view_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.2,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          0,
          AppSpacing.xl,
          AppSpacing.sm,
        ),
        child: Container(
          height: 66,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: dark
                  ? [colors.card, colors.card]
                  : [colors.card, colors.softPink],
            ),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: colors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: dark ? 0.4 : 0.14),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Row(
              children: [
                for (var index = 0; index < _items.length; index++)
                  Expanded(
                    child: _NavButton(
                      item: _items[index],
                      selected: index == currentIndex,
                      onTap: () => onSelected(index),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final duration = reduceMotion ? Duration.zero : AppDurations.normal;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: PressScale(
        scale: 0.94,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: Center(
            child: AnimatedContainer(
              duration: duration,
              curve: Curves.easeOutCubic,
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: selected ? colors.softPink : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: reduceMotion
                        ? Duration.zero
                        : const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    child: Icon(
                      selected ? item.selectedIcon : item.icon,
                      key: ValueKey(selected),
                      size: 20,
                      color: selected ? colors.primary : colors.muted,
                    ),
                  ),
                  const SizedBox(height: 1),
                  AnimatedDefaultTextStyle(
                    duration: duration,
                    curve: Curves.easeOutCubic,
                    style: context.texts.labelSmall?.copyWith(
                          color: selected ? colors.primary : colors.muted,
                          fontWeight:
                              selected ? FontWeight.w800 : FontWeight.w500,
                          height: 1.1,
                        ) ??
                        const TextStyle(),
                    child: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
