class CheckIn {
  const CheckIn({
    required this.id,
    required this.uid,
    required this.mood,
    this.note = '',
    required this.dateKey,
    required this.createdAt,
  });

  final String id;
  final String uid;
  final int mood;
  final String note;
  final String dateKey;
  final DateTime createdAt;

  CheckIn copyWith({
    String? id,
    String? uid,
    int? mood,
    String? note,
    String? dateKey,
    DateTime? createdAt,
  }) {
    return CheckIn(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      mood: mood ?? this.mood,
      note: note ?? this.note,
      dateKey: dateKey ?? this.dateKey,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'mood': mood,
      'note': note,
      'dateKey': dateKey,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CheckIn.fromMap(Map<String, dynamic> map) {
    return CheckIn(
      id: map['id'] as String? ?? '',
      uid: map['uid'] as String? ?? '',
      mood: (map['mood'] as num?)?.toInt() ?? 3,
      note: map['note'] as String? ?? '',
      dateKey: map['dateKey'] as String? ?? '',
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ??
              DateTime.now(),
    );
  }
}
