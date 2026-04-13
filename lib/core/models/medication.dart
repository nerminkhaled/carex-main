class Medication {
  final String id;
  final String patientId;
  final String name;
  final String dose;
  final String? instructions;
  final String? imageUrl;
  final DateTime createdAt;

  const Medication({
    required this.id,
    required this.patientId,
    required this.name,
    required this.dose,
    this.instructions,
    this.imageUrl,
    required this.createdAt,
  });

  factory Medication.fromJson(Map<String, dynamic> json) => Medication(
        id: json['id'] as String,
        patientId: json['patient_id'] as String,
        name: json['name'] as String,
        dose: json['dose'] as String,
        instructions: json['instructions'] as String?,
        imageUrl: json['image_url'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'patient_id': patientId,
        'name': name,
        'dose': dose,
        if (instructions != null) 'instructions': instructions,
        if (imageUrl != null) 'image_url': imageUrl,
        'created_at': createdAt.toIso8601String(),
      };

  Medication copyWith({
    String? name,
    String? dose,
    String? instructions,
    String? imageUrl,
  }) =>
      Medication(
        id: id,
        patientId: patientId,
        name: name ?? this.name,
        dose: dose ?? this.dose,
        instructions: instructions ?? this.instructions,
        imageUrl: imageUrl ?? this.imageUrl,
        createdAt: createdAt,
      );
}
