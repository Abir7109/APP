import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'app_card.dart';
import 'app_illustration.dart';
import 'press_scale.dart';

/// A soft feature tile: spot art, label, and one short caption.
class FeatureTile extends StatelessWidget {
  const FeatureTile({
    super.key,
    required this.art,
    required this.label,
    required this.caption,
    this.onTap,
    this.artSize = 54,
    this.tint,
  });

  final AppArt art;
  final String label;
  final String caption;
  final VoidCallback? onTap;
  final double artSize;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final resolvedTint = tint == null
        ? null
        : dark
            ? Color.alphaBlend(tint!.withValues(alpha: 0.16), colors.card)
            : tint;
    final tile = SectionCard(
      color: resolvedTint,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IllustrationTile(art, size: artSize),
              const Spacer(),
              if (onTap != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.north_east_rounded,
                    size: 16,
                    color: colors.muted.withValues(alpha: 0.6),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.texts.titleSmall,
          ),
          const SizedBox(height: 2),
          Text(
            caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.texts.bodySmall?.copyWith(color: colors.muted),
          ),
        ],
      ),
    );
    if (onTap == null) return tile;
    return PressScale(onTap: onTap, child: tile);
  }
}
