import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/ui.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_illustration.dart';
import '../../core/widgets/app_pill.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/hero_card.dart';
import '../../core/widgets/list_row.dart';
import '../../core/widgets/soft_icon.dart';
import '../../core/widgets/staggered_enter.dart';
import '../../state/data_providers.dart';
import '../../state/live_providers.dart';
import '../../state/session_provider.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final session = ref.watch(sessionProvider);
    final days = ref.watch(daysTogetherProvider);
    final anniversary = session.couple?.anniversary;
    final liveBusy = ref.watch(
      liveDistanceControllerProvider.select((state) => state.busy),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.sm,
          AppSpacing.xl,
          AppSpacing.navClearance,
        ),
        children: [
          StaggeredEnter(
            index: 0,
            child: HeroCard(
              backgroundColor: colors.softPink,
              art: AppArt.mascots,
              artSize: 104,
              eyebrow: 'DAY $days',
              title: '${session.myName} & ${session.partnerName}',
              subtitle: session.isDemo
                  ? 'A demo space, kept on this device.'
                  : 'Your shared space, synced for two.',
              footer: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  if (session.pin.isNotEmpty)
                    AppPill(
                      label: 'PIN ${session.pin}',
                      color: colors.primary,
                      filled: true,
                      icon: Icons.lock_rounded,
                    ),
                  if (session.hasPartner)
                    AppPill(
                      label: 'Paired',
                      color: colors.success,
                      icon: Icons.favorite_rounded,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          StaggeredEnter(
            index: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your space', style: context.texts.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                SectionCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Column(
                    children: [
                      ListRow(
                        leading: SoftIcon(
                          icon: Icons.settings_rounded,
                          color: colors.muted,
                          size: 36,
                        ),
                        title: 'Settings',
                        subtitle: 'Profile, theme, PIN, and space',
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: colors.muted,
                        ),
                        onTap: () => context.push('/settings'),
                      ),
                      if (session.pin.isNotEmpty)
                        ListRow(
                          leading: SoftIcon(
                            icon: Icons.key_rounded,
                            color: colors.primary,
                            size: 36,
                          ),
                          title: 'Invite code',
                          subtitle: 'PIN ${session.pin} · tap to copy',
                          trailing: Icon(
                            Icons.copy_rounded,
                            size: 18,
                            color: colors.muted,
                          ),
                          onTap: () {
                            Clipboard.setData(
                              ClipboardData(text: session.pin),
                            );
                            showAppSnackBar(context, 'PIN copied.');
                          },
                        ),
                      ListRow(
                        leading: SoftIcon(
                          icon: Icons.near_me_rounded,
                          color: colors.primary,
                          size: 36,
                        ),
                        title: 'Live distance',
                        subtitle: 'Consent-first, 15 minutes at a time',
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: colors.muted,
                        ),
                        onTap: () => context.push('/live'),
                      ),
                      if (anniversary != null)
                        ListRow(
                          showDivider: false,
                          leading: SoftIcon(
                            icon: Icons.cake_outlined,
                            color: colors.primary,
                            size: 36,
                          ),
                          title: 'Your anniversary',
                          subtitle:
                              '${longDate(anniversary)} · Day $days together',
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          StaggeredEnter(
            index: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Good to know', style: context.texts.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                SectionCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Column(
                    children: [
                      ListRow(
                        leading: SoftIcon(
                          icon: Icons.lock_outline_rounded,
                          color: colors.success,
                          size: 36,
                        ),
                        title: 'Location stays private',
                        subtitle:
                            'Shared only when you both allow it. It ends by itself.',
                      ),
                      ListRow(
                        showDivider: false,
                        leading: SoftIcon(
                          icon: Icons.favorite_rounded,
                          color: colors.primary,
                          size: 36,
                        ),
                        title: 'Made for two',
                        subtitle: 'A quiet home for your relationship.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (session.isDemo) ...[
            const SizedBox(height: AppSpacing.xxl),
            StaggeredEnter(
              index: 3,
              child: SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const IllustrationTile(AppArt.mascots, size: 52),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Demo playground',
                                style: context.texts.titleSmall,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Feel the other side of a live request without a second phone.',
                                style: context.texts.bodySmall?.copyWith(
                                  color: colors.muted,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    GradientButton(
                      label: 'Preview an incoming request',
                      icon: Icons.notifications_active_outlined,
                      loading: liveBusy,
                      height: 48,
                      onPressed: liveBusy
                          ? null
                          : () => ref
                              .read(liveDistanceControllerProvider.notifier)
                              .previewIncoming(),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xxl),
          Row(
            children: [
              Icon(Icons.lock_outline_rounded, size: 14, color: colors.muted),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  session.isDemo
                      ? 'Demo mode: your data stays on this device.'
                      : 'Connected to your shared Firebase space.',
                  style: context.texts.bodySmall?.copyWith(color: colors.muted),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
