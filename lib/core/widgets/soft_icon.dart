import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';

class SoftIcon extends StatelessWidget {
  const SoftIcon({
    super.key,
    required this.icon,
    this.color,
    this.size = 44,
  });

  final IconData icon;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? context.colors.primary;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Icon(icon, color: accent, size: size * 0.46),
    );
  }
}
