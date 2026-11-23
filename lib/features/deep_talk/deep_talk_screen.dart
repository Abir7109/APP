import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/ids.dart';
import '../../core/utils/ui.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_illustration.dart';
import '../../core/widgets/app_pill.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/list_row.dart';
import '../../data/models/models.dart';
import '../../data/seed/seed_content.dart';
import '../../state/data_providers.dart';
import '../../state/session_provider.dart';

class DeepTalkScreen extends ConsumerStatefulWidget {
  const DeepTalkScreen({super.key});

  @override
  ConsumerState<DeepTalkScreen> createState() => _DeepTalkScreenState();
}

class _DeepTalkScreenState extends ConsumerState<DeepTalkScreen> {
  final _answer = TextEditingController();
  final _random = Random();
  late String _prompt = _nextPrompt();
  bool _saving = false;

  String _nextPrompt() {
    final prompts = SeedContent.deepTalkPrompts;
    if (prompts.length == 1) return prompts.first;
    var next = prompts[_random.nextInt(prompts.length)];
    while (next == _prompt) {
      next = prompts[_random.nextInt(prompts.length)];
    }
    return next;
  }

  @override
  void dispose() {
    _answer.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final answer = _answer.text.trim();
    if (answer.isEmpty) {
      showAppSnackBar(context, 'Write a little something first.', isError: true);
      return;
    }
    setState(() => _saving = true);
    final session = ref.read(sessionProvider);
    final entry = DeepTalkEntry(
      id: newId(),
      question: _prompt,
      answer: answer,
      uid: session.myId,
      createdAt: DateTime.now(),
    );
    try {
      await ref.read(backendProvider).saveDeepTalk(entry);
      if (!mounted) return;
      _answer.clear();
      setState(() {
        _saving = false;
        _prompt = _nextPrompt();
      });
      showAppSnackBar(context, 'Saved. That is one to keep.');
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
    final entries =
        ref.watch(deepTalkProvider).value ?? const <DeepTalkEntry>[];
    final sorted = [...entries]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final session = ref.watch(sessionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Deep talk')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.sm,
          AppSpacing.xl,
          AppSpacing.xxxl,
        ),
        children: [
          GestureDetector(
            onHorizontalDragEnd: (details) {
              final velocity = details.primaryVelocity ?? 0;
              if (velocity.abs() > 120) {
                setState(() => _prompt = _nextPrompt());
              }
            },
            child: SectionCard(
              color: colors.softPink,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: AppDurations.fast,
                          child: Text(
                            _prompt,
                            key: ValueKey(_prompt),
                            style: context.texts.titleMedium?.copyWith(
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      const AppIllustration(AppArt.deepTalk, size: 64),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Icon(
                        Icons.favorite_rounded,
                        size: 12,
                        color: colors.primary.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Swipe for another',
                        style: context.texts.bodySmall?.copyWith(
                          color: colors.muted,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () =>
                            setState(() => _prompt = _nextPrompt()),
                        icon: const Icon(Icons.casino_rounded, size: 18),
                        label: const Text('Shuffle'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          TextField(
            controller: _answer,
            minLines: 4,
            maxLines: 8,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Your answer',
              hintText: 'Take your time. Be honest.',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          GradientButton(
            label: 'Save this answer',
            icon: Icons.auto_awesome_rounded,
            loading: _saving,
            onPressed: _save,
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text('Our conversations', style: context.texts.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          if (sorted.isEmpty)
            const EmptyState(
              art: AppArt.deepTalk,
              title: 'No deep talks yet',
              message: 'Answer the question above. Keep what matters.',
            )
          else
            SectionCard(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                children: [
                  for (var index = 0; index < sorted.length; index++)
                    ListRow(
                      showDivider: index < sorted.length - 1,
                      title: sorted[index].question,
                      subtitle: sorted[index].answer,
                      trailing: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          AppPill(
                            label: sorted[index].uid == session.myId
                                ? 'You'
                                : session.partnerName,
                            color: colors.tintDarker,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            relativeDate(sorted[index].createdAt),
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
            ),
        ],
      ),
    );
  }
}
