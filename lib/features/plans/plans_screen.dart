import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_pill.dart';
import '../../core/widgets/avatar.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/soft_icon.dart';
import '../../data/models/models.dart';
import '../../state/data_providers.dart';
import '../../state/session_provider.dart';
import '../bucket/date_idea_picker.dart';

class PlansScreen extends ConsumerWidget {
  const PlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final session = ref.watch(sessionProvider);
    final bucket = ref.watch(bucketItemsProvider).value ?? const <BucketItem>[];
    final capsules =
        ref.watch(capsulesProvider).value ?? const <TimeCapsule>[];
    final open = bucket.where((item) => !item.done).toList();
    final dateIdeas = open
        .where((item) => item.category == BucketCategory.dateIdea)
        .toList();
    final locked = capsules.where((capsule) => capsule.isLocked).toList()
      ..sort((a, b) => a.unlockAt.compareTo(b.unlockAt));
    final ready = capsules.where((capsule) => !capsule.isLocked && !capsule.opened).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plans'),
        actions: [
          IconButton(
            tooltip: 'New plan',
            onPressed: () => context.push('/bucket'),
            icon: const Icon(Icons.add_rounded),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.sm,
          AppSpacing.xl,
          AppSpacing.xxxl,
        ),
        children: [
          AppCard(
            gradient: AppGradients.lilac,
            borderColor: Colors.transparent,
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AvatarPair(
                      me: session.myName,
                      partner: session.partnerName,
                      size: 42,
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.explore_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Make memories,\nnot just plans.',
                  style: context.texts.headlineMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${open.length} open ideas · ${capsules.length} capsules',
                  style: context.texts.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          SectionHeader(
            title: 'Bucket list',
            subtitle: '${open.length} things still to do together.',
            actionLabel: 'See all',
            onAction: () => context.push('/bucket'),
          ),
          const SizedBox(height: AppSpacing.md),
          if (open.isEmpty)
            AppCard(
              onTap: () => context.push('/bucket'),
              child: Row(
                children: [
                  const SoftIcon(icon: Icons.explore_rounded, size: 44),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Add your first shared wish.',
                      style: context.texts.bodyMedium,
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            )
          else
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var index = 0; index < open.take(4).length; index++) ...[
                    if (index > 0) Divider(height: 1, color: colors.border),
                    ListTile(
                      onTap: () => context.push('/bucket'),
                      leading: SoftIcon(
                        icon: _categoryIcon(open[index].category),
                        size: 40,
                      ),
                      title: Text(
                        open[index].title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(open[index].category.label),
                      trailing: const Icon(Icons.chevron_right_rounded),
                    ),
                  ],
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.xxl),
          SectionHeader(
            title: 'Date ideas',
            subtitle: '${dateIdeas.length} saved for a free evening.',
            actionLabel: 'Surprise me',
            onAction: () => showDateIdeaPicker(
              context,
              dateIdeas.isEmpty ? open : dateIdeas,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            onTap: () => context.push('/bucket'),
            child: Row(
              children: [
                const SoftIcon(
                  icon: Icons.local_cafe_rounded,
                  color: Color(0xFFFF9500),
                  size: 44,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateIdeas.isEmpty
                            ? 'Save a date idea'
                            : dateIdeas.first.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.texts.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateIdeas.isEmpty
                            ? 'A little inspiration for the two of you.'
                            : '${dateIdeas.length} ideas waiting',
                        style: context.texts.bodySmall?.copyWith(
                          color: colors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          SectionHeader(
            title: 'Time capsules',
            subtitle: 'Letters for the future.',
            actionLabel: 'See all',
            onAction: () => context.push('/capsules'),
          ),
          const SizedBox(height: AppSpacing.md),
          if (capsules.isEmpty)
            AppCard(
              onTap: () => context.push('/capsules'),
              child: Row(
                children: [
                  const SoftIcon(icon: Icons.mail_rounded, size: 44),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Write a letter to open later.',
                      style: context.texts.bodyMedium,
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            )
          else
            AppCard(
              onTap: () => context.push('/capsules'),
              child: Row(
                children: [
                  const SoftIcon(
                    icon: Icons.lock_clock_rounded,
                    color: Color(0xFFFF9500),
                    size: 44,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          locked.isNotEmpty
                              ? locked.first.title
                              : 'A capsule is ready',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.texts.titleSmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          locked.isNotEmpty
                              ? 'Unlocks in ${locked.first.daysUntilUnlock} days'
                              : '${ready.length} ready to open',
                          style: context.texts.bodySmall?.copyWith(
                            color: colors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (locked.isNotEmpty)
                    AppPill(
                      label: '${locked.first.daysUntilUnlock}d',
                      color: colors.warning,
                    ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

IconData _categoryIcon(BucketCategory category) => switch (category) {
      BucketCategory.adventure => Icons.terrain_rounded,
      BucketCategory.food => Icons.restaurant_rounded,
      BucketCategory.travel => Icons.flight_takeoff_rounded,
      BucketCategory.cozy => Icons.weekend_rounded,
      BucketCategory.dateIdea => Icons.local_cafe_rounded,
      BucketCategory.someday => Icons.auto_awesome_rounded,
    };
