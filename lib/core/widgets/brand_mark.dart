import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({
    super.key,
    this.size = 52,
    this.wordmark = false,
    this.onDark = false,
  });

  final double size;
  final bool wordmark;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final mark = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.24),
            blurRadius: size * 0.4,
            offset: Offset(0, size * 0.14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.28),
        child: Image.asset(
          'assets/brand/heart_icon.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          errorBuilder: (context, error, stackTrace) => Container(
            decoration: const BoxDecoration(gradient: AppGradients.brand),
            child: Icon(
              Icons.favorite_rounded,
              color: Colors.white,
              size: size * 0.5,
            ),
          ),
        ),
      ),
    );

    if (!wordmark) return mark;

    final textColor = onDark ? Colors.white : colors.text;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        SizedBox(width: size * 0.28),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'YOU', style: TextStyle(color: textColor)),
              const TextSpan(
                text: '&',
                style: TextStyle(color: Color(0xFFFF4576)),
              ),
              TextSpan(text: 'ME', style: TextStyle(color: textColor)),
            ],
          ),
          style: TextStyle(
            fontSize: size * 0.42,
            fontWeight: FontWeight.w900,
            letterSpacing: size * 0.015,
          ),
        ),
      ],
    );
  }
}
