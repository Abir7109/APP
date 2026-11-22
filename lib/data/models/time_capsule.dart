class TimeCapsule {
  const TimeCapsule({
    required this.id,
    required this.title,
    required this.body,
    required this.unlockAt,
    required this.createdBy,
    required this.createdAt,
    this.opened = false,
  });

  final String id;
  final String title;
  final String body;
  final DateTime unlockAt;
  final String createdBy;
  final DateTime createdAt;
  final bool opened;

  bool get isLocked => !opened && DateTime.now().isBefore(unlockAt);

  int get daysUntilUnlock {
    final difference = unlockAt.difference(DateTime.now()).inHours;
    if (difference <= 0) return 0;
    return (difference / 24).ceil();
  }

  TimeCapsule copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? unlockAt,
    String? createdBy,
    DateTime? createdAt,
    bool? opened,
  }) {
    return TimeCapsule(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      unlockAt: unlockAt ?? this.unlockAt,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      opened: opened ?? this.opened,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'unlockAt': unlockAt.toIso8601String(),
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'opened': opened,
    };
  }

  factory TimeCapsule.fromMap(Map<String, dynamic> map) {
    return TimeCapsule(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      unlockAt:
          DateTime.tryParse(map['unlockAt'] as String? ?? '') ?? DateTime.now(),
      createdBy: map['createdBy'] as String? ?? '',
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ??
              DateTime.now(),
      opened: map['opened'] as bool? ?? false,
    );
  }
}
