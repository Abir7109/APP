import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_illustration.dart';
import '../../core/widgets/gradient_button.dart';
import '../../data/models/models.dart';
import '../../services/notification_service.dart';
import '../../state/live_providers.dart';
import '../../state/session_provider.dart';

class LiveSessionHost extends ConsumerStatefulWidget {
  const LiveSessionHost({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<LiveSessionHost> createState() => _LiveSessionHostState();
}

class _LiveSessionHostState extends ConsumerState<LiveSessionHost>
    with WidgetsBindingObserver {
  StreamSubscription<LiveNotificationEvent>? _notificationEvents;
  StreamSubscription<LivePoint>? _positionUpdates;
  OverlayEntry? _promptEntry;
  String? _promptKey;
  String? _notifiedKey;
  LiveSession? _session;
  bool _resumed = true;
  bool _initialized = false;
  bool _promptRetryScheduled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialized = true;
    Future.microtask(_prepareNotifications);
  }

  Future<void> _prepareNotifications() async {
    if (!_initialized) return;
    final notifications = ref.read(notificationServiceProvider);
    await notifications.initialize();
    _notificationEvents = notifications.events.listen(_onNotificationEvent);
    final launch = notifications.takeLaunchEvent();
    if (launch != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _onNotificationEvent(launch);
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _resumed = state == AppLifecycleState.resumed;
    if (_resumed) {
      _syncPrompt(_session);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _notificationEvents?.cancel();
    _positionUpdates?.cancel();
    _promptEntry?.remove();
    _promptEntry = null;
    _initialized = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<LiveSession?>>(liveSessionProvider, (previous, next) {
      final session = next.value;
      if (session == null && previous?.value == null) return;
      _onSessionChanged(session);
    });

    ref.listen<LiveDistanceState>(liveDistanceControllerProvider,
        (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        _showError(next.error!, canOpenSettings: next.errorCanOpenSettings);
        ref.read(liveDistanceControllerProvider.notifier).clearError();
      }
    });

    return widget.child;
  }

  void _onSessionChanged(LiveSession? session) {
    _session = session;
    final myId = ref.read(sessionProvider).myId;
    final incoming = session != null &&
        session.isPending &&
        !session.requestedBy(myId) &&
        !session.isExpired;

    _syncLocation(session);
    _syncPrompt(session);

    if (incoming) {
      if (!_resumed) _showNotification(session);
    } else {
      _notifiedKey = null;
      unawaited(
        ref.read(notificationServiceProvider).cancelLiveRequest(),
      );
    }
  }

  void _syncLocation(LiveSession? session) {
    final active = session?.isAllowed ?? false;
    if (active) {
      _positionUpdates ??= ref
          .read(locationServiceProvider)
          .watch()
          .listen(
            (point) => ref
                .read(liveDistanceControllerProvider.notifier)
                .sharePoint(point),
            onError: (_) {},
          );
    } else {
      _positionUpdates?.cancel();
      _positionUpdates = null;
    }
  }

  void _syncPrompt(LiveSession? session) {
    final myId = ref.read(sessionProvider).myId;
    final incoming = session != null &&
        session.isPending &&
        !session.requestedBy(myId) &&
        !session.isExpired;
    if (!incoming) {
      _removePrompt();
      return;
    }
    if (!_resumed) return;
    final key = '${session.requesterId}:${session.createdAt.toIso8601String()}';
    if (_promptEntry != null && _promptKey == key) return;
    _removePrompt();
    final overlay = _rootOverlay();
    if (overlay == null) {
      if (_promptRetryScheduled) return;
      _promptRetryScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _promptRetryScheduled = false;
        if (mounted) _syncPrompt(session);
      });
      return;
    }
    _promptKey = key;
    _promptEntry = OverlayEntry(
      builder: (context) => _LiveRequestOverlay(session: session),
    );
    overlay.insert(_promptEntry!);
  }

  OverlayState? _rootOverlay() {
    final router = ref.read(routerProvider);
    return router.routerDelegate.navigatorKey.currentState?.overlay;
  }

  void _removePrompt() {
    _promptEntry?.remove();
    _promptEntry = null;
    _promptKey = null;
  }

  Future<void> _showNotification(LiveSession session) async {
    final key = '${session.requesterId}:${session.createdAt.toIso8601String()}';
    if (_notifiedKey == key) return;
    _notifiedKey = key;
    await ref
        .read(notificationServiceProvider)
        .showLiveRequest(requesterName: session.requesterName);
  }

  Future<void> _onNotificationEvent(LiveNotificationEvent event) async {
    final controller = ref.read(liveDistanceControllerProvider.notifier);
    if (event.action == LiveNotificationAction.allow) {
      final allowed = await controller.allowIncoming();
      if (allowed && mounted) {
        _removePrompt();
        _goToLive();
      }
      return;
    }
    if (event.action == LiveNotificationAction.deny) {
      await controller.denyIncoming();
      _removePrompt();
      return;
    }
    _goToLive();
  }

  void _goToLive() {
    if (!mounted) return;
    final router = ref.read(routerProvider);
    final path = router.routeInformationProvider.value.uri.path;
    if (path != '/live') router.push('/live');
  }

  void _showError(String message, {required bool canOpenSettings}) {
    if (!mounted) return;
    final router = ref.read(routerProvider);
    final navigatorContext =
        router.routerDelegate.navigatorKey.currentContext;
    final messenger = ScaffoldMessenger.maybeOf(context) ??
        (navigatorContext == null
            ? null
            : ScaffoldMessenger.maybeOf(navigatorContext));
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          action: canOpenSettings
              ? SnackBarAction(
                  label: 'Settings',
                  onPressed: () =>
                      ref.read(locationServiceProvider).openAppSettings(),
                )
              : null,
        ),
      );
  }
}

class _LiveRequestOverlay extends ConsumerWidget {
  const _LiveRequestOverlay({required this.session});

  final LiveSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final busy = ref.watch(
      liveDistanceControllerProvider.select((state) => state.busy),
    );
    final controller = ref.read(liveDistanceControllerProvider.notifier);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            0,
          ),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: -1, end: 0),
            duration: AppDurations.pop,
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, value * 36),
                child: Opacity(opacity: 1 + value, child: child),
              );
            },
            child: AppCard(
              shadow: true,
              gradient: AppGradients.soft(colors),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppIllustration(AppArt.mascots, size: 58),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${session.requesterName} misses you',
                              style: context.texts.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Allow live distance? We will show a little map '
                              'for 15 minutes, then it turns off.',
                              style: context.texts.bodySmall?.copyWith(
                                color: colors.muted,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: GradientButton(
                          label: 'Allow',
                          icon: Icons.favorite_rounded,
                          loading: busy,
                          height: 48,
                          onPressed: busy
                              ? null
                              : () async {
                                  final allowed =
                                      await controller.allowIncoming();
                                  if (allowed && context.mounted) {
                                    ref.read(routerProvider).push('/live');
                                  }
                                },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      TextButton(
                        onPressed: busy
                            ? null
                            : () => controller.denyIncoming(),
                        child: const Text('Not now'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
