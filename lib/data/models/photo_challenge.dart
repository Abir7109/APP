class PhotoChallenge {
  const PhotoChallenge({
    required this.id,
    required this.prompt,
    required this.weekKey,
    this.photoData,
    this.photoUrl,
    this.completedBy,
    this.completedAt,
    required this.createdAt,
  });

  final String id;
  final String prompt;
  final String weekKey;
  final String? photoData;
  final String? photoUrl;
  final String? completedBy;
  final DateTime? completedAt;
  final DateTime createdAt;

  bool get isComplete => completedAt != null;

  String? get imageSource => photoUrl ?? photoData;

  PhotoChallenge copyWith({
    String? id,
    String? prompt,
    String? weekKey,
    String? photoData,
    String? photoUrl,
    String? completedBy,
    DateTime? completedAt,
    DateTime? createdAt,
    bool clearPhoto = false,
    bool clearCompletion = false,
  }) {
    return PhotoChallenge(
      id: id ?? this.id,
      prompt: prompt ?? this.prompt,
      weekKey: weekKey ?? this.weekKey,
      photoData: clearPhoto ? null : (photoData ?? this.photoData),
      photoUrl: clearPhoto ? null : (photoUrl ?? this.photoUrl),
      completedBy: clearCompletion ? null : (completedBy ?? this.completedBy),
      completedAt: clearCompletion ? null : (completedAt ?? this.completedAt),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'prompt': prompt,
      'weekKey': weekKey,
      'photoData': photoData,
      'photoUrl': photoUrl,
      'completedBy': completedBy,
      'completedAt': completedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PhotoChallenge.fromMap(Map<String, dynamic> map) {
    return PhotoChallenge(
      id: map['id'] as String? ?? '',
      prompt: map['prompt'] as String? ?? '',
      weekKey: map['weekKey'] as String? ?? '',
      photoData: map['photoData'] as String?,
      photoUrl: map['photoUrl'] as String?,
      completedBy: map['completedBy'] as String?,
      completedAt: DateTime.tryParse(map['completedAt'] as String? ?? ''),
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ??
              DateTime.now(),
    );
  }
}
