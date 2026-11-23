import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../models/models.dart';
import 'app_backend.dart';

class _PinTakenException implements Exception {
  const _PinTakenException();
}

class FirebaseBackend implements AppBackend {
  FirebaseBackend()
      : _auth = fb.FirebaseAuth.instance,
        _db = FirebaseFirestore.instance,
        _storage = FirebaseStorage.instance;

  final fb.FirebaseAuth _auth;
  final FirebaseFirestore _db;
  final FirebaseStorage _storage;
  final Uuid _uuid = const Uuid();

  String? _uid;
  String? _coupleId;

  @override
  BackendMode get mode => BackendMode.firebase;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  CollectionReference<Map<String, dynamic>> get _couples =>
      _db.collection('couples');

  CollectionReference<Map<String, dynamic>> get _pins =>
      _db.collection('pins');

  CollectionReference<Map<String, dynamic>>? _coupleCollection(String name) {
    final coupleId = _coupleId;
    if (coupleId == null) return null;
    return _couples.doc(coupleId).collection(name);
  }

  String _requireUid() {
    final uid = _auth.currentUser?.uid ?? _uid;
    if (uid == null) throw StateError('Not signed in.');
    return uid;
  }

  @override
  Future<void> initialize() async {
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }
    await _ensureUserDoc();
    unawaited(_syncMessagingToken());
  }

  Future<void> _syncMessagingToken() async {
    final uid = _auth.currentUser?.uid ?? _uid;
    if (uid == null) return;
    try {
      final messaging = FirebaseMessaging.instance;
      if (!await messaging.isSupported()) return;
      await messaging.requestPermission();
      final registered = messaging.onRegistered
          .first
          .timeout(const Duration(seconds: 15));
      await messaging.register();
      final installationId = await registered;
      await _users.doc(uid).set(
        {
          'fcmInstallationId': installationId,
          'fcmUpdatedAt': DateTime.now().toIso8601String(),
        },
        SetOptions(merge: true),
      );
    } catch (_) {
      // Messaging is optional; the app works without push configured.
    }
  }

  Future<AppUser> _ensureUserDoc() async {
    final authUser = _auth.currentUser;
    if (authUser == null) throw StateError('Not signed in.');
    _uid = authUser.uid;
    final ref = _users.doc(authUser.uid);
    final doc = await ref.get();
    if (!doc.exists) {
      final created = AppUser(
        id: authUser.uid,
        name: authUser.displayName ?? 'You',
        createdAt: DateTime.now(),
      );
      await ref.set(created.toMap());
      _coupleId = null;
      return created;
    }
    final appUser = AppUser.fromMap({...doc.data()!, 'id': authUser.uid});
    _coupleId = appUser.coupleId;
    return appUser;
  }

  @override
  Future<AppUser?> currentUser() async {
    if (_auth.currentUser == null) return null;
    return _ensureUserDoc();
  }

  @override
  Future<Couple?> getCouple() async {
    final uid = _auth.currentUser?.uid ?? _uid;
    if (uid == null) return null;
    if (_coupleId == null) {
      final userDoc = await _users.doc(uid).get();
      _coupleId = userDoc.data()?['coupleId'] as String?;
    }
    final coupleId = _coupleId;
    if (coupleId == null) return null;
    final doc = await _couples.doc(coupleId).get();
    if (!doc.exists) {
      _coupleId = null;
      return null;
    }
    return Couple.fromMap({...doc.data()!, 'id': coupleId});
  }

  @override
  Future<Couple> createSpace({
    required String myName,
    required String partnerName,
    required DateTime anniversary,
  }) async {
    final uid = _requireUid();
    final now = DateTime.now();
    final resolvedName = myName.trim().isEmpty ? 'You' : myName.trim();
    final resolvedPartner =
        partnerName.trim().isEmpty ? null : partnerName.trim();
    final coupleId = _uuid.v4();

    for (var attempt = 0; attempt < 12; attempt++) {
      final pin = _generatePin();
      final couple = Couple(
        id: coupleId,
        memberIds: [uid],
        pin: pin,
        anniversary: anniversary,
        createdAt: now,
        partnerName: resolvedPartner,
      );
      try {
        await _db.runTransaction((transaction) async {
          final pinDoc = await transaction.get(_pins.doc(pin));
          if (pinDoc.exists) throw const _PinTakenException();
          transaction.set(_couples.doc(coupleId), couple.toMap());
          transaction.set(_pins.doc(pin), {
            'coupleId': coupleId,
            'createdAt': now.toIso8601String(),
          });
          transaction.set(
            _users.doc(uid),
            {'coupleId': coupleId, 'name': resolvedName},
            SetOptions(merge: true),
          );
        });
        _coupleId = coupleId;
        return couple;
      } on _PinTakenException {
        continue;
      }
    }
    throw Exception('Could not reserve a PIN. Please try again.');
  }

  @override
  Future<Couple> joinSpace({
    required String myName,
    required String pin,
  }) async {
    final uid = _requireUid();
    final digits = pin.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 6) {
      throw Exception('Enter the 6-digit PIN from your partner.');
    }
    final pinDoc = await _pins.doc(digits).get();
    if (!pinDoc.exists) {
      throw Exception('No space found for that PIN. Check the 6 digits.');
    }
    final coupleId = pinDoc.data()?['coupleId'] as String?;
    if (coupleId == null) {
      throw Exception('That PIN is not linked to a space.');
    }
    final resolvedName = myName.trim().isEmpty ? 'You' : myName.trim();
    final coupleRef = _couples.doc(coupleId);
    final userRef = _users.doc(uid);

    await _db.runTransaction((transaction) async {
      final coupleDoc = await transaction.get(coupleRef);
      final userDoc = await transaction.get(userRef);
      if (!coupleDoc.exists) {
        throw Exception('That space no longer exists.');
      }
      final current = userDoc.data()?['coupleId'] as String?;
      if (current != null && current != coupleId) {
        throw Exception('Leave your current space before joining another.');
      }
      final data = coupleDoc.data()!;
      final members =
          (data['memberIds'] as List<dynamic>?)?.cast<String>() ?? const [];
      if (!members.contains(uid) && members.length >= 2) {
        throw Exception('That space already has two partners.');
      }
      transaction.update(coupleRef, {
        'memberIds': FieldValue.arrayUnion([uid]),
      });
      transaction.set(
        userRef,
        {'coupleId': coupleId, 'name': resolvedName},
        SetOptions(merge: true),
      );
    });

    _coupleId = coupleId;
    final doc = await coupleRef.get();
    return Couple.fromMap({...doc.data()!, 'id': coupleId});
  }

  @override
  Future<void> leaveSpace() async {
    final uid = _requireUid();
    final userRef = _users.doc(uid);
    final userDoc = await userRef.get();
    final coupleId = userDoc.data()?['coupleId'] as String?;
    if (coupleId == null) {
      _coupleId = null;
      return;
    }
    final coupleRef = _couples.doc(coupleId);

    await _db.runTransaction((transaction) async {
      final coupleDoc = await transaction.get(coupleRef);
      if (!coupleDoc.exists) {
        transaction.set(
          userRef,
          {'coupleId': FieldValue.delete()},
          SetOptions(merge: true),
        );
        return;
      }
      final data = coupleDoc.data()!;
      final members =
          (data['memberIds'] as List<dynamic>?)?.cast<String>() ?? const [];
      final remaining = members.where((id) => id != uid).toList();
      if (remaining.isEmpty) {
        final pin = data['pin'] as String?;
        transaction.delete(coupleRef);
        if (pin != null && pin.isNotEmpty) {
          transaction.delete(_pins.doc(pin));
        }
      } else {
        transaction.update(coupleRef, {'memberIds': remaining});
      }
      transaction.set(
        userRef,
        {'coupleId': FieldValue.delete()},
        SetOptions(merge: true),
      );
    });

    _coupleId = null;
  }

  @override
  Future<AppUser> updateProfile({required String name}) async {
    final uid = _requireUid();
    final resolved = name.trim().isEmpty ? 'You' : name.trim();
    await _users.doc(uid).set(
      {'name': resolved},
      SetOptions(merge: true),
    );
    final authUser = _auth.currentUser;
    if (authUser != null && authUser.displayName != resolved) {
      await authUser.updateDisplayName(resolved);
    }
    final doc = await _users.doc(uid).get();
    return AppUser.fromMap({...doc.data()!, 'id': uid});
  }

  @override
  Stream<AppUser?> watchPartner() {
    final coupleId = _coupleId;
    final uid = _auth.currentUser?.uid ?? _uid;
    if (coupleId == null || uid == null) {
      return Stream<AppUser?>.value(null);
    }
    return _users
        .where('coupleId', isEqualTo: coupleId)
        .snapshots()
        .map((snapshot) {
      for (final doc in snapshot.docs) {
        if (doc.id != uid) {
          return AppUser.fromMap({...doc.data(), 'id': doc.id});
        }
      }
      return null;
    });
  }

  Stream<List<T>> _watchCollection<T>(
    String name,
    T Function(Map<String, dynamic>) fromMap,
  ) {
    final collection = _coupleCollection(name);
    if (collection == null) return Stream<List<T>>.value(<T>[]);
    return collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Future<void> _setDocument(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    final ref = _coupleCollection(collection);
    if (ref == null) throw StateError('No space linked yet.');
    await ref.doc(id).set(data, SetOptions(merge: true));
  }

  Future<void> _updateDocument(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    final ref = _coupleCollection(collection);
    if (ref == null) throw StateError('No space linked yet.');
    await ref.doc(id).update(data);
  }

  Future<void> _deleteDocument(String collection, String id) async {
    final ref = _coupleCollection(collection);
    if (ref == null) throw StateError('No space linked yet.');
    await ref.doc(id).delete();
  }

  @override
  Stream<List<BucketItem>> watchBucketItems() =>
      _watchCollection('bucketItems', BucketItem.fromMap);

  @override
  Future<void> saveBucketItem(BucketItem item) =>
      _setDocument('bucketItems', item.id, item.toMap());

  @override
  Future<void> deleteBucketItem(String id) =>
      _deleteDocument('bucketItems', id);

  @override
  Stream<List<CheckIn>> watchCheckIns() =>
      _watchCollection('checkins', CheckIn.fromMap);

  @override
  Future<void> saveCheckIn(CheckIn checkIn) =>
      _setDocument('checkins', checkIn.id, checkIn.toMap());

  @override
  Stream<List<TimeCapsule>> watchCapsules() =>
      _watchCollection('capsules', TimeCapsule.fromMap);

  @override
  Future<void> saveCapsule(TimeCapsule capsule) =>
      _setDocument('capsules', capsule.id, capsule.toMap());

  @override
  Future<void> openCapsule(String id) =>
      _updateDocument('capsules', id, {'opened': true});

  @override
  Stream<List<Coupon>> watchCoupons() =>
      _watchCollection('coupons', Coupon.fromMap);

  @override
  Future<void> saveCoupon(Coupon coupon) =>
      _setDocument('coupons', coupon.id, coupon.toMap());

  @override
  Future<void> redeemCoupon(String id) => _updateDocument('coupons', id, {
        'redeemed': true,
        'redeemedAt': DateTime.now().toIso8601String(),
      });

  @override
  Stream<List<Goal>> watchGoals() => _watchCollection('goals', Goal.fromMap);

  @override
  Future<void> saveGoal(Goal goal) =>
      _setDocument('goals', goal.id, goal.toMap());

  @override
  Future<void> addToGoal(String id, double amount) =>
      _updateDocument('goals', id, {'savedAmount': FieldValue.increment(amount)});

  @override
  Future<void> deleteGoal(String id) => _deleteDocument('goals', id);

  @override
  Stream<List<PhotoChallenge>> watchPhotoChallenges() =>
      _watchCollection('photoChallenges', PhotoChallenge.fromMap);

  @override
  Future<void> savePhotoChallenge(PhotoChallenge challenge) =>
      _setDocument('photoChallenges', challenge.id, challenge.toMap());

  @override
  Future<String> uploadPhoto(
    Uint8List bytes, {
    String contentType = 'image/jpeg',
  }) async {
    final coupleId = _coupleId;
    if (coupleId == null) throw StateError('No space linked yet.');
    final ref = _storage
        .ref()
        .child('couples/$coupleId/photos/${_uuid.v4()}.jpg');
    await ref.putData(bytes, SettableMetadata(contentType: contentType));
    return ref.getDownloadURL();
  }

  @override
  Stream<List<DeepTalkEntry>> watchDeepTalk() =>
      _watchCollection('deepTalk', DeepTalkEntry.fromMap);

  @override
  Future<void> saveDeepTalk(DeepTalkEntry entry) =>
      _setDocument('deepTalk', entry.id, entry.toMap());

  @override
  Stream<List<Chore>> watchChores() => _watchCollection('chores', Chore.fromMap);

  @override
  Future<void> saveChore(Chore chore) =>
      _setDocument('chores', chore.id, chore.toMap());

  @override
  Future<void> toggleChore(String id, bool done) =>
      _updateDocument('chores', id, {'done': done});

  @override
  Future<void> deleteChore(String id) => _deleteDocument('chores', id);

  @override
  Stream<LiveSession?> watchLiveSession() async* {
    if (_coupleId == null) {
      await getCouple();
    }
    final collection = _coupleCollection('live');
    if (collection == null) {
      yield null;
      return;
    }
    yield* collection.doc('current').snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return LiveSession.fromMap({...snapshot.data()!, 'id': snapshot.id});
    });
  }

  Future<DocumentReference<Map<String, dynamic>>> _liveDocument() async {
    if (_coupleId == null) {
      await getCouple();
    }
    final collection = _coupleCollection('live');
    if (collection == null) throw StateError('No space linked yet.');
    return collection.doc('current');
  }

  @override
  Future<void> sendLiveRequest({
    required String requesterName,
    LivePoint? point,
  }) async {
    final uid = _requireUid();
    final doc = await _liveDocument();
    final now = DateTime.now();
    final points = <String, dynamic>{};
    if (point != null) points[uid] = point.toMap();
    await doc.set({
      'requesterId': uid,
      'requesterName': requesterName,
      'status': LiveSessionStatus.pending.wireName,
      'createdAt': now.toIso8601String(),
      'respondedAt': null,
      'expiresAt': now.add(const Duration(minutes: 3)).toIso8601String(),
      'points': points,
    });
  }

  @override
  Future<void> respondToLiveRequest({
    required bool allow,
    LivePoint? point,
  }) async {
    final uid = _requireUid();
    final doc = await _liveDocument();
    final now = DateTime.now();
    final updates = <String, dynamic>{
      'status': allow
          ? LiveSessionStatus.allowed.wireName
          : LiveSessionStatus.denied.wireName,
      'respondedAt': now.toIso8601String(),
    };
    if (allow) {
      updates['expiresAt'] =
          now.add(const Duration(minutes: 15)).toIso8601String();
      if (point != null) updates['points.$uid'] = point.toMap();
    }
    await doc.update(updates);
  }

  @override
  Future<void> updateLiveLocation(LivePoint point) async {
    final uid = _requireUid();
    final doc = await _liveDocument();
    await doc.update({'points.$uid': point.toMap()});
  }

  @override
  Future<void> endLiveSession() async {
    final doc = await _liveDocument();
    await doc.update({
      'status': LiveSessionStatus.ended.wireName,
      'respondedAt': DateTime.now().toIso8601String(),
      'points': <String, dynamic>{},
    });
  }

  @override
  Future<void> simulateIncomingLiveRequest({
    required String requesterName,
    LivePoint? point,
  }) async {
    throw UnsupportedError('Live request simulation is only in demo mode.');
  }

  String _generatePin() {
    final random = Random.secure();
    return (100000 + random.nextInt(900000)).toString();
  }
}
