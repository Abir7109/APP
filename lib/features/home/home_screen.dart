import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/moods.dart';
import '../../core/utils/ui.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_pill.dart';
import '../../core/widgets/avatar.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/soft_icon.dart';
import '../../data/models/models.dart';
import '../../state/data_providers.dart';
import '../../state/session_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final session = ref.watch(sessionProvider);
    final today = ref.watch(todayCheckInProvider);
    final partnerToday = ref.watch(partnerTodayCheckInProvider);
    final days = ref.watch(daysTogetherProvider);
    final streak = ref.watch(myStreakProvider);
    final openBucket = ref.watch(openBucketItemsProvider);
    final nextCapsule = ref.watch(nextCapsuleProvider);
    final activeCoupons = ref.watch(activeCouponsProvider);
    final photo = ref.watch(currentPhotoChallengeProvider);
    final chores = ref.watch(choreStatsProvider);
    final goals = ref.watch(goalsProvider).value ?? const [];
    final goalsProgress = ref.watch(goalsProgressProvider);
    final saved = goals.fold<double>(0, (sum, goal) => sum + goal.savedAmount);
    final target = goals.fold<double>(0, (sum, goal) => sum + goal.targetAmount);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greetingFor(DateTime.now()),
              style: context.texts.bodySmall?.copyWith(color: colors.muted),
            ),
            Text('${session.myName} & ${session.partnerName}'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
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
          _HeroCard(
            days: days,
            streak: streak,
            anniversary: session.couple?.anniversary,
            me: session.myName,
            partner: session.partnerName,
            isDemo: session.isDemo,
          ),
          if (!session.hasPartner && session.pin.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            _InviteCard(pin: session.pin),
          ],
          const SizedBox(height: AppSpacing.lg),
          _CheckInCard(today: today),
          const SizedBox(height: AppSpacing.lg),
          _PartnerMoodCard(
            partnerName: session.partnerName,
            partnerMood: partnerToday,
            hasPartner: session.hasPartner,
          ),
          const SizedBox(height: AppSpacing.xxl),
          SectionHeader(
            title: 'Quick actions',
            subtitle: 'Everything you two are building.',
          ),
          const SizedBox(height: AppSpacing.md),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.5,
            children: [
              _QuickTile(
                icon: Icons.explore_rounded,
                color: colors.info,
                title: 'Bucket list',
                caption: '${openBucket.length} open',
                onTap: () => context.push('/bucket'),
              ),
              _QuickTile(
                icon: Icons.mail_rounded,
                color: colors.warning,
                title: 'Time capsules',
                caption: nextCapsule == null
                    ? 'Write one'
                    : '${nextCapsule.daysUntilUnlock}d to unlock',
                onTap: () => context.push('/capsules'),
              ),
              _QuickTile(
                icon: Icons.confirmation_num_rounded,
                color: colors.primary,
                title: 'Coupons',
                caption: '${activeCoupons.length} ready',
                onTap: () => context.push('/coupons'),
              ),
              _QuickTile(
                icon: Icons.camera_alt_rounded,
                color: colors.success,
                title: 'Photo challenge',
                caption: photo?.isComplete == true ? 'Complete' : 'This week',
                onTap: () => context.go('/album'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          SectionHeader(
            title: 'Next up',
            actionLabel: 'Plans',
            onAction: () => context.go('/plans'),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppCard(
                  onTap: () => context.push('/capsules'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SoftIcon(
                        icon: Icons.lock_clock_rounded,
                        size: 40,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        nextCapsule?.title ?? 'Write a capsule',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.texts.titleSmall,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        nextCapsule == null
                            ? 'A letter for later'
                            : 'Unlocks in ${nextCapsule.daysUntilUnlock} days',
                        style: context.texts.bodySmall?.copyWith(
                          color: colors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppCard(
                  onTap: () => context.go('/album'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SoftIcon(
                        icon: Icons.photo_camera_rounded,
                        color: colors.success,
                        size: 40,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        photo?.prompt ?? 'This week’s photo',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.texts.titleSmall,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        photo?.isComplete == true
                            ? 'You did it'
                            : 'Take yours',
                        style: context.texts.bodySmall?.copyWith(
                          color: colors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          SectionHeader(
            title: 'Shared goals',
            subtitle: goals.isEmpty
                ? 'Save toward something together.'
                : '${formatMoney(saved)} of ${formatMoney(target)}',
            actionLabel: 'See all',
            onAction: () => context.push('/goals'),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            onTap: () => context.push('/goals'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        goals.isEmpty
                            ? 'Start your first goal'
                            : '${goals.length} shared goal${goals.length == 1 ? '' : 's'}',
                        style: context.texts.titleSmall,
                      ),
                    ),
                    AppPill(
                      label: '${(goalsProgress * 100).round()}%',
                      color: colors.primary,
                      filled: true,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: goalsProgress,
                    minHeight: 9,
                    backgroundColor: colors.field,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          SectionHeader(
            title: 'Chores & errands',
            subtitle: chores.totalOpen == 0
                ? 'All clear for now.'
                : '${chores.totalOpen} open · ${chores.completed} done',
            actionLabel: 'See all',
            onAction: () => context.push('/chores'),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            onTap: () => context.push('/chores'),
            child: Row(
              children: [
                Expanded(
                  child: _ChoreStat(
                    label: 'Yours',
                    value: chores.mineOpen,
                    color: colors.primary,
                  ),
                ),
                Expanded(
                  child: _ChoreStat(
                    label: 'Partner',
                    value: chores.partnerOpen,
                    color: colors.info,
                  ),
                ),
                Expanded(
                  child: _ChoreStat(
                    label: 'Shared',
                    value: chores.sharedOpen,
                    color: colors.warning,
                  ),
                ),
                Expanded(
                  child: _ChoreStat(
                    label: 'Done',
                    value: chores.completed,
                    color: colors.success,
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

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.days,
    required this.streak,
    required this.anniversary,
    required this.me,
    required this.partner,
    required this.isDemo,
  });

  final int days;
  final int streak;
  final DateTime? anniversary;
  final String me;
  final String partner;
  final bool isDemo;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: AppGradients.brand,
      borderColor: Colors.transparent,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarPair(me: me, partner: partner, size: 46),
              const Spacer(),
              if (isDemo)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'DEMO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Day $days',
            style: context.texts.displaySmall?.copyWith(
              color: Colors.white,
              fontSize: 42,
            ),
          ),
          Text(
            'together',
            style: context.texts.titleMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _HeroPill(
                icon: Icons.local_fire_department_rounded,
                label: '$streak day streak',
              ),
              const SizedBox(width: AppSpacing.sm),
              if (anniversary != null)
                _HeroPill(
                  icon: Icons.favorite_rounded,
                  label: 'Since ${shortDate(anniversary!)}',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InviteCard extends StatelessWidget {
  const _InviteCard({required this.pin});

  final String pin;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      color: colors.softPink,
      borderColor: colors.primary.withValues(alpha: 0.25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SoftIcon(icon: Icons.key_rounded, size: 40),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Invite your partner', style: context.texts.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      'Share this 6-digit PIN',
                      style: context.texts.bodySmall?.copyWith(
                        color: colors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Copy PIN',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: pin));
                  showAppSnackBar(context, 'PIN copied.');
                },
                icon: const Icon(Icons.copy_rounded),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            pin.split('').join('  '),
            style: context.texts.displaySmall?.copyWith(
              letterSpacing: 2,
              fontSize: 34,
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckInCard extends StatelessWidget {
  const _CheckInCard({required this.today});

  final CheckIn? today;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final checkIn = today;
    if (checkIn != null) {
      final mood = moodInfo(checkIn.mood);
      return AppCard(
        onTap: () => context.push('/check-in'),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: mood.color.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(mood.icon, color: mood.color, size: 28),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Today you feel ${mood.label.toLowerCase()}',
                      style: context.texts.titleSmall),
                  const SizedBox(height: 2),
                  Text(
                    checkIn.note.isEmpty
                        ? 'Tap to update your check-in'
                        : checkIn.note,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
      );
    }
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How are you feeling today?', style: context.texts.titleSmall),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final mood in moodScale)
                InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () => context.push('/check-in?mood=${mood.value}'),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: mood.color.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(mood.icon, color: mood.color, size: 26),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mood.label,
                          style: context.texts.labelSmall?.copyWith(
                            color: colors.muted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PartnerMoodCard extends StatelessWidget {
  const _PartnerMoodCard({
    required this.partnerName,
    required this.partnerMood,
    required this.hasPartner,
  });

  final String partnerName;
  final CheckIn? partnerMood;
  final bool hasPartner;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (!hasPartner) {
      return AppCard(
        child: Row(
          children: [
            InitialsAvatar(name: partnerName, size: 44),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                'Your partner’s mood will show up here after they join.',
                style: context.texts.bodySmall?.copyWith(color: colors.muted),
              ),
            ),
          ],
        ),
      );
    }
    if (partnerMood == null) {
      return AppCard(
        child: Row(
          children: [
            InitialsAvatar(name: partnerName, size: 44),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                '$partnerName hasn’t checked in yet today.',
                style: context.texts.bodySmall?.copyWith(color: colors.muted),
              ),
            ),
          ],
        ),
      );
    }
    final checkIn = partnerMood!;
    final mood = moodInfo(checkIn.mood);
    return AppCard(
      child: Row(
        children: [
          InitialsAvatar(name: partnerName, size: 44),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$partnerName is feeling ${mood.label.toLowerCase()}',
                    style: context.texts.titleSmall),
                if (checkIn.note.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    checkIn.note,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.texts.bodySmall?.copyWith(
                      color: colors.muted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(mood.icon, color: mood.color, size: 30),
        ],
      ),
    );
  }
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.caption,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String caption;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SoftIcon(icon: icon, color: color, size: 38),
          const Spacer(),
          Text(title, style: context.texts.titleSmall),
          const SizedBox(height: 2),
          Text(
            caption,
            style: context.texts.bodySmall?.copyWith(color: colors.muted),
          ),
        ],
      ),
    );
  }
}

class _ChoreStat extends StatelessWidget {
  const _ChoreStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: context.texts.headlineSmall?.copyWith(color: color),
        ),
        const SizedBox(height: 2),
        Text(label, style: context.texts.bodySmall),
      ],
    );
  }
}
