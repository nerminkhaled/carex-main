import 'adherence_log.dart';
import 'medication.dart';
import 'schedule_entry.dart';

class TodayDose {
  final ScheduleEntry entry;
  final Medication medication;
  final AdherenceLog? log;

  const TodayDose({
    required this.entry,
    required this.medication,
    this.log,
  });

  bool get isTaken => log?.status == AdherenceStatus.taken;
  bool get isSkipped => log?.status == AdherenceStatus.skipped;
  bool get isPending => log == null;

  /// The exact DateTime this dose is scheduled for today.
  DateTime get scheduledAt {
    final now = DateTime.now();
    final (hour, minute) = entry.parsedTime;
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  bool get isOverdue => isPending && scheduledAt.isBefore(DateTime.now());
}
