import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'app_illustration.dart';
import 'press_scale.dart';

/// The one hero at the top of a screen.
///
/// Uses the brand gradient by default; pass [backgroundColor] for a soft, flat
/// hero. The illustration is allowed to spill past the bottom-right corner by
/// [artOffset] so the card feels composed rather than boxed.
class HeroCard extends StatelessWidget {
  const HeroCard({
    super.key,
    this.art,
    this.eyebrow,
    required this.title,
    this.subtitle,
    this.trailing,
    this.footer,
    this.onTap,
    this.gradient,
    this.backgroundColor,
    this.artSize = 132,
    this.artOffset = 10,
    this.artAspectRatio = 1,
  });

  final AppArt? art;
  final String? eyebrow;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? footer;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final Color? backgroundColor;
  final double artSize;
  final double artOffset;

  /// Width divided by height for [art]. Used to keep the subtitle clear of
  /// wide art such as the mascot pair.
  final double artAspectRatio;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final soft = backgroundColor != null;
    final foreground = soft ? colors.text : Colors.white;
    final secondary =
        soft ? colors.muted : Colors.white.withValues(alpha: 0.82);
    final shape = BorderRadius.circular(AppRadii.xl);

    return LayoutBuilder(
      builder: (context, constraints) {
        final ratio = artAspectRatio <= 0 ? 1.0 : artAspectRatio;
        final maxArtWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth * 0.62
            : artSize * ratio;
        final effectiveArtHeight = math.min(artSize, maxArtWidth / ratio);
        final artWidth = effectiveArtHeight * ratio;
        final subtitleMaxWidth = art == null
            ? null
            : math.max(
                0.0,
                constraints.maxWidth -
                    artWidth +
                    artOffset -
                    AppSpacing.xl -
                    AppSpacing.md,
              );

        return ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 180),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              PressScale(
                enabled: onTap != null,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: soft ? null : (gradient ?? AppGradients.brand),
                    color: backgroundColor,
                    borderRadius: shape,
                    boxShadow: dark ? null : AppShadows.soft(colors.shadow),
                  ),
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      onTap: onTap,
                      borderRadius: shape,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.xl,
                          AppSpacing.xl,
                          art == null ? AppSpacing.xl : artSize * 0.6,
                          AppSpacing.xl,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (eyebrow != null || trailing != null) ...[
                              Row(
                                children: [
                                  if (eyebrow != null)
                                    Expanded(
                                      child: Text(
                                        eyebrow!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: context.texts.labelSmall
                                            ?.copyWith(color: secondary),
                                      ),
                                    )
                                  else
                                    const Spacer(),
                                  ?trailing,
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm),
                            ],
                            Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: context.texts.headlineMedium?.copyWith(
                                color: foreground,
                              ),
                            ),
                            if (subtitle != null) ...[
                              const SizedBox(height: AppSpacing.xs),
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      subtitleMaxWidth ?? double.infinity,
                                ),
                                child: Text(
                                  subtitle!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.texts.bodySmall?.copyWith(
                                    color: secondary,
                                  ),
                                ),
                              ),
                            ],
                            if (footer != null) ...[
                              const SizedBox(height: AppSpacing.lg),
                              footer!,
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (art != null)
                Positioned(
                  right: -artOffset,
                  bottom: -artOffset,
                  child: IgnorePointer(
                    child: AppIllustration(art!, size: effectiveArtHeight),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
