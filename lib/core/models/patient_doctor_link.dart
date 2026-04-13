class PatientDoctorLink {
  final String id;
  final String patientId;
  final String doctorId;
  final DateTime createdAt;

  const PatientDoctorLink({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.createdAt,
  });

  factory PatientDoctorLink.fromJson(Map<String, dynamic> json) =>
      PatientDoctorLink(
        id: json['id'] as String,
        patientId: json['patient_id'] as String,
        doctorId: json['doctor_id'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'patient_id': patientId,
        'doctor_id': doctorId,
        'created_at': createdAt.toIso8601String(),
      };
}
