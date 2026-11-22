import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/ui.dart';
import '../../core/widgets/app_pill.dart';
import '../../data/models/models.dart';

Future<void> showDateIdeaPicker(
  BuildContext context,
  List<BucketItem> ideas,
) async {
  if (ideas.isEmpty) {
    showAppSnackBar(
      context,
      'Add a date idea to your bucket list first.',
    );
    return;
  }

  final random = Random();
  var current = ideas[random.nextInt(ideas.length)];

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          final colors = context.colors;
          return AlertDialog(
            title: const Text('Your next date idea'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(current.title, style: context.texts.titleMedium),
                if (current.note.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    current.note,
                    style: context.texts.bodySmall?.copyWith(
                      color: colors.muted,
                      height: 1.5,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                AppPill(
                  label: current.category.label,
                  color: colors.primary,
                  icon: Icons.local_cafe_rounded,
                ),
              ],
            ),
            actions: [
              TextButton.icon(
                onPressed: () {
                  if (ideas.length == 1) {
                    showAppSnackBar(
                      context,
                      'That is the only idea saved so far.',
                    );
                    return;
                  }
                  var next = current;
                  while (next.id == current.id) {
                    next = ideas[random.nextInt(ideas.length)];
                  }
                  setState(() => current = next);
                },
                icon: const Icon(Icons.casino_rounded, size: 18),
                label: const Text('Another'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Nice'),
              ),
            ],
          );
        },
      );
    },
  );
}
