import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/ui.dart';
import '../data/models/models.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import 'session_provider.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final liveSessionProvider = StreamProvider<LiveSession?>((ref) {
  final coupleId =
      ref.watch(sessionProvider.select((state) => state.couple?.id));
  if (coupleId == null) return Stream<LiveSession?>.value(null);
  return ref.watch(backendProvider).watchLiveSession();
});

class LiveDistanceState {
  const LiveDistanceState({
    this.busy = false,
    this.error,
    this.errorCanOpenSettings = false,
  });

  final bool busy;
  final String? error;
  final bool errorCanOpenSettings;

  LiveDistanceState copyWith({
    bool? busy,
    String? error,
    bool clearError = false,
    bool? errorCanOpenSettings,
  }) {
    return LiveDistanceState(
      busy: busy ?? this.busy,
      error: clearError ? null : (error ?? this.error),
      errorCanOpenSettings:
          errorCanOpenSettings ?? this.errorCanOpenSettings,
    );
  }
}

class LiveDistanceController extends Notifier<LiveDistanceState> {
  @override
  LiveDistanceState build() => const LiveDistanceState();

  Future<bool> requestLive() async {
    if (state.busy) return false;
    final session = ref.read(sessionProvider);
    if (!session.hasPartner) {
      _fail('Link with your person before sharing live distance.');
      return false;
    }
    state = state.copyWith(busy: true, clearError: true);
    try {
      await ref.read(notificationServiceProvider).ensurePermission();
      final point = await _resolvePoint();
      await ref.read(backendProvider).sendLiveRequest(
        requesterName: session.myName,
        point: point,
      );
      state = state.copyWith(busy: false);
      return true;
    } on LocationUnavailableException catch (error) {
      _fail(error.message, canOpenSettings: error.canOpenSettings);
      return false;
    } catch (error) {
      _fail(friendlyError(error));
      return false;
    }
  }

  Future<bool> allowIncoming() async {
    if (state.busy) return false;
    state = state.copyWith(busy: true, clearError: true);
    try {
      await ref.read(notificationServiceProvider).ensurePermission();
      final point = await _resolvePoint();
      await ref.read(backendProvider).respondToLiveRequest(
        allow: true,
        point: point,
      );
      await ref.read(notificationServiceProvider).cancelLiveRequest();
      state = state.copyWith(busy: false);
      return true;
    } on LocationUnavailableException catch (error) {
      _fail(error.message, canOpenSettings: error.canOpenSettings);
      return false;
    } catch (error) {
      _fail(friendlyError(error));
      return false;
    }
  }

  Future<void> denyIncoming() async {
    if (state.busy) return;
    state = state.copyWith(busy: true, clearError: true);
    try {
      await ref.read(backendProvider).respondToLiveRequest(allow: false);
      await ref.read(notificationServiceProvider).cancelLiveRequest();
      state = state.copyWith(busy: false);
    } catch (error) {
      _fail(friendlyError(error));
    }
  }

  Future<void> endLive() async {
    if (state.busy) return;
    state = state.copyWith(busy: true, clearError: true);
    try {
      await ref.read(backendProvider).endLiveSession();
      await ref.read(notificationServiceProvider).cancelLiveRequest();
      state = state.copyWith(busy: false);
    } catch (error) {
      _fail(friendlyError(error));
    }
  }

  Future<void> sharePoint(LivePoint point) async {
    try {
      await ref.read(backendProvider).updateLiveLocation(point);
    } catch (_) {
      // A missed position update is not worth interrupting the moment.
    }
  }

  Future<void> previewIncoming() async {
    if (state.busy) return;
    final session = ref.read(sessionProvider);
    if (!session.isDemo) {
      _fail('Preview is only available in demo mode.');
      return;
    }
    state = state.copyWith(busy: true, clearError: true);
    try {
      final mine = await _resolvePoint();
      await ref.read(backendProvider).simulateIncomingLiveRequest(
        requesterName: session.partnerName,
        point: _offsetPoint(mine),
      );
      state = state.copyWith(busy: false);
    } on LocationUnavailableException catch (error) {
      _fail(error.message, canOpenSettings: error.canOpenSettings);
    } catch (error) {
      _fail(friendlyError(error));
    }
  }

  void clearError() {
    if (state.error == null) return;
    state = state.copyWith(clearError: true);
  }

  Future<LivePoint> _resolvePoint() async {
    try {
      return await ref.read(locationServiceProvider).currentPoint();
    } on LocationUnavailableException {
      if (ref.read(sessionProvider).isDemo) {
        return LivePoint(
          latitude: 48.8584,
          longitude: 2.2945,
          updatedAt: DateTime.now(),
          accuracy: 25,
        );
      }
      rethrow;
    }
  }

  LivePoint _offsetPoint(LivePoint origin) {
    const latOffset = 0.0042;
    const lonOffset = 0.0058;
    return LivePoint(
      latitude: (origin.latitude + latOffset).clamp(-85.0, 85.0).toDouble(),
      longitude: origin.longitude + lonOffset,
      updatedAt: DateTime.now(),
      accuracy: 18,
    );
  }

  void _fail(String message, {bool canOpenSettings = false}) {
    state = LiveDistanceState(
      error: message,
      errorCanOpenSettings: canOpenSettings,
    );
  }
}

final liveDistanceControllerProvider =
    NotifierProvider<LiveDistanceController, LiveDistanceState>(
  LiveDistanceController.new,
);
