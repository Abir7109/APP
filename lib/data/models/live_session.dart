enum LiveSessionStatus {
  pending,
  allowed,
  denied,
  ended;

  static LiveSessionStatus parse(Object? value) {
    return switch (value) {
      'allowed' => LiveSessionStatus.allowed,
      'denied' => LiveSessionStatus.denied,
      'ended' => LiveSessionStatus.ended,
      _ => LiveSessionStatus.pending,
    };
  }

  String get wireName => name;
}

class LivePoint {
  const LivePoint({
    required this.latitude,
    required this.longitude,
    required this.updatedAt,
    this.accuracy,
  });

  final double latitude;
  final double longitude;
  final DateTime updatedAt;
  final double? accuracy;

  bool get isValid =>
      latitude.isFinite &&
      longitude.isFinite &&
      latitude.abs() <= 90 &&
      longitude.abs() <= 180;

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'updatedAt': updatedAt.toIso8601String(),
      'accuracy': accuracy,
    };
  }

  factory LivePoint.fromMap(Map<String, dynamic> map) {
    return LivePoint(
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0,
      updatedAt:
          DateTime.tryParse(map['updatedAt'] as String? ?? '') ??
              DateTime.now(),
      accuracy: (map['accuracy'] as num?)?.toDouble(),
    );
  }
}

class LiveSession {
  const LiveSession({
    required this.id,
    required this.requesterId,
    required this.requesterName,
    required this.status,
    required this.createdAt,
    this.respondedAt,
    this.expiresAt,
    this.points = const {},
  });

  final String id;
  final String requesterId;
  final String requesterName;
  final LiveSessionStatus status;
  final DateTime createdAt;
  final DateTime? respondedAt;
  final DateTime? expiresAt;
  final Map<String, LivePoint> points;

  bool get isPending => status == LiveSessionStatus.pending;
  bool get isAllowed => status == LiveSessionStatus.allowed;
  bool get isDenied => status == LiveSessionStatus.denied;
  bool get isEnded => status == LiveSessionStatus.ended;

  bool get isExpired {
    final limit = expiresAt;
    return isPending && limit != null && !DateTime.now().isBefore(limit);
  }

  LivePoint? pointFor(String uid) => points[uid];

  bool requestedBy(String uid) => requesterId == uid;

  LiveSession copyWith({
    String? id,
    String? requesterId,
    String? requesterName,
    LiveSessionStatus? status,
    DateTime? createdAt,
    DateTime? respondedAt,
    DateTime? expiresAt,
    Map<String, LivePoint>? points,
    bool clearRespondedAt = false,
    bool clearExpiresAt = false,
  }) {
    return LiveSession(
      id: id ?? this.id,
      requesterId: requesterId ?? this.requesterId,
      requesterName: requesterName ?? this.requesterName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: clearRespondedAt ? null : (respondedAt ?? this.respondedAt),
      expiresAt: clearExpiresAt ? null : (expiresAt ?? this.expiresAt),
      points: points ?? this.points,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'requesterId': requesterId,
      'requesterName': requesterName,
      'status': status.wireName,
      'createdAt': createdAt.toIso8601String(),
      'respondedAt': respondedAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'points': points.map((uid, point) => MapEntry(uid, point.toMap())),
    };
  }

  factory LiveSession.fromMap(Map<String, dynamic> map) {
    final rawPoints = map['points'];
    final points = <String, LivePoint>{};
    if (rawPoints is Map) {
      for (final entry in rawPoints.entries) {
        final value = entry.value;
        if (value is Map) {
          points[entry.key.toString()] = LivePoint.fromMap(
            value.cast<String, dynamic>(),
          );
        }
      }
    }
    return LiveSession(
      id: map['id'] as String? ?? 'current',
      requesterId: map['requesterId'] as String? ?? '',
      requesterName: map['requesterName'] as String? ?? 'Your person',
      status: LiveSessionStatus.parse(map['status']),
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ??
              DateTime.now(),
      respondedAt: DateTime.tryParse(map['respondedAt'] as String? ?? ''),
      expiresAt: DateTime.tryParse(map['expiresAt'] as String? ?? ''),
      points: points,
    );
  }
}
