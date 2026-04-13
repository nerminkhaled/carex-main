import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/sos_alert.dart';

class SOSRepository {
  final SupabaseClient _client = Supabase.instance.client;

  String get _uid =>
      _client.auth.currentUser?.id ??
      (throw Exception('Session expired. Please log in again.'));

  Future<SOSAlert> sendSOS({String message = 'Emergency! I need help.'}) async {
    final row = await _client
        .from('sos_alerts')
        .insert({
          'patient_id': _uid,
          'message': message,
          'status': 'pending',
        })
        .select()
        .single();
    return SOSAlert.fromJson(row);
  }

  Future<List<SOSAlert>> getMyAlerts() async {
    final rows = await _client
        .from('sos_alerts')
        .select()
        .eq('patient_id', _uid)
        .order('time', ascending: false)
        .limit(20);
    return rows.map((r) => SOSAlert.fromJson(r)).toList();
  }
}
