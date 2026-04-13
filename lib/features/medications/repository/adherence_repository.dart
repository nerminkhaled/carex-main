import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/adherence_log.dart';

/// Manages adherence logging with offline support.
/// The Hive box is opened lazily on first use — no explicit init() required.
class AdherenceRepository {
  static const _boxName = 'pending_adherence_logs';

  final SupabaseClient _client = Supabase.instance.client;
  Box<Map>? _pendingBox;

  String get _uid =>
      _client.auth.currentUser?.id ??
      (throw Exception('Session expired. Please log in again.'));

  Future<Box<Map>> _box() async {
    _pendingBox ??= await Hive.openBox<Map>(_boxName);
    return _pendingBox!;
  }

  // Keep init() for backwards compatibility — calling it is still fine.
  Future<void> init() => _box();

  // ── Log a dose ────────────────────────────────────────────────

  Future<void> logDose({
    required String scheduleEntryId,
    required DateTime scheduledAt,
    required AdherenceStatus status,
    DateTime? takenAt,
  }) async {
    final payload = {
      'schedule_entry_id': scheduleEntryId,
      'patient_id': _uid,
      'scheduled_at': scheduledAt.toIso8601String(),
      'status': status.value,
      if (takenAt != null) 'taken_at': takenAt.toIso8601String(),
    };

    try {
      await _client.from('adherence_logs').insert(payload);
    } catch (_) {
      // Offline — queue for later sync.
      final box = await _box();
      await box.add(payload);
    }
  }

  /// Flushes any locally queued logs to Supabase.
  Future<void> syncPending() async {
    final box = await _box();
    if (box.isEmpty) return;
    final pending = box.values.toList();
    try {
      await _client
          .from('adherence_logs')
          .insert(pending.map((m) => Map<String, dynamic>.from(m)).toList());
      await box.clear();
    } catch (_) {
      // Still offline — leave in box for next attempt.
    }
  }

  // ── Queries ───────────────────────────────────────────────────

  Future<List<AdherenceLog>> getLogsForEntry(String scheduleEntryId) async {
    final rows = await _client
        .from('adherence_logs')
        .select()
        .eq('schedule_entry_id', scheduleEntryId)
        .order('scheduled_at', ascending: false);
    return rows.map((r) => AdherenceLog.fromJson(r)).toList();
  }

  Future<List<AdherenceLog>> getRecentLogs({int days = 7}) async {
    final since =
        DateTime.now().subtract(Duration(days: days)).toIso8601String();
    final rows = await _client
        .from('adherence_logs')
        .select()
        .eq('patient_id', _uid)
        .gte('scheduled_at', since)
        .order('scheduled_at', ascending: false);
    return rows.map((r) => AdherenceLog.fromJson(r)).toList();
  }

  Future<List<AdherenceLog>> getLogsForPatient(
    String patientId, {
    int days = 7,
  }) async {
    final since =
        DateTime.now().subtract(Duration(days: days)).toIso8601String();
    final rows = await _client
        .from('adherence_logs')
        .select()
        .eq('patient_id', patientId)
        .gte('scheduled_at', since)
        .order('scheduled_at', ascending: false);
    return rows.map((r) => AdherenceLog.fromJson(r)).toList();
  }
}
