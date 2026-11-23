import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_illustration.dart';
import '../../core/widgets/app_pill.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/soft_icon.dart';
import '../../data/models/models.dart';
import '../../state/live_providers.dart';
import '../../state/session_provider.dart';

class LiveDistanceScreen extends ConsumerWidget {
  const LiveDistanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(liveSessionProvider);
    final session = sessionAsync.value;
    final busy = ref.watch(
      liveDistanceControllerProvider.select((state) => state.busy),
    );
    final sessionState = ref.watch(sessionProvider);
    final myId = sessionState.myId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live distance'),
        actions: [
          if (session?.isAllowed ?? false)
            IconButton(
              tooltip: 'End live distance',
              onPressed: busy
                  ? null
                  : () => ref
                      .read(liveDistanceControllerProvider.notifier)
                      .endLive(),
              icon: const Icon(Icons.link_off_rounded),
            ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: sessionAsync.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(context, ref, session, myId, sessionState),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    LiveSession? session,
    String myId,
    SessionState sessionState,
  ) {
    if (session == null) {
      return _IdleState(session: sessionState);
    }
    if (session.isPending) {
      if (session.isExpired) {
        return _SoftState(
          icon: Icons.timer_off_rounded,
          title: 'That request expired',
          message: 'No rush. Ask again when the moment feels right.',
          actionLabel: 'Ask again',
          onAction: () =>
              ref.read(liveDistanceControllerProvider.notifier).requestLive(),
        );
      }
      if (session.requestedBy(myId)) {
        return _WaitingState(
          session: session,
          partnerName: sessionState.partnerName,
        );
      }
      return _IncomingState(session: session);
    }
    if (session.isAllowed) {
      final mine = session.pointFor(myId);
      final partner = _partnerPoint(session, myId);
      final expired = session.expiresAt != null &&
          !DateTime.now().isBefore(session.expiresAt!);
      if (mine != null && partner != null && !expired) {
        return _ActiveLiveView(
          session: session,
          mine: mine,
          partner: partner,
          myName: sessionState.myName,
          partnerName: sessionState.partnerName,
        );
      }
      return _SoftState(
        icon: expired ? Icons.timer_off_rounded : Icons.sync_rounded,
        title: expired ? 'This live moment ended' : 'Finding you both',
        message: expired
            ? 'Live distance turns off after 15 minutes. Start a new one anytime.'
            : 'The map will appear as soon as both locations arrive.',
        actionLabel: expired ? 'Ask again' : 'End live distance',
        onAction: expired
            ? () =>
                ref.read(liveDistanceControllerProvider.notifier).requestLive()
            : () =>
                ref.read(liveDistanceControllerProvider.notifier).endLive(),
      );
    }
    return _SoftState(
      icon: session.isDenied
          ? Icons.favorite_border_rounded
          : Icons.link_off_rounded,
      title: session.isDenied ? 'Not this time' : 'Live distance ended',
      message: session.isDenied
          ? 'Your person said not now. Give them a little space, then ask again.'
          : 'Your locations are private again. Start a new moment whenever you like.',
      actionLabel: 'Ask again',
      onAction: () =>
          ref.read(liveDistanceControllerProvider.notifier).requestLive(),
    );
  }

  LivePoint? _partnerPoint(LiveSession session, String myId) {
    for (final entry in session.points.entries) {
      if (entry.key != myId && entry.value.isValid) return entry.value;
    }
    return null;
  }
}

class _IdleState extends ConsumerWidget {
  const _IdleState({required this.session});

  final SessionState session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final busy = ref.watch(
      liveDistanceControllerProvider.select((state) => state.busy),
    );
    final controller = ref.read(liveDistanceControllerProvider.notifier);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xxxl,
      ),
      children: [
        const Center(
          child: AppIllustration(AppArt.mascots, size: 150),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'A little map of the two of you',
          textAlign: TextAlign.center,
          style: context.texts.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Ask ${session.partnerName} to share locations for a few minutes. '
          'You will see both hearts, the space between them, and nothing else.',
          textAlign: TextAlign.center,
          style: context.texts.bodyMedium?.copyWith(
            color: colors.muted,
            height: 1.45,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        GradientButton(
          label: 'Ask ${session.partnerName} to share',
          icon: Icons.favorite_rounded,
          loading: busy,
          onPressed: busy ? null : () => controller.requestLive(),
        ),
        const SizedBox(height: AppSpacing.md),
        _PrivacyNote(),
        if (session.isDemo) ...[
          const SizedBox(height: AppSpacing.xxl),
          OutlinedButton.icon(
            onPressed: busy ? null : () => controller.previewIncoming(),
            icon: const Icon(Icons.notifications_active_outlined),
            label: const Text('Preview an incoming request'),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Demo mode only. This is how the little ping feels on the other phone.',
            textAlign: TextAlign.center,
            style: context.texts.bodySmall?.copyWith(color: colors.muted),
          ),
        ],
      ],
    );
  }
}

class _WaitingState extends ConsumerWidget {
  const _WaitingState({required this.session, required this.partnerName});

  final LiveSession session;
  final String partnerName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xxl,
        AppSpacing.xl,
        AppSpacing.xxxl,
      ),
      children: [
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.softPink,
                ),
              ),
              const AppIllustration(AppArt.mascots, size: 120),
              const Positioned(
                right: 18,
                top: 18,
                child: _PulseDot(),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Waiting for $partnerName',
          textAlign: TextAlign.center,
          style: context.texts.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'We sent a tiny ping. Live distance starts the moment they allow it.',
          textAlign: TextAlign.center,
          style: context.texts.bodyMedium?.copyWith(
            color: colors.muted,
            height: 1.45,
          ),
        ),
        if (session.expiresAt != null) ...[
          const SizedBox(height: AppSpacing.lg),
          Center(child: _ExpiryCountdown(expiresAt: session.expiresAt!)),
        ],
        const SizedBox(height: AppSpacing.xxl),
        _PrivacyNote(),
        const SizedBox(height: AppSpacing.xl),
        TextButton(
          onPressed: () =>
              ref.read(liveDistanceControllerProvider.notifier).endLive(),
          child: const Text('Cancel request'),
        ),
      ],
    );
  }
}

class _IncomingState extends ConsumerWidget {
  const _IncomingState({required this.session});

  final LiveSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final busy = ref.watch(
      liveDistanceControllerProvider.select((state) => state.busy),
    );
    final controller = ref.read(liveDistanceControllerProvider.notifier);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xxl,
        AppSpacing.xl,
        AppSpacing.xxxl,
      ),
      children: [
        const Center(child: AppIllustration(AppArt.mascots, size: 150)),
        const SizedBox(height: AppSpacing.lg),
        Text(
          '${session.requesterName} misses you',
          textAlign: TextAlign.center,
          style: context.texts.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Allow live distance? We will show a little map for 15 minutes, '
          'then it turns off by itself.',
          textAlign: TextAlign.center,
          style: context.texts.bodyMedium?.copyWith(
            color: colors.muted,
            height: 1.45,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        GradientButton(
          label: 'Allow',
          icon: Icons.favorite_rounded,
          loading: busy,
          onPressed: busy ? null : () => controller.allowIncoming(),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: busy ? null : () => controller.denyIncoming(),
          child: const Text('Not now'),
        ),
        const SizedBox(height: AppSpacing.xxl),
        _PrivacyNote(),
      ],
    );
  }
}

class _ActiveLiveView extends ConsumerWidget {
  const _ActiveLiveView({
    required this.session,
    required this.mine,
    required this.partner,
    required this.myName,
    required this.partnerName,
  });

  final LiveSession session;
  final LivePoint mine;
  final LivePoint partner;
  final String myName;
  final String partnerName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busy = ref.watch(
      liveDistanceControllerProvider.select((state) => state.busy),
    );
    final distance = const Distance().as(
      LengthUnit.Meter,
      LatLng(mine.latitude, mine.longitude),
      LatLng(partner.latitude, partner.longitude),
    );

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.sm,
              AppSpacing.xl,
              0,
            ),
            child: _LiveMap(
              mine: mine,
              partner: partner,
              myName: myName,
              partnerName: partnerName,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: _DistancePanel(
            session: session,
            distanceMeters: distance,
            partner: partner,
            partnerName: partnerName,
            busy: busy,
            onEnd: () =>
                ref.read(liveDistanceControllerProvider.notifier).endLive(),
          ),
        ),
      ],
    );
  }
}

class _LiveMap extends StatefulWidget {
  const _LiveMap({
    required this.mine,
    required this.partner,
    required this.myName,
    required this.partnerName,
  });

  final LivePoint mine;
  final LivePoint partner;
  final String myName;
  final String partnerName;

  @override
  State<_LiveMap> createState() => _LiveMapState();
}

class _LiveMapState extends State<_LiveMap> {
  final MapController _controller = MapController();

  List<LatLng> _latLngs() {
    return [
      LatLng(widget.mine.latitude, widget.mine.longitude),
      LatLng(widget.partner.latitude, widget.partner.longitude),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final points = _latLngs();

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.xl),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: colors.border),
          borderRadius: BorderRadius.circular(AppRadii.xl),
        ),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _controller,
              options: MapOptions(
                initialCenter: points.first,
                initialZoom: 15,
                initialCameraFit: CameraFit.coordinates(
                  coordinates: points,
                  padding: const EdgeInsets.all(68),
                  maxZoom: 16,
                ),
                backgroundColor: colors.softPink,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    (dark ? colors.primary : colors.softPink).withValues(
                      alpha: dark ? 0.12 : 0.28,
                    ),
                    BlendMode.srcATop,
                  ),
                  child: TileLayer(
                    urlTemplate:
                        'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c', 'd'],
                    userAgentPackageName: 'app.youandme.couple',
                    maxNativeZoom: 19,
                  ),
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: points,
                      color: colors.primary,
                      strokeWidth: 4,
                      pattern: StrokePattern.dashed(segments: const [10, 8]),
                      borderStrokeWidth: 6,
                      borderColor: Colors.white.withValues(alpha: 0.75),
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: points.first,
                      width: 66,
                      height: 66,
                      child: _HeartMarker(
                        name: widget.myName,
                        gradient: AppGradients.brand,
                        halo: true,
                      ),
                    ),
                    Marker(
                      point: points.last,
                      width: 66,
                      height: 66,
                      child: _HeartMarker(
                        name: widget.partnerName,
                        gradient: AppGradients.lilac,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              top: AppSpacing.md,
              left: AppSpacing.md,
              child: const _LiveBadge(),
            ),
            Positioned(
              right: AppSpacing.sm,
              bottom: AppSpacing.xs,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.background.withValues(alpha: 0.82),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  child: Text(
                    '© OpenStreetMap · © CARTO',
                    style: context.texts.labelSmall?.copyWith(
                      color: colors.muted,
                      fontSize: 9,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeartMarker extends StatelessWidget {
  const _HeartMarker({
    required this.name,
    required this.gradient,
    this.halo = false,
  });

  final String name;
  final Gradient gradient;
  final bool halo;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Tooltip(
        message: name,
        child: SizedBox(
          width: 66,
          height: 66,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (halo)
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.primary.withValues(alpha: 0.14),
                  ),
                ),
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: gradient,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: colors.shadow,
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: colors.background.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: colors.danger,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'LIVE',
            style: context.texts.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: colors.text,
            ),
          ),
        ],
      ),
    );
  }
}

class _DistancePanel extends StatelessWidget {
  const _DistancePanel({
    required this.session,
    required this.distanceMeters,
    required this.partner,
    required this.partnerName,
    required this.busy,
    required this.onEnd,
  });

  final LiveSession session;
  final double distanceMeters;
  final LivePoint partner;
  final String partnerName;
  final bool busy;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final label = _distanceLabel(distanceMeters);
    final until = session.expiresAt == null
        ? null
        : MaterialLocalizations.of(context).formatTimeOfDay(
            TimeOfDay.fromDateTime(session.expiresAt!),
          );
    final updated = DateTime.now().difference(partner.updatedAt);

    return AppCard(
      shadow: true,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const SoftIcon(icon: Icons.favorite_rounded),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('You & $partnerName', style: context.texts.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      until == null
                          ? 'Live right now'
                          : 'Live until $until · ${_ago(updated)}',
                      style: context.texts.bodySmall?.copyWith(
                        color: colors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              AppPill(
                label: 'LIVE',
                color: colors.danger,
                icon: Icons.circle,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            label,
            style: context.texts.headlineLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: colors.text,
            ),
          ),
          Text(
            'apart right now',
            style: context.texts.bodyMedium?.copyWith(color: colors.muted),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: busy ? null : onEnd,
              icon: const Icon(Icons.link_off_rounded, size: 18),
              label: const Text('End live distance'),
            ),
          ),
        ],
      ),
    );
  }

  static String _distanceLabel(double meters) {
    if (meters < 100) return 'Right next to you';
    if (meters < 1000) return '${meters.round()} m';
    final km = meters / 1000;
    return '${km.toStringAsFixed(km < 10 ? 1 : 0)} km';
  }

  static String _ago(Duration duration) {
    if (duration.inSeconds < 45) return 'just now';
    if (duration.inMinutes < 1) return 'a moment ago';
    if (duration.inMinutes < 60) return '${duration.inMinutes}m ago';
    return '${duration.inHours}h ago';
  }
}

class _SoftState extends StatelessWidget {
  const _SoftState({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xxl,
        AppSpacing.xl,
        AppSpacing.xxxl,
      ),
      children: [
        Center(child: SoftIcon(icon: icon, size: 72)),
        const SizedBox(height: AppSpacing.lg),
        Text(title, textAlign: TextAlign.center, style: context.texts.headlineSmall),
        const SizedBox(height: AppSpacing.sm),
        Text(
          message,
          textAlign: TextAlign.center,
          style: context.texts.bodyMedium?.copyWith(
            color: colors.muted,
            height: 1.45,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        GradientButton(label: actionLabel, onPressed: onAction),
        const SizedBox(height: AppSpacing.md),
        TextButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
          child: const Text('Back home'),
        ),
      ],
    );
  }
}

class _PrivacyNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.lock_outline_rounded, size: 16, color: colors.muted),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            'Only your person sees this. It turns off after 15 minutes, '
            'and either of you can end it sooner.',
            style: context.texts.bodySmall?.copyWith(
              color: colors.muted,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ScaleTransition(
      scale: Tween(begin: 0.82, end: 1.08).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: colors.danger,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
      ),
    );
  }
}

class _ExpiryCountdown extends StatefulWidget {
  const _ExpiryCountdown({required this.expiresAt});

  final DateTime expiresAt;

  @override
  State<_ExpiryCountdown> createState() => _ExpiryCountdownState();
}

class _ExpiryCountdownState extends State<_ExpiryCountdown> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final remaining = widget.expiresAt.difference(DateTime.now());
    final seconds = math.max(0, remaining.inSeconds);
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final rest = (seconds % 60).toString().padLeft(2, '0');
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.softPink,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 16, color: colors.primary),
          const SizedBox(width: 6),
          Text(
            'Expires in $minutes:$rest',
            style: context.texts.bodySmall?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
