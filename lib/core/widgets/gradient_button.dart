import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/app_spacing.dart';

class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.loading = false,
    this.gradient,
    this.height = 54,
    this.expand = true,
    this.foregroundColor = Colors.white,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final Gradient? gradient;
  final double height;
  final bool expand;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Container(
        width: expand ? double.infinity : null,
        height: height,
        decoration: BoxDecoration(
          gradient: gradient ?? AppGradients.brand,
          borderRadius: BorderRadius.circular(height / 2),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF4576).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled
                ? () {
                    HapticFeedback.lightImpact();
                    onPressed!();
                  }
                : null,
            borderRadius: BorderRadius.circular(height / 2),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  if (loading)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: foregroundColor,
                      ),
                    )
                  else ...[
                    if (icon != null) ...[
                      Icon(icon, size: 20, color: foregroundColor),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: foregroundColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 15.5,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
