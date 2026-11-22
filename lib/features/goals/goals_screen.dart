import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/ids.dart';
import '../../core/utils/ui.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_pill.dart';
import '../../core/widgets/app_sheet.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/gradient_button.dart';
import '../../data/models/models.dart';
import '../../state/data_providers.dart';
import '../../state/session_provider.dart';

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
              icon: Icons.savings_rounded,
              title: 'Dream something up',
              message:
                  'A trip, a home project, an emergency fund. Save toward it together.',
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
                AppCard(
                  gradient: AppGradients.sunrise,
                  borderColor: Colors.transparent,
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.savings_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                          const Spacer(),
                          Text(
                            '${(overall * 100).round()}%',
                            style: context.texts.headlineSmall?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Building something together.',
                        style: context.texts.headlineSmall?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '${formatMoney(totalSaved)} saved of ${formatMoney(totalTarget)}',
                        style: context.texts.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: overall,
                          minHeight: 8,
                          backgroundColor:
                              Colors.white.withValues(alpha: 0.22),
                          valueColor: const AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  'YOUR GOALS',
                  style: context.texts.labelSmall?.copyWith(
                    color: colors.muted,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                for (final goal in sorted) ...[
                  _GoalCard(
                    goal: goal,
                    onAdd: () => _showContribution(context, goal),
                    onEdit: () => _showEditor(context, goal: goal),
                    onDelete: () => _delete(context, ref, goal),
                  ),
                  const SizedBox(height: AppSpacing.md),
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
    return AppCard(
      onTap: onEdit,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(goal.title, style: context.texts.titleMedium),
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
          if (goal.deadline != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Target ${longDate(goal.deadline!)}',
              style: context.texts.bodySmall?.copyWith(color: colors.muted),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: goal.progress,
              minHeight: 8,
              backgroundColor: colors.background,
              valueColor: AlwaysStoppedAnimation(
                goal.isComplete ? colors.success : colors.primary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Text(
                formatMoney(goal.savedAmount, currency: goal.currency),
                style: context.texts.titleSmall?.copyWith(
                  color: goal.isComplete ? colors.success : colors.primary,
                ),
              ),
              Text(
                ' of ${formatMoney(goal.targetAmount, currency: goal.currency)}',
                style: context.texts.bodySmall?.copyWith(color: colors.muted),
              ),
              const Spacer(),
              Text(
                '${(goal.progress * 100).round()}%',
                style: context.texts.bodySmall?.copyWith(color: colors.muted),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add money'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton(
                tooltip: 'Edit goal',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 20),
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
    final target = double.tryParse(
      _target.text.replaceAll(',', '').replaceAll('\$', '').trim(),
    );
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _title,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'What are you saving for?'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _target,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Target amount',
              prefixText: '\$ ',
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
    final amount = double.tryParse(
      _amount.text.replaceAll(',', '').replaceAll('\$', '').trim(),
    );
    if (amount == null || amount <= 0) {
      showAppSnackBar(context, 'Enter an amount above zero.', isError: true);
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(backendProvider).addToGoal(widget.goal.id, amount);
      if (!mounted) return;
      showAppSnackBar(
        context,
        '${formatMoney(amount)} added to ${widget.goal.title}.',
      );
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
    return AppSheet(
      title: 'Add to goal',
      subtitle: widget.goal.title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _amount,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount',
              prefixText: '\$ ',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final amount in const [10, 25, 50, 100])
                ActionChip(
                  label: Text(formatMoney(amount.toDouble())),
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
