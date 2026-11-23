import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/ids.dart';
import '../../core/utils/moods.dart';
import '../../core/utils/ui.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_illustration.dart';
import '../../core/widgets/app_pill.dart';
import '../../core/widgets/feature_tile.dart';
import '../../core/widgets/heart_pop.dart';
import '../../core/widgets/hero_card.dart';
import '../../core/widgets/mood_chip.dart';
import '../../core/widgets/mood_face.dart';
import '../../core/widgets/staggered_enter.dart';
import '../../data/models/models.dart';
import '../../state/data_providers.dart';
import '../../state/session_provider.dart';
import '../live/live_distance_card.dart';

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
    final photo = ref.watch(currentPhotoChallengeProvider);
    final chores = ref.watch(choresProvider).value ?? const <Chore>[];
    final goals = ref.watch(goalsProvider).value ?? const <Goal>[];
    final coupons = ref.watch(couponsProvider).value ?? const <Coupon>[];
    final deepTalks =
        ref.watch(deepTalkProvider).value ?? const <DeepTalkEntry>[];
    final openChores = chores.where((chore) => !chore.done).length;
    final openGoals = goals.where((goal) => !goal.isComplete).length;
    final readyCoupons = coupons.where((coupon) => !coupon.redeemed).length;
    final nudge = _pickNudge(chores, nextCapsule, goals);
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.3;

    final tiles = [
      FeatureTile(
        art: AppArt.checkIn,
        tint: colors.softPink,
        artSize: 46,
        label: 'Check-in',
        caption: today == null ? 'How are you?' : 'Mood saved',
        onTap: () => context.push('/check-in'),
      ),
      FeatureTile(
        art: AppArt.bucket,
        tint: colors.butter,
        artSize: 46,
        label: 'Bucket list',
        caption: '${openBucket.length} open',
        onTap: () => context.push('/bucket'),
      ),
      FeatureTile(
        art: AppArt.capsules,
        tint: colors.nude,
        artSize: 46,
        label: 'Time capsules',
        caption: nextCapsule == null
            ? 'Write one'
            : '${nextCapsule.daysUntilUnlock}d to unlock',
        onTap: () => context.push('/capsules'),
      ),
      FeatureTile(
        art: AppArt.coupons,
        tint: colors.mint,
        artSize: 46,
        label: 'Coupons',
        caption: '$readyCoupons ready',
        onTap: () => context.push('/coupons'),
      ),
      FeatureTile(
        art: AppArt.goals,
        tint: colors.butter,
        artSize: 46,
        label: 'Shared goals',
        caption: '$openGoals in progress',
        onTap: () => context.push('/goals'),
      ),
      FeatureTile(
        art: AppArt.photos,
        tint: colors.softPink,
        artSize: 46,
        label: 'Photo album',
        caption: photo?.isComplete == true ? 'This week saved' : 'This week',
        onTap: () => context.push('/album'),
      ),
      FeatureTile(
        art: AppArt.deepTalk,
        tint: colors.nude,
        artSize: 46,
        label: 'Deep talk',
        caption: '${deepTalks.length} prompts',
        onTap: () => context.push('/deep-talk'),
      ),
      FeatureTile(
        art: AppArt.chores,
        tint: colors.mint,
        artSize: 46,
        label: 'Chores',
        caption: openChores == 0 ? 'All done' : '$openChores to do',
        onTap: () => context.push('/chores'),
      ),
    ];

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
          AppSpacing.navClearance,
        ),
        children: [
          if (session.isDemo) ...[
            const _DemoBanner(),
            const SizedBox(height: AppSpacing.md),
          ],
          StaggeredEnter(
            index: 0,
            child: HeroCard(
              art: AppArt.mascots,
              artSize: 138,
              artAspectRatio: 1.765,
              backgroundColor: colors.softPink,
              eyebrow: 'DAY $days',
              title: '${greetingFor(DateTime.now())}, ${session.myName}',
              subtitle: session.hasPartner
                  ? partnerToday == null
                      ? '${session.partnerName}: no mood yet'
                      : '${session.partnerName}: ${moodInfo(partnerToday.mood).label.toLowerCase()}'
                  : 'Your private space.',
              footer: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  AppPill(
                    label: '$streak day streak',
                    color: colors.primary,
                    filled: true,
                    icon: Icons.local_fire_department_rounded,
                  ),
                  if (!session.hasPartner && session.pin.isNotEmpty)
                    AppPill(
                      label: 'Invite · ${session.pin}',
                      color: colors.primary,
                      filled: true,
                      icon: Icons.key_rounded,
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: session.pin));
                        showAppSnackBar(context, 'PIN copied.');
                      },
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const StaggeredEnter(index: 1, child: LiveDistanceCard()),
          const SizedBox(height: AppSpacing.xxl),
          StaggeredEnter(
            index: 2,
            child: _SectionHeading(
              title: 'Today',
              caption: 'A tiny pulse check for the two of you.',
              actionLabel: 'Open',
              onAction: () => context.push('/check-in'),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          StaggeredEnter(
            index: 3,
            child: _TodayCard(
              today: today,
              partnerToday: partnerToday,
              partnerName: session.partnerName,
              hasPartner: session.hasPartner,
              onMood: (mood) => _saveMood(context, ref, mood),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          StaggeredEnter(
            index: 4,
            child: _SectionHeading(
              title: 'Everything you share',
              caption: 'Little boxes for your little world.',
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          StaggeredEnter(
            index: 5,
            child: _FeatureGrid(tiles: tiles, largeText: largeText),
          ),
          const SizedBox(height: AppSpacing.lg),
          StaggeredEnter(
            index: 6,
            child: SectionCard(
              onTap: () => context.push(nudge.route),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  IllustrationTile(nudge.art, size: 48),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nudge.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.texts.titleSmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          nudge.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.texts.bodySmall?.copyWith(
                            color: colors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: colors.muted),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _saveMood(BuildContext context, WidgetRef ref, int mood) async {
    final session = ref.read(sessionProvider);
    final existing = ref.read(todayCheckInProvider);
    final now = DateTime.now();
    final checkIn = CheckIn(
      id: existing?.id ?? newId(),
      uid: session.myId,
      mood: mood,
      note: existing?.note ?? '',
      dateKey: dateKeyOf(now),
      createdAt: existing?.createdAt ?? now,
    );
    try {
      await ref.read(backendProvider).saveCheckIn(checkIn);
      if (!context.mounted) return true;
      if (existing == null) {
        showHeartPop(context);
        final streak = ref.read(myStreakProvider);
        showAppSnackBar(
          context,
          "Saved. That's $streak day${streak == 1 ? '' : 's'}.",
        );
      }
      return true;
    } catch (error) {
      if (context.mounted) {
        showAppSnackBar(context, friendlyError(error), isError: true);
      }
      return false;
    }
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.caption,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String caption;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: context.texts.titleMedium),
              const SizedBox(height: 2),
              Text(
                caption,
                style: context.texts.bodySmall?.copyWith(color: colors.muted),
              ),
            ],
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid({required this.tiles, required this.largeText});

  final List<FeatureTile> tiles;
  final bool largeText;

  @override
  Widget build(BuildContext context) {
    if (largeText) {
      return Column(
        children: [
          for (var index = 0; index < tiles.length; index++) ...[
            if (index > 0) const SizedBox(height: AppSpacing.sm),
            tiles[index],
          ],
        ],
      );
    }
    final rows = <Widget>[];
    for (var index = 0; index < tiles.length; index += 2) {
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: tiles[index]),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: index + 1 < tiles.length
                    ? tiles[index + 1]
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      );
      if (index + 2 < tiles.length) {
        rows.add(const SizedBox(height: AppSpacing.sm));
      }
    }
    return Column(children: rows);
  }
}

class _Nudge {
  const _Nudge({
    required this.art,
    required this.title,
    required this.caption,
    required this.route,
  });

  final AppArt art;
  final String title;
  final String caption;
  final String route;
}

_Nudge _pickNudge(
  List<Chore> chores,
  TimeCapsule? nextCapsule,
  List<Goal> goals,
) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final overdue = chores
      .where((chore) => !chore.done && chore.dueAt != null)
      .where((chore) => chore.dueAt!.isBefore(today))
      .toList();
  if (overdue.isNotEmpty) {
    final chore = overdue.first;
    return _Nudge(
      art: AppArt.chores,
      title: chore.title,
      caption: 'Overdue · ${relativeDate(chore.dueAt!)}',
      route: '/chores',
    );
  }
  if (nextCapsule != null) {
    return _Nudge(
      art: AppArt.capsules,
      title: nextCapsule.title,
      caption: 'Unlocks in ${nextCapsule.daysUntilUnlock} days',
      route: '/capsules',
    );
  }
  final openGoals = goals.where((goal) => !goal.isComplete).toList()
    ..sort((a, b) {
      if (a.deadline == null && b.deadline == null) return 0;
      if (a.deadline == null) return 1;
      if (b.deadline == null) return -1;
      return a.deadline!.compareTo(b.deadline!);
    });
  if (openGoals.isNotEmpty) {
    final goal = openGoals.first;
    return _Nudge(
      art: AppArt.goals,
      title: goal.title,
      caption: '${(goal.progress * 100).round()}% saved',
      route: '/goals',
    );
  }
  return const _Nudge(
    art: AppArt.bucket,
    title: 'Nothing urgent today',
    caption: 'Add a little plan to look forward to.',
    route: '/bucket',
  );
}

class _DemoBanner extends StatelessWidget {
  const _DemoBanner();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.softPink,
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Row(
        children: [
          Text(
            'DEMO',
            style: context.texts.labelSmall?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Sample data, kept on this device.',
              style: context.texts.bodySmall?.copyWith(color: colors.muted),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayCard extends StatefulWidget {
  const _TodayCard({
    required this.today,
    required this.partnerToday,
    required this.partnerName,
    required this.hasPartner,
    required this.onMood,
  });

  final CheckIn? today;
  final CheckIn? partnerToday;
  final String partnerName;
  final bool hasPartner;
  final Future<bool> Function(int mood) onMood;

  @override
  State<_TodayCard> createState() => _TodayCardState();
}

class _TodayCardState extends State<_TodayCard> {
  int? _pending;

  @override
  void didUpdateWidget(covariant _TodayCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_pending != null && widget.today?.mood == _pending) {
      _pending = null;
    }
  }

  Future<void> _select(int mood) async {
    if (_pending == mood) return;
    setState(() => _pending = mood);
    final saved = await widget.onMood(mood);
    if (!mounted) return;
    if (!saved) setState(() => _pending = null);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final moodValue = _pending ?? widget.today?.mood;
    final selected = moodValue == null ? null : moodInfo(moodValue);
    final checkIn = widget.today;
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    final partnerLine = !widget.hasPartner
        ? 'Your partner’s mood will show up here after they join.'
        : widget.partnerToday == null
            ? '${widget.partnerName} hasn’t checked in yet today.'
            : '${widget.partnerName} is feeling ${moodInfo(widget.partnerToday!.mood).label.toLowerCase()} today.';
    final baseCard = dark ? colors.cardAlt : colors.card;
    final tint = selected == null
        ? baseCard
        : Color.alphaBlend(
            selected.color.withValues(alpha: dark ? 0.12 : 0.06),
            baseCard,
          );

    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(begin: baseCard, end: tint),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      builder: (context, animatedColor, _) {
        return SectionCard(
          color: animatedColor,
          borderColor: selected?.color.withValues(alpha: 0.22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox.square(
                    dimension: 56,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 320),
                      switchInCurve: Curves.easeOutBack,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                          scale: animation,
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child: selected == null
                          ? const IllustrationTile(
                              AppArt.checkIn,
                              key: ValueKey('checkin-art'),
                              size: 56,
                            )
                          : Container(
                              key: ValueKey('mood-${selected.value}'),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: selected.color.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: MoodFace(
                                mood: selected.value,
                                color: selected.color,
                                size: 56,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 280),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder: (child, animation) {
                            final slide = Tween<Offset>(
                              begin: const Offset(0, 0.25),
                              end: Offset.zero,
                            ).animate(animation);
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: slide,
                                child: child,
                              ),
                            );
                          },
                          child: Text(
                            selected == null
                                ? 'How are you today?'
                                : 'You feel ${selected.label.toLowerCase()} today',
                            key: ValueKey(selected?.value ?? 0),
                            style: context.texts.titleMedium,
                          ),
                        ),
                        const SizedBox(height: 2),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 240),
                          child: Text(
                            partnerLine,
                            key: ValueKey(partnerLine),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: context.texts.bodySmall?.copyWith(
                              color: colors.muted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              LayoutBuilder(
                builder: (context, constraints) {
                  final chipSize =
                      ((constraints.maxWidth / 5) - 8).clamp(38.0, 56.0);
                  final chips = [
                    for (final mood in moodScale)
                      MoodChip(
                        mood: mood,
                        size: chipSize,
                        selected: moodValue == mood.value,
                        onTap: () => _select(mood.value),
                      ),
                  ];
                  if (largeText) {
                    return Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: chips,
                    );
                  }
                  return Row(
                    children: [
                      for (final chip in chips) Expanded(child: chip),
                    ],
                  );
                },
              ),
              if (checkIn != null) ...[
                const SizedBox(height: AppSpacing.md),
                if (largeText)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        checkIn.note.isEmpty
                            ? 'Tap a face to update your mood.'
                            : checkIn.note,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.texts.bodySmall?.copyWith(
                          color: colors.muted,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => context.push('/check-in'),
                          child: const Text('Add a note'),
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          checkIn.note.isEmpty
                              ? 'Tap a face to update your mood.'
                              : checkIn.note,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.texts.bodySmall?.copyWith(
                            color: colors.muted,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/check-in'),
                        child: const Text('Add a note'),
                      ),
                    ],
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}
