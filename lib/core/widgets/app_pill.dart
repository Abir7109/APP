import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';

class AppPill extends StatelessWidget {
  const AppPill({
    super.key,
    required this.label,
    this.color,
    this.icon,
    this.filled = false,
    this.onTap,
  });

  final String label;
  final Color? color;
  final IconData? icon;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = color ?? colors.primary;
    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: filled ? accent : accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: filled ? Colors.white : accent),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: context.texts.labelSmall?.copyWith(
              color: filled ? Colors.white : accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: content,
    );
  }
}
