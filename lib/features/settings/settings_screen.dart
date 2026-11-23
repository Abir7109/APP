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
import '../../core/widgets/app_sheet.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/list_row.dart';
import '../../state/data_providers.dart';
import '../../state/session_provider.dart';
import '../../state/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final session = ref.watch(sessionProvider);
    final themeMode = ref.watch(themeModeProvider);
    final days = ref.watch(daysTogetherProvider);
    final anniversary = session.couple?.anniversary;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.sm,
          AppSpacing.xl,
          AppSpacing.xxxl,
        ),
        children: [
          SectionCard(
            child: Row(
              children: [
                const AppIllustration(AppArt.mascots, size: 64),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(session.myName, style: context.texts.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        session.hasPartner
                            ? 'Paired with ${session.partnerName}'
                            : 'Waiting for your person',
                        style: context.texts.bodySmall?.copyWith(
                          color: colors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Edit my name',
                  onPressed: () =>
                      _editName(context, ref, session.myName),
                  icon: const Icon(Icons.edit_outlined, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text('Space', style: context.texts.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          SectionCard(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              children: [
                ListRow(
                  leading: Icon(Icons.lock_rounded, size: 20),
                  title: 'Pairing PIN',
                  trailing: AppPill(
                    label: session.pin,
                    color: colors.primary,
                    filled: true,
                  ),
                ),
                ListRow(
                  leading: Icon(Icons.copy_rounded, size: 20),
                  title: 'Copy PIN',
                  onTap: () => _copyPin(context, session.pin),
                  trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                ),
                ListRow(
                  leading: Icon(Icons.ios_share_rounded, size: 20),
                  title: 'Share invite',
                  onTap: () => _sharePin(context, session.pin),
                  trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                ),
                if (anniversary != null)
                  ListRow(
                    leading: Icon(Icons.favorite_rounded, size: 20),
                    title: 'Together since',
                    subtitle: longDate(anniversary),
                    trailing: Text(
                      '$days days',
                      style: context.texts.bodySmall?.copyWith(
                        color: colors.muted,
                      ),
                    ),
                  ),
                ListRow(
                  showDivider: false,
                  leading: Icon(Icons.storage_rounded, size: 20),
                  title: 'Storage',
                  subtitle:
                      session.isDemo ? 'On this device' : 'Shared Firebase space',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text('Appearance', style: context.texts.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          SectionCard(
            child: Row(
              children: [
                Expanded(
                  child: Text('Theme', style: context.texts.titleSmall),
                ),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: Icon(Icons.brightness_auto_rounded),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: Icon(Icons.light_mode_rounded),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: Icon(Icons.dark_mode_rounded),
                    ),
                  ],
                  selected: {themeMode},
                  showSelectedIcon: false,
                  onSelectionChanged: (selection) {
                    ref
                        .read(themeModeProvider.notifier)
                        .setMode(selection.first);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text('About', style: context.texts.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          SectionCard(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListRow(
                  leading: Icon(Icons.favorite_rounded, size: 20),
                  title: 'YOU&ME',
                  trailing: Text(
                    'Version 1.0.0',
                    style: context.texts.bodySmall?.copyWith(
                      color: colors.muted,
                    ),
                  ),
                ),
                ListRow(
                  showDivider: false,
                  leading: Icon(Icons.shield_rounded, size: 20),
                  title: 'Privacy',
                  subtitle: session.isDemo ? 'On this device' : 'Firebase',
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: AppSpacing.sm,
                    bottom: AppSpacing.md,
                  ),
                  child: Text(
                    'Made for the two of you. No feeds, no noise — just the small things that keep you close.',
                    style: context.texts.bodySmall?.copyWith(
                      color: colors.muted,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            'Leave',
            style: context.texts.titleMedium?.copyWith(color: colors.danger),
          ),
          const SizedBox(height: AppSpacing.sm),
          SectionCard(
            borderColor: colors.danger.withValues(alpha: 0.35),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: ListRow(
              showDivider: false,
              onTap: () => _leave(context, ref),
              leading: Icon(Icons.logout_rounded, color: colors.danger),
              title: 'Leave this space',
              subtitle: session.isDemo
                  ? 'Return to setup. Your demo data stays on this device.'
                  : 'You will stop syncing with this space.',
              trailing:
                  Icon(Icons.chevron_right_rounded, color: colors.danger),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editName(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _NameSheet(current: current),
    );
  }

  Future<void> _copyPin(BuildContext context, String pin) async {
    await Clipboard.setData(ClipboardData(text: pin));
    if (context.mounted) {
      showAppSnackBar(context, 'PIN copied.');
    }
  }

  Future<void> _sharePin(BuildContext context, String pin) async {
    await Clipboard.setData(
      ClipboardData(
        text: 'Join me on YOU&ME. Our pairing PIN is $pin.',
      ),
    );
    if (context.mounted) {
      showAppSnackBar(context, 'Invite copied. Send it to your person.');
    }
  }

  Future<void> _leave(BuildContext context, WidgetRef ref) async {
    final confirmed = await confirmAction(
      context,
      title: 'Leave this space?',
      message:
          'You can rejoin later with the same PIN. Your shared data stays in the space.',
      confirmLabel: 'Leave',
      destructive: true,
    );
    if (!confirmed) return;
    try {
      await ref.read(sessionProvider.notifier).leaveSpace();
      if (context.mounted) {
        showAppSnackBar(context, 'You left the space.');
        context.go('/setup');
      }
    } catch (error) {
      if (context.mounted) {
        showAppSnackBar(context, friendlyError(error), isError: true);
      }
    }
  }
}

class _NameSheet extends ConsumerStatefulWidget {
  const _NameSheet({required this.current});

  final String current;

  @override
  ConsumerState<_NameSheet> createState() => _NameSheetState();
}

class _NameSheetState extends ConsumerState<_NameSheet> {
  late final TextEditingController _name;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(
      text: widget.current == 'You' ? '' : widget.current,
    );
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      showAppSnackBar(context, 'Your name cannot be empty.', isError: true);
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(sessionProvider.notifier).updateName(name);
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
      title: 'Edit your name',
      subtitle: 'This is what your partner sees.',
      art: AppArt.mascots,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _name,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Your name'),
          ),
          const SizedBox(height: AppSpacing.xl),
          GradientButton(
            label: 'Save name',
            loading: _saving,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
