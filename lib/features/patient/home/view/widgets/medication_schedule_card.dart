import 'package:flutter/material.dart';

import '../../../../../core/models/today_dose.dart';
import '../../../../../core/theme/app_theme.dart';

class MedicationScheduleCard extends StatelessWidget {
  final TodayDose dose;
  final VoidCallback onTaken;
  final VoidCallback onSkipped;

  const MedicationScheduleCard({
    super.key,
    required this.dose,
    required this.onTaken,
    required this.onSkipped,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: dose.isPending ? null : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Medication icon
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.medication_rounded,
                color: AppColors.teal,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            // Name + dosage + time
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dose.medication.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dose.medication.dose,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded,
                          size: 12, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(
                        _fmt(dose.entry.time),
                        style:
                            TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Status badge + chevron
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _StatusBadge(dose: dose),
                const SizedBox(height: 6),
                if (dose.isPending)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ActionBtn(
                        label: 'Take',
                        color: AppColors.teal,
                        onTap: onTaken,
                      ),
                      const SizedBox(width: 6),
                      _ActionBtn(
                        label: 'Skip',
                        color: Colors.grey,
                        onTap: onSkipped,
                      ),
                    ],
                  )
                else
                  Icon(Icons.chevron_right_rounded,
                      color: Colors.grey[300], size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(String hhmm) {
    final parts = hhmm.split(':');
    final h = int.parse(parts[0]);
    final m = parts[1];
    final period = h >= 12 ? 'PM' : 'AM';
    final hour = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$hour:$m $period';
  }
}

class _StatusBadge extends StatelessWidget {
  final TodayDose dose;
  const _StatusBadge({required this.dose});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (true) {
      _ when dose.isTaken => ('Taken', Colors.green),
      _ when dose.isSkipped => ('Skipped', Colors.grey),
      _ when dose.isOverdue => ('Missed', AppColors.pinkRed),
      _ => ('Upcoming', AppColors.teal),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn(
      {required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
