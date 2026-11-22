import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    super.key,
    required this.name,
    this.size = 44,
    this.ring = false,
    this.paletteIndex,
  });

  final String name;
  final double size;
  final bool ring;
  final int? paletteIndex;

  String get _initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return parts.take(2).map((part) => part.characters.first).join().toUpperCase();
  }

  int get _index {
    if (paletteIndex != null) {
      return paletteIndex! % AppGradients.avatarPalettes.length;
    }
    final sum = name.codeUnits.fold<int>(0, (total, unit) => total + unit);
    return sum % AppGradients.avatarPalettes.length;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final palette = AppGradients.avatarPalettes[_index];
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: palette,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: ring
            ? Border.all(color: colors.background, width: size * 0.055)
            : null,
      ),
      child: Text(
        _initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.36,
          height: 1,
        ),
      ),
    );
  }
}

class AvatarPair extends StatelessWidget {
  const AvatarPair({
    super.key,
    required this.me,
    required this.partner,
    this.size = 48,
    this.showHeart = true,
  });

  final String me;
  final String partner;
  final double size;
  final bool showHeart;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      width: size * 1.68,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: InitialsAvatar(name: me, size: size, ring: true),
          ),
          Positioned(
            left: size * 0.68,
            top: 0,
            child: InitialsAvatar(name: partner, size: size, ring: true),
          ),
          if (showHeart)
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                width: size * 0.4,
                height: size * 0.4,
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.background, width: 2),
                ),
                child: Icon(
                  Icons.favorite_rounded,
                  color: Colors.white,
                  size: size * 0.2,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
