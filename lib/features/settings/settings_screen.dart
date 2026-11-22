import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/ui.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_pill.dart';
import '../../core/widgets/app_sheet.dart';
import '../../core/widgets/avatar.dart';
import '../../core/widgets/gradient_button.dart';
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
          AppCard(
            child: Column(
              children: [
                AvatarPair(
                  me: session.myName,
                  partner: session.partnerName,
                  size: 58,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(session.myName, style: context.texts.headlineSmall),
                const SizedBox(height: 2),
                Text(
                  session.hasPartner
                      ? 'Paired with ${session.partnerName}'
                      : 'Waiting for your person',
                  style: context.texts.bodySmall?.copyWith(color: colors.muted),
                ),
                const SizedBox(height: AppSpacing.lg),
                OutlinedButton.icon(
                  onPressed: () => _editName(context, ref, session.myName),
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  label: const Text('Edit my name'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            'OUR SPACE',
            style: context.texts.labelSmall?.copyWith(
              color: colors.muted,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.lock_rounded, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Pairing PIN', style: context.texts.titleSmall),
                    const Spacer(),
                    AppPill(
                      label: session.pin,
                      color: colors.primary,
                      filled: true,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _copyPin(context, session.pin),
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        label: const Text('Copy PIN'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _sharePin(context, session.pin),
                        icon: const Icon(Icons.ios_share_rounded, size: 18),
                        label: const Text('Share'),
                      ),
                    ),
                  ],
                ),
                if (anniversary != null) ...[
                  const Divider(height: AppSpacing.xxl),
                  _InfoRow(
                    icon: Icons.favorite_rounded,
                    label: 'Together since',
                    value: longDate(anniversary),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _InfoRow(
                    icon: Icons.timelapse_rounded,
                    label: 'Days together',
                    value: '$days',
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                _InfoRow(
                  icon: Icons.storage_rounded,
                  label: 'Storage',
                  value: session.isDemo ? 'Demo mode' : 'Firebase',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            'APPEARANCE',
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
                Text(
                  'Theme',
                  style: context.texts.titleSmall,
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final entry in const [
                      (ThemeMode.system, 'System', Icons.brightness_auto_rounded),
                      (ThemeMode.light, 'Light', Icons.light_mode_rounded),
                      (ThemeMode.dark, 'Dark', Icons.dark_mode_rounded),
                    ])
                      ChoiceChip(
                        avatar: Icon(
                          entry.$3,
                          size: 17,
                          color: themeMode == entry.$1
                              ? Colors.white
                              : colors.muted,
                        ),
                        label: Text(entry.$2),
                        selected: themeMode == entry.$1,
                        onSelected: (_) => ref
                            .read(themeModeProvider.notifier)
                            .setMode(entry.$1),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            'ABOUT',
            style: context.texts.labelSmall?.copyWith(
              color: colors.muted,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.favorite_rounded,
                  label: 'YOU&ME',
                  value: 'Version 1.0.0',
                ),
                const SizedBox(height: AppSpacing.sm),
                _InfoRow(
                  icon: Icons.shield_rounded,
                  label: 'Privacy',
                  value: session.isDemo ? 'On this device' : 'Firebase',
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Made for the two of you. No feeds, no noise — just the small things that keep you close.',
                  style: context.texts.bodySmall?.copyWith(
                    color: colors.muted,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            'LEAVE',
            style: context.texts.labelSmall?.copyWith(
              color: colors.danger,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            borderColor: colors.danger.withValues(alpha: 0.35),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.logout_rounded, color: colors.danger),
              title: Text(
                'Leave this space',
                style: context.texts.titleSmall?.copyWith(color: colors.danger),
              ),
              subtitle: Text(
                session.isDemo
                    ? 'Return to setup. Your demo data stays on this device.'
                    : 'You will stop syncing with this space.',
                style: context.texts.bodySmall?.copyWith(color: colors.muted),
              ),
              trailing: Icon(Icons.chevron_right_rounded, color: colors.danger),
              onTap: () => _leave(context, ref),
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Icon(icon, size: 18, color: colors.muted),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: context.texts.bodySmall?.copyWith(color: colors.muted),
        ),
        const Spacer(),
        Text(value, style: context.texts.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
        )),
      ],
    );
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
    _name = TextEditingController(text: widget.current == 'You' ? '' : widget.current);
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
