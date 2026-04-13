import 'package:flutter/material.dart';

import '../../../core/models/adherence_log.dart';
import '../../../core/models/today_dose.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_theme.dart';
import '../repository/adherence_repository.dart';

/// Bottom sheet shown when a medication reminder notification is tapped.
class MedicationReminderSheet extends StatefulWidget {
  final TodayDose dose;
  final VoidCallback? onTaken;

  const MedicationReminderSheet({
    super.key,
    required this.dose,
    this.onTaken,
  });

  static Future<void> show(
    BuildContext context, {
    required TodayDose dose,
    VoidCallback? onTaken,
  }) =>
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => MedicationReminderSheet(dose: dose, onTaken: onTaken),
      );

  @override
  State<MedicationReminderSheet> createState() =>
      _MedicationReminderSheetState();
}

class _MedicationReminderSheetState extends State<MedicationReminderSheet> {
  bool _loading = false;
  final _adherenceRepo = AdherenceRepository();

  String _formatTime(String hhmm) {
    final parts = hhmm.split(':');
    final h = int.parse(parts[0]);
    final m = parts[1];
    final period = h >= 12 ? 'PM' : 'AM';
    final hour = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$hour:$m $period';
  }

  String _repeatLabel(String pattern) {
    if (pattern == 'daily') return 'Every Day';
    if (pattern == 'weekly') return 'Every Week';
    return pattern
        .split('_')
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  Future<void> _markTaken() async {
    setState(() => _loading = true);
    try {
      await _adherenceRepo.logDose(
        scheduleEntryId: widget.dose.entry.id,
        scheduledAt: widget.dose.scheduledAt,
        status: AdherenceStatus.taken,
        takenAt: DateTime.now(),
      );
      if (mounted) {
        Navigator.of(context).pop();
        widget.onTaken?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.pinkRed,
          ),
        );
      }
    }
  }

  Future<void> _remindInOneHour() async {
    await NotificationService.instance.remindInOneHour(
      entry: widget.dose.entry,
      medicationName: widget.dose.medication.name,
    );
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reminder set for 1 hour from now.')),
      );
    }
  }

  Widget _fallbackImage() => Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          color: AppColors.teal.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child:
            const Icon(Icons.medication_rounded, color: AppColors.teal, size: 44),
      );

  @override
  Widget build(BuildContext context) {
    final med = widget.dose.medication;
    final entry = widget.dose.entry;
    final timeLabel = _formatTime(entry.time);
    final instructions = med.instructions;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).viewInsets.bottom + 36,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Time chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.alarm_rounded, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  timeLabel,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Text(
            "It's time for your medicine",
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),

          // Medicine image
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: med.imageUrl != null
                ? Image.network(
                    med.imageUrl!,
                    width: 110,
                    height: 110,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _fallbackImage(),
                  )
                : Image.asset(
                    'assets/images/homescreen/pill.png',
                    width: 110,
                    height: 110,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => _fallbackImage(),
                  ),
          ),
          const SizedBox(height: 18),

          // Medicine name
          Text(
            med.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 6),

          // Dose | Frequency
          Text(
            '${med.dose} | ${_repeatLabel(entry.repeatPattern)}',
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),

          if (instructions != null && instructions.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.restaurant_rounded,
                    size: 15, color: AppColors.teal),
                const SizedBox(width: 5),
                Text(
                  instructions,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.teal,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 28),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _loading ? null : _remindInOneHour,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.teal,
                    side: const BorderSide(color: AppColors.teal),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Remind in 1 hr',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _loading ? null : _markTaken,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Medicine Taken',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
