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
import '../../data/seed/seed_content.dart';
import '../../state/data_providers.dart';
import '../../state/session_provider.dart';

class CouponsScreen extends ConsumerWidget {
  const CouponsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final coupons =
        ref.watch(couponsProvider).value ?? const <Coupon>[];
    final active = coupons.where((coupon) => !coupon.redeemed).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final redeemed = coupons.where((coupon) => coupon.redeemed).toList()
      ..sort((a, b) => (b.redeemedAt ?? b.createdAt)
          .compareTo(a.redeemedAt ?? a.createdAt));
    final session = ref.watch(sessionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kindness coupons'),
        actions: [
          IconButton(
            tooltip: 'Create a coupon',
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
            gradient: AppGradients.brand,
            borderColor: Colors.transparent,
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.confirmation_number_rounded,
                  color: Colors.white,
                  size: 30,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Little acts of love,\nready to redeem.',
                  style: context.texts.headlineMedium?.copyWith(
                    color: Colors.white,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${active.length} coupon${active.length == 1 ? '' : 's'} waiting.',
                  style: context.texts.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
              ],
            ),
          ),
          if (active.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xxl),
            Text(
              'READY TO REDEEM',
              style: context.texts.labelSmall?.copyWith(
                color: colors.muted,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final coupon in active) ...[
              _CouponCard(
                coupon: coupon,
                author: coupon.createdBy == session.myId
                    ? 'From you'
                    : 'From ${session.partnerName}',
                onRedeem: () => _redeem(context, ref, coupon),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
          if (redeemed.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xxl),
            Text(
              'REDEEMED',
              style: context.texts.labelSmall?.copyWith(
                color: colors.muted,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final coupon in redeemed) ...[
              _CouponCard(
                coupon: coupon,
                author: coupon.createdBy == session.myId
                    ? 'From you'
                    : 'From ${session.partnerName}',
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
          if (coupons.isEmpty)
            EmptyState(
              icon: Icons.confirmation_number_rounded,
              title: 'No coupons yet',
              message:
                  'Offer something small and specific: breakfast, a massage, one phone-free hour.',
              actionLabel: 'Create a coupon',
              onAction: () => _showEditor(context),
            ),
        ],
      ),
    );
  }

  Future<void> _redeem(
    BuildContext context,
    WidgetRef ref,
    Coupon coupon,
  ) async {
    final confirmed = await confirmAction(
      context,
      title: 'Redeem this coupon?',
      message: '“${coupon.title}” will be marked as used.',
      confirmLabel: 'Redeem',
    );
    if (!confirmed) return;
    try {
      await ref.read(backendProvider).redeemCoupon(coupon.id);
      if (context.mounted) {
        showAppSnackBar(context, 'Coupon redeemed. Enjoy it.');
      }
    } catch (error) {
      if (context.mounted) {
        showAppSnackBar(context, friendlyError(error), isError: true);
      }
    }
  }

  Future<void> _showEditor(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _CouponSheet(),
    );
  }
}

class _CouponCard extends StatelessWidget {
  const _CouponCard({required this.coupon, required this.author, this.onRedeem});

  final Coupon coupon;
  final String author;
  final VoidCallback? onRedeem;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final redeemed = coupon.redeemed;
    return AppCard(
      borderColor: redeemed ? colors.border : colors.primary.withValues(alpha: 0.35),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SoftIcon(
            icon: redeemed
                ? Icons.check_rounded
                : Icons.confirmation_number_rounded,
            color: redeemed ? colors.success : colors.primary,
            size: 48,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coupon.title,
                  style: context.texts.titleSmall?.copyWith(
                    decoration: redeemed ? TextDecoration.lineThrough : null,
                    color: redeemed ? colors.muted : colors.text,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  author,
                  style: context.texts.bodySmall?.copyWith(color: colors.muted),
                ),
                if (redeemed && coupon.redeemedAt != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  AppPill(
                    label: 'Redeemed ${relativeDate(coupon.redeemedAt!)}',
                    color: colors.success,
                    icon: Icons.check_rounded,
                  ),
                ],
              ],
            ),
          ),
          if (!redeemed)
            TextButton(
              onPressed: onRedeem,
              child: const Text('Redeem'),
            ),
        ],
      ),
    );
  }
}

class _CouponSheet extends ConsumerStatefulWidget {
  const _CouponSheet();

  @override
  ConsumerState<_CouponSheet> createState() => _CouponSheetState();
}

class _CouponSheetState extends ConsumerState<_CouponSheet> {
  final _title = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty) {
      showAppSnackBar(context, 'Name your coupon first.', isError: true);
      return;
    }
    setState(() => _saving = true);
    final session = ref.read(sessionProvider);
    final coupon = Coupon(
      id: newId(),
      title: title,
      createdBy: session.myId,
      createdAt: DateTime.now(),
    );
    try {
      await ref.read(backendProvider).saveCoupon(coupon);
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
    final colors = context.colors;
    return AppSheet(
      title: 'Create a coupon',
      subtitle: 'A small promise your partner can cash in.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _title,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'What are you offering?',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Need an idea?',
            style: context.texts.labelSmall?.copyWith(color: colors.muted),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final idea in SeedContent.couponIdeas)
                ActionChip(
                  label: Text(idea),
                  onPressed: () => _title.text = idea,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          GradientButton(
            label: 'Offer this coupon',
            icon: Icons.favorite_rounded,
            loading: _saving,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
