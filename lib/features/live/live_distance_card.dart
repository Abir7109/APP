import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/press_scale.dart';
import '../../data/models/models.dart';
import '../../state/live_providers.dart';
import '../../state/session_provider.dart';

class LiveDistanceCard extends ConsumerWidget {
  const LiveDistanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(liveSessionProvider).value;
    final sessionState = ref.watch(sessionProvider);
    final busy = ref.watch(
      liveDistanceControllerProvider.select((state) => state.busy),
    );
    final myId = sessionState.myId;
    final partnerName = sessionState.partnerName;
    final active = session?.isAllowed ?? false;
    final incoming = session?.isPending == true &&
        session?.requestedBy(myId) == false &&
        !(session?.isExpired ?? false);

    final status = _statusFor(
      session: session,
      myId: myId,
      partnerName: partnerName,
    );
    final title = active
        ? _activeTitle(session, myId)
        : incoming
            ? '$partnerName misses you'
            : 'See how close you are';

    return PressScale(
      enabled: !busy,
      onTap: busy
          ? null
          : () => _open(context, ref, session: session, incoming: incoming),
      child: Semantics(
        button: true,
        label: 'Live distance. $status',
        child: Container(
          width: double.infinity,
          height: 192,
          decoration: BoxDecoration(
            gradient: AppGradients.lilac,
            borderRadius: BorderRadius.circular(AppRadii.xl),
            boxShadow: Theme.of(context).brightness == Brightness.light
                ? [
                    BoxShadow(
                      color: const Color(0xFF9B51E0).withValues(alpha: 0.25),
                      blurRadius: 28,
                      offset: const Offset(0, 14),
                    ),
                  ]
                : null,
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            children: [
              const Positioned.fill(child: CustomPaint(painter: _MapLines())),
              Positioned(
                right: -18,
                top: -20,
                child: Icon(
                  Icons.favorite_rounded,
                  size: 150,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.near_me_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'LIVE DISTANCE',
                          style: context.texts.labelMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.4,
                          ),
                        ),
                        const Spacer(),
                        if (busy)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        else if (active)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'LIVE',
                                  style: context.texts.labelSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      title,
                      style: context.texts.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      status,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.texts.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        _MiniHeart(color: Colors.white),
                        Transform.translate(
                          offset: const Offset(-6, 0),
                          child: _MiniHeart(
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          active
                              ? 'Tap to open the map'
                              : incoming
                                  ? 'Tap to allow'
                                  : 'Tap to share a little map',
                          style: context.texts.labelMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _open(
    BuildContext context,
    WidgetRef ref, {
    required LiveSession? session,
    required bool incoming,
  }) async {
    if (session != null &&
        (session.isPending || session.isAllowed || session.isDenied)) {
      if (!session.isDenied) {
        context.push('/live');
        return;
      }
    }
    if (incoming) {
      context.push('/live');
      return;
    }
    final asked =
        await ref.read(liveDistanceControllerProvider.notifier).requestLive();
    if (asked && context.mounted) context.push('/live');
  }

  String _activeTitle(LiveSession? session, String myId) {
    if (session == null || !session.isAllowed) return 'You are close by';
    final mine = session.pointFor(myId);
    LivePoint? partner;
    for (final entry in session.points.entries) {
      if (entry.key != myId && entry.value.isValid) {
        partner = entry.value;
        break;
      }
    }
    if (mine == null || partner == null) return 'Live right now';
    final meters = const Distance().as(
      LengthUnit.Meter,
      LatLng(mine.latitude, mine.longitude),
      LatLng(partner.latitude, partner.longitude),
    );
    if (meters < 1000) return 'You are close by';
    if (meters < 50000) return 'Not far at all';
    if (meters < 500000) return 'A little far apart';
    return 'Far apart, close at heart';
  }

  String _statusFor({
    required LiveSession? session,
    required String myId,
    required String partnerName,
  }) {
    if (session == null) return 'A private map for just the two of you';
    if (session.isAllowed) {
      final mine = session.pointFor(myId);
      LivePoint? partner;
      for (final entry in session.points.entries) {
        if (entry.key != myId && entry.value.isValid) {
          partner = entry.value;
          break;
        }
      }
      if (mine != null && partner != null) {
        final meters = const Distance().as(
          LengthUnit.Meter,
          LatLng(mine.latitude, mine.longitude),
          LatLng(partner.latitude, partner.longitude),
        );
        if (meters < 100) return 'Right next to you · live now';
        if (meters < 1000) return '${meters.round()} m apart · live now';
        return '${(meters / 1000).toStringAsFixed(1)} km apart · live now';
      }
      return 'Live right now';
    }
    if (session.isPending) {
      if (session.isExpired) return 'The request expired · ask again';
      if (session.requestedBy(myId)) {
        return 'Waiting for $partnerName to allow';
      }
      return 'Allow to see each other for a few minutes';
    }
    if (session.isDenied) return 'Not this time · ask again';
    return 'A private map for just the two of you';
  }
}

class _MiniHeart extends StatelessWidget {
  const _MiniHeart({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.22),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.7), width: 1.5),
      ),
      child: Icon(Icons.favorite_rounded, size: 13, color: color),
    );
  }
}

class _MapLines extends CustomPainter {
  const _MapLines();

  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = Colors.white.withValues(alpha: 0.13);
    final strongRoad = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..color = Colors.white.withValues(alpha: 0.16);

    final paths = [
      ui.Path()
        ..moveTo(-20, size.height * 0.78)
        ..quadraticBezierTo(
          size.width * 0.28,
          size.height * 0.62,
          size.width * 0.56,
          size.height * 0.72,
        )
        ..quadraticBezierTo(
          size.width * 0.82,
          size.height * 0.82,
          size.width + 20,
          size.height * 0.66,
        ),
      ui.Path()
        ..moveTo(size.width * 0.18, -10)
        ..quadraticBezierTo(
          size.width * 0.24,
          size.height * 0.4,
          size.width * 0.48,
          size.height * 0.58,
        )
        ..quadraticBezierTo(
          size.width * 0.68,
          size.height * 0.72,
          size.width * 0.72,
          size.height + 10,
        ),
      ui.Path()
        ..moveTo(size.width * 0.58, -10)
        ..lineTo(size.width * 0.62, size.height + 10),
      ui.Path()
        ..moveTo(-10, size.height * 0.36)
        ..lineTo(size.width + 10, size.height * 0.3),
    ];
    for (final path in paths) {
      canvas.drawPath(path, road);
    }

    final diagonal = ui.Path()
      ..moveTo(size.width * 0.18, size.height * 0.74)
      ..quadraticBezierTo(
        size.width * 0.42,
        size.height * 0.6,
        size.width * 0.7,
        size.height * 0.34,
      );
    _drawDashed(canvas, diagonal, strongRoad);

    final point = Paint()..color = Colors.white.withValues(alpha: 0.22);
    canvas.drawCircle(
      Offset(size.width * 0.18, size.height * 0.74),
      8,
      point,
    );
    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.34),
      8,
      point,
    );
  }

  void _drawDashed(Canvas canvas, ui.Path path, Paint paint) {
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = math.min(distance + 9, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + 7;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
