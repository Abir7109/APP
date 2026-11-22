import 'dart:typed_data';

import '../models/models.dart';

enum BackendMode { demo, firebase }

extension BackendModeX on BackendMode {
  bool get isDemo => this == BackendMode.demo;

  String get label => this == BackendMode.demo ? 'Demo mode' : 'Firebase';
}

abstract class AppBackend {
  BackendMode get mode;

  Future<void> initialize();

  Future<AppUser?> currentUser();

  Future<Couple?> getCouple();

  Future<Couple> createSpace({
    required String myName,
    required String partnerName,
    required DateTime anniversary,
  });

  Future<Couple> joinSpace({
    required String myName,
    required String pin,
  });

  Future<void> leaveSpace();

  Future<AppUser> updateProfile({required String name});

  Stream<AppUser?> watchPartner();

  Stream<List<BucketItem>> watchBucketItems();

  Future<void> saveBucketItem(BucketItem item);

  Future<void> deleteBucketItem(String id);

  Stream<List<CheckIn>> watchCheckIns();

  Future<void> saveCheckIn(CheckIn checkIn);

  Stream<List<TimeCapsule>> watchCapsules();

  Future<void> saveCapsule(TimeCapsule capsule);

  Future<void> openCapsule(String id);

  Stream<List<Coupon>> watchCoupons();

  Future<void> saveCoupon(Coupon coupon);

  Future<void> redeemCoupon(String id);

  Stream<List<Goal>> watchGoals();

  Future<void> saveGoal(Goal goal);

  Future<void> addToGoal(String id, double amount);

  Future<void> deleteGoal(String id);

  Stream<List<PhotoChallenge>> watchPhotoChallenges();

  Future<void> savePhotoChallenge(PhotoChallenge challenge);

  Future<String> uploadPhoto(
    Uint8List bytes, {
    String contentType = 'image/jpeg',
  });

  Stream<List<DeepTalkEntry>> watchDeepTalk();

  Future<void> saveDeepTalk(DeepTalkEntry entry);

  Stream<List<Chore>> watchChores();

  Future<void> saveChore(Chore chore);

  Future<void> toggleChore(String id, bool done);

  Future<void> deleteChore(String id);
}
