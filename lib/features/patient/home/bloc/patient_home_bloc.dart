import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/app_error.dart';
import '../../../../core/models/adherence_log.dart';
import '../../../../core/models/medication.dart';
import '../../../../core/models/reading.dart';
import '../../../../core/models/schedule_entry.dart';
import '../../../../core/models/today_dose.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../features/medications/repository/adherence_repository.dart';
import '../../../../features/medications/repository/medication_repository.dart';
import '../../../../features/readings/repository/reading_repository.dart';
import '../../../patient/repository/sos_repository.dart';
import 'patient_home_event.dart';
import 'patient_home_state.dart';

class PatientHomeBloc extends Bloc<PatientHomeEvent, PatientHomeState> {
  final MedicationRepository _medRepo;
  final AdherenceRepository _adherenceRepo;
  final ReadingRepository _readingRepo;
  final SOSRepository _sosRepo;

  PatientHomeBloc({
    required MedicationRepository medRepo,
    required AdherenceRepository adherenceRepo,
    required ReadingRepository readingRepo,
    required SOSRepository sosRepo,
  })  : _medRepo = medRepo,
        _adherenceRepo = adherenceRepo,
        _readingRepo = readingRepo,
        _sosRepo = sosRepo,
        super(const PatientHomeState()) {
    on<PatientHomeLoadRequested>(_onLoad);
    on<PatientHomeDoseTaken>(_onDoseTaken);
    on<PatientHomeDoseSkipped>(_onDoseSkipped);
    on<PatientHomeDoseRemindLater>(_onDoseRemindLater);
    on<PatientHomeSOSSent>(_onSOSSent);
  }

  Future<void> _onLoad(
    PatientHomeLoadRequested event,
    Emitter<PatientHomeState> emit,
  ) async {
    emit(state.copyWith(status: PatientHomeStatus.loading));
    try {
      final meds = await _medRepo.getMedications();
      final entries = await _medRepo.getAllScheduleEntries();
      // Fetch 7 days of logs — covers both today's doses and weekly stats.
      final weeklyLogs = await _adherenceRepo.getRecentLogs(days: 7);
      final readings = await _readingRepo.getReadings(limit: 30);

      final todayDoses = _buildTodayDoses(meds, entries, weeklyLogs);

      // Weekly adherence stats.
      final taken =
          weeklyLogs.where((l) => l.status == AdherenceStatus.taken).length;
      final missed =
          weeklyLogs.where((l) => l.status == AdherenceStatus.missed).length;
      final total = weeklyLogs.length;
      final weeklyPercent = total > 0 ? taken / total : 0.0;

      // Resync local notifications with latest schedule.
      final medsById = {for (final m in meds) m.id: m};
      await NotificationService.instance.resyncSchedule(
        entries: entries,
        medicationsById: medsById,
      );

      // Flush any offline-queued adherence logs.
      await _adherenceRepo.syncPending();

      emit(state.copyWith(
        status: PatientHomeStatus.loaded,
        todayDoses: todayDoses,
        weeklyAdherencePercent: weeklyPercent,
        missedThisWeek: missed,
        lastBP: readings.where((r) => r.type == ReadingType.bp).firstOrNull,
        lastSugar:
            readings.where((r) => r.type == ReadingType.sugar).firstOrNull,
        lastPulse:
            readings.where((r) => r.type == ReadingType.pulse).firstOrNull,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PatientHomeStatus.error,
        errorMessage: toUserMessage(e),
      ));
    }
  }

  Future<void> _onDoseTaken(
    PatientHomeDoseTaken event,
    Emitter<PatientHomeState> emit,
  ) async {
    await _adherenceRepo.logDose(
      scheduleEntryId: event.scheduleEntryId,
      scheduledAt: event.scheduledAt,
      status: AdherenceStatus.taken,
      takenAt: DateTime.now(),
    );
    await NotificationService.instance.cancelForEntry(event.scheduleEntryId);
    add(const PatientHomeLoadRequested());
  }

  Future<void> _onDoseSkipped(
    PatientHomeDoseSkipped event,
    Emitter<PatientHomeState> emit,
  ) async {
    await _adherenceRepo.logDose(
      scheduleEntryId: event.scheduleEntryId,
      scheduledAt: event.scheduledAt,
      status: AdherenceStatus.skipped,
    );
    add(const PatientHomeLoadRequested());
  }

  Future<void> _onDoseRemindLater(
    PatientHomeDoseRemindLater event,
    Emitter<PatientHomeState> emit,
  ) async {
    await NotificationService.instance.scheduleRemindLater(
      scheduleEntryId: event.scheduleEntryId,
      medicationName: event.medicationName,
    );
  }

  Future<void> _onSOSSent(
    PatientHomeSOSSent event,
    Emitter<PatientHomeState> emit,
  ) async {
    try {
      await _sosRepo.sendSOS();
      emit(state.copyWith(sosSent: true));
      // Reset flag after a moment so UI can respond.
      await Future.delayed(const Duration(seconds: 3));
      emit(state.copyWith(sosSent: false));
    } catch (_) {}
  }

  List<TodayDose> _buildTodayDoses(
    List<Medication> meds,
    List<ScheduleEntry> entries,
    List<AdherenceLog> logs,
  ) {
    final medsById = {for (final m in meds) m.id: m};
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    // Index today's logs by scheduleEntryId.
    final logsToday = {
      for (final l in logs)
        if (l.scheduledAt.isAfter(todayStart) &&
            l.scheduledAt.isBefore(todayEnd))
          l.scheduleEntryId: l,
    };

    final doses = <TodayDose>[];
    for (final entry in entries) {
      final med = medsById[entry.medicationId];
      if (med == null) continue;
      doses.add(TodayDose(
        entry: entry,
        medication: med,
        log: logsToday[entry.id],
      ));
    }

    // Sort by scheduled time.
    doses.sort((a, b) => a.entry.time.compareTo(b.entry.time));
    return doses;
  }
}
