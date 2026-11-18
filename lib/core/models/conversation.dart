class Conversation {
  final int id;
  final int requestId;
  final String requestType; // 'service_request' | 'shift'
  final int familyId;
  final int professionalId;
  final String familyName;
  final String professionalName;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;

  /// dateStart of the linked shift. Null for on-demand (always unlocked).
  final DateTime? visitDate;

  /// Name of the patient for display in the conversation list.
  final String? patientName;

  Conversation({
    required this.id,
    required this.requestId,
    required this.requestType,
    required this.familyId,
    required this.professionalId,
    required this.familyName,
    required this.professionalName,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.visitDate,
    this.patientName,
  });

  /// Chat is locked until 24 h before a scheduled visit.
  /// On-demand conversations are always open.
  bool get isChatLocked {
    if (requestType == 'service_request') return false;
    if (visitDate == null) return false;
    return visitDate!.difference(DateTime.now()) > const Duration(hours: 24);
  }

  /// Time remaining until chat unlocks. Null if already unlocked.
  Duration? get timeUntilUnlock {
    if (!isChatLocked || visitDate == null) return null;
    final unlockAt = visitDate!.subtract(const Duration(hours: 24));
    return unlockAt.difference(DateTime.now());
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as int,
      requestId: json['request_id'] as int,
      requestType: json['request_type'] as String,
      familyId: json['family_id'] as int,
      professionalId: json['professional_id'] as int,
      familyName: json['family_name'] as String,
      professionalName: json['professional_name'] as String,
      lastMessage: json['last_message'] as String?,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : null,
      unreadCount: json['unread_count'] as int? ?? 0,
      visitDate: json['visit_date'] != null
          ? DateTime.parse(json['visit_date'] as String)
          : null,
      patientName: json['patient_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'request_id': requestId,
        'request_type': requestType,
        'family_id': familyId,
        'professional_id': professionalId,
        'family_name': familyName,
        'professional_name': professionalName,
        'last_message': lastMessage,
        'last_message_at': lastMessageAt?.toIso8601String(),
        'unread_count': unreadCount,
        'visit_date': visitDate?.toIso8601String(),
        'patient_name': patientName,
      };

  Conversation copyWith({
    int? id,
    int? requestId,
    String? requestType,
    int? familyId,
    int? professionalId,
    String? familyName,
    String? professionalName,
    String? lastMessage,
    DateTime? lastMessageAt,
    int? unreadCount,
    DateTime? visitDate,
    String? patientName,
  }) =>
      Conversation(
        id: id ?? this.id,
        requestId: requestId ?? this.requestId,
        requestType: requestType ?? this.requestType,
        familyId: familyId ?? this.familyId,
        professionalId: professionalId ?? this.professionalId,
        familyName: familyName ?? this.familyName,
        professionalName: professionalName ?? this.professionalName,
        lastMessage: lastMessage ?? this.lastMessage,
        lastMessageAt: lastMessageAt ?? this.lastMessageAt,
        unreadCount: unreadCount ?? this.unreadCount,
        visitDate: visitDate ?? this.visitDate,
        patientName: patientName ?? this.patientName,
      );
}
