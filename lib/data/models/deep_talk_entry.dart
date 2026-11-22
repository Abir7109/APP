class DeepTalkEntry {
  const DeepTalkEntry({
    required this.id,
    required this.question,
    required this.answer,
    required this.uid,
    required this.createdAt,
  });

  final String id;
  final String question;
  final String answer;
  final String uid;
  final DateTime createdAt;

  DeepTalkEntry copyWith({
    String? id,
    String? question,
    String? answer,
    String? uid,
    DateTime? createdAt,
  }) {
    return DeepTalkEntry(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      uid: uid ?? this.uid,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'uid': uid,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory DeepTalkEntry.fromMap(Map<String, dynamic> map) {
    return DeepTalkEntry(
      id: map['id'] as String? ?? '',
      question: map['question'] as String? ?? '',
      answer: map['answer'] as String? ?? '',
      uid: map['uid'] as String? ?? '',
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ??
              DateTime.now(),
    );
  }
}
