class Coupon {
  const Coupon({
    required this.id,
    required this.title,
    this.redeemed = false,
    required this.createdBy,
    required this.createdAt,
    this.redeemedAt,
  });

  final String id;
  final String title;
  final bool redeemed;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? redeemedAt;

  Coupon copyWith({
    String? id,
    String? title,
    bool? redeemed,
    String? createdBy,
    DateTime? createdAt,
    DateTime? redeemedAt,
    bool clearRedeemedAt = false,
  }) {
    return Coupon(
      id: id ?? this.id,
      title: title ?? this.title,
      redeemed: redeemed ?? this.redeemed,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      redeemedAt: clearRedeemedAt ? null : (redeemedAt ?? this.redeemedAt),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'redeemed': redeemed,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'redeemedAt': redeemedAt?.toIso8601String(),
    };
  }

  factory Coupon.fromMap(Map<String, dynamic> map) {
    return Coupon(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      redeemed: map['redeemed'] as bool? ?? false,
      createdBy: map['createdBy'] as String? ?? '',
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ??
              DateTime.now(),
      redeemedAt: DateTime.tryParse(map['redeemedAt'] as String? ?? ''),
    );
  }
}
