abstract class PatientHomeEvent {
  const PatientHomeEvent();
}

class PatientHomeLoadRequested extends PatientHomeEvent {
  const PatientHomeLoadRequested();
}

class PatientHomeDoseTaken extends PatientHomeEvent {
  final String scheduleEntryId;
  final DateTime scheduledAt;
  const PatientHomeDoseTaken({
    required this.scheduleEntryId,
    required this.scheduledAt,
  });
}

class PatientHomeDoseSkipped extends PatientHomeEvent {
  final String scheduleEntryId;
  final DateTime scheduledAt;
  const PatientHomeDoseSkipped({
    required this.scheduleEntryId,
    required this.scheduledAt,
  });
}

class PatientHomeDoseRemindLater extends PatientHomeEvent {
  final String scheduleEntryId;
  final String medicationName;
  const PatientHomeDoseRemindLater({
    required this.scheduleEntryId,
    required this.medicationName,
  });
}

class PatientHomeSOSSent extends PatientHomeEvent {
  const PatientHomeSOSSent();
}
