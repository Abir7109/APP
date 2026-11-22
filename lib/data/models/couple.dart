class Couple {
  const Couple({
    required this.id,
    required this.memberIds,
    required this.pin,
    required this.anniversary,
    required this.createdAt,
    this.partnerName,
  });

  final String id;
  final List<String> memberIds;
  final String pin;
  final DateTime anniversary;
  final DateTime createdAt;
  final String? partnerName;

  Couple copyWith({
    String? id,
    List<String>? memberIds,
    String? pin,
    DateTime? anniversary,
    DateTime? createdAt,
    String? partnerName,
  }) {
    return Couple(
      id: id ?? this.id,
      memberIds: memberIds ?? this.memberIds,
      pin: pin ?? this.pin,
      anniversary: anniversary ?? this.anniversary,
      createdAt: createdAt ?? this.createdAt,
      partnerName: partnerName ?? this.partnerName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'memberIds': memberIds,
      'pin': pin,
      'anniversary': anniversary.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'partnerName': partnerName,
    };
  }

  factory Couple.fromMap(Map<String, dynamic> map) {
    return Couple(
      id: map['id'] as String? ?? '',
      memberIds:
          (map['memberIds'] as List<dynamic>?)?.cast<String>() ?? const [],
      pin: map['pin'] as String? ?? '',
      anniversary:
          DateTime.tryParse(map['anniversary'] as String? ?? '') ??
              DateTime.now(),
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ??
              DateTime.now(),
      partnerName: map['partnerName'] as String?,
    );
  }
}
