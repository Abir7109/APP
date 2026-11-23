import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/ids.dart';
import '../../core/utils/ui.dart';
import '../../core/widgets/app_illustration.dart';
import '../../core/widgets/app_pill.dart';
import '../../core/widgets/app_sheet.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/hero_card.dart';
import '../../core/widgets/staggered_enter.dart';
import '../../data/models/models.dart';
import '../../data/seed/seed_content.dart';
import '../../state/data_providers.dart';
import '../../state/session_provider.dart';

class CouponsScreen extends ConsumerWidget {
  const CouponsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final coupons = ref.watch(couponsProvider).value ?? const <Coupon>[];
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
          StaggeredEnter(
            index: 0,
            child: HeroCard(
              backgroundColor: colors.softPink,
              art: AppArt.coupons,
              artSize: 96,
              eyebrow: 'Coupons',
              title: 'Little acts of love, ready to redeem.',
              subtitle:
                  '${active.length} coupon${active.length == 1 ? '' : 's'} waiting.',
            ),
          ),
          if (active.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xxl),
            Text('Ready to redeem', style: context.texts.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            for (var index = 0; index < active.length; index++) ...[
              StaggeredEnter(
                index: index + 1,
                child: _CouponTicket(
                  coupon: active[index],
                  author: active[index].createdBy == session.myId
                      ? 'From you'
                      : 'From ${session.partnerName}',
                  onRedeem: () => _redeem(context, ref, active[index]),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
          if (redeemed.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xxl),
            Text('Redeemed', style: context.texts.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            for (final coupon in redeemed) ...[
              _CouponTicket(
                coupon: coupon,
                author: coupon.createdBy == session.myId
                    ? 'From you'
                    : 'From ${session.partnerName}',
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
          if (coupons.isEmpty)
            EmptyState(
              art: AppArt.coupons,
              title: 'No coupons yet',
              message: 'Offer one small thing they can cash in.',
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

class _CouponTicket extends StatelessWidget {
  const _CouponTicket({
    required this.coupon,
    required this.author,
    this.onRedeem,
  });

  final Coupon coupon;
  final String author;
  final VoidCallback? onRedeem;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final redeemed = coupon.redeemed;
    final shape = BorderRadius.circular(AppRadii.lg);
    return Container(
      decoration: BoxDecoration(
        color: dark ? colors.cardAlt : colors.card,
        borderRadius: shape,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                IllustrationTile(
                  AppArt.coupons,
                  size: 44,
                  background: redeemed ? colors.background : colors.softPink,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coupon.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.texts.titleSmall?.copyWith(
                          decoration:
                              redeemed ? TextDecoration.lineThrough : null,
                          color: redeemed ? colors.muted : colors.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        author,
                        style: context.texts.bodySmall?.copyWith(
                          color: colors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (redeemed)
                  Icon(Icons.check_circle_rounded,
                      color: colors.success, size: 22),
              ],
            ),
          ),
          SizedBox(
            height: 18,
            child: CustomPaint(
              painter: _TicketCutPainter(
                background: colors.background,
                line: colors.border,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    redeemed && coupon.redeemedAt != null
                        ? 'Redeemed ${relativeDate(coupon.redeemedAt!)}'
                        : 'A small promise, just for them.',
                    style: context.texts.bodySmall?.copyWith(
                      color: colors.muted,
                    ),
                  ),
                ),
                if (!redeemed)
                  FilledButton(
                    onPressed: onRedeem,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 44),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                      ),
                      textStyle: context.texts.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Text('Redeem'),
                  )
                else
                  AppPill(
                    label: 'Used',
                    color: colors.success,
                    icon: Icons.check_rounded,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketCutPainter extends CustomPainter {
  const _TicketCutPainter({required this.background, required this.line});

  final Color background;
  final Color line;

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    const notchRadius = 9.0;
    final notchPaint = Paint()..color = background;
    canvas.drawCircle(Offset(0, centerY), notchRadius, notchPaint);
    canvas.drawCircle(Offset(size.width, centerY), notchRadius, notchPaint);

    final dashPaint = Paint()
      ..color = line
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    const dashWidth = 5.0;
    const dashSpace = 4.0;
    var x = notchRadius + 4;
    final end = size.width - notchRadius - 4;
    while (x < end) {
      canvas.drawLine(
        Offset(x, centerY),
        Offset((x + dashWidth).clamp(x, end), centerY),
        dashPaint,
      );
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_TicketCutPainter oldDelegate) =>
      oldDelegate.background != background || oldDelegate.line != line;
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
      art: AppArt.coupons,
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
