class NotificationModel {
  final String id;
  final String patientId;
  final String message;
  final DateTime sendAt;
  final DateTime? readAt;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.patientId,
    required this.message,
    required this.sendAt,
    this.readAt,
    required this.createdAt,
  });

  bool get isRead => readAt != null;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json['id'] as String,
        patientId: json['patient_id'] as String,
        message: json['message'] as String,
        sendAt: DateTime.parse(json['send_at'] as String),
        readAt: json['read_at'] != null
            ? DateTime.parse(json['read_at'] as String)
            : null,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'patient_id': patientId,
        'message': message,
        'send_at': sendAt.toIso8601String(),
        if (readAt != null) 'read_at': readAt!.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };

  NotificationModel copyWith({DateTime? readAt}) => NotificationModel(
        id: id,
        patientId: patientId,
        message: message,
        sendAt: sendAt,
        readAt: readAt ?? this.readAt,
        createdAt: createdAt,
      );
}
