import '../../core/utils/dates.dart';
import '../models/models.dart';

abstract final class SeedContent {
  static const deepTalkPrompts = <String>[
    'What is a small thing I do that makes you feel loved?',
    'When did you last feel truly proud of us?',
    'What is one dream you have not told me yet?',
    'What does a perfect ordinary day look like with me?',
    'When do you feel most like yourself?',
    'What is a fear you want to share with me?',
    'How can I support you better this week?',
    'What is a memory of us you never want to forget?',
    'What makes you feel safe with me?',
    'If we could relive one day together, which would it be?',
    'What is something you appreciate about your own life right now?',
    'What is one boundary you want us to protect?',
    'What do you need more of from me lately?',
    'What is a silly thing you love about me?',
    'Where do you see us in five years?',
    'What is the best advice we have ever given each other?',
  ];

  static const photoPrompts = <String>[
    'Capture something that reminds you of us.',
    'A photo of your favorite shared corner.',
    'Show me your view right now.',
    'Something that made you smile today.',
    'A meal that tastes like home.',
    'Your coziest outfit.',
    'A place you want to take me.',
    'One thing you are grateful for today.',
  ];

  static const couponIdeas = <String>[
    'Breakfast in bed',
    'A massage, no rush',
    'You pick the movie',
    'Dessert date',
    'One phone-free hour',
    'A handwritten note',
    'Sleep in, I have got it',
    'Surprise walk',
  ];

  static List<BucketItem> bucketItems({
    required String meId,
    required String partnerId,
    DateTime? now,
  }) {
    final base = now ?? DateTime.now();
    final created = base.subtract(const Duration(days: 45));
    return [
      BucketItem(
        id: 'seed-bucket-1',
        title: 'Watch the sunrise together',
        note: 'Pack coffee and a blanket.',
        category: BucketCategory.adventure,
        done: true,
        createdBy: meId,
        createdAt: created,
        completedAt: base.subtract(const Duration(days: 12)),
      ),
      BucketItem(
        id: 'seed-bucket-2',
        title: 'Try a pasta-making class',
        note: 'Find a Saturday afternoon session.',
        category: BucketCategory.food,
        createdBy: meId,
        createdAt: created,
      ),
      BucketItem(
        id: 'seed-bucket-3',
        title: 'Weekend in a tiny cabin',
        note: 'Somewhere with trees and no notifications.',
        category: BucketCategory.travel,
        createdBy: partnerId,
        createdAt: created,
      ),
      BucketItem(
        id: 'seed-bucket-4',
        title: 'Build a blanket fort and watch old movies',
        category: BucketCategory.cozy,
        done: true,
        createdBy: partnerId,
        createdAt: created,
        completedAt: base.subtract(const Duration(days: 25)),
      ),
      BucketItem(
        id: 'seed-bucket-5',
        title: 'Rooftop picnic at golden hour',
        note: 'Bring the good blanket and something cold.',
        category: BucketCategory.dateIdea,
        createdBy: meId,
        createdAt: created,
      ),
      BucketItem(
        id: 'seed-bucket-6',
        title: 'Learn to dance one song properly',
        category: BucketCategory.adventure,
        createdBy: partnerId,
        createdAt: created,
      ),
      BucketItem(
        id: 'seed-bucket-7',
        title: 'Take a photo together in every season',
        category: BucketCategory.someday,
        createdBy: partnerId,
        createdAt: created,
      ),
      BucketItem(
        id: 'seed-bucket-8',
        title: 'Cook a recipe from every country we visit',
        category: BucketCategory.food,
        createdBy: meId,
        createdAt: created,
      ),
    ];
  }

  static List<CheckIn> checkIns({
    required String meId,
    required String partnerId,
    DateTime? now,
  }) {
    final base = now ?? DateTime.now();
    final today = DateTime(base.year, base.month, base.day);
    return [
      CheckIn(
        id: 'seed-checkin-me-0',
        uid: meId,
        mood: 4,
        note: 'Feeling warm and grateful.',
        dateKey: dateKeyOf(today),
        createdAt: today.add(const Duration(hours: 8)),
      ),
      CheckIn(
        id: 'seed-checkin-partner-0',
        uid: partnerId,
        mood: 5,
        note: 'Best day. Thought about you all morning.',
        dateKey: dateKeyOf(today),
        createdAt: today.add(const Duration(hours: 9)),
      ),
      CheckIn(
        id: 'seed-checkin-me-1',
        uid: meId,
        mood: 3,
        dateKey: dateKeyOf(today.subtract(const Duration(days: 1))),
        createdAt: today.subtract(const Duration(days: 1)).add(
              const Duration(hours: 19),
            ),
      ),
      CheckIn(
        id: 'seed-checkin-partner-1',
        uid: partnerId,
        mood: 4,
        note: 'Tired but happy.',
        dateKey: dateKeyOf(today.subtract(const Duration(days: 1))),
        createdAt: today.subtract(const Duration(days: 1)).add(
              const Duration(hours: 20),
            ),
      ),
      CheckIn(
        id: 'seed-checkin-me-2',
        uid: meId,
        mood: 5,
        note: 'That walk was exactly what I needed.',
        dateKey: dateKeyOf(today.subtract(const Duration(days: 2))),
        createdAt: today.subtract(const Duration(days: 2)).add(
              const Duration(hours: 21),
            ),
      ),
      CheckIn(
        id: 'seed-checkin-partner-2',
        uid: partnerId,
        mood: 4,
        dateKey: dateKeyOf(today.subtract(const Duration(days: 2))),
        createdAt: today.subtract(const Duration(days: 2)).add(
              const Duration(hours: 22),
            ),
      ),
    ];
  }

  static List<TimeCapsule> capsules({
    required String meId,
    required String partnerId,
    DateTime? now,
  }) {
    final base = now ?? DateTime.now();
    return [
      TimeCapsule(
        id: 'seed-capsule-1',
        title: 'Open on our next anniversary',
        body:
            'Hey us. If you are reading this, another year happened. I hope we still dance in the kitchen and still say sorry properly. I hope we kept choosing each other, even on the ordinary days.',
        unlockAt: base.add(const Duration(days: 180)),
        createdBy: meId,
        createdAt: base.subtract(const Duration(days: 10)),
      ),
      TimeCapsule(
        id: 'seed-capsule-2',
        title: 'A note from the beginning',
        body:
            'The beginning was mostly nervous laughter and too many coffees. I already knew you were someone I wanted to keep learning.',
        unlockAt: base.subtract(const Duration(days: 20)),
        createdBy: partnerId,
        createdAt: base.subtract(const Duration(days: 120)),
        opened: true,
      ),
    ];
  }

  static List<Coupon> coupons({
    required String meId,
    required String partnerId,
    DateTime? now,
  }) {
    final base = now ?? DateTime.now();
    final created = base.subtract(const Duration(days: 60));
    return [
      Coupon(
        id: 'seed-coupon-1',
        title: 'Breakfast in bed',
        createdBy: meId,
        createdAt: created,
      ),
      Coupon(
        id: 'seed-coupon-2',
        title: 'A massage, no rush',
        createdBy: partnerId,
        createdAt: created,
      ),
      Coupon(
        id: 'seed-coupon-3',
        title: 'You pick the movie',
        createdBy: meId,
        createdAt: created,
        redeemed: true,
        redeemedAt: base.subtract(const Duration(days: 15)),
      ),
      Coupon(
        id: 'seed-coupon-4',
        title: 'Dessert date',
        createdBy: partnerId,
        createdAt: created,
      ),
      Coupon(
        id: 'seed-coupon-5',
        title: 'One phone-free hour',
        createdBy: meId,
        createdAt: created,
        redeemed: true,
        redeemedAt: base.subtract(const Duration(days: 5)),
      ),
      Coupon(
        id: 'seed-coupon-6',
        title: 'A handwritten note',
        createdBy: partnerId,
        createdAt: created,
      ),
    ];
  }

  static List<Goal> goals({
    required String meId,
    required String partnerId,
    DateTime? now,
  }) {
    final base = now ?? DateTime.now();
    final created = base.subtract(const Duration(days: 80));
    return [
      Goal(
        id: 'seed-goal-1',
        title: 'Japan in spring',
        targetAmount: 3500,
        savedAmount: 1400,
        deadline: base.add(const Duration(days: 240)),
        createdBy: meId,
        createdAt: created,
      ),
      Goal(
        id: 'seed-goal-2',
        title: 'Our cozy couch fund',
        targetAmount: 900,
        savedAmount: 420,
        deadline: base.add(const Duration(days: 120)),
        createdBy: partnerId,
        createdAt: created,
      ),
    ];
  }

  static List<PhotoChallenge> photoChallenges({
    required String meId,
    required String partnerId,
    DateTime? now,
  }) {
    final base = now ?? DateTime.now();
    return [
      PhotoChallenge(
        id: 'seed-photo-1',
        prompt: photoPrompts[0],
        weekKey: weekKeyOf(base),
        createdAt: base,
      ),
      PhotoChallenge(
        id: 'seed-photo-2',
        prompt: photoPrompts[1],
        weekKey: weekKeyOf(base.subtract(const Duration(days: 7))),
        completedBy: partnerId,
        completedAt: base.subtract(const Duration(days: 4)),
        createdAt: base.subtract(const Duration(days: 7)),
      ),
      PhotoChallenge(
        id: 'seed-photo-3',
        prompt: photoPrompts[3],
        weekKey: weekKeyOf(base.subtract(const Duration(days: 14))),
        completedBy: meId,
        completedAt: base.subtract(const Duration(days: 10)),
        createdAt: base.subtract(const Duration(days: 14)),
      ),
    ];
  }

  static List<DeepTalkEntry> deepTalk({
    required String meId,
    required String partnerId,
    DateTime? now,
  }) {
    final base = now ?? DateTime.now();
    return [
      DeepTalkEntry(
        id: 'seed-deeptalk-1',
        question: deepTalkPrompts[0],
        answer:
            'The way you make coffee for two without asking. It is such a small thing, but it feels like being known.',
        uid: partnerId,
        createdAt: base.subtract(const Duration(days: 2)),
      ),
    ];
  }

  static List<Chore> chores({
    required String meId,
    required String partnerId,
    DateTime? now,
  }) {
    final base = now ?? DateTime.now();
    final created = base.subtract(const Duration(days: 20));
    return [
      Chore(
        id: 'seed-chore-1',
        title: 'Take out the recycling',
        assignedTo: Chore.both,
        dueAt: base.add(const Duration(days: 1)),
        createdBy: meId,
        createdAt: created,
      ),
      Chore(
        id: 'seed-chore-2',
        title: 'Water the plants',
        assignedTo: meId,
        done: true,
        createdBy: partnerId,
        createdAt: created,
      ),
      Chore(
        id: 'seed-chore-3',
        title: 'Grocery run',
        assignedTo: partnerId,
        dueAt: base,
        createdBy: meId,
        createdAt: created,
      ),
      Chore(
        id: 'seed-chore-4',
        title: 'Deep clean the kitchen',
        assignedTo: Chore.both,
        dueAt: base.add(const Duration(days: 3)),
        createdBy: partnerId,
        createdAt: created,
      ),
      Chore(
        id: 'seed-chore-5',
        title: 'Change the sheets',
        assignedTo: meId,
        dueAt: base.add(const Duration(days: 1)),
        createdBy: meId,
        createdAt: created,
      ),
      Chore(
        id: 'seed-chore-6',
        title: 'Book the car service',
        assignedTo: partnerId,
        done: true,
        createdBy: meId,
        createdAt: created,
      ),
    ];
  }
}
