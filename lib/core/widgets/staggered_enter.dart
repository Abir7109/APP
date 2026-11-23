import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../theme/app_spacing.dart';

/// Fades and lifts its child into place, with a 40ms stagger per [index].
///
/// Use it for the first five items of a list. It is a no-op when the platform
/// asks for reduced motion, so content still appears instantly.
class StaggeredEnter extends StatefulWidget {
  const StaggeredEnter({
    super.key,
    required this.index,
    required this.child,
    this.delay = const Duration(milliseconds: 40),
  });

  final int index;
  final Widget child;
  final Duration delay;

  @override
  State<StaggeredEnter> createState() => _StaggeredEnterState();
}

class _StaggeredEnterState extends State<StaggeredEnter> {
  bool _visible = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final reduceMotion =
        WidgetsBinding.instance.platformDispatcher.accessibilityFeatures
            .disableAnimations;
    if (reduceMotion || widget.index >= 5) {
      _visible = true;
      return;
    }
    _timer = Timer(widget.delay * widget.index, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) return widget.child;
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: AppDurations.enter,
      curve: Curves.easeOutCubic,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, 0.04),
        duration: AppDurations.enter,
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
