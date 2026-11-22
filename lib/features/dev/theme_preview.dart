import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_pill.dart';
import '../../core/widgets/brand_mark.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/soft_icon.dart';
import '../../state/theme_provider.dart';

class ThemePreviewScreen extends ConsumerWidget {
  const ThemePreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final mode = ref.watch(themeModeProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Design system'),
        actions: [
          IconButton(
            tooltip: 'Toggle theme',
            onPressed: () => ref.read(themeModeProvider.notifier).cycle(),
            icon: Icon(
              mode == ThemeMode.dark
                  ? Icons.dark_mode_rounded
                  : Icons.light_mode_rounded,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          const Center(
            child: BrandMark(size: 64, wordmark: true),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          Text('Colors', style: context.texts.headlineSmall),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _Swatch(label: 'Primary', color: colors.primary),
              _Swatch(label: 'Tint', color: colors.tint),
              _Swatch(label: 'Nude', color: colors.nude),
              _Swatch(label: 'Soft pink', color: colors.softPink),
              _Swatch(label: 'Success', color: colors.success),
              _Swatch(label: 'Warning', color: colors.warning),
              _Swatch(label: 'Danger', color: colors.danger),
            ],
          ),
          const SizedBox(height: AppSpacing.xxxl),
          Text('Cards & actions', style: context.texts.headlineSmall),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SoftIcon(icon: Icons.favorite_rounded),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Daily check-in', style: context.texts.titleMedium),
                          Text(
                            'How are you feeling today?',
                            style: context.texts.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const AppPill(label: '3 day streak'),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                const GradientButton(
                  label: 'Check in now',
                  icon: Icons.arrow_forward_rounded,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          const SectionHeader(
            title: 'Section header',
            subtitle: 'With a supporting line of copy',
            actionLabel: 'See all',
          ),
          const SizedBox(height: AppSpacing.xxl),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              const AppPill(label: 'Bucket list', icon: Icons.checklist_rounded),
              AppPill(
                label: 'Date night',
                icon: Icons.local_fire_department_rounded,
                color: colors.tintDarker,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 68,
          height: 56,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppRadii.sm),
            border: Border.all(color: context.colors.border),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(label, style: context.texts.labelSmall),
      ],
    );
  }
}
