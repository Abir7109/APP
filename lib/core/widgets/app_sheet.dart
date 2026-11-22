import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class AppSheet extends StatelessWidget {
  const AppSheet({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            0,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: context.texts.headlineSmall),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle!,
                  style: context.texts.bodySmall?.copyWith(color: colors.muted),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              child,
              if (actions.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xl),
                ...actions,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
