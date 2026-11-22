import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/ui.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/brand_mark.dart';
import '../../core/widgets/gradient_button.dart';
import '../../state/session_provider.dart';

enum _SetupMode { create, join }

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final _nameController = TextEditingController();
  final _partnerController = TextEditingController();
  final _pinController = TextEditingController();
  _SetupMode _mode = _SetupMode.create;
  DateTime _anniversary = DateTime.now();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _partnerController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _pickAnniversary() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _anniversary,
      firstDate: DateTime(1950),
      lastDate: now,
      helpText: 'When did your story begin?',
    );
    if (picked != null) {
      setState(() => _anniversary = picked);
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await action();
    } catch (error) {
      if (mounted) {
        setState(() => _error = friendlyError(error));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _create() {
    return _run(() async {
      final name = _nameController.text.trim();
      if (name.isEmpty) throw Exception('Tell us your name first.');
      await ref.read(sessionProvider.notifier).createSpace(
            myName: name,
            partnerName: _partnerController.text.trim(),
            anniversary: _anniversary,
          );
    });
  }

  Future<void> _join() {
    return _run(() async {
      final name = _nameController.text.trim();
      final pin = _pinController.text.trim();
      if (name.isEmpty) throw Exception('Tell us your name first.');
      if (pin.length != 6) throw Exception('The PIN has 6 digits.');
      await ref.read(sessionProvider.notifier).joinSpace(
            myName: name,
            pin: pin,
          );
    });
  }

  Future<void> _demo() {
    return _run(() async {
      final now = DateTime.now();
      await ref.read(sessionProvider.notifier).createSpace(
            myName: _nameController.text.trim().isEmpty
                ? 'Alex'
                : _nameController.text.trim(),
            partnerName: 'Sam',
            anniversary: DateTime(now.year - 2, 2, 14),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final session = ref.watch(sessionProvider);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors.softPink, colors.background],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0, 0.45],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: BrandMark(size: 76)),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'A private space for two',
                      textAlign: TextAlign.center,
                      style: context.texts.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Create a space and share the 6-digit PIN, or join with the PIN your partner sent you.',
                      textAlign: TextAlign.center,
                      style: context.texts.bodyMedium?.copyWith(
                        color: colors.muted,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    SegmentedButton<_SetupMode>(
                      segments: const [
                        ButtonSegment(
                          value: _SetupMode.create,
                          label: Text('Create a space'),
                          icon: Icon(Icons.add_rounded),
                        ),
                        ButtonSegment(
                          value: _SetupMode.join,
                          label: Text('Join with PIN'),
                          icon: Icon(Icons.key_rounded),
                        ),
                      ],
                      selected: {_mode},
                      showSelectedIcon: false,
                      onSelectionChanged: (selection) {
                        setState(() {
                          _mode = selection.first;
                          _error = null;
                        });
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: _nameController,
                            textInputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              labelText: 'Your name',
                              prefixIcon: Icon(Icons.person_outline_rounded),
                            ),
                          ),
                          if (_mode == _SetupMode.create) ...[
                            const SizedBox(height: AppSpacing.md),
                            TextField(
                              controller: _partnerController,
                              textInputAction: TextInputAction.done,
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(
                                labelText: 'Partner name (optional)',
                                prefixIcon: Icon(Icons.favorite_border_rounded),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            InkWell(
                              onTap: _pickAnniversary,
                              borderRadius:
                                  BorderRadius.circular(AppRadii.md),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Your anniversary',
                                  prefixIcon:
                                      Icon(Icons.calendar_today_rounded),
                                ),
                                child: Text(
                                  longDate(_anniversary),
                                  style: context.texts.bodyLarge,
                                ),
                              ),
                            ),
                          ] else ...[
                            const SizedBox(height: AppSpacing.md),
                            TextField(
                              controller: _pinController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              maxLength: 6,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(6),
                              ],
                              style: context.texts.headlineSmall?.copyWith(
                                letterSpacing: 8,
                              ),
                              decoration: const InputDecoration(
                                labelText: '6-digit PIN',
                                counterText: '',
                                prefixIcon: Icon(Icons.pin_rounded),
                              ),
                            ),
                          ],
                          if (_error != null) ...[
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              _error!,
                              style: context.texts.bodySmall?.copyWith(
                                color: colors.danger,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.xl),
                          GradientButton(
                            label: _mode == _SetupMode.create
                                ? 'Create our space'
                                : 'Join our space',
                            icon: _mode == _SetupMode.create
                                ? Icons.favorite_rounded
                                : Icons.login_rounded,
                            loading: _loading,
                            onPressed:
                                _mode == _SetupMode.create ? _create : _join,
                          ),
                          if (session.isDemo) ...[
                            const SizedBox(height: AppSpacing.md),
                            TextButton.icon(
                              onPressed: _loading ? null : _demo,
                              icon: const Icon(Icons.auto_awesome_rounded),
                              label: const Text('Open the demo space'),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 15,
                          color: colors.muted,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'No passwords. Just your PIN.',
                          style: context.texts.bodySmall?.copyWith(
                            color: colors.muted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
