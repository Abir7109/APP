import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/ui.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_pill.dart';
import '../../core/widgets/app_sheet.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/gradient_button.dart';
import '../../data/models/models.dart';
import '../../state/data_providers.dart';
import '../../state/session_provider.dart';

class AlbumScreen extends ConsumerWidget {
  const AlbumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final challenges =
        ref.watch(photoChallengesProvider).value ?? const <PhotoChallenge>[];
    final session = ref.watch(sessionProvider);
    final sorted = [...challenges]
      ..sort((a, b) => b.weekKey.compareTo(a.weekKey));
    final currentKey = weekKeyOf(DateTime.now());
    final current = sorted.where((c) => c.weekKey == currentKey).toList();
    final past = sorted.where((c) => c.weekKey != currentKey).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Our album')),
      body: challenges.isEmpty
          ? EmptyState(
              icon: Icons.photo_library_rounded,
              title: 'Your album is empty',
              message:
                  'Weekly photo prompts will appear here. Add your first photo to start the collection.',
              actionLabel: 'Create a prompt',
              onAction: () => _showPromptSheet(context),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.sm,
                AppSpacing.xl,
                AppSpacing.xxxl,
              ),
              children: [
                if (current.isNotEmpty) ...[
                  Text(
                    'THIS WEEK',
                    style: context.texts.labelSmall?.copyWith(
                      color: colors.muted,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  for (final challenge in current) ...[
                    _CurrentChallengeCard(
                      challenge: challenge,
                      partnerName: session.partnerName,
                      myId: session.myId,
                      onAddPhoto: () => _addPhoto(context, ref, challenge),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ],
                if (past.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'PAST PROMPTS',
                    style: context.texts.labelSmall?.copyWith(
                      color: colors.muted,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  for (final challenge in past) ...[
                    _PastChallengeCard(
                      challenge: challenge,
                      onTap: () => _preview(context, challenge),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ],
                const SizedBox(height: AppSpacing.lg),
                OutlinedButton.icon(
                  onPressed: () => _showPromptSheet(context),
                  icon: const Icon(Icons.add_a_photo_rounded),
                  label: const Text('Add a custom prompt'),
                ),
              ],
            ),
    );
  }

  Future<void> _addPhoto(
    BuildContext context,
    WidgetRef ref,
    PhotoChallenge challenge,
  ) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) => AppSheet(
        title: 'Add a photo',
        subtitle: challenge.prompt,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded),
              title: const Text('Take a photo'),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    Uint8List? bytes;
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 82,
      );
      if (picked == null) return;
      bytes = await picked.readAsBytes();
    } catch (error) {
      if (context.mounted) {
        showAppSnackBar(context, 'Could not open the photo picker.', isError: true);
      }
      return;
    }
    if (!context.mounted) return;
    final session = ref.read(sessionProvider);
    try {
      final url = await ref.read(backendProvider).uploadPhoto(
            bytes,
            contentType: 'image/jpeg',
          );
      await ref.read(backendProvider).savePhotoChallenge(
            challenge.copyWith(
              photoUrl: url,
              completedBy: session.myId,
              completedAt: DateTime.now(),
            ),
          );
      if (context.mounted) showAppSnackBar(context, 'Photo added to your album.');
    } catch (error) {
      if (context.mounted) {
        showAppSnackBar(context, friendlyError(error), isError: true);
      }
    }
  }

  Future<void> _preview(BuildContext context, PhotoChallenge challenge) async {
    if (challenge.imageSource == null) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ChallengeImage(
                source: challenge.imageSource,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(challenge.prompt, style: context.texts.titleSmall),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Week of ${shortDate(DateTime.tryParse(challenge.weekKey) ?? DateTime.now())}',
                    style: context.texts.bodySmall?.copyWith(
                      color: context.colors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPromptSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _PromptSheet(),
    );
  }
}

class _CurrentChallengeCard extends StatelessWidget {
  const _CurrentChallengeCard({
    required this.challenge,
    required this.partnerName,
    required this.myId,
    required this.onAddPhoto,
  });

  final PhotoChallenge challenge;
  final String partnerName;
  final String myId;
  final VoidCallback onAddPhoto;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final image = challenge.imageSource;
    final author = challenge.completedBy == null
        ? null
        : challenge.completedBy == myId
            ? 'You'
            : partnerName;
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (image != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadii.lg),
              ),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: ChallengeImage(source: image),
              ),
            )
          else
            Container(
              height: 170,
              decoration: BoxDecoration(
                gradient: AppGradients.soft(colors),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadii.lg),
                ),
              ),
              child: Icon(
                Icons.photo_camera_rounded,
                size: 42,
                color: colors.primary.withValues(alpha: 0.55),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppPill(
                      label: challenge.isComplete ? 'Captured' : 'This week',
                      color: challenge.isComplete
                          ? colors.success
                          : colors.primary,
                      icon: challenge.isComplete
                          ? Icons.check_rounded
                          : Icons.auto_awesome_rounded,
                    ),
                    const Spacer(),
                    Text(
                      shortDate(DateTime.tryParse(challenge.weekKey) ??
                          DateTime.now()),
                      style: context.texts.bodySmall?.copyWith(
                        color: colors.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(challenge.prompt, style: context.texts.titleMedium),
                if (author != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Captured by $author',
                    style: context.texts.bodySmall?.copyWith(
                      color: colors.muted,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                GradientButton(
                  label: challenge.isComplete ? 'Change photo' : 'Add your photo',
                  icon: Icons.add_a_photo_rounded,
                  height: 46,
                  onPressed: onAddPhoto,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PastChallengeCard extends StatelessWidget {
  const _PastChallengeCard({required this.challenge, required this.onTap});

  final PhotoChallenge challenge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final image = challenge.imageSource;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.md),
            child: SizedBox(
              width: 72,
              height: 72,
              child: image == null
                  ? Container(
                      color: colors.background,
                      child: Icon(
                        Icons.image_not_supported_rounded,
                        color: colors.muted,
                        size: 24,
                      ),
                    )
                  : ChallengeImage(source: image),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.prompt,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.texts.titleSmall,
                ),
                const SizedBox(height: 3),
                Text(
                  'Week of ${shortDate(DateTime.tryParse(challenge.weekKey) ?? DateTime.now())}',
                  style: context.texts.bodySmall?.copyWith(
                    color: colors.muted,
                  ),
                ),
              ],
            ),
          ),
          if (challenge.isComplete)
            Icon(Icons.check_circle_rounded, color: colors.success, size: 20)
          else
            Icon(Icons.circle_outlined, color: colors.border, size: 20),
        ],
      ),
    );
  }
}

class ChallengeImage extends StatelessWidget {
  const ChallengeImage({super.key, required this.source, this.fit = BoxFit.cover});

  final String? source;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final value = source;
    if (value == null || value.isEmpty) {
      return ColoredBox(
        color: context.colors.background,
        child: Icon(Icons.image_rounded, color: context.colors.muted),
      );
    }
    if (value.startsWith('data:')) {
      final comma = value.indexOf(',');
      if (comma == -1) {
        return const SizedBox.shrink();
      }
      try {
        return Image.memory(
          base64Decode(value.substring(comma + 1)),
          fit: fit,
          errorBuilder: (_, _, _) => const Icon(Icons.broken_image_rounded),
        );
      } catch (_) {
        return const Icon(Icons.broken_image_rounded);
      }
    }
    return Image.network(
      value,
      fit: fit,
      errorBuilder: (_, _, _) => const Icon(Icons.broken_image_rounded),
    );
  }
}

class _PromptSheet extends ConsumerStatefulWidget {
  const _PromptSheet();

  @override
  ConsumerState<_PromptSheet> createState() => _PromptSheetState();
}

class _PromptSheetState extends ConsumerState<_PromptSheet> {
  final _prompt = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _prompt.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final prompt = _prompt.text.trim();
    if (prompt.isEmpty) {
      showAppSnackBar(context, 'Write a prompt first.', isError: true);
      return;
    }
    setState(() => _saving = true);
    final now = DateTime.now();
    final challenge = PhotoChallenge(
      id: '${now.microsecondsSinceEpoch}',
      prompt: prompt,
      weekKey: weekKeyOf(now),
      createdAt: now,
    );
    try {
      await ref.read(backendProvider).savePhotoChallenge(challenge);
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
      title: 'Custom photo prompt',
      subtitle: 'Add a prompt for this week.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _prompt,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'What should you capture?',
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          GradientButton(
            label: 'Add prompt',
            icon: Icons.add_a_photo_rounded,
            loading: _saving,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
