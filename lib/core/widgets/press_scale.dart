import 'package:material_ui/material_ui.dart';

import '../theme/app_spacing.dart';

/// Scales its child down slightly while pressed.
///
/// Use it around cards and large buttons. If [onTap] is provided the wrapper
/// owns the tap; otherwise it only provides visual feedback and lets the child
/// handle its own gestures.
class PressScale extends StatefulWidget {
  const PressScale({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.97,
    this.enabled = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final bool enabled;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!widget.enabled || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    Widget content = AnimatedScale(
      scale: _pressed && !reduceMotion ? widget.scale : 1,
      duration: AppDurations.press,
      curve: Curves.easeOut,
      child: widget.child,
    );
    content = Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: content,
    );
    if (widget.onTap == null || !widget.enabled) return content;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: content,
    );
  }
}
