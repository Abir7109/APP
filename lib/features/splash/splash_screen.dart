import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/brand_mark.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors.softPink, colors.background],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const BrandMark(size: 108),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'YOU&ME',
                  style: context.texts.displaySmall?.copyWith(
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'A private space for two.',
                  style: context.texts.bodyMedium?.copyWith(
                    color: colors.muted,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),
                const SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
