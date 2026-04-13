import 'package:equatable/equatable.dart';

import '../../../../core/models/reading.dart';
import '../../../../core/models/today_dose.dart';

enum PatientHomeStatus { initial, loading, loaded, error }

class PatientHomeState extends Equatable {
  final PatientHomeStatus status;
  final List<TodayDose> todayDoses;
  final Reading? lastBP;
  final Reading? lastSugar;
  final Reading? lastPulse;
  final String? errorMessage;
  final bool sosSent;
  final double weeklyAdherencePercent;
  final int missedThisWeek;

  const PatientHomeState({
    this.status = PatientHomeStatus.initial,
    this.todayDoses = const [],
    this.lastBP,
    this.lastSugar,
    this.lastPulse,
    this.errorMessage,
    this.sosSent = false,
    this.weeklyAdherencePercent = 0.0,
    this.missedThisWeek = 0,
  });

  /// The next pending dose for the upcoming reminder card.
  TodayDose? get nextDose =>
      todayDoses.where((d) => d.isPending).cast<TodayDose?>().firstOrNull;

  PatientHomeState copyWith({
    PatientHomeStatus? status,
    List<TodayDose>? todayDoses,
    Reading? lastBP,
    Reading? lastSugar,
    Reading? lastPulse,
    String? errorMessage,
    bool? sosSent,
    double? weeklyAdherencePercent,
    int? missedThisWeek,
  }) =>
      PatientHomeState(
        status: status ?? this.status,
        todayDoses: todayDoses ?? this.todayDoses,
        lastBP: lastBP ?? this.lastBP,
        lastSugar: lastSugar ?? this.lastSugar,
        lastPulse: lastPulse ?? this.lastPulse,
        errorMessage: errorMessage ?? this.errorMessage,
        sosSent: sosSent ?? this.sosSent,
        weeklyAdherencePercent:
            weeklyAdherencePercent ?? this.weeklyAdherencePercent,
        missedThisWeek: missedThisWeek ?? this.missedThisWeek,
      );

  @override
  List<Object?> get props => [
        status,
        todayDoses,
        lastBP,
        lastSugar,
        lastPulse,
        errorMessage,
        sosSent,
        weeklyAdherencePercent,
        missedThisWeek,
      ];
}
