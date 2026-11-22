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

class ChoresScreen extends ConsumerWidget {
  const ChoresScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final chores = ref.watch(choresProvider).value ?? const <Chore>[];
    final session = ref.watch(sessionProvider);
    final open = chores.where((chore) => !chore.done).toList()
      ..sort((a, b) {
        if (a.dueAt == null && b.dueAt == null) return 0;
        if (a.dueAt == null) return 1;
        if (b.dueAt == null) return -1;
        return a.dueAt!.compareTo(b.dueAt!);
      });
    final done = chores.where((chore) => chore.done).toList();
    final progress = chores.isEmpty ? 0.0 : done.length / chores.length;

    String assigneeName(Chore chore) {
      if (chore.assignedTo == Chore.both) return 'Both';
      if (chore.assignedTo == session.myId) return 'You';
      return session.partnerName;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chores & errands'),
        actions: [
          IconButton(
            tooltip: 'Add a chore',
            onPressed: () => _showEditor(context),
            icon: const Icon(Icons.add_rounded),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: chores.isEmpty
          ? EmptyState(
              icon: Icons.cleaning_services_rounded,
              title: 'Nothing on the board',
              message:
                  'Split the little things so the shared life feels lighter.',
              actionLabel: 'Add a chore',
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
                  gradient: AppGradients.brand,
                  borderColor: Colors.transparent,
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.cleaning_services_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                          const Spacer(),
                          Text(
                            '${done.length}/${chores.length}',
                            style: context.texts.headlineSmall?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Teamwork makes\nthe shared life lighter.',
                        style: context.texts.headlineSmall?.copyWith(
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor:
                              Colors.white.withValues(alpha: 0.22),
                          valueColor: const AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                if (open.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    'TO DO · ${open.length}',
                    style: context.texts.labelSmall?.copyWith(
                      color: colors.muted,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  for (final chore in open) ...[
                    _ChoreCard(
                      chore: chore,
                      assignee: assigneeName(chore),
                      onToggle: () => _toggle(context, ref, chore),
                      onEdit: () => _showEditor(context, chore: chore),
                      onDelete: () => _delete(context, ref, chore),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ],
                if (done.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    'DONE · ${done.length}',
                    style: context.texts.labelSmall?.copyWith(
                      color: colors.muted,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  for (final chore in done) ...[
                    _ChoreCard(
                      chore: chore,
                      assignee: assigneeName(chore),
                      onToggle: () => _toggle(context, ref, chore),
                      onEdit: () => _showEditor(context, chore: chore),
                      onDelete: () => _delete(context, ref, chore),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ],
              ],
            ),
    );
  }

  Future<void> _toggle(
    BuildContext context,
    WidgetRef ref,
    Chore chore,
  ) async {
    try {
      await ref.read(backendProvider).toggleChore(chore.id, !chore.done);
    } catch (error) {
      if (context.mounted) {
        showAppSnackBar(context, friendlyError(error), isError: true);
      }
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Chore chore,
  ) async {
    final confirmed = await confirmAction(
      context,
      title: 'Remove this chore?',
      message: '“${chore.title}” will be removed for both of you.',
      confirmLabel: 'Remove',
      destructive: true,
    );
    if (!confirmed) return;
    try {
      await ref.read(backendProvider).deleteChore(chore.id);
    } catch (error) {
      if (context.mounted) {
        showAppSnackBar(context, friendlyError(error), isError: true);
      }
    }
  }

  Future<void> _showEditor(BuildContext context, {Chore? chore}) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ChoreSheet(chore: chore),
    );
  }
}

class _ChoreCard extends StatelessWidget {
  const _ChoreCard({
    required this.chore,
    required this.assignee,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final Chore chore;
  final String assignee;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final overdue = !chore.done &&
        chore.dueAt != null &&
        chore.dueAt!.isBefore(
          DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
          ),
        );
    return AppCard(
      onTap: onEdit,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: chore.done ? colors.success : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: chore.done ? colors.success : colors.border,
                  width: 1.6,
                ),
              ),
              child: chore.done
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 19)
                  : null,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chore.title,
                  style: context.texts.titleSmall?.copyWith(
                    decoration: chore.done ? TextDecoration.lineThrough : null,
                    color: chore.done ? colors.muted : colors.text,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    AppPill(
                      label: assignee,
                      color: chore.assignedTo == Chore.both
                          ? colors.tintDarker
                          : colors.primary,
                      icon: chore.assignedTo == Chore.both
                          ? Icons.people_rounded
                          : Icons.person_rounded,
                    ),
                    if (chore.dueAt != null)
                      AppPill(
                        label: relativeDate(chore.dueAt!),
                        color: overdue ? colors.danger : colors.muted,
                        icon: Icons.event_rounded,
                      ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Remove',
            onPressed: onDelete,
            icon: Icon(
              Icons.delete_outline_rounded,
              color: colors.muted,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoreSheet extends ConsumerStatefulWidget {
  const _ChoreSheet({this.chore});

  final Chore? chore;

  @override
  ConsumerState<_ChoreSheet> createState() => _ChoreSheetState();
}

class _ChoreSheetState extends ConsumerState<_ChoreSheet> {
  late final TextEditingController _title;
  String _assignedTo = Chore.both;
  DateTime? _dueAt;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.chore?.title ?? '');
    _assignedTo = widget.chore?.assignedTo ?? Chore.both;
    _dueAt = widget.chore?.dueAt;
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueAt ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: DateTime(now.year + 3),
      helpText: 'When is it due?',
    );
    if (picked != null) setState(() => _dueAt = picked);
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty) {
      showAppSnackBar(context, 'Give this chore a name.', isError: true);
      return;
    }
    setState(() => _saving = true);
    final session = ref.read(sessionProvider);
    final now = DateTime.now();
    final chore = widget.chore == null
        ? Chore(
            id: newId(),
            title: title,
            assignedTo: _assignedTo,
            dueAt: _dueAt,
            createdBy: session.myId,
            createdAt: now,
          )
        : widget.chore!.copyWith(
            title: title,
            assignedTo: _assignedTo,
            dueAt: _dueAt,
            clearDueAt: _dueAt == null,
          );
    try {
      await ref.read(backendProvider).saveChore(chore);
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
    final session = ref.watch(sessionProvider);
    final colors = context.colors;
    return AppSheet(
      title: widget.chore == null ? 'Add a chore' : 'Edit chore',
      subtitle: 'Keep the shared list honest and light.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _title,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'What needs doing?',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Who is it for?', style: context.texts.labelMedium),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              ChoiceChip(
                label: const Text('Both of us'),
                selected: _assignedTo == Chore.both,
                onSelected: (_) => setState(() => _assignedTo = Chore.both),
              ),
              ChoiceChip(
                label: Text(session.myName),
                selected: _assignedTo == session.myId,
                onSelected: (_) =>
                    setState(() => _assignedTo = session.myId),
              ),
              ChoiceChip(
                label: Text(session.partnerName),
                selected: _assignedTo == session.partnerId,
                onSelected: (_) =>
                    setState(() => _assignedTo = session.partnerId),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Due date', style: context.texts.labelMedium),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              ChoiceChip(
                label: const Text('None'),
                selected: _dueAt == null,
                onSelected: (_) => setState(() => _dueAt = null),
              ),
              ChoiceChip(
                label: const Text('Today'),
                selected: _dueAt != null &&
                    dateKeyOf(_dueAt!) == dateKeyOf(DateTime.now()),
                onSelected: (_) {
                  final now = DateTime.now();
                  setState(() => _dueAt = DateTime(now.year, now.month, now.day));
                },
              ),
              ChoiceChip(
                label: const Text('Tomorrow'),
                selected: _dueAt != null &&
                    dateKeyOf(_dueAt!) ==
                        dateKeyOf(DateTime.now().add(const Duration(days: 1))),
                onSelected: (_) {
                  final tomorrow = DateTime.now().add(const Duration(days: 1));
                  setState(
                    () => _dueAt =
                        DateTime(tomorrow.year, tomorrow.month, tomorrow.day),
                  );
                },
              ),
              ActionChip(
                avatar: Icon(
                  Icons.event_rounded,
                  size: 16,
                  color: colors.muted,
                ),
                label: Text(
                  _dueAt == null ? 'Pick date' : relativeDate(_dueAt!),
                ),
                onPressed: _pickDate,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          GradientButton(
            label: widget.chore == null ? 'Add to the board' : 'Save changes',
            icon: Icons.checklist_rounded,
            loading: _saving,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
