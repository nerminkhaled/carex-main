import 'package:flutter/material.dart';

import '../../../../../core/models/reading.dart';
import '../../../../../core/theme/app_theme.dart';

class ReadingSummaryCard extends StatelessWidget {
  final ReadingType type;
  final Reading? lastReading;
  final VoidCallback onTap;

  const ReadingSummaryCard({
    super.key,
    required this.type,
    required this.lastReading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_icon, color: AppColors.teal, size: 18),
                const SizedBox(width: 6),
                Text(
                  _label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.teal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (lastReading != null) ...[
              Text(
                lastReading!.value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                lastReading!.unit,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
            ] else
              Text(
                'No data',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[400],
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String get _label => switch (type) {
        ReadingType.bp => 'Blood Pressure',
        ReadingType.sugar => 'Blood Sugar',
        ReadingType.pulse => 'Pulse',
        ReadingType.weight => 'Weight',
      };

  IconData get _icon => switch (type) {
        ReadingType.bp => Icons.favorite_border,
        ReadingType.sugar => Icons.water_drop_outlined,
        ReadingType.pulse => Icons.monitor_heart_outlined,
        ReadingType.weight => Icons.scale_outlined,
      };
}
