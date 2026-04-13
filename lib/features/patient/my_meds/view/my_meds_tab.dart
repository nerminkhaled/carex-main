import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/models/medication.dart';
import '../../../../core/models/schedule_entry.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../medications/repository/medication_repository.dart';
import '../../../medications/view/create_alert_page.dart';

// ── Data class ─────────────────────────────────────────────────────────────

class _MedWithSchedule {
  final Medication med;
  final List<ScheduleEntry> entries;
  _MedWithSchedule(this.med, this.entries);
}

// ── Tab widget ────────────────────────────────────────────────────────────────

class MyMedsTab extends StatefulWidget {
  const MyMedsTab({super.key});

  @override
  State<MyMedsTab> createState() => MyMedsTabState();
}

class MyMedsTabState extends State<MyMedsTab> {
  final _repo = MedicationRepository();
  List<_MedWithSchedule> _meds = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final meds = await _repo.getMedications();
      final result = <_MedWithSchedule>[];
      for (final med in meds) {
        final entries = await _repo.getScheduleEntries(med.id);
        result.add(_MedWithSchedule(med, entries));
      }
      if (mounted) {
        setState(() {
          _meds = result;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 18),
            const Text(
              'My Med Reminders',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.teal),
                    )
                  : _error != null
                      ? _ErrorView(error: _error!, onRetry: load)
                      : _meds.isEmpty
                          ? const _EmptyState()
                          : RefreshIndicator(
                              color: AppColors.teal,
                              onRefresh: load,
                              child: ListView.builder(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 4, 16, 100),
                                itemCount: _meds.length,
                                itemBuilder: (_, i) => _MedCard(
                                  item: _meds[i],
                                  onEdit: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      fullscreenDialog: true,
                                      builder: (_) => EditAlertPage(
                                        medication: _meds[i].med,
                                        entries: _meds[i].entries,
                                        onSaved: load,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Medication card ───────────────────────────────────────────────────────────

class _MedCard extends StatefulWidget {
  final _MedWithSchedule item;
  final VoidCallback onEdit;

  const _MedCard({required this.item, required this.onEdit});

  @override
  State<_MedCard> createState() => _MedCardState();
}

class _MedCardState extends State<_MedCard> {
  bool _isActive = true;

  Widget _fallbackIcon() => Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.teal.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.medication_rounded,
            color: AppColors.teal, size: 28),
      );

  String _nextDoseLabel() {
    if (widget.item.entries.isEmpty) return '';
    final now = DateTime.now();
    Duration? soonest;
    for (final entry in widget.item.entries) {
      final (h, m) = entry.parsedTime;
      var next = DateTime(now.year, now.month, now.day, h, m);
      if (!next.isAfter(now)) next = next.add(const Duration(days: 1));
      final diff = next.difference(now);
      if (soonest == null || diff < soonest) soonest = diff;
    }
    if (soonest == null) return '';
    final hrs = soonest.inHours;
    final mins = soonest.inMinutes % 60;
    if (hrs == 0) return 'Next in ${mins}m';
    if (mins == 0) return 'Next in ${hrs} hrs';
    return 'Next in ${hrs}h ${mins}m';
  }

  String _repeatLabel() {
    if (widget.item.entries.isEmpty) return '';
    final pattern = widget.item.entries.first.repeatPattern;
    if (pattern == 'daily') return 'Every Day';
    if (pattern == 'weekly') return 'Every Week';
    // e.g. 'every_2_hours' → 'Every 2 Hours'
    return pattern
        .split('_')
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final med = widget.item.med;
    final nextLabel = _nextDoseLabel();
    final repeatLabel = _repeatLabel();
    final doseText = repeatLabel.isNotEmpty
        ? '${med.dose} | $repeatLabel'
        : med.dose;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Medicine image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: med.imageUrl != null
                ? Image.network(
                    med.imageUrl!,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _fallbackIcon(),
                  )
                : Image.asset(
                    'assets/images/homescreen/pill.png',
                    width: 56,
                    height: 56,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => _fallbackIcon(),
                  ),
          ),
          const SizedBox(width: 12),
          // Info column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  med.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  doseText,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                if (nextLabel.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          size: 13, color: Color(0xFFFF7043)),
                      const SizedBox(width: 4),
                      Text(
                        nextLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFFF7043),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Toggle + Edit column
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CupertinoSwitch(
                value: _isActive,
                activeTrackColor: AppColors.teal,
                onChanged: (val) => setState(() => _isActive = val),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: widget.onEdit,
                child: const Text(
                  'Edit',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.teal,
                    fontWeight: FontWeight.w600,
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

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.medication_rounded,
                  color: AppColors.teal, size: 44),
            ),
            const SizedBox(height: 20),
            const Text(
              'No medications yet',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button below to add\nyour first medication reminder',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.grey[500], fontSize: 13, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error view ────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.pinkRed, size: 48),
            const SizedBox(height: 12),
            Text(error,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}