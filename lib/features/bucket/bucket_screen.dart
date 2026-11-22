import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
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
import 'date_idea_picker.dart';

class BucketScreen extends ConsumerStatefulWidget {
  const BucketScreen({super.key});

  @override
  ConsumerState<BucketScreen> createState() => _BucketScreenState();
}

class _BucketScreenState extends ConsumerState<BucketScreen> {
  BucketCategory? _filter;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final items = ref.watch(bucketItemsProvider).value ?? const <BucketItem>[];
    final filtered = _filter == null
        ? items
        : items.where((item) => item.category == _filter).toList();
    final open = filtered.where((item) => !item.done).toList();
    final done = filtered.where((item) => item.done).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bucket list'),
        actions: [
          IconButton(
            tooltip: 'Surprise date',
            onPressed: () => showDateIdeaPicker(context, _dateIdeas(open)),
            icon: const Icon(Icons.casino_rounded),
          ),
          IconButton(
            tooltip: 'Add an idea',
            onPressed: () => _showEditor(context, ref),
            icon: const Icon(Icons.add_rounded),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: ChoiceChip(
                    label: const Text('All'),
                    selected: _filter == null,
                    onSelected: (_) => setState(() => _filter = null),
                  ),
                ),
                for (final category in BucketCategory.values)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: ChoiceChip(
                      label: Text(category.label),
                      selected: _filter == category,
                      onSelected: (_) => setState(() => _filter = category),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? EmptyState(
                    icon: Icons.explore_rounded,
                    title: 'Your list is wide open',
                    message:
                        'Add the places, meals, and small adventures you want to share.',
                    actionLabel: 'Add an idea',
                    onAction: () => _showEditor(context, ref),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.md,
                      AppSpacing.xl,
                      AppSpacing.xxxl,
                    ),
                    children: [
                      if (open.isNotEmpty) ...[
                        Text(
                          'TO DO · ${open.length}',
                          style: context.texts.labelSmall?.copyWith(
                            color: colors.muted,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        for (final item in open) ...[
                          _BucketCard(
                            item: item,
                            onToggle: () => _toggle(ref, item),
                            onEdit: () => _showEditor(context, ref, item: item),
                            onDelete: () => _delete(context, ref, item),
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                      ],
                      if (done.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'DONE · ${done.length}',
                          style: context.texts.labelSmall?.copyWith(
                            color: colors.muted,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        for (final item in done) ...[
                          _BucketCard(
                            item: item,
                            onToggle: () => _toggle(ref, item),
                            onEdit: () => _showEditor(context, ref, item: item),
                            onDelete: () => _delete(context, ref, item),
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  List<BucketItem> _dateIdeas(List<BucketItem> open) {
    final ideas = open
        .where((item) => item.category == BucketCategory.dateIdea)
        .toList();
    return ideas.isEmpty ? open : ideas;
  }

  Future<void> _toggle(WidgetRef ref, BucketItem item) async {
    try {
      await ref.read(backendProvider).saveBucketItem(
            item.copyWith(
              done: !item.done,
              completedAt: item.done ? null : DateTime.now(),
              clearCompletedAt: item.done,
            ),
          );
    } catch (error) {
      if (mounted) showAppSnackBar(context, friendlyError(error), isError: true);
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    BucketItem item,
  ) async {
    final confirmed = await confirmAction(
      context,
      title: 'Remove this idea?',
      message: '“${item.title}” will be removed for both of you.',
      confirmLabel: 'Remove',
      destructive: true,
    );
    if (!confirmed) return;
    try {
      await ref.read(backendProvider).deleteBucketItem(item.id);
    } catch (error) {
      if (context.mounted) {
        showAppSnackBar(context, friendlyError(error), isError: true);
      }
    }
  }

  Future<void> _showEditor(
    BuildContext context,
    WidgetRef ref, {
    BucketItem? item,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _BucketSheet(item: item),
    );
  }
}

class _BucketCard extends StatelessWidget {
  const _BucketCard({
    required this.item,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final BucketItem item;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
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
                color: item.done ? colors.success : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: item.done ? colors.success : colors.border,
                  width: 1.6,
                ),
              ),
              child: item.done
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
                  item.title,
                  style: context.texts.titleSmall?.copyWith(
                    decoration: item.done ? TextDecoration.lineThrough : null,
                    color: item.done ? colors.muted : colors.text,
                  ),
                ),
                if (item.note.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    item.note,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.texts.bodySmall?.copyWith(
                      color: colors.muted,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                AppPill(
                  label: item.category.label,
                  color: _categoryColor(colors, item.category),
                  icon: _categoryIcon(item.category),
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

class _BucketSheet extends ConsumerStatefulWidget {
  const _BucketSheet({this.item});

  final BucketItem? item;

  @override
  ConsumerState<_BucketSheet> createState() => _BucketSheetState();
}

class _BucketSheetState extends ConsumerState<_BucketSheet> {
  late final TextEditingController _title;
  late final TextEditingController _note;
  late BucketCategory _category;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.item?.title ?? '');
    _note = TextEditingController(text: widget.item?.note ?? '');
    _category = widget.item?.category ?? BucketCategory.someday;
  }

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty) {
      showAppSnackBar(context, 'Give your idea a name.', isError: true);
      return;
    }
    setState(() => _saving = true);
    final session = ref.read(sessionProvider);
    final now = DateTime.now();
    final item = widget.item?.copyWith(
          title: title,
          note: _note.text.trim(),
          category: _category,
        ) ??
        BucketItem(
          id: newId(),
          title: title,
          note: _note.text.trim(),
          category: _category,
          createdBy: session.myId,
          createdAt: now,
        );
    try {
      await ref.read(backendProvider).saveBucketItem(item);
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
      title: widget.item == null ? 'Add an idea' : 'Edit idea',
      subtitle: 'A little something to look forward to.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _title,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'What do you want to do?'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _note,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Category', style: context.texts.labelMedium),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final category in BucketCategory.values)
                ChoiceChip(
                  label: Text(category.label),
                  selected: _category == category,
                  onSelected: (_) => setState(() => _category = category),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          GradientButton(
            label: widget.item == null ? 'Add to our list' : 'Save changes',
            loading: _saving,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}

IconData _categoryIcon(BucketCategory category) => switch (category) {
      BucketCategory.adventure => Icons.terrain_rounded,
      BucketCategory.food => Icons.restaurant_rounded,
      BucketCategory.travel => Icons.flight_takeoff_rounded,
      BucketCategory.cozy => Icons.weekend_rounded,
      BucketCategory.dateIdea => Icons.local_cafe_rounded,
      BucketCategory.someday => Icons.auto_awesome_rounded,
    };

Color _categoryColor(AppColors colors, BucketCategory category) =>
    switch (category) {
      BucketCategory.adventure => colors.success,
      BucketCategory.food => colors.warning,
      BucketCategory.travel => colors.info,
      BucketCategory.cozy => colors.tintDarker,
      BucketCategory.dateIdea => colors.primary,
      BucketCategory.someday => colors.muted,
    };
