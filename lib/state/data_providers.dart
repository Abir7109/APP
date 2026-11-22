import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/dates.dart';
import '../data/models/models.dart';
import 'session_provider.dart';

Stream<List<T>> _emptyList<T>() => Stream<List<T>>.value(<T>[]);

final bucketItemsProvider = StreamProvider<List<BucketItem>>((ref) {
  final coupleId =
      ref.watch(sessionProvider.select((state) => state.couple?.id));
  if (coupleId == null) return _emptyList<BucketItem>();
  return ref.watch(backendProvider).watchBucketItems();
});

final checkInsProvider = StreamProvider<List<CheckIn>>((ref) {
  final coupleId =
      ref.watch(sessionProvider.select((state) => state.couple?.id));
  if (coupleId == null) return _emptyList<CheckIn>();
  return ref.watch(backendProvider).watchCheckIns();
});

final capsulesProvider = StreamProvider<List<TimeCapsule>>((ref) {
  final coupleId =
      ref.watch(sessionProvider.select((state) => state.couple?.id));
  if (coupleId == null) return _emptyList<TimeCapsule>();
  return ref.watch(backendProvider).watchCapsules();
});

final couponsProvider = StreamProvider<List<Coupon>>((ref) {
  final coupleId =
      ref.watch(sessionProvider.select((state) => state.couple?.id));
  if (coupleId == null) return _emptyList<Coupon>();
  return ref.watch(backendProvider).watchCoupons();
});

final goalsProvider = StreamProvider<List<Goal>>((ref) {
  final coupleId =
      ref.watch(sessionProvider.select((state) => state.couple?.id));
  if (coupleId == null) return _emptyList<Goal>();
  return ref.watch(backendProvider).watchGoals();
});

final photoChallengesProvider = StreamProvider<List<PhotoChallenge>>((ref) {
  final coupleId =
      ref.watch(sessionProvider.select((state) => state.couple?.id));
  if (coupleId == null) return _emptyList<PhotoChallenge>();
  return ref.watch(backendProvider).watchPhotoChallenges();
});

final deepTalkProvider = StreamProvider<List<DeepTalkEntry>>((ref) {
  final coupleId =
      ref.watch(sessionProvider.select((state) => state.couple?.id));
  if (coupleId == null) return _emptyList<DeepTalkEntry>();
  return ref.watch(backendProvider).watchDeepTalk();
});

final choresProvider = StreamProvider<List<Chore>>((ref) {
  final coupleId =
      ref.watch(sessionProvider.select((state) => state.couple?.id));
  if (coupleId == null) return _emptyList<Chore>();
  return ref.watch(backendProvider).watchChores();
});

final myCheckInsProvider = Provider<List<CheckIn>>((ref) {
  final uid = ref.watch(sessionProvider.select((state) => state.user?.id));
  final checkIns =
      ref.watch(checkInsProvider).value ?? const <CheckIn>[];
  if (uid == null) return const <CheckIn>[];
  return checkIns.where((checkIn) => checkIn.uid == uid).toList();
});

final todayCheckInProvider = Provider<CheckIn?>((ref) {
  final mine = ref.watch(myCheckInsProvider);
  final key = dateKeyOf(DateTime.now());
  for (final checkIn in mine) {
    if (checkIn.dateKey == key) return checkIn;
  }
  return null;
});

final partnerTodayCheckInProvider = Provider<CheckIn?>((ref) {
  final partnerId =
      ref.watch(sessionProvider.select((state) => state.partner?.id));
  if (partnerId == null) return null;
  final checkIns =
      ref.watch(checkInsProvider).value ?? const <CheckIn>[];
  final key = dateKeyOf(DateTime.now());
  for (final checkIn in checkIns) {
    if (checkIn.uid == partnerId && checkIn.dateKey == key) {
      return checkIn;
    }
  }
  return null;
});

final myStreakProvider = Provider<int>((ref) {
  final mine = ref.watch(myCheckInsProvider);
  return calculateStreak(mine.map((checkIn) => checkIn.dateKey));
});

final daysTogetherProvider = Provider<int>((ref) {
  final couple = ref.watch(sessionProvider.select((state) => state.couple));
  if (couple == null) return 0;
  return daysTogether(couple.anniversary);
});

final openBucketItemsProvider = Provider<List<BucketItem>>((ref) {
  final items =
      ref.watch(bucketItemsProvider).value ?? const <BucketItem>[];
  return items.where((item) => !item.done).toList();
});

final nextCapsuleProvider = Provider<TimeCapsule?>((ref) {
  final capsules =
      ref.watch(capsulesProvider).value ?? const <TimeCapsule>[];
  final locked = capsules.where((capsule) => capsule.isLocked).toList()
    ..sort((a, b) => a.unlockAt.compareTo(b.unlockAt));
  return locked.isEmpty ? null : locked.first;
});

final activeCouponsProvider = Provider<List<Coupon>>((ref) {
  final coupons =
      ref.watch(couponsProvider).value ?? const <Coupon>[];
  return coupons.where((coupon) => !coupon.redeemed).toList();
});

final goalsProgressProvider = Provider<double>((ref) {
  final goals = ref.watch(goalsProvider).value ?? const <Goal>[];
  if (goals.isEmpty) return 0;
  final target = goals.fold<double>(0, (sum, goal) => sum + goal.targetAmount);
  final saved = goals.fold<double>(0, (sum, goal) => sum + goal.savedAmount);
  if (target <= 0) return 0;
  return (saved / target).clamp(0.0, 1.0);
});

final currentPhotoChallengeProvider = Provider<PhotoChallenge?>((ref) {
  final challenges =
      ref.watch(photoChallengesProvider).value ?? const <PhotoChallenge>[];
  final key = weekKeyOf(DateTime.now());
  for (final challenge in challenges) {
    if (challenge.weekKey == key) return challenge;
  }
  return challenges.isEmpty ? null : challenges.first;
});

class ChoreStats {
  const ChoreStats({
    required this.mineOpen,
    required this.partnerOpen,
    required this.sharedOpen,
    required this.completed,
  });

  final int mineOpen;
  final int partnerOpen;
  final int sharedOpen;
  final int completed;

  int get totalOpen => mineOpen + partnerOpen + sharedOpen;
  int get total => totalOpen + completed;
}

final choreStatsProvider = Provider<ChoreStats>((ref) {
  final session = ref.watch(sessionProvider);
  final chores = ref.watch(choresProvider).value ?? const <Chore>[];
  var mineOpen = 0;
  var partnerOpen = 0;
  var sharedOpen = 0;
  var completed = 0;
  for (final chore in chores) {
    if (chore.done) {
      completed += 1;
      continue;
    }
    if (chore.isShared) {
      sharedOpen += 1;
    } else if (chore.assignedTo == session.myId) {
      mineOpen += 1;
    } else if (chore.assignedTo == session.partnerId) {
      partnerOpen += 1;
    }
  }
  return ChoreStats(
    mineOpen: mineOpen,
    partnerOpen: partnerOpen,
    sharedOpen: sharedOpen,
    completed: completed,
  );
});
