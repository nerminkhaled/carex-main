import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/schedule_entry.dart';
import '../models/medication.dart';

/// Handles all local notification scheduling for medication reminders.
/// Call [init] once at app startup.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  static const _channelId = 'carex_medications';
  static const _channelName = 'Medication Reminders';

  /// Callback invoked when the user taps a notification.
  /// Receives the scheduleEntryId encoded in the payload.
  void Function(String scheduleEntryId)? onNotificationTap;

  /// Stores the most recent tapped scheduleEntryId until a handler picks it up.
  String? pendingEntryId;

  Future<void> init({void Function(String scheduleEntryId)? onTap}) async {
    onNotificationTap = onTap;
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) {
          onNotificationTap?.call(details.payload!);
        }
      },
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Cancels all existing medication reminders and reschedules from [entries].
  /// Call this every time the schedule changes or the app comes to foreground.
  Future<void> resyncSchedule({
    required List<ScheduleEntry> entries,
    required Map<String, Medication> medicationsById,
  }) async {
    await _plugin.cancelAll();

    for (final entry in entries) {
      final med = medicationsById[entry.medicationId];
      if (med == null) continue;
      await _scheduleDailyReminder(entry: entry, medicationName: med.name);
    }
  }

  Future<void> _scheduleDailyReminder({
    required ScheduleEntry entry,
    required String medicationName,
  }) async {
    final (hour, minute) = entry.parsedTime;
    final now = tz.TZDateTime.now(tz.local);

    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    // If time already passed today, start from tomorrow.
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    final notifId = _idFromEntryId(entry.id);

    await _plugin.zonedSchedule(
      notifId,
      'Time to take $medicationName',
      'Tap to mark as taken',
      scheduled,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // repeat daily
      payload: entry.id,
    );
  }

  Future<void> cancelForEntry(String scheduleEntryId) async {
    await _plugin.cancel(_idFromEntryId(scheduleEntryId));
  }

  /// Schedules a one-off notification exactly 1 hour from now.
  Future<void> remindInOneHour({
    required ScheduleEntry entry,
    required String medicationName,
  }) =>
      scheduleRemindLater(
        scheduleEntryId: entry.id,
        medicationName: medicationName,
        delay: const Duration(hours: 1),
      );

  /// Schedules a one-time "remind later" notification [delay] from now.
  Future<void> scheduleRemindLater({
    required String scheduleEntryId,
    required String medicationName,
    Duration delay = const Duration(minutes: 15),
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    final scheduled = now.add(delay);
    final notifId = _idFromEntryId('rl_$scheduleEntryId');

    await _plugin.zonedSchedule(
      notifId,
      "Don't forget: $medicationName",
      'Tap to mark as taken',
      scheduled,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: scheduleEntryId,
    );
  }

  /// Converts a UUID to a stable int id for the notification system.
  int _idFromEntryId(String id) => id.hashCode.abs() % 2147483647;
}
