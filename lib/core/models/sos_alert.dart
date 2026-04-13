enum SOSStatus { pending, acknowledged }

extension SOSStatusX on SOSStatus {
  String get value => name;
  static SOSStatus from(String s) =>
      SOSStatus.values.firstWhere((e) => e.name == s);
}

class SOSAlert {
  final String id;
  final String patientId;
  final String message;
  final DateTime time;
  final SOSStatus status;
  final DateTime createdAt;

  const SOSAlert({
    required this.id,
    required this.patientId,
    required this.message,
    required this.time,
    required this.status,
    required this.createdAt,
  });

  factory SOSAlert.fromJson(Map<String, dynamic> json) => SOSAlert(
        id: json['id'] as String,
        patientId: json['patient_id'] as String,
        message: json['message'] as String,
        time: DateTime.parse(json['time'] as String),
        status: SOSStatusX.from(json['status'] as String),
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'patient_id': patientId,
        'message': message,
        'time': time.toIso8601String(),
        'status': status.value,
        'created_at': createdAt.toIso8601String(),
      };

  SOSAlert copyWith({SOSStatus? status}) => SOSAlert(
        id: id,
        patientId: patientId,
        message: message,
        time: time,
        status: status ?? this.status,
        createdAt: createdAt,
      );
}
