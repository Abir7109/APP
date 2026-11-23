import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:you_and_me/core/utils/dates.dart';
import 'package:you_and_me/data/models/models.dart';

void main() {
  test('bucket item survives a JSON round trip', () {
    final item = BucketItem(
      id: '1',
      title: 'Sunrise',
      note: 'Bring coffee',
      category: BucketCategory.adventure,
      done: true,
      createdBy: 'me',
      createdAt: DateTime(2026, 1, 2, 3, 4),
      completedAt: DateTime(2026, 1, 3),
    );
    final copy = BucketItem.fromMap(item.toMap());
    expect(copy.id, item.id);
    expect(copy.title, item.title);
    expect(copy.category, BucketCategory.adventure);
    expect(copy.done, isTrue);
    expect(copy.completedAt, item.completedAt);
  });

  test('goal computes progress and remaining', () {
    final goal = Goal(
      id: 'g',
      title: 'Trip',
      targetAmount: 1000,
      savedAmount: 250,
      createdBy: 'me',
      createdAt: DateTime(2026),
    );
    expect(goal.progress, 0.25);
    expect(goal.remaining, 750);
    expect(goal.isComplete, isFalse);
  });

  test('streak counts consecutive days ending today', () {
    final now = DateTime(2026, 11, 22);
    final keys = [
      dateKeyOf(now),
      dateKeyOf(now.subtract(const Duration(days: 1))),
      dateKeyOf(now.subtract(const Duration(days: 2))),
    ];
    expect(calculateStreak(keys, now: now), 3);
  });

  test('streak survives a missing today and counts from yesterday', () {
    final now = DateTime(2026, 11, 22);
    final keys = [
      dateKeyOf(now.subtract(const Duration(days: 1))),
      dateKeyOf(now.subtract(const Duration(days: 2))),
    ];
    expect(calculateStreak(keys, now: now), 2);
  });

  test('streak is zero when the last check-in is older', () {
    final now = DateTime(2026, 11, 22);
    final keys = [dateKeyOf(now.subtract(const Duration(days: 5)))];
    expect(calculateStreak(keys, now: now), 0);
  });

  test('days together includes the first day', () {
    expect(
      daysTogether(DateTime(2026, 11, 20), now: DateTime(2026, 11, 22)),
      3,
    );
  });

  test('live session survives a JSON round trip', () {
    final created = DateTime(2020, 1, 2, 3, 4);
    final session = LiveSession(
      id: 'current',
      requesterId: 'me',
      requesterName: 'Alex',
      status: LiveSessionStatus.allowed,
      createdAt: created,
      respondedAt: created.add(const Duration(seconds: 20)),
      expiresAt: created.add(const Duration(minutes: 15)),
      points: {
        'me': LivePoint(
          latitude: 48.8584,
          longitude: 2.2945,
          updatedAt: created,
          accuracy: 12,
        ),
        'partner': LivePoint(
          latitude: 48.8600,
          longitude: 2.3000,
          updatedAt: created,
        ),
      },
    );

    final copy = LiveSession.fromMap(
      jsonDecode(jsonEncode(session.toMap())) as Map<String, dynamic>,
    );

    expect(copy.id, session.id);
    expect(copy.requesterId, 'me');
    expect(copy.status, LiveSessionStatus.allowed);
    expect(copy.isAllowed, isTrue);
    expect(copy.isExpired, isFalse);
    expect(copy.pointFor('me')!.accuracy, 12);
    expect(copy.pointFor('partner')!.longitude, 2.3);
  });

  test('pending live session expires after its deadline', () {
    final created = DateTime(2020, 1, 2, 3, 4);
    final session = LiveSession(
      id: 'current',
      requesterId: 'me',
      requesterName: 'Alex',
      status: LiveSessionStatus.pending,
      createdAt: created,
      expiresAt: created.add(const Duration(minutes: 3)),
    );

    expect(session.isPending, isTrue);
    expect(session.isExpired, isTrue);
  });

  test('live point validates coordinate bounds', () {
    expect(
      LivePoint(
        latitude: 91,
        longitude: 0,
        updatedAt: DateTime(2026),
      ).isValid,
      isFalse,
    );
    expect(
      LivePoint(
        latitude: 48.85,
        longitude: 2.29,
        updatedAt: DateTime(2026),
      ).isValid,
      isTrue,
    );
  });
}
