import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/backend/app_backend.dart';
import '../data/models/models.dart';

final backendProvider = Provider<AppBackend>((ref) {
  throw UnimplementedError('backendProvider must be overridden in main().');
});

enum SessionStatus { loading, needsSetup, ready }

class SessionState {
  const SessionState({
    required this.status,
    this.user,
    this.partner,
    this.couple,
    required this.mode,
  });

  final SessionStatus status;
  final AppUser? user;
  final AppUser? partner;
  final Couple? couple;
  final BackendMode mode;

  bool get isReady => status == SessionStatus.ready;
  bool get needsSetup => status == SessionStatus.needsSetup;
  bool get isDemo => mode == BackendMode.demo;
  bool get hasPartner => partner != null;

  String get myId => user?.id ?? '';
  String get myName => user?.firstName ?? 'You';
  String get partnerId => partner?.id ?? '';
  String get partnerName =>
      partner?.firstName ?? couple?.partnerName ?? 'Partner';
  String get pin => couple?.pin ?? '';

  SessionState copyWith({
    SessionStatus? status,
    AppUser? user,
    AppUser? partner,
    Couple? couple,
    BackendMode? mode,
    bool clearPartner = false,
    bool clearCouple = false,
  }) {
    return SessionState(
      status: status ?? this.status,
      user: user ?? this.user,
      partner: clearPartner ? null : (partner ?? this.partner),
      couple: clearCouple ? null : (couple ?? this.couple),
      mode: mode ?? this.mode,
    );
  }
}

class SessionController extends Notifier<SessionState> {
  StreamSubscription<AppUser?>? _partnerSubscription;
  int _generation = 0;
  bool _started = false;

  @override
  SessionState build() {
    final backend = ref.watch(backendProvider);
    ref.onDispose(() {
      _partnerSubscription?.cancel();
    });
    if (!_started) {
      _started = true;
      Future.microtask(_bootstrap);
    }
    return SessionState(status: SessionStatus.loading, mode: backend.mode);
  }

  Future<void> _bootstrap() async {
    final backend = ref.read(backendProvider);
    try {
      await backend.initialize();
      final user = await backend.currentUser();
      if (user == null) {
        state = SessionState(
          status: SessionStatus.needsSetup,
          mode: backend.mode,
        );
        return;
      }
      final couple = await backend.getCouple();
      if (couple == null) {
        state = SessionState(
          status: SessionStatus.needsSetup,
          user: user,
          mode: backend.mode,
        );
        return;
      }
      _enterCouple(user.copyWith(coupleId: couple.id), couple);
    } catch (_) {
      state = SessionState(
        status: SessionStatus.needsSetup,
        mode: backend.mode,
      );
    }
  }

  void _enterCouple(AppUser user, Couple couple) {
    final token = ++_generation;
    _partnerSubscription?.cancel();
    final backend = ref.read(backendProvider);
    state = SessionState(
      status: SessionStatus.ready,
      user: user,
      couple: couple,
      mode: backend.mode,
    );
    _partnerSubscription = backend.watchPartner().listen((partner) {
      if (token != _generation) return;
      state = state.copyWith(partner: partner, clearPartner: partner == null);
    });
  }

  Future<Couple> createSpace({
    required String myName,
    required String partnerName,
    required DateTime anniversary,
  }) async {
    final backend = ref.read(backendProvider);
    final couple = await backend.createSpace(
      myName: myName,
      partnerName: partnerName,
      anniversary: anniversary,
    );
    final user = await backend.currentUser();
    if (user == null) throw StateError('Could not create your local profile.');
    _enterCouple(user, couple);
    return couple;
  }

  Future<Couple> joinSpace({
    required String myName,
    required String pin,
  }) async {
    final backend = ref.read(backendProvider);
    final couple = await backend.joinSpace(myName: myName, pin: pin);
    final user = await backend.currentUser();
    if (user == null) throw StateError('Could not load your local profile.');
    _enterCouple(user, couple);
    return couple;
  }

  Future<void> leaveSpace() async {
    final backend = ref.read(backendProvider);
    await backend.leaveSpace();
    await _partnerSubscription?.cancel();
    _partnerSubscription = null;
    _generation++;
    final user = await backend.currentUser();
    state = SessionState(
      status: SessionStatus.needsSetup,
      user: user,
      mode: backend.mode,
    );
  }

  Future<void> updateName(String name) async {
    final updated = await ref.read(backendProvider).updateProfile(name: name);
    state = state.copyWith(user: updated);
  }

  Future<void> retry() => _bootstrap();
}

final sessionProvider =
    NotifierProvider<SessionController, SessionState>(SessionController.new);
