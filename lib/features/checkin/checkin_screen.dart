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
import '../../core/widgets/avatar.dart';
import '../../core/widgets/gradient_button.dart';
import '../../data/models/models.dart';
import '../../state/data_providers.dart';
import '../../state/session_provider.dart';

class CheckInScreen extends ConsumerWidget {
  const CheckInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requested = int.tryParse(
      GoRouterState.of(context).uri.queryParameters['mood'] ?? '',
    );
    final today = ref.watch(todayCheckInProvider);
    return _CheckInForm(
      initialMood: requested ?? today?.mood ?? 3,
      existing: today,
    );
  }
}

class _CheckInForm extends ConsumerStatefulWidget {
  const _CheckInForm({required this.initialMood, this.existing});

  final int initialMood;
  final CheckIn? existing;

  @override
  ConsumerState<_CheckInForm> createState() => _CheckInFormState();
}

class _CheckInFormState extends ConsumerState<_CheckInForm> {
  late int _mood;
  late final TextEditingController _note;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _mood = widget.initialMood;
    _note = TextEditingController(text: widget.existing?.note ?? '');
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final session = ref.read(sessionProvider);
    final now = DateTime.now();
    final checkIn = CheckIn(
      id: widget.existing?.id ?? newId(),
      uid: session.myId,
      mood: _mood,
      note: _note.text.trim(),
      dateKey: dateKeyOf(now),
      createdAt: widget.existing?.createdAt ?? now,
    );
    try {
      await ref.read(backendProvider).saveCheckIn(checkIn);
      if (!mounted) return;
      showAppSnackBar(context, 'Check-in saved.');
      context.pop();
    } catch (error) {
      if (mounted) {
        setState(() => _saving = false);
        showAppSnackBar(context, friendlyError(error), isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final partnerCheckIn = ref.watch(partnerTodayCheckInProvider);
    final session = ref.watch(sessionProvider);
    final selected = moodInfo(_mood);
    final myCheckIns = ref.watch(myCheckInsProvider);
    final streak = ref.watch(myStreakProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Daily check-in')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.sm,
          AppSpacing.xl,
          AppSpacing.xxxl,
        ),
        children: [
          Text(
            'How are you feeling today?',
            style: context.texts.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'A tiny pulse for the two of you.',
            style: context.texts.bodySmall?.copyWith(color: colors.muted),
          ),
          const SizedBox(height: AppSpacing.xl),
          for (final mood in moodScale) ...[
            _MoodOption(
              mood: mood,
              selected: _mood == mood.value,
              onTap: () => setState(() => _mood = mood.value),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            color: selected.color.withValues(alpha: 0.08),
            borderColor: selected.color.withValues(alpha: 0.3),
            child: Row(
              children: [
                Icon(selected.icon, color: selected.color, size: 30),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Today you feel ${selected.label.toLowerCase()}.',
                    style: context.texts.titleSmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _note,
            minLines: 3,
            maxLines: 6,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Anything you want to share? (optional)',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          GradientButton(
            label: widget.existing == null ? 'Save my check-in' : 'Update check-in',
            icon: Icons.favorite_rounded,
            loading: _saving,
            onPressed: _save,
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            'YOUR LAST 14 DAYS',
            style: context.texts.labelSmall?.copyWith(
              color: colors.muted,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.local_fire_department_rounded,
                      color: colors.warning,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '$streak day streak',
                      style: context.texts.titleSmall,
                    ),
                    const Spacer(),
                    Text(
                      '${myCheckIns.length} total',
                      style: context.texts.bodySmall?.copyWith(
                        color: colors.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 72,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 14,
                    separatorBuilder: (_, _) =>
                        const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final day = DateTime.now().subtract(
                        Duration(days: 13 - index),
                      );
                      final key = dateKeyOf(day);
                      CheckIn? match;
                      for (final entry in myCheckIns) {
                        if (entry.dateKey == key) {
                          match = entry;
                          break;
                        }
                      }
                      return _HistoryDay(day: day, checkIn: match);
                    },
                  ),
                ),
              ],
            ),
          ),
          if (session.hasPartner) ...[
            const SizedBox(height: AppSpacing.xxl),
            Text(
              'PARTNER TODAY',
              style: context.texts.labelSmall?.copyWith(
                color: colors.muted,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              child: Row(
                children: [
                  InitialsAvatar(name: session.partnerName, size: 44),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: partnerCheckIn == null
                        ? Text(
                            '${session.partnerName} hasn’t checked in yet.',
                            style: context.texts.bodySmall?.copyWith(
                              color: colors.muted,
                            ),
                          )
                        : Text(
                            '${session.partnerName} is feeling ${moodInfo(partnerCheckIn.mood).label.toLowerCase()}.',
                            style: context.texts.titleSmall,
                          ),
                  ),
                  if (partnerCheckIn != null)
                    Icon(
                      moodInfo(partnerCheckIn.mood).icon,
                      color: moodInfo(partnerCheckIn.mood).color,
                      size: 28,
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HistoryDay extends StatelessWidget {
  const _HistoryDay({required this.day, this.checkIn});

  final DateTime day;
  final CheckIn? checkIn;

  static const _weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final mood = checkIn == null ? null : moodInfo(checkIn!.mood);
    final isToday = dateKeyOf(day) == dateKeyOf(DateTime.now());
    return Column(
      children: [
        Text(
          _weekdays[day.weekday - 1],
          style: context.texts.labelSmall?.copyWith(color: colors.muted),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: mood == null
                ? colors.background
                : mood.color.withValues(alpha: 0.14),
            shape: BoxShape.circle,
            border: Border.all(
              color: isToday
                  ? colors.primary
                  : mood == null
                      ? colors.border
                      : mood.color,
              width: isToday ? 2 : 1.2,
            ),
          ),
          child: Icon(
            mood?.icon ?? Icons.remove_rounded,
            size: 18,
            color: mood?.color ?? colors.muted,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${day.day}',
          style: context.texts.labelSmall?.copyWith(
            color: isToday ? colors.primary : colors.muted,
            fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _MoodOption extends StatelessWidget {
  const _MoodOption({
    required this.mood,
    required this.selected,
    required this.onTap,
  });

  final MoodInfo mood;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      onTap: onTap,
      borderColor: selected ? mood.color : colors.border,
      color: selected ? mood.color.withValues(alpha: 0.08) : colors.card,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: mood.color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(mood.icon, color: mood.color, size: 26),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(mood.label, style: context.texts.titleMedium),
          ),
          if (selected)
            Icon(Icons.check_circle_rounded, color: mood.color, size: 24)
          else
            Icon(
              Icons.circle_outlined,
              color: colors.border,
              size: 24,
            ),
        ],
      ),
    );
  }
}
