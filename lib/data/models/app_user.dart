class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    this.photoUrl,
    this.coupleId,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String? photoUrl;
  final String? coupleId;
  final DateTime createdAt;

  String get firstName {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'You';
    return trimmed.split(RegExp(r'\s+')).first;
  }

  AppUser copyWith({
    String? id,
    String? name,
    String? photoUrl,
    String? coupleId,
    DateTime? createdAt,
    bool clearCoupleId = false,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      coupleId: clearCoupleId ? null : (coupleId ?? this.coupleId),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'photoUrl': photoUrl,
      'coupleId': coupleId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? 'You',
      photoUrl: map['photoUrl'] as String?,
      coupleId: map['coupleId'] as String?,
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ??
              DateTime.now(),
    );
  }
}
