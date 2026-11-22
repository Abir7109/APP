import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/ids.dart';
import '../../core/utils/ui.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_pill.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/gradient_button.dart';
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
    final sorted = [...entries]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
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
            child: AppCard(
              gradient: AppGradients.sunset,
              borderColor: Colors.transparent,
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.format_quote_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                      const Spacer(),
                      AppPill(
                        label: 'Prompt',
                        color: Colors.white.withValues(alpha: 0.2),
                        filled: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    _prompt,
                    style: context.texts.headlineSmall?.copyWith(
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () =>
                            setState(() => _prompt = _nextPrompt()),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          alignment: Alignment.centerLeft,
                        ),
                        icon: const Icon(Icons.casino_rounded, size: 18),
                        label: const Text('Shuffle prompt'),
                      ),
                      const Spacer(),
                      Text(
                        'Swipe for another',
                        style: context.texts.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
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
          Text(
            'OUR CONVERSATIONS',
            style: context.texts.labelSmall?.copyWith(
              color: colors.muted,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (sorted.isEmpty)
            const EmptyState(
              icon: Icons.forum_rounded,
              title: 'No deep talks yet',
              message: 'Answer the prompt above and start a little ritual.',
            )
          else
            for (final entry in sorted) ...[
              _EntryCard(
                entry: entry,
                author: entry.uid == session.myId
                    ? 'You'
                    : session.partnerName,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
        ],
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry, required this.author});

  final DeepTalkEntry entry;
  final String author;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  entry.question,
                  style: context.texts.labelMedium?.copyWith(
                    color: colors.primary,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              AppPill(label: author, color: colors.tintDarker),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            entry.answer,
            style: context.texts.bodyLarge?.copyWith(height: 1.5),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            relativeDate(entry.createdAt),
            style: context.texts.bodySmall?.copyWith(color: colors.muted),
          ),
        ],
      ),
    );
  }
}
