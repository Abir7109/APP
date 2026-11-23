import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'press_scale.dart';

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
    this.shadow = false,
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
    final showShadow =
        shadow && Theme.of(context).brightness == Brightness.light;
    return PressScale(
      enabled: onTap != null,
      child: Container(
        decoration: BoxDecoration(
          color: gradient == null ? (color ?? colors.card) : null,
          gradient: gradient,
          borderRadius: shape,
          border: Border.all(color: borderColor ?? colors.border),
          boxShadow: showShadow ? AppShadows.soft(colors.shadow) : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: shape,
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}

/// Flat, border-only card. The default container for grouped content.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.color,
    this.borderColor,
    this.radius = AppRadii.lg,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? borderColor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final shape = BorderRadius.circular(radius);
    return PressScale(
      enabled: onTap != null,
      child: Container(
        decoration: BoxDecoration(
          color: color ?? (dark ? colors.cardAlt : colors.card),
          borderRadius: shape,
          border: Border.all(color: borderColor ?? colors.border),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: shape,
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}
