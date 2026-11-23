import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/moods.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_illustration.dart';
import '../../core/widgets/app_pill.dart';
import '../../core/widgets/avatar.dart';
import '../../core/widgets/hero_card.dart';
import '../../core/widgets/mood_face.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/staggered_enter.dart';
import '../../data/models/models.dart';
import '../../state/data_providers.dart';
import '../../state/session_provider.dart';

class ConnectScreen extends ConsumerWidget {
  const ConnectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final session = ref.watch(sessionProvider);
    final myCheckIn = ref.watch(todayCheckInProvider);
    final partnerCheckIn = ref.watch(partnerTodayCheckInProvider);
    final streak = ref.watch(myStreakProvider);
    final days = ref.watch(daysTogetherProvider);
    final deepTalks =
        ref.watch(deepTalkProvider).value ?? const <DeepTalkEntry>[];
    final coupons = ref.watch(couponsProvider).value ?? const <Coupon>[];
    final activeCoupons = coupons.where((coupon) => !coupon.redeemed).length;
    final challenges =
        ref.watch(photoChallengesProvider).value ?? const <PhotoChallenge>[];
    final completedChallenges =
        challenges.where((challenge) => challenge.isComplete).length;
    final checkIns = ref.watch(checkInsProvider).value ?? const <CheckIn>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Connect')),
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
              title: 'How are you two?',
              subtitle: 'Day $days of us · $streak day streak',
              footer: Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  AvatarPair(
                    me: session.myName,
                    partner: session.partnerName,
                    size: 42,
                  ),
                  AppPill(
                    label: '${session.myName} & ${session.partnerName}',
                    color: Colors.white.withValues(alpha: 0.22),
                    filled: true,
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionHeader(
                  title: 'Daily pulse',
                  trailing: Text(
                    dateKeyOf(DateTime.now()),
                    style: context.texts.bodySmall?.copyWith(
                      color: colors.muted,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _PulseCard(
                        name: session.myName,
                        label: 'You',
                        checkIn: myCheckIn,
                        onTap: () => context.push('/check-in'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _PulseCard(
                        name: session.partnerName,
                        label: 'Partner',
                        checkIn: partnerCheckIn,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          StaggeredEnter(
            index: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionHeader(title: 'Keep talking'),
                const SizedBox(height: AppSpacing.sm),
                _RitualTile(
                  art: AppArt.deepTalk,
                  title: 'Deep talk',
                  subtitle: deepTalks.isEmpty
                      ? 'Start your first conversation'
                      : '${deepTalks.length} answer${deepTalks.length == 1 ? '' : 's'} saved',
                  onTap: () => context.push('/deep-talk'),
                ),
                const SizedBox(height: AppSpacing.sm),
                _RitualTile(
                  art: AppArt.coupons,
                  title: 'Kindness coupons',
                  subtitle: activeCoupons == 0
                      ? 'Offer something small'
                      : '$activeCoupons ready to redeem',
                  onTap: () => context.push('/coupons'),
                ),
                const SizedBox(height: AppSpacing.sm),
                _RitualTile(
                  art: AppArt.photos,
                  title: 'Photo challenges',
                  subtitle: '$completedChallenges of ${challenges.length} captured',
                  onTap: () => context.push('/album'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          StaggeredEnter(
            index: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionHeader(title: 'Your week'),
                const SizedBox(height: AppSpacing.sm),
                SectionCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (final day in _lastSevenDays())
                        _DayMood(
                          day: day,
                          checkIn: _checkInFor(
                            checkIns,
                            session.myId,
                            dateKeyOf(day),
                          ),
                        ),
                    ],
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

List<DateTime> _lastSevenDays() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return List.generate(
    7,
    (index) => today.subtract(Duration(days: 6 - index)),
  );
}

CheckIn? _checkInFor(List<CheckIn> checkIns, String uid, String key) {
  for (final checkIn in checkIns) {
    if (checkIn.uid == uid && checkIn.dateKey == key) return checkIn;
  }
  return null;
}

class _PulseCard extends StatelessWidget {
  const _PulseCard({
    required this.name,
    required this.label,
    required this.checkIn,
    this.onTap,
  });

  final String name;
  final String label;
  final CheckIn? checkIn;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final mood = checkIn == null ? null : moodInfo(checkIn!.mood);
    return SectionCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InitialsAvatar(name: name, size: 36),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.texts.titleSmall,
                    ),
                    Text(
                      label,
                      style: context.texts.bodySmall?.copyWith(
                        color: colors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (mood == null)
            Row(
              children: [
                Icon(
                  Icons.sentiment_neutral_rounded,
                  color: colors.muted,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Not checked in',
                    style: context.texts.bodySmall?.copyWith(
                      color: colors.muted,
                    ),
                  ),
                ),
              ],
            )
          else ...[
            Row(
              children: [
                MoodFace(
                  mood: mood.value,
                  color: mood.color,
                  size: 24,
                  animate: false,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    mood.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        context.texts.titleSmall?.copyWith(color: mood.color),
                  ),
                ),
              ],
            ),
            if (checkIn!.note.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                checkIn!.note,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.texts.bodySmall?.copyWith(color: colors.muted),
              ),
            ],
          ],
          if (mood == null && onTap != null) ...[
            const SizedBox(height: AppSpacing.md),
            AppPill(
              label: 'Check in',
              color: colors.primary,
              icon: Icons.add_rounded,
              onTap: onTap,
            ),
          ],
        ],
      ),
    );
  }
}

class _RitualTile extends StatelessWidget {
  const _RitualTile({
    required this.art,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final AppArt art;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SectionCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          IllustrationTile(art, size: 46),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.texts.titleSmall),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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

class _DayMood extends StatelessWidget {
  const _DayMood({required this.day, this.checkIn});

  final DateTime day;
  final CheckIn? checkIn;

  static const _labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final mood = checkIn == null ? null : moodInfo(checkIn!.mood);
    return Column(
      children: [
        Text(
          _labels[day.weekday - 1],
          style: context.texts.bodySmall?.copyWith(color: colors.muted),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: mood == null
                ? colors.background
                : mood.color.withValues(alpha: 0.14),
            shape: BoxShape.circle,
            border: Border.all(
              color: mood == null ? colors.border : mood.color,
              width: 1.2,
            ),
          ),
          child: mood == null
              ? Icon(Icons.remove_rounded, size: 18, color: colors.muted)
              : MoodFace(
                  mood: mood.value,
                  color: mood.color,
                  size: 24,
                  animate: false,
                ),
        ),
      ],
    );
  }
}
