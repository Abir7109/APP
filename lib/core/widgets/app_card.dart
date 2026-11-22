import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.onTap,
    this.color,
    this.gradient,
    this.borderColor,
    this.radius = AppRadii.lg,
    this.shadow = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final Gradient? gradient;
  final Color? borderColor;
  final double radius;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final shape = BorderRadius.circular(radius);
    return Container(
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? colors.card) : null,
        gradient: gradient,
        borderRadius: shape,
        border: Border.all(color: borderColor ?? colors.border),
        boxShadow: shadow ? AppShadows.soft(colors.shadow) : null,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: shape,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
