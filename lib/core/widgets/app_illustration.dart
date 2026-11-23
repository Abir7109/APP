import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Every illustration in the brand set, in one place.
///
/// Screens should never hardcode an asset string. Add new art here, then use
/// `AppIllustration` or `IllustrationTile` so sizing and semantics stay
/// consistent across the app.
enum AppArt {
  /// The mascot pair: a pink heart and a lilac bun holding hands.
  mascots('assets/illustrations/mascots.png'),

  /// The pair sitting on a cloud. Tall art, made for splash / onboarding.
  splash('assets/illustrations/splash_art.png'),

  /// Two characters peeking into an empty box. Reusable empty state.
  empty('assets/illustrations/empty_state.png'),

  bucket('assets/illustrations/spot_bucket.png'),
  checkIn('assets/illustrations/spot_checkin.png'),
  capsules('assets/illustrations/spot_capsule.png'),
  coupons('assets/illustrations/spot_coupons.png'),
  goals('assets/illustrations/spot_goals.png'),
  photos('assets/illustrations/spot_photo.png'),
  deepTalk('assets/illustrations/spot_deeptalk.png'),
  chores('assets/illustrations/spot_chores.png'),

  /// Seamless scatter tile. Use with `ImageRepeat.repeat` at low opacity as a
  /// backdrop, never as a foreground illustration.
  pattern('assets/illustrations/pattern_hearts.png');

  const AppArt(this.asset);

  final String asset;

  /// Art that shows up on the first two screens, precached at startup so the
  /// first frame never pops in.
  static const List<AppArt> aboveTheFold = [splash, mascots, empty];
}

/// A transparent PNG from the cute set, sized by its longest edge.
class AppIllustration extends StatelessWidget {
  const AppIllustration(
    this.art, {
    super.key,
    this.size = 96,
    this.opacity,
    this.semanticLabel,
  });

  final AppArt art;
  final double size;

  /// Leave null to use full opacity in light mode and 0.92 in dark mode.
  final double? opacity;

  /// Leave null for decorative art. Set a short label when the picture is the
  /// only carrier of meaning (for example, a mascot reacting to a saved mood).
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final dpr = MediaQuery.maybeOf(context)?.devicePixelRatio ?? 1;
    return Opacity(
      opacity: opacity ?? (dark ? 0.92 : 1),
      child: Image.asset(
        art.asset,
        height: size,
        cacheWidth: (size * dpr).round(),
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        semanticLabel: semanticLabel,
        excludeFromSemantics: semanticLabel == null,
        errorBuilder: (context, error, stackTrace) => SizedBox(
          width: size,
          height: size,
          child: Icon(
            Icons.favorite_rounded,
            size: size * 0.5,
            color: context.colors.primary,
          ),
        ),
      ),
    );
  }
}

/// The standard way to show a spot illustration: a soft tinted tile that keeps
/// the art grounded instead of floating in white space.
///
/// The tile is slightly larger than the art, so every icon in a list lines up.
class IllustrationTile extends StatelessWidget {
  const IllustrationTile(
    this.art, {
    super.key,
    this.size = 56,
    this.padding = 10,
    this.background,
    this.radius,
    this.onTap,
  });

  final AppArt art;

  /// Outer square size of the tile.
  final double size;
  final double padding;
  final Color? background;
  final double? radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final outerRadius = radius ?? size * 0.34;
    final tile = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background ?? colors.softPink,
        borderRadius: BorderRadius.circular(outerRadius),
      ),
      child: SizedBox(
        width: size - padding * 2,
        height: size - padding * 2,
        // FittedBox keeps wide art (the mascot pair) from overflowing a square
        // tile while still honouring the requested art size.
        child: FittedBox(
          fit: BoxFit.contain,
          child: AppIllustration(art, size: size - padding * 2),
        ),
      ),
    );
    if (onTap == null) return tile;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(outerRadius),
        child: tile,
      ),
    );
  }
}

/// Preloads art so the first frame of a screen never flashes.
Future<void> precacheAppArt(
  BuildContext context, {
  List<AppArt> art = AppArt.aboveTheFold,
}) async {
  for (final item in art) {
    try {
      await precacheImage(AssetImage(item.asset), context);
    } catch (_) {
      // Art is decoration; a missing asset must never break startup.
    }
  }
}

/// Small floating heart used as a decorative accent around the mascots.
///
/// Purely decorative: keep it out of the semantics tree and keep it subtle.
class FloatingHeart extends StatelessWidget {
  const FloatingHeart({
    super.key,
    this.size = 14,
    this.color,
    this.rotation = 0,
  });

  final double size;
  final Color? color;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Icon(
        Icons.favorite_rounded,
        size: size,
        color: (color ?? context.colors.primary).withValues(alpha: 0.55),
      ),
    );
  }
}

/// A quiet, consistent heading used above illustration-led sections.
class ArtSectionLabel extends StatelessWidget {
  const ArtSectionLabel(this.label, {super.key, this.trailing});

  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: context.texts.labelSmall?.copyWith(
              color: colors.muted,
              letterSpacing: AppSpacing.xs / 8,
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}
