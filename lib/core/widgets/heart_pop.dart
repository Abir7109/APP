import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Drops a small heart that pops in the middle of the screen.
///
/// Used to celebrate a check-in save or a finished goal. The overlay removes
/// itself and is skipped entirely when the platform asks for reduced motion.
void showHeartPop(BuildContext context) {
  final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
  if (reduceMotion) return;
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (overlayContext) => Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: _HeartPop(
            onDone: () {
              entry.remove();
            },
          ),
        ),
      ),
    ),
  );
  overlay.insert(entry);
}

class _HeartPop extends StatefulWidget {
  const _HeartPop({required this.onDone});

  final VoidCallback onDone;

  @override
  State<_HeartPop> createState() => _HeartPopState();
}

class _HeartPopState extends State<_HeartPop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.pop,
  )..forward();
  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(begin: 0.6, end: 1.1).chain(
        CurveTween(curve: Curves.easeOutBack),
      ),
      weight: 70,
    ),
    TweenSequenceItem(
      tween: Tween(begin: 1.1, end: 1.0),
      weight: 30,
    ),
  ]).animate(_controller);
  late final Animation<double> _opacity = Tween<double>(begin: 1, end: 0)
      .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) widget.onDone();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.favorite_rounded,
            color: colors.primary,
            size: 52,
          ),
        ),
      ),
    );
  }
}
