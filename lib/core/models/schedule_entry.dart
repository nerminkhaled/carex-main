class ScheduleEntry {
  final String id;
  final String medicationId;
  /// Time in HH:mm 24-hour format e.g. "08:00"
  final String time;
  /// "daily" | "weekly" | "custom"
  final String repeatPattern;
  final DateTime? nextOccurrence;
  final DateTime createdAt;

  const ScheduleEntry({
    required this.id,
    required this.medicationId,
    required this.time,
    required this.repeatPattern,
    this.nextOccurrence,
    required this.createdAt,
  });

  factory ScheduleEntry.fromJson(Map<String, dynamic> json) => ScheduleEntry(
        id: json['id'] as String,
        medicationId: json['medication_id'] as String,
        time: json['time'] as String,
        repeatPattern: json['repeat_pattern'] as String,
        nextOccurrence: json['next_occurrence'] != null
            ? DateTime.parse(json['next_occurrence'] as String)
            : null,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'medication_id': medicationId,
        'time': time,
        'repeat_pattern': repeatPattern,
        if (nextOccurrence != null)
          'next_occurrence': nextOccurrence!.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };

  /// Returns hour and minute parsed from [time] string.
  (int hour, int minute) get parsedTime {
    final parts = time.split(':');
    return (int.parse(parts[0]), int.parse(parts[1]));
  }
}
