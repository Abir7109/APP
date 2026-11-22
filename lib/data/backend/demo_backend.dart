import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/models.dart';
import '../seed/seed_content.dart';
import 'app_backend.dart';

class DemoBackend implements AppBackend {
  DemoBackend(this._prefs) {
    _load();
  }

  final SharedPreferences _prefs;
  final Uuid _uuid = const Uuid();

  static const _meId = 'demo-me';
  static const _partnerId = 'demo-partner';

  static const _userKey = 'demo.user';
  static const _partnerKey = 'demo.partner';
  static const _coupleKey = 'demo.couple';
  static const _bucketKey = 'demo.bucket';
  static const _checkInsKey = 'demo.checkins';
  static const _capsulesKey = 'demo.capsules';
  static const _couponsKey = 'demo.coupons';
  static const _goalsKey = 'demo.goals';
  static const _photosKey = 'demo.photos';
  static const _deepTalkKey = 'demo.deeptalk';
  static const _choresKey = 'demo.chores';

  AppUser? _user;
  AppUser? _partner;
  Couple? _couple;

  List<BucketItem> _bucket = [];
  List<CheckIn> _checkIns = [];
  List<TimeCapsule> _capsules = [];
  List<Coupon> _coupons = [];
  List<Goal> _goals = [];
  List<PhotoChallenge> _photos = [];
  List<DeepTalkEntry> _deepTalk = [];
  List<Chore> _chores = [];

  final _partnerController = StreamController<AppUser?>.broadcast();
  final _bucketController = StreamController<List<BucketItem>>.broadcast();
  final _checkInsController = StreamController<List<CheckIn>>.broadcast();
  final _capsulesController = StreamController<List<TimeCapsule>>.broadcast();
  final _couponsController = StreamController<List<Coupon>>.broadcast();
  final _goalsController = StreamController<List<Goal>>.broadcast();
  final _photosController = StreamController<List<PhotoChallenge>>.broadcast();
  final _deepTalkController = StreamController<List<DeepTalkEntry>>.broadcast();
  final _choresController = StreamController<List<Chore>>.broadcast();

  bool _initialized = false;

  @override
  BackendMode get mode => BackendMode.demo;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    final now = DateTime.now();

    if (_user == null) {
      _user = AppUser(id: _meId, name: 'You', createdAt: now);
      await _persistUser();
    }

    if (_user!.coupleId != null && _couple == null) {
      _user = _user!.copyWith(clearCoupleId: true);
      await _persistUser();
    }

    final couple = _couple;
    if (couple != null && couple.pin.isEmpty) {
      _couple = couple.copyWith(pin: _generatePin());
      await _persistCouple();
    }

    if (_user!.coupleId != null) {
      _partner ??= AppUser(
        id: _partnerId,
        name: _couple?.partnerName ?? 'Sam',
        coupleId: _user!.coupleId,
        createdAt: now,
      );
      await _persistPartner();
      await _seedIfNeeded();
    }
  }

  @override
  Future<AppUser?> currentUser() async => _user;

  @override
  Future<Couple?> getCouple() async {
    final user = _user;
    final couple = _couple;
    if (user == null || user.coupleId == null || couple == null) return null;
    if (couple.id != user.coupleId) return null;
    return couple;
  }

  @override
  Future<Couple> createSpace({
    required String myName,
    required String partnerName,
    required DateTime anniversary,
  }) async {
    final now = DateTime.now();
    final user = _user ?? AppUser(id: _meId, name: 'You', createdAt: now);
    final resolvedName = myName.trim().isEmpty ? user.name : myName.trim();
    final resolvedPartner =
        partnerName.trim().isEmpty ? 'Sam' : partnerName.trim();
    final partnerId = 'demo-partner-${_uuid.v4().substring(0, 8)}';
    final coupleId = 'demo-couple-${_uuid.v4().substring(0, 8)}';
    final pin = _generatePin();

    _user = user.copyWith(name: resolvedName, coupleId: coupleId);
    _partner = AppUser(
      id: partnerId,
      name: resolvedPartner,
      coupleId: coupleId,
      createdAt: now,
    );
    _couple = Couple(
      id: coupleId,
      memberIds: [_user!.id, partnerId],
      pin: pin,
      anniversary: anniversary,
      createdAt: now,
      partnerName: resolvedPartner,
    );

    await _resetContent();
    await _persistUser();
    await _persistPartner();
    await _persistCouple();
    await _seedIfNeeded();
    _partnerController.add(_partner);
    return _couple!;
  }

  @override
  Future<Couple> joinSpace({
    required String myName,
    required String pin,
  }) async {
    final digits = pin.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 6) {
      throw Exception('Enter the 6-digit PIN from your partner.');
    }
    final now = DateTime.now();
    final user = _user ?? AppUser(id: _meId, name: 'You', createdAt: now);
    final resolvedName = myName.trim().isEmpty ? user.name : myName.trim();

    final existing = _couple;
    if (existing != null && existing.pin == digits) {
      _user = user.copyWith(name: resolvedName, coupleId: existing.id);
      _partner ??= AppUser(
        id: _partnerId,
        name: existing.partnerName ?? 'Sam',
        coupleId: existing.id,
        createdAt: now,
      );
      _couple = existing.copyWith(
        memberIds: {...existing.memberIds, _user!.id}.toList(),
      );
      await _persistUser();
      await _persistPartner();
      await _persistCouple();
      await _seedIfNeeded();
      _partnerController.add(_partner);
      return _couple!;
    }

    final coupleId = 'demo-couple-${_uuid.v4().substring(0, 8)}';
    final partnerId = 'demo-partner-${_uuid.v4().substring(0, 8)}';
    _user = user.copyWith(name: resolvedName, coupleId: coupleId);
    _partner = AppUser(
      id: partnerId,
      name: 'Sam',
      coupleId: coupleId,
      createdAt: now,
    );
    _couple = Couple(
      id: coupleId,
      memberIds: [_user!.id, partnerId],
      pin: digits,
      anniversary: DateTime(now.year, now.month, now.day),
      createdAt: now,
      partnerName: 'Sam',
    );

    await _resetContent();
    await _persistUser();
    await _persistPartner();
    await _persistCouple();
    await _seedIfNeeded();
    _partnerController.add(_partner);
    return _couple!;
  }

  @override
  Future<void> leaveSpace() async {
    final user = _user;
    if (user == null) return;
    _user = user.copyWith(clearCoupleId: true);
    await _persistUser();
    _partnerController.add(null);
  }

  @override
  Future<AppUser> updateProfile({required String name}) async {
    final user = _user;
    if (user == null) throw StateError('No local profile yet.');
    _user = user.copyWith(name: name.trim().isEmpty ? user.name : name.trim());
    await _persistUser();
    return _user!;
  }

  void _load() {
    _user = _readObject(_userKey, AppUser.fromMap);
    _partner = _readObject(_partnerKey, AppUser.fromMap);
    _couple = _readObject(_coupleKey, Couple.fromMap);
    _bucket = _readList(_bucketKey, BucketItem.fromMap);
    _checkIns = _readList(_checkInsKey, CheckIn.fromMap);
    _capsules = _readList(_capsulesKey, TimeCapsule.fromMap);
    _coupons = _readList(_couponsKey, Coupon.fromMap);
    _goals = _readList(_goalsKey, Goal.fromMap);
    _photos = _readList(_photosKey, PhotoChallenge.fromMap);
    _deepTalk = _readList(_deepTalkKey, DeepTalkEntry.fromMap);
    _chores = _readList(_choresKey, Chore.fromMap);
  }

  T? _readObject<T>(String key, T Function(Map<String, dynamic>) fromMap) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      return fromMap((jsonDecode(raw) as Map).cast<String, dynamic>());
    } catch (_) {
      return null;
    }
  }

  List<T> _readList<T>(String key, T Function(Map<String, dynamic>) fromMap) {
    final raw = _prefs.getString(key);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => fromMap((item as Map).cast<String, dynamic>()))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _writeList<T>(
    String key,
    List<T> items,
    Map<String, dynamic> Function(T) toMap,
  ) async {
    await _prefs.setString(
      key,
      jsonEncode(items.map(toMap).toList()),
    );
  }

  Future<void> _persistAll() async {
    await Future.wait([
      _writeList(_bucketKey, _bucket, (item) => item.toMap()),
      _writeList(_checkInsKey, _checkIns, (item) => item.toMap()),
      _writeList(_capsulesKey, _capsules, (item) => item.toMap()),
      _writeList(_couponsKey, _coupons, (item) => item.toMap()),
      _writeList(_goalsKey, _goals, (item) => item.toMap()),
      _writeList(_photosKey, _photos, (item) => item.toMap()),
      _writeList(_deepTalkKey, _deepTalk, (item) => item.toMap()),
      _writeList(_choresKey, _chores, (item) => item.toMap()),
    ]);
  }

  Future<void> _persistUser() async {
    final user = _user;
    if (user == null) {
      await _prefs.remove(_userKey);
      return;
    }
    await _prefs.setString(_userKey, jsonEncode(user.toMap()));
  }

  Future<void> _persistPartner() async {
    final partner = _partner;
    if (partner == null) {
      await _prefs.remove(_partnerKey);
      return;
    }
    await _prefs.setString(_partnerKey, jsonEncode(partner.toMap()));
  }

  Future<void> _persistCouple() async {
    final couple = _couple;
    if (couple == null) {
      await _prefs.remove(_coupleKey);
      return;
    }
    await _prefs.setString(_coupleKey, jsonEncode(couple.toMap()));
  }

  Future<void> _resetContent() async {
    _bucket = [];
    _checkIns = [];
    _capsules = [];
    _coupons = [];
    _goals = [];
    _photos = [];
    _deepTalk = [];
    _chores = [];
    await _persistAll();
  }

  void _upsert<T>(List<T> list, T item, String Function(T) idOf) {
    final index = list.indexWhere((existing) => idOf(existing) == idOf(item));
    if (index >= 0) {
      list[index] = item;
    } else {
      list.insert(0, item);
    }
  }

  @override
  Stream<AppUser?> watchPartner() async* {
    yield _user?.coupleId == null ? null : _partner;
    yield* _partnerController.stream;
  }

  Future<void> _seedIfNeeded() async {
    final couple = _couple;
    final user = _user;
    final partner = _partner;
    if (couple == null || user == null || partner == null) return;
    final seededKey = 'demo.seeded.${couple.id}';
    if (_prefs.getBool(seededKey) == true) return;
    final now = DateTime.now();
    if (_bucket.isEmpty) {
      _bucket = SeedContent.bucketItems(
        meId: user.id,
        partnerId: partner.id,
        now: now,
      );
    }
    if (_checkIns.isEmpty) {
      _checkIns = SeedContent.checkIns(
        meId: user.id,
        partnerId: partner.id,
        now: now,
      );
    }
    if (_capsules.isEmpty) {
      _capsules = SeedContent.capsules(
        meId: user.id,
        partnerId: partner.id,
        now: now,
      );
    }
    if (_coupons.isEmpty) {
      _coupons = SeedContent.coupons(
        meId: user.id,
        partnerId: partner.id,
        now: now,
      );
    }
    if (_goals.isEmpty) {
      _goals = SeedContent.goals(
        meId: user.id,
        partnerId: partner.id,
        now: now,
      );
    }
    if (_photos.isEmpty) {
      _photos = SeedContent.photoChallenges(
        meId: user.id,
        partnerId: partner.id,
        now: now,
      );
    }
    if (_deepTalk.isEmpty) {
      _deepTalk = SeedContent.deepTalk(
        meId: user.id,
        partnerId: partner.id,
        now: now,
      );
    }
    if (_chores.isEmpty) {
      _chores = SeedContent.chores(
        meId: user.id,
        partnerId: partner.id,
        now: now,
      );
    }
    await _persistAll();
    await _prefs.setBool(seededKey, true);
  }

  @override
  Stream<List<BucketItem>> watchBucketItems() async* {
    yield List.unmodifiable(_bucket);
    yield* _bucketController.stream;
  }

  @override
  Future<void> saveBucketItem(BucketItem item) async {
    _upsert(_bucket, item, (existing) => existing.id);
    await _writeList(_bucketKey, _bucket, (existing) => existing.toMap());
    _bucketController.add(List.unmodifiable(_bucket));
  }

  @override
  Future<void> deleteBucketItem(String id) async {
    _bucket.removeWhere((item) => item.id == id);
    await _writeList(_bucketKey, _bucket, (item) => item.toMap());
    _bucketController.add(List.unmodifiable(_bucket));
  }

  @override
  Stream<List<CheckIn>> watchCheckIns() async* {
    yield List.unmodifiable(_checkIns);
    yield* _checkInsController.stream;
  }

  @override
  Future<void> saveCheckIn(CheckIn checkIn) async {
    final index = _checkIns.indexWhere(
      (existing) =>
          existing.uid == checkIn.uid && existing.dateKey == checkIn.dateKey,
    );
    if (index >= 0) {
      _checkIns[index] = checkIn;
    } else {
      _checkIns.insert(0, checkIn);
    }
    await _writeList(_checkInsKey, _checkIns, (item) => item.toMap());
    _checkInsController.add(List.unmodifiable(_checkIns));
  }

  @override
  Stream<List<TimeCapsule>> watchCapsules() async* {
    yield List.unmodifiable(_capsules);
    yield* _capsulesController.stream;
  }

  @override
  Future<void> saveCapsule(TimeCapsule capsule) async {
    _upsert(_capsules, capsule, (existing) => existing.id);
    await _writeList(_capsulesKey, _capsules, (item) => item.toMap());
    _capsulesController.add(List.unmodifiable(_capsules));
  }

  @override
  Future<void> openCapsule(String id) async {
    final index = _capsules.indexWhere((capsule) => capsule.id == id);
    if (index < 0) return;
    _capsules[index] = _capsules[index].copyWith(opened: true);
    await _writeList(_capsulesKey, _capsules, (item) => item.toMap());
    _capsulesController.add(List.unmodifiable(_capsules));
  }

  @override
  Stream<List<Coupon>> watchCoupons() async* {
    yield List.unmodifiable(_coupons);
    yield* _couponsController.stream;
  }

  @override
  Future<void> saveCoupon(Coupon coupon) async {
    _upsert(_coupons, coupon, (existing) => existing.id);
    await _writeList(_couponsKey, _coupons, (item) => item.toMap());
    _couponsController.add(List.unmodifiable(_coupons));
  }

  @override
  Future<void> redeemCoupon(String id) async {
    final index = _coupons.indexWhere((coupon) => coupon.id == id);
    if (index < 0) return;
    _coupons[index] = _coupons[index].copyWith(
      redeemed: true,
      redeemedAt: DateTime.now(),
    );
    await _writeList(_couponsKey, _coupons, (item) => item.toMap());
    _couponsController.add(List.unmodifiable(_coupons));
  }

  @override
  Stream<List<Goal>> watchGoals() async* {
    yield List.unmodifiable(_goals);
    yield* _goalsController.stream;
  }

  @override
  Future<void> saveGoal(Goal goal) async {
    _upsert(_goals, goal, (existing) => existing.id);
    await _writeList(_goalsKey, _goals, (item) => item.toMap());
    _goalsController.add(List.unmodifiable(_goals));
  }

  @override
  Future<void> addToGoal(String id, double amount) async {
    final index = _goals.indexWhere((goal) => goal.id == id);
    if (index < 0) return;
    final goal = _goals[index];
    _goals[index] = goal.copyWith(
      savedAmount: max(0, goal.savedAmount + amount),
    );
    await _writeList(_goalsKey, _goals, (item) => item.toMap());
    _goalsController.add(List.unmodifiable(_goals));
  }

  @override
  Future<void> deleteGoal(String id) async {
    _goals.removeWhere((goal) => goal.id == id);
    await _writeList(_goalsKey, _goals, (item) => item.toMap());
    _goalsController.add(List.unmodifiable(_goals));
  }

  @override
  Stream<List<PhotoChallenge>> watchPhotoChallenges() async* {
    yield List.unmodifiable(_photos);
    yield* _photosController.stream;
  }

  @override
  Future<void> savePhotoChallenge(PhotoChallenge challenge) async {
    _upsert(_photos, challenge, (existing) => existing.id);
    await _writeList(_photosKey, _photos, (item) => item.toMap());
    _photosController.add(List.unmodifiable(_photos));
  }

  @override
  Future<String> uploadPhoto(
    Uint8List bytes, {
    String contentType = 'image/jpeg',
  }) async {
    return 'data:$contentType;base64,${base64Encode(bytes)}';
  }

  @override
  Stream<List<DeepTalkEntry>> watchDeepTalk() async* {
    yield List.unmodifiable(_deepTalk);
    yield* _deepTalkController.stream;
  }

  @override
  Future<void> saveDeepTalk(DeepTalkEntry entry) async {
    _upsert(_deepTalk, entry, (existing) => existing.id);
    await _writeList(_deepTalkKey, _deepTalk, (item) => item.toMap());
    _deepTalkController.add(List.unmodifiable(_deepTalk));
  }

  @override
  Stream<List<Chore>> watchChores() async* {
    yield List.unmodifiable(_chores);
    yield* _choresController.stream;
  }

  @override
  Future<void> saveChore(Chore chore) async {
    _upsert(_chores, chore, (existing) => existing.id);
    await _writeList(_choresKey, _chores, (item) => item.toMap());
    _choresController.add(List.unmodifiable(_chores));
  }

  @override
  Future<void> toggleChore(String id, bool done) async {
    final index = _chores.indexWhere((chore) => chore.id == id);
    if (index < 0) return;
    _chores[index] = _chores[index].copyWith(done: done);
    await _writeList(_choresKey, _chores, (item) => item.toMap());
    _choresController.add(List.unmodifiable(_chores));
  }

  @override
  Future<void> deleteChore(String id) async {
    _chores.removeWhere((chore) => chore.id == id);
    await _writeList(_choresKey, _chores, (item) => item.toMap());
    _choresController.add(List.unmodifiable(_chores));
  }

  String _generatePin() {
    final random = Random.secure();
    return (100000 + random.nextInt(900000)).toString();
  }
}
