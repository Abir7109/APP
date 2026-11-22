class Chore {
  const Chore({
    required this.id,
    required this.title,
    this.assignedTo = both,
    this.dueAt,
    this.done = false,
    required this.createdBy,
    required this.createdAt,
  });

  static const both = 'both';

  final String id;
  final String title;
  final String assignedTo;
  final DateTime? dueAt;
  final bool done;
  final String createdBy;
  final DateTime createdAt;

  bool get isShared => assignedTo == both;

  bool isAssignedTo(String uid) => assignedTo == uid;

  Chore copyWith({
    String? id,
    String? title,
    String? assignedTo,
    DateTime? dueAt,
    bool? done,
    String? createdBy,
    DateTime? createdAt,
    bool clearDueAt = false,
  }) {
    return Chore(
      id: id ?? this.id,
      title: title ?? this.title,
      assignedTo: assignedTo ?? this.assignedTo,
      dueAt: clearDueAt ? null : (dueAt ?? this.dueAt),
      done: done ?? this.done,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'assignedTo': assignedTo,
      'dueAt': dueAt?.toIso8601String(),
      'done': done,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Chore.fromMap(Map<String, dynamic> map) {
    return Chore(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      assignedTo: map['assignedTo'] as String? ?? both,
      dueAt: DateTime.tryParse(map['dueAt'] as String? ?? ''),
      done: map['done'] as bool? ?? false,
      createdBy: map['createdBy'] as String? ?? '',
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ??
              DateTime.now(),
    );
  }
}
