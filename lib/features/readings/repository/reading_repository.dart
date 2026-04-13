import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/reading.dart';

class ReadingRepository {
  final SupabaseClient _client = Supabase.instance.client;

  String get _uid =>
      _client.auth.currentUser?.id ??
      (throw Exception('Session expired. Please log in again.'));

  Future<List<Reading>> getReadings({ReadingType? type, int limit = 50}) async {
    var query = _client
        .from('readings')
        .select()
        .eq('patient_id', _uid);
    if (type != null) {
      query = query.eq('type', type.dbValue);
    }
    final rows = await query
        .order('date', ascending: false)
        .limit(limit);
    return rows.map((r) => Reading.fromJson(r)).toList();
  }

  Future<Reading> addReading({
    required ReadingType type,
    required String value,
  }) async {
    final row = await _client
        .from('readings')
        .insert({
          'patient_id': _uid,
          'type': type.dbValue,
          'value': value,
          'unit': type.unit,
        })
        .select()
        .single();
    return Reading.fromJson(row);
  }

  Future<void> deleteReading(String readingId) async {
    await _client.from('readings').delete().eq('id', readingId);
  }

  /// Returns readings for a specific patient — used by doctors.
  Future<List<Reading>> getReadingsForPatient(
    String patientId, {
    ReadingType? type,
    int limit = 50,
  }) async {
    var query = _client
        .from('readings')
        .select()
        .eq('patient_id', patientId);
    if (type != null) {
      query = query.eq('type', type.dbValue);
    }
    final rows = await query
        .order('date', ascending: false)
        .limit(limit);
    return rows.map((r) => Reading.fromJson(r)).toList();
  }
}
