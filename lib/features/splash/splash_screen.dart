import 'dart:async';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_illustration.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  );
  Timer? _spinnerTimer;
  bool _showSpinner = false;

  @override
  void initState() {
    super.initState();
    _float.repeat();
    _spinnerTimer = Timer(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _showSpinner = true);
    });
  }

  @override
  void dispose() {
    _spinnerTimer?.cancel();
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final art = AppIllustration(AppArt.splash, size: 240);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors.softPink, colors.background],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: Image.asset(
                  AppArt.pattern.asset,
                  repeat: ImageRepeat.repeat,
                  opacity: const AlwaysStoppedAnimation(0.06),
                  filterQuality: FilterQuality.low,
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (reduceMotion)
                      art
                    else
                      AnimatedBuilder(
                        animation: _float,
                        builder: (context, child) {
                          final offset =
                              math.sin(_float.value * math.pi * 2) * 7;
                          return Transform.translate(
                            offset: Offset(0, offset),
                            child: child,
                          );
                        },
                        child: art,
                      ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'YOU&ME',
                      style: context.texts.displaySmall?.copyWith(
                        fontSize: 28,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'A private space for two.',
                      style: context.texts.bodySmall?.copyWith(
                        color: colors.muted,
                      ),
                    ),
                    if (_showSpinner) ...[
                      const SizedBox(height: AppSpacing.xxxl),
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.2),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
