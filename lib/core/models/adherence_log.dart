enum AdherenceStatus { taken, missed, skipped }

extension AdherenceStatusX on AdherenceStatus {
  String get value => name; // 'taken' | 'missed' | 'skipped'

  static AdherenceStatus from(String s) =>
      AdherenceStatus.values.firstWhere((e) => e.name == s);
}

class AdherenceLog {
  final String id;
  final String scheduleEntryId;
  final String patientId;
  final DateTime scheduledAt;
  final DateTime? takenAt;
  final AdherenceStatus status;
  final DateTime createdAt;

  const AdherenceLog({
    required this.id,
    required this.scheduleEntryId,
    required this.patientId,
    required this.scheduledAt,
    this.takenAt,
    required this.status,
    required this.createdAt,
  });

  factory AdherenceLog.fromJson(Map<String, dynamic> json) => AdherenceLog(
        id: json['id'] as String,
        scheduleEntryId: json['schedule_entry_id'] as String,
        patientId: json['patient_id'] as String,
        scheduledAt: DateTime.parse(json['scheduled_at'] as String),
        takenAt: json['taken_at'] != null
            ? DateTime.parse(json['taken_at'] as String)
            : null,
        status: AdherenceStatusX.from(json['status'] as String),
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'schedule_entry_id': scheduleEntryId,
        'patient_id': patientId,
        'scheduled_at': scheduledAt.toIso8601String(),
        if (takenAt != null) 'taken_at': takenAt!.toIso8601String(),
        'status': status.value,
        'created_at': createdAt.toIso8601String(),
      };

  AdherenceLog copyWith({AdherenceStatus? status, DateTime? takenAt}) =>
      AdherenceLog(
        id: id,
        scheduleEntryId: scheduleEntryId,
        patientId: patientId,
        scheduledAt: scheduledAt,
        takenAt: takenAt ?? this.takenAt,
        status: status ?? this.status,
        createdAt: createdAt,
      );
}
