import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_pill.dart';
import '../../core/widgets/avatar.dart';
import '../../core/widgets/soft_icon.dart';
import '../../state/data_providers.dart';
import '../../state/session_provider.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final session = ref.watch(sessionProvider);
    final days = ref.watch(daysTogetherProvider);
    final bucket = ref.watch(openBucketItemsProvider).length;
    final capsules = ref.watch(capsulesProvider).value ?? const [];
    final lockedCapsules = capsules.where((capsule) => capsule.isLocked).length;
    final coupons =
        (ref.watch(couponsProvider).value ?? const [])
            .where((coupon) => !coupon.redeemed)
            .length;
    final goals = ref.watch(goalsProvider).value ?? const [];
    final openGoals = goals.where((goal) => !goal.isComplete).length;
    final chores =
        (ref.watch(choresProvider).value ?? const [])
            .where((chore) => !chore.done)
            .length;
    final deepTalks = ref.watch(deepTalkProvider).value ?? const [];

    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.sm,
          AppSpacing.xl,
          AppSpacing.xxxl,
        ),
        children: [
          AppCard(
            gradient: AppGradients.brand,
            borderColor: Colors.transparent,
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              children: [
                AvatarPair(
                  me: session.myName,
                  partner: session.partnerName,
                  size: 62,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  '${session.myName} & ${session.partnerName}',
                  style: context.texts.headlineSmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Day $days of us',
                  style: context.texts.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                AppPill(
                  label: 'PIN ${session.pin}',
                  color: Colors.white.withValues(alpha: 0.22),
                  filled: true,
                  icon: Icons.lock_rounded,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            'YOUR SPACE',
            style: context.texts.labelSmall?.copyWith(
              color: colors.muted,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _MoreTile(
            icon: Icons.explore_rounded,
            color: colors.success,
            title: 'Bucket list',
            subtitle: '$bucket ideas waiting',
            onTap: () => context.push('/bucket'),
          ),
          const SizedBox(height: AppSpacing.md),
          _MoreTile(
            icon: Icons.mail_rounded,
            color: colors.warning,
            title: 'Time capsules',
            subtitle: '$lockedCapsules sealed letters',
            onTap: () => context.push('/capsules'),
          ),
          const SizedBox(height: AppSpacing.md),
          _MoreTile(
            icon: Icons.confirmation_number_rounded,
            color: colors.primary,
            title: 'Kindness coupons',
            subtitle: '$coupons ready to redeem',
            onTap: () => context.push('/coupons'),
          ),
          const SizedBox(height: AppSpacing.md),
          _MoreTile(
            icon: Icons.savings_rounded,
            color: colors.info,
            title: 'Shared goals',
            subtitle: '$openGoals goals in progress',
            onTap: () => context.push('/goals'),
          ),
          const SizedBox(height: AppSpacing.md),
          _MoreTile(
            icon: Icons.cleaning_services_rounded,
            color: colors.tintDarker,
            title: 'Chores & errands',
            subtitle: '$chores things to do',
            onTap: () => context.push('/chores'),
          ),
          const SizedBox(height: AppSpacing.md),
          _MoreTile(
            icon: Icons.forum_rounded,
            color: colors.primary,
            title: 'Deep talk',
            subtitle: '${deepTalks.length} answers saved',
            onTap: () => context.push('/deep-talk'),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            'SETTINGS',
            style: context.texts.labelSmall?.copyWith(
              color: colors.muted,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _MoreTile(
            icon: Icons.settings_rounded,
            color: colors.muted,
            title: 'Settings',
            subtitle: 'Profile, theme, PIN, and space',
            onTap: () => context.push('/settings'),
          ),
          const SizedBox(height: AppSpacing.xxl),
          AppCard(
            color: colors.primary.withValues(alpha: 0.06),
            borderColor: colors.primary.withValues(alpha: 0.2),
            child: Row(
              children: [
                Icon(Icons.favorite_rounded, color: colors.primary),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    session.isDemo
                        ? 'Demo mode: your data stays on this device.'
                        : 'Connected to your shared Firebase space.',
                    style: context.texts.bodySmall?.copyWith(
                      color: colors.muted,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreTile extends StatelessWidget {
  const _MoreTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          SoftIcon(icon: icon, color: color, size: 46),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.texts.titleSmall),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: context.texts.bodySmall?.copyWith(color: colors.muted),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: colors.muted),
        ],
      ),
    );
  }
}
