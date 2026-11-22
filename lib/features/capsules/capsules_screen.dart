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
import '../../core/widgets/soft_icon.dart';
import '../../data/models/models.dart';
import '../../state/data_providers.dart';
import '../../state/session_provider.dart';

class CapsulesScreen extends ConsumerWidget {
  const CapsulesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final capsules =
        ref.watch(capsulesProvider).value ?? const <TimeCapsule>[];
    final ready = capsules
        .where((capsule) => !capsule.opened && !capsule.isLocked)
        .toList();
    final locked = capsules.where((capsule) => capsule.isLocked).toList()
      ..sort((a, b) => a.unlockAt.compareTo(b.unlockAt));
    final opened = capsules.where((capsule) => capsule.opened).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Time capsules'),
        actions: [
          IconButton(
            tooltip: 'Write a capsule',
            onPressed: () => _showEditor(context),
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
            gradient: AppGradients.sunset,
            borderColor: Colors.transparent,
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.mail_rounded, color: Colors.white, size: 30),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Write it now.\nOpen it later.',
                  style: context.texts.headlineMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  locked.isEmpty
                      ? 'No capsules waiting yet.'
                      : '${locked.length} capsule${locked.length == 1 ? '' : 's'} waiting for the right moment.',
                  style: context.texts.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
              ],
            ),
          ),
          if (ready.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xxl),
            Text(
              'READY TO OPEN',
              style: context.texts.labelSmall?.copyWith(
                color: colors.muted,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final capsule in ready) ...[
              _CapsuleCard(
                capsule: capsule,
                onOpen: () => _open(context, ref, capsule),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
          if (locked.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xxl),
            Text(
              'LOCKED',
              style: context.texts.labelSmall?.copyWith(
                color: colors.muted,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final capsule in locked) ...[
              _CapsuleCard(
                capsule: capsule,
                onOpen: () => _open(context, ref, capsule),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
          if (opened.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xxl),
            Text(
              'OPENED',
              style: context.texts.labelSmall?.copyWith(
                color: colors.muted,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final capsule in opened) ...[
              _CapsuleCard(
                capsule: capsule,
                onOpen: () => _open(context, ref, capsule),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
          if (capsules.isEmpty)
            EmptyState(
              icon: Icons.mail_rounded,
              title: 'No capsules yet',
              message:
                  'Write a letter to your future selves and choose when it unlocks.',
              actionLabel: 'Write a capsule',
              onAction: () => _showEditor(context),
            ),
        ],
      ),
    );
  }

  Future<void> _open(
    BuildContext context,
    WidgetRef ref,
    TimeCapsule capsule,
  ) async {
    if (capsule.isLocked) {
      showAppSnackBar(
        context,
        'This capsule unlocks on ${longDate(capsule.unlockAt)}.',
      );
      return;
    }
    if (!capsule.opened) {
      final confirmed = await confirmAction(
        context,
        title: 'Open this capsule?',
        message: 'Once opened, you can read it together anytime.',
        confirmLabel: 'Open it',
      );
      if (!confirmed) return;
      try {
        await ref.read(backendProvider).openCapsule(capsule.id);
      } catch (error) {
        if (context.mounted) {
          showAppSnackBar(context, friendlyError(error), isError: true);
        }
        return;
      }
    }
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(capsule.title),
        content: SingleChildScrollView(
          child: Text(
            capsule.body,
            style: context.texts.bodyLarge?.copyWith(height: 1.6),
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditor(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _CapsuleSheet(),
    );
  }
}

class _CapsuleCard extends StatelessWidget {
  const _CapsuleCard({required this.capsule, required this.onOpen});

  final TimeCapsule capsule;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final locked = capsule.isLocked;
    return AppCard(
      onTap: onOpen,
      child: Row(
        children: [
          SoftIcon(
            icon: locked
                ? Icons.lock_rounded
                : capsule.opened
                    ? Icons.mark_email_read_rounded
                    : Icons.mark_email_unread_rounded,
            color: locked
                ? colors.warning
                : capsule.opened
                    ? colors.success
                    : colors.primary,
            size: 46,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  capsule.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.texts.titleSmall,
                ),
                const SizedBox(height: 3),
                Text(
                  locked
                      ? 'Unlocks in ${capsule.daysUntilUnlock} days · ${longDate(capsule.unlockAt)}'
                      : capsule.opened
                          ? 'Opened · ${relativeDate(capsule.createdAt)}'
                          : 'Ready to open',
                  style: context.texts.bodySmall?.copyWith(
                    color: colors.muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (locked)
            AppPill(
              label: '${capsule.daysUntilUnlock}d',
              color: colors.warning,
            )
          else if (capsule.opened)
            AppPill(label: 'Read', color: colors.success)
          else
            AppPill(label: 'Open', color: colors.primary, filled: true),
        ],
      ),
    );
  }
}

class _CapsuleSheet extends ConsumerStatefulWidget {
  const _CapsuleSheet();

  @override
  ConsumerState<_CapsuleSheet> createState() => _CapsuleSheetState();
}

class _CapsuleSheetState extends ConsumerState<_CapsuleSheet> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  DateTime _unlockAt = DateTime.now().add(const Duration(days: 30));
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _unlockAt,
      firstDate: now.add(const Duration(days: 1)),
      lastDate: DateTime(now.year + 10),
      helpText: 'When should it unlock?',
    );
    if (picked != null) {
      setState(() => _unlockAt = DateTime(picked.year, picked.month, picked.day, 9));
    }
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    final body = _body.text.trim();
    if (title.isEmpty || body.isEmpty) {
      showAppSnackBar(
        context,
        'Give your capsule a title and a message.',
        isError: true,
      );
      return;
    }
    setState(() => _saving = true);
    final session = ref.read(sessionProvider);
    final capsule = TimeCapsule(
      id: newId(),
      title: title,
      body: body,
      unlockAt: _unlockAt,
      createdBy: session.myId,
      createdAt: DateTime.now(),
    );
    try {
      await ref.read(backendProvider).saveCapsule(capsule);
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
      title: 'Write a capsule',
      subtitle: 'A letter for the two of you to open later.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _title,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _body,
            minLines: 5,
            maxLines: 10,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Your message',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(AppRadii.md),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Unlock date',
                prefixIcon: Icon(Icons.event_rounded),
              ),
              child: Text(
                '${longDate(_unlockAt)} · in ${_unlockAt.difference(DateTime.now()).inDays} days',
                style: context.texts.bodyLarge,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          GradientButton(
            label: 'Seal this capsule',
            icon: Icons.lock_rounded,
            loading: _saving,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
