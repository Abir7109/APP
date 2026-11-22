enum BucketCategory { adventure, food, travel, cozy, dateIdea, someday }

extension BucketCategoryX on BucketCategory {
  String get label => switch (this) {
        BucketCategory.adventure => 'Adventure',
        BucketCategory.food => 'Food',
        BucketCategory.travel => 'Travel',
        BucketCategory.cozy => 'Cozy',
        BucketCategory.dateIdea => 'Date idea',
        BucketCategory.someday => 'Someday',
      };
}

BucketCategory bucketCategoryFromName(String? name) {
  return BucketCategory.values.firstWhere(
    (category) => category.name == name,
    orElse: () => BucketCategory.someday,
  );
}

class BucketItem {
  const BucketItem({
    required this.id,
    required this.title,
    this.note = '',
    this.category = BucketCategory.someday,
    this.done = false,
    required this.createdBy,
    required this.createdAt,
    this.completedAt,
  });

  final String id;
  final String title;
  final String note;
  final BucketCategory category;
  final bool done;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? completedAt;

  BucketItem copyWith({
    String? id,
    String? title,
    String? note,
    BucketCategory? category,
    bool? done,
    String? createdBy,
    DateTime? createdAt,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return BucketItem(
      id: id ?? this.id,
      title: title ?? this.title,
      note: note ?? this.note,
      category: category ?? this.category,
      done: done ?? this.done,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      completedAt:
          clearCompletedAt ? null : (completedAt ?? this.completedAt),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'note': note,
      'category': category.name,
      'done': done,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory BucketItem.fromMap(Map<String, dynamic> map) {
    return BucketItem(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      note: map['note'] as String? ?? '',
      category: bucketCategoryFromName(map['category'] as String?),
      done: map['done'] as bool? ?? false,
      createdBy: map['createdBy'] as String? ?? '',
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ??
              DateTime.now(),
      completedAt: DateTime.tryParse(map['completedAt'] as String? ?? ''),
    );
  }
}
