import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/medication.dart';
import '../../../core/models/schedule_entry.dart';

class MedicationRepository {
  final SupabaseClient _client = Supabase.instance.client;

  String get _uid =>
      _client.auth.currentUser?.id ??
      (throw Exception('Session expired. Please log in again.'));

  // ── Medications ──────────────────────────────────────────────

  Future<List<Medication>> getMedications() async {
    final rows = await _client
        .from('medications')
        .select()
        .eq('patient_id', _uid)
        .order('created_at');
    return rows.map((r) => Medication.fromJson(r)).toList();
  }

  Future<Medication> addMedication({
    required String name,
    required String dose,
    String? instructions,
    String? imageUrl,
  }) async {
    final row = await _client
        .from('medications')
        .insert({
          'patient_id': _uid,
          'name': name,
          'dose': dose,
          if (instructions != null) 'instructions': instructions,
          if (imageUrl != null) 'image_url': imageUrl,
        })
        .select()
        .single();
    return Medication.fromJson(row);
  }

  Future<Medication> updateMedication(Medication med) async {
    final row = await _client
        .from('medications')
        .update({
          'name': med.name,
          'dose': med.dose,
          'instructions': med.instructions,
          'image_url': med.imageUrl,
        })
        .eq('id', med.id)
        .select()
        .single();
    return Medication.fromJson(row);
  }

  /// Uploads [image] to Supabase Storage and returns the public URL.
  /// Bucket: `medication-images` (create it in your Supabase dashboard,
  /// set to public so URLs can be read without auth).
  Future<String> uploadMedicationImage(File image, String medicationId) async {
    final ext = image.path.split('.').last.toLowerCase();
    final path = '$_uid/$medicationId.$ext';
    await _client.storage
        .from('medication-images')
        .upload(path, image, fileOptions: const FileOptions(upsert: true));
    return _client.storage.from('medication-images').getPublicUrl(path);
  }

  Future<void> deleteMedication(String medicationId) async {
    await _client.from('medications').delete().eq('id', medicationId);
  }

  // ── Schedule Entries ──────────────────────────────────────────

  Future<List<ScheduleEntry>> getScheduleEntries(String medicationId) async {
    final rows = await _client
        .from('schedule_entries')
        .select()
        .eq('medication_id', medicationId)
        .order('time');
    return rows.map((r) => ScheduleEntry.fromJson(r)).toList();
  }

  /// Returns all schedule entries for all of the patient's medications.
  Future<List<ScheduleEntry>> getAllScheduleEntries() async {
    final meds = await getMedications();
    if (meds.isEmpty) return [];
    final ids = meds.map((m) => m.id).toList();
    final rows = await _client
        .from('schedule_entries')
        .select()
        .inFilter('medication_id', ids)
        .order('time');
    return rows.map((r) => ScheduleEntry.fromJson(r)).toList();
  }

  Future<ScheduleEntry> addScheduleEntry({
    required String medicationId,
    required String time,
    String repeatPattern = 'daily',
  }) async {
    final row = await _client
        .from('schedule_entries')
        .insert({
          'medication_id': medicationId,
          'time': time,
          'repeat_pattern': repeatPattern,
        })
        .select()
        .single();
    return ScheduleEntry.fromJson(row);
  }

  Future<void> deleteScheduleEntry(String entryId) async {
    await _client.from('schedule_entries').delete().eq('id', entryId);
  }
}
