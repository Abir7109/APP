import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/ids.dart';
import '../../core/utils/ui.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_illustration.dart';
import '../../core/widgets/app_pill.dart';
import '../../core/widgets/app_sheet.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/heart_pop.dart';
import '../../core/widgets/staggered_enter.dart';
import '../../data/models/models.dart';
import '../../state/data_providers.dart';
import '../../state/session_provider.dart';

String _currencySymbol(String? currency) =>
    NumberFormat.simpleCurrency(name: currency ?? 'USD').currencySymbol;

double? _parseAmount(String text) =>
    double.tryParse(text.replaceAll(RegExp(r'[^0-9.]'), ''));

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final goals = ref.watch(goalsProvider).value ?? const <Goal>[];
    final sorted = [...goals]
      ..sort((a, b) {
        if (a.isComplete != b.isComplete) return a.isComplete ? 1 : -1;
        return b.createdAt.compareTo(a.createdAt);
      });
    final totalTarget =
        goals.fold<double>(0, (sum, goal) => sum + goal.targetAmount);
    final totalSaved =
        goals.fold<double>(0, (sum, goal) => sum + goal.savedAmount);
    final overall =
        totalTarget == 0 ? 0.0 : (totalSaved / totalTarget).clamp(0.0, 1.0);
    final currency = goals.isEmpty ? 'USD' : goals.first.currency;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared goals'),
        actions: [
          IconButton(
            tooltip: 'New goal',
            onPressed: () => _showEditor(context),
            icon: const Icon(Icons.add_rounded),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: goals.isEmpty
          ? EmptyState(
              art: AppArt.goals,
              title: 'Dream something up',
              message: 'Pick something to save for, together.',
              actionLabel: 'Create a goal',
              onAction: () => _showEditor(context),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.sm,
                AppSpacing.xl,
                AppSpacing.xxxl,
              ),
              children: [
                StaggeredEnter(
                  index: 0,
                  child: SectionCard(
                    child: Row(
                      children: [
                        const IllustrationTile(AppArt.goals, size: 96),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${(overall * 100).round()}%',
                                style: context.texts.headlineMedium,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${formatMoney(totalSaved, currency: currency)} of ${formatMoney(totalTarget, currency: currency)}',
                                style: context.texts.bodySmall?.copyWith(
                                  color: colors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text('Your goals', style: context.texts.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                for (var index = 0; index < sorted.length; index++) ...[
                  StaggeredEnter(
                    index: index + 1,
                    child: _GoalCard(
                      goal: sorted[index],
                      onAdd: () => _showContribution(context, sorted[index]),
                      onEdit: () => _showEditor(context, goal: sorted[index]),
                      onDelete: () => _delete(context, ref, sorted[index]),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ],
            ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Goal goal) async {
    final confirmed = await confirmAction(
      context,
      title: 'Delete this goal?',
      message: '“${goal.title}” and its progress will be removed.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!confirmed) return;
    try {
      await ref.read(backendProvider).deleteGoal(goal.id);
    } catch (error) {
      if (context.mounted) {
        showAppSnackBar(context, friendlyError(error), isError: true);
      }
    }
  }

  Future<void> _showEditor(BuildContext context, {Goal? goal}) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _GoalSheet(goal: goal),
    );
  }

  Future<void> _showContribution(BuildContext context, Goal goal) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ContributionSheet(goal: goal),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.goal,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  final Goal goal;
  final VoidCallback onAdd;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SectionCard(
      onTap: onEdit,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const IllustrationTile(AppArt.goals, size: 44),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.texts.titleSmall,
                    ),
                    if (goal.deadline != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Target ${longDate(goal.deadline!)}',
                        style: context.texts.bodySmall?.copyWith(
                          color: colors.muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (goal.isComplete)
                AppPill(
                  label: 'Complete',
                  color: colors.success,
                  icon: Icons.check_rounded,
                )
              else
                IconButton(
                  tooltip: 'Delete goal',
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: colors.muted,
                    size: 20,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: goal.progress,
              minHeight: 8,
              backgroundColor: colors.field,
              valueColor: AlwaysStoppedAnimation(
                goal.isComplete ? colors.success : colors.primary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${formatMoney(goal.savedAmount, currency: goal.currency)} of ${formatMoney(goal.targetAmount, currency: goal.currency)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.texts.bodySmall?.copyWith(
                    color: colors.muted,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (!goal.isComplete)
                TextButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add money'),
                )
              else
                Text(
                  '${(goal.progress * 100).round()}%',
                  style: context.texts.bodySmall?.copyWith(
                    color: colors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoalSheet extends ConsumerStatefulWidget {
  const _GoalSheet({this.goal});

  final Goal? goal;

  @override
  ConsumerState<_GoalSheet> createState() => _GoalSheetState();
}

class _GoalSheetState extends ConsumerState<_GoalSheet> {
  late final TextEditingController _title;
  late final TextEditingController _target;
  DateTime? _deadline;
  bool _saving = false;

  String get _currency => widget.goal?.currency ?? 'USD';

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.goal?.title ?? '');
    _target = TextEditingController(
      text: widget.goal == null
          ? ''
          : widget.goal!.targetAmount.toStringAsFixed(
              widget.goal!.targetAmount % 1 == 0 ? 0 : 2,
            ),
    );
    _deadline = widget.goal?.deadline;
  }

  @override
  void dispose() {
    _title.dispose();
    _target.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? now.add(const Duration(days: 90)),
      firstDate: now,
      lastDate: DateTime(now.year + 10),
      helpText: 'Target date',
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    final target = _parseAmount(_target.text);
    if (title.isEmpty || target == null || target <= 0) {
      showAppSnackBar(
        context,
        'Add a title and a target above zero.',
        isError: true,
      );
      return;
    }
    setState(() => _saving = true);
    final session = ref.read(sessionProvider);
    final now = DateTime.now();
    final goal = widget.goal == null
        ? Goal(
            id: newId(),
            title: title,
            targetAmount: target,
            deadline: _deadline,
            createdBy: session.myId,
            createdAt: now,
          )
        : widget.goal!.copyWith(
            title: title,
            targetAmount: target,
            deadline: _deadline,
            clearDeadline: _deadline == null,
          );
    try {
      await ref.read(backendProvider).saveGoal(goal);
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        setState(() => _saving = false);
        showAppSnackBar(context, friendlyError(error), isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppSheet(
      title: widget.goal == null ? 'New shared goal' : 'Edit goal',
      subtitle: 'Small deposits, shared momentum.',
      art: AppArt.goals,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _title,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration:
                const InputDecoration(labelText: 'What are you saving for?'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _target,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Target amount',
              prefixText: '${_currencySymbol(_currency)} ',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(AppRadii.md),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Target date (optional)',
                prefixIcon: const Icon(Icons.event_rounded),
                suffixIcon: _deadline == null
                    ? null
                    : IconButton(
                        tooltip: 'Clear date',
                        onPressed: () => setState(() => _deadline = null),
                        icon: const Icon(Icons.close_rounded, size: 18),
                      ),
              ),
              child: Text(
                _deadline == null ? 'No deadline' : longDate(_deadline!),
                style: context.texts.bodyLarge,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          GradientButton(
            label: widget.goal == null ? 'Create goal' : 'Save changes',
            icon: Icons.savings_rounded,
            loading: _saving,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}

class _ContributionSheet extends ConsumerStatefulWidget {
  const _ContributionSheet({required this.goal});

  final Goal goal;

  @override
  ConsumerState<_ContributionSheet> createState() =>
      _ContributionSheetState();
}

class _ContributionSheetState extends ConsumerState<_ContributionSheet> {
  final _amount = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = _parseAmount(_amount.text);
    if (amount == null || amount <= 0) {
      showAppSnackBar(context, 'Enter an amount above zero.', isError: true);
      return;
    }
    setState(() => _saving = true);
    final completes = amount >= widget.goal.remaining;
    try {
      await ref.read(backendProvider).addToGoal(widget.goal.id, amount);
      if (!mounted) return;
      if (completes) {
        showHeartPop(context);
        showAppSnackBar(context, 'Goal complete. Look at you two.');
      } else {
        showAppSnackBar(
          context,
          '${formatMoney(amount, currency: widget.goal.currency)} added to ${widget.goal.title}.',
        );
      }
      Navigator.of(context).pop();
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
    final symbol = _currencySymbol(widget.goal.currency);
    return AppSheet(
      title: 'Add to goal',
      subtitle: widget.goal.title,
      art: AppArt.goals,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _amount,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Amount',
              prefixText: '$symbol ',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final amount in const [10, 25, 50, 100])
                ActionChip(
                  label: Text(
                    formatMoney(
                      amount.toDouble(),
                      currency: widget.goal.currency,
                    ),
                  ),
                  onPressed: () => _amount.text = amount.toString(),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '${formatMoney(widget.goal.savedAmount, currency: widget.goal.currency)} saved · ${formatMoney(widget.goal.remaining, currency: widget.goal.currency)} to go',
            style: context.texts.bodySmall?.copyWith(color: colors.muted),
          ),
          const SizedBox(height: AppSpacing.xl),
          GradientButton(
            label: 'Add to our goal',
            icon: Icons.add_rounded,
            loading: _saving,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
