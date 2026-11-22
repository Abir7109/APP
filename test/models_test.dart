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
}
