class Goal {
  const Goal({
    required this.id,
    required this.title,
    required this.targetAmount,
    this.savedAmount = 0,
    this.currency = 'USD',
    this.deadline,
    required this.createdBy,
    required this.createdAt,
  });

  final String id;
  final String title;
  final double targetAmount;
  final double savedAmount;
  final String currency;
  final DateTime? deadline;
  final String createdBy;
  final DateTime createdAt;

  double get progress {
    if (targetAmount <= 0) return 0;
    return (savedAmount / targetAmount).clamp(0.0, 1.0);
  }

  double get remaining {
    final value = targetAmount - savedAmount;
    return value < 0 ? 0 : value;
  }

  bool get isComplete => savedAmount >= targetAmount;

  Goal copyWith({
    String? id,
    String? title,
    double? targetAmount,
    double? savedAmount,
    String? currency,
    DateTime? deadline,
    String? createdBy,
    DateTime? createdAt,
    bool clearDeadline = false,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      currency: currency ?? this.currency,
      deadline: clearDeadline ? null : (deadline ?? this.deadline),
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'targetAmount': targetAmount,
      'savedAmount': savedAmount,
      'currency': currency,
      'deadline': deadline?.toIso8601String(),
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      targetAmount: (map['targetAmount'] as num?)?.toDouble() ?? 0,
      savedAmount: (map['savedAmount'] as num?)?.toDouble() ?? 0,
      currency: map['currency'] as String? ?? 'USD',
      deadline: DateTime.tryParse(map['deadline'] as String? ?? ''),
      createdBy: map['createdBy'] as String? ?? '',
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ??
              DateTime.now(),
    );
  }
}
