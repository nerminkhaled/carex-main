enum ReadingType { bp, sugar, pulse, weight }

extension ReadingTypeX on ReadingType {
  /// The string stored in the DB matches the original class diagram values.
  String get dbValue => switch (this) {
        ReadingType.bp => 'BP',
        ReadingType.sugar => 'Sugar',
        ReadingType.pulse => 'Pulse',
        ReadingType.weight => 'Weight',
      };

  static ReadingType from(String s) => switch (s) {
        'BP' => ReadingType.bp,
        'Sugar' => ReadingType.sugar,
        'Pulse' => ReadingType.pulse,
        'Weight' => ReadingType.weight,
        _ => throw ArgumentError('Unknown reading type: $s'),
      };

  String get unit => switch (this) {
        ReadingType.bp => 'mmHg',
        ReadingType.sugar => 'mg/dL',
        ReadingType.pulse => 'bpm',
        ReadingType.weight => 'kg',
      };
}

class Reading {
  final String id;
  final String patientId;
  final ReadingType type;
  final String value;
  final String unit;
  final DateTime date;
  final DateTime createdAt;

  const Reading({
    required this.id,
    required this.patientId,
    required this.type,
    required this.value,
    required this.unit,
    required this.date,
    required this.createdAt,
  });

  factory Reading.fromJson(Map<String, dynamic> json) => Reading(
        id: json['id'] as String,
        patientId: json['patient_id'] as String,
        type: ReadingTypeX.from(json['type'] as String),
        value: json['value'] as String,
        unit: json['unit'] as String,
        date: DateTime.parse(json['date'] as String),
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'patient_id': patientId,
        'type': type.dbValue,
        'value': value,
        'unit': unit,
        'date': date.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };
}
