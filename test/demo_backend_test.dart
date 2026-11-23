import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:you_and_me/data/backend/demo_backend.dart';
import 'package:you_and_me/data/models/models.dart';

Future<DemoBackend> _backend() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final backend = DemoBackend(prefs);
  await backend.initialize();
  return backend;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('starts with a local profile and no space', () async {
    final backend = await _backend();
    final user = await backend.currentUser();
    expect(user, isNotNull);
    expect(user!.coupleId, isNull);
    expect(await backend.getCouple(), isNull);
  });

  test('creating a space generates a 6-digit PIN and seeds every feature',
      () async {
    final backend = await _backend();
    final couple = await backend.createSpace(
      myName: 'Alex',
      partnerName: 'Sam',
      anniversary: DateTime(2024, 2, 14),
    );

    expect(RegExp(r'^\d{6}$').hasMatch(couple.pin), isTrue);
    expect(couple.memberIds.length, 2);

    final user = await backend.currentUser();
    expect(user!.name, 'Alex');
    expect(user.coupleId, couple.id);

    final partner = await backend.watchPartner().first;
    expect(partner?.name, 'Sam');

    expect((await backend.watchBucketItems().first).isNotEmpty, isTrue);
    expect((await backend.watchCheckIns().first).length, 6);
    expect((await backend.watchCoupons().first).length, 6);
    expect((await backend.watchGoals().first).length, 2);
    expect((await backend.watchCapsules().first).length, 2);
    expect((await backend.watchPhotoChallenges().first).length, 3);
    expect((await backend.watchDeepTalk().first).length, 1);
    expect((await backend.watchChores().first).length, 6);
  });

  test('leaving and rejoining with the same PIN keeps shared data', () async {
    final backend = await _backend();
    final couple = await backend.createSpace(
      myName: 'Alex',
      partnerName: 'Sam',
      anniversary: DateTime(2024, 2, 14),
    );
    await backend.saveBucketItem(
      BucketItem(
        id: 'keep-1',
        title: 'Keep this',
        createdBy: 'demo-me',
        createdAt: DateTime.now(),
      ),
    );

    await backend.leaveSpace();
    expect((await backend.currentUser())!.coupleId, isNull);
    expect(await backend.getCouple(), isNull);
    expect(await backend.watchPartner().first, isNull);

    final rejoined = await backend.joinSpace(
      myName: 'Alex',
      pin: couple.pin,
    );
    expect(rejoined.id, couple.id);
    final items = await backend.watchBucketItems().first;
    expect(items.any((entry) => entry.id == 'keep-1'), isTrue);
  });

  test('joining a new PIN simulates a fresh partner space', () async {
    final backend = await _backend();
    final first = await backend.createSpace(
      myName: 'Alex',
      partnerName: 'Sam',
      anniversary: DateTime(2024, 2, 14),
    );
    await backend.leaveSpace();
    final newPin = first.pin == '654321' ? '123456' : '654321';

    final couple = await backend.joinSpace(myName: 'Alex', pin: newPin);
    expect(couple.pin, newPin);
    expect(couple.id, isNot(first.id));
    expect((await backend.currentUser())!.coupleId, couple.id);
    expect((await backend.watchCoupons().first).length, 6);
  });

  test('updates the local profile name', () async {
    final backend = await _backend();
    await backend.createSpace(
      myName: 'Alex',
      partnerName: 'Sam',
      anniversary: DateTime(2024, 2, 14),
    );
    final updated = await backend.updateProfile(name: 'Alex Rivera');
    expect(updated.name, 'Alex Rivera');
    expect((await backend.currentUser())!.name, 'Alex Rivera');
  });

  test('persists a new bucket item', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final backend = DemoBackend(prefs);
    await backend.initialize();
    await backend.createSpace(
      myName: 'Alex',
      partnerName: 'Sam',
      anniversary: DateTime(2024, 2, 14),
    );

    final item = BucketItem(
      id: 'test-1',
      title: 'Test wish',
      createdBy: 'demo-me',
      createdAt: DateTime.now(),
    );
    await backend.saveBucketItem(item);

    final reloaded = DemoBackend(prefs);
    await reloaded.initialize();
    final items = await reloaded.watchBucketItems().first;
    expect(items.any((entry) => entry.id == 'test-1'), isTrue);
  });

  test('records one check-in per day', () async {
    final backend = await _backend();
    await backend.createSpace(
      myName: 'Alex',
      partnerName: 'Sam',
      anniversary: DateTime(2024, 2, 14),
    );

    final key = '2026-11-22';
    await backend.saveCheckIn(
      CheckIn(
        id: 'checkin-a',
        uid: 'demo-me',
        mood: 4,
        dateKey: key,
        createdAt: DateTime.now(),
      ),
    );
    await backend.saveCheckIn(
      CheckIn(
        id: 'checkin-b',
        uid: 'demo-me',
        mood: 5,
        dateKey: key,
        createdAt: DateTime.now(),
      ),
    );

    final checkIns = await backend.watchCheckIns().first;
    final today = checkIns.where(
      (entry) => entry.uid == 'demo-me' && entry.dateKey == key,
    );
    expect(today.length, 1);
    expect(today.first.mood, 5);
  });

  test('live request can be allowed, moved, and ended', () async {
    final backend = await _backend();
    await backend.createSpace(
      myName: 'Alex',
      partnerName: 'Sam',
      anniversary: DateTime(2024, 2, 14),
    );
    final me = (await backend.currentUser())!;
    final partner = (await backend.watchPartner().first)!;
    final now = DateTime.now();

    await backend.sendLiveRequest(
      requesterName: 'Alex',
      point: LivePoint(
        latitude: 48.8584,
        longitude: 2.2945,
        updatedAt: now,
        accuracy: 10,
      ),
    );

    var session = (await backend.watchLiveSession().first)!;
    expect(session.isPending, isTrue);
    expect(session.requesterId, me.id);
    expect(session.pointFor(me.id), isNotNull);

    await backend.respondToLiveRequest(
      allow: true,
      point: LivePoint(
        latitude: 48.8600,
        longitude: 2.3000,
        updatedAt: now,
      ),
    );

    session = (await backend.watchLiveSession().first)!;
    expect(session.isAllowed, isTrue);
    expect(session.points.length, 2);
    expect(session.pointFor(partner.id), isNotNull);
    expect(session.expiresAt!.isAfter(DateTime.now()), isTrue);

    final moved = LivePoint(
      latitude: 48.8610,
      longitude: 2.3010,
      updatedAt: DateTime.now(),
    );
    await backend.updateLiveLocation(moved);
    session = (await backend.watchLiveSession().first)!;
    expect(session.pointFor(me.id)!.latitude, moved.latitude);

    await backend.endLiveSession();
    session = (await backend.watchLiveSession().first)!;
    expect(session.isEnded, isTrue);
    expect(session.points, isEmpty);
  });

  test('demo can simulate and deny an incoming live request', () async {
    final backend = await _backend();
    await backend.createSpace(
      myName: 'Alex',
      partnerName: 'Sam',
      anniversary: DateTime(2024, 2, 14),
    );
    final partner = (await backend.watchPartner().first)!;

    await backend.simulateIncomingLiveRequest(
      requesterName: 'Sam',
      point: LivePoint(
        latitude: 48.8584,
        longitude: 2.2945,
        updatedAt: DateTime.now(),
      ),
    );

    var session = (await backend.watchLiveSession().first)!;
    expect(session.isPending, isTrue);
    expect(session.requesterId, partner.id);
    expect(session.requesterName, 'Sam');
    expect(session.pointFor(partner.id), isNotNull);

    await backend.respondToLiveRequest(allow: false);
    session = (await backend.watchLiveSession().first)!;
    expect(session.isDenied, isTrue);
  });
}
