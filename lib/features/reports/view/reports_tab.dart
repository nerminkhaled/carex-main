import 'package:flutter/material.dart';

import '../../../core/models/reading.dart';
import '../../../core/theme/app_theme.dart';
import '../../readings/repository/reading_repository.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

String _formatTime(DateTime dt) {
  final h = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
  final period = dt.hour < 12 ? 'AM' : 'PM';
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m $period';
}

String _formatShortDate(DateTime dt) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return '${months[dt.month - 1]} ${dt.day}';
}

bool _isToday(DateTime dt) {
  final now = DateTime.now();
  return dt.year == now.year && dt.month == now.month && dt.day == now.day;
}

// ── Tab widget ────────────────────────────────────────────────────────────────

class ReportsTab extends StatefulWidget {
  const ReportsTab({super.key});

  @override
  State<ReportsTab> createState() => ReportsTabState();
}

class ReportsTabState extends State<ReportsTab> {
  final _repo = ReadingRepository();
  List<Reading> _readings = [];
  bool _loading = true;
  String? _error;
  int _tabIndex = 0; // 0 = Today, 1 = History

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final readings = await _repo.getReadings(limit: 200);
      if (mounted) setState(() { _readings = readings; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  List<Reading> get _filteredReadings {
    if (_tabIndex == 0) {
      return _readings.where((r) => _isToday(r.date)).toList();
    }
    return _readings.where((r) => !_isToday(r.date)).toList();
  }

  void _openAddReading() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddReadingSheet(repo: _repo, onAdded: _load),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Row(
                children: [
                  const Text(
                    'Health Readings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _openAddReading,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: AppColors.teal,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // ── Tab switcher ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    _TabButton(
                      label: 'Today',
                      active: _tabIndex == 0,
                      onTap: () => setState(() => _tabIndex = 0),
                    ),
                    _TabButton(
                      label: 'History',
                      active: _tabIndex == 1,
                      onTap: () => setState(() => _tabIndex = 1),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // ── Content ──────────────────────────────────────────────────────
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.teal),
                    )
                  : _error != null
                      ? _ErrorView(error: _error!, onRetry: _load)
                      : RefreshIndicator(
                          color: AppColors.teal,
                          onRefresh: _load,
                          child: _filteredReadings.isEmpty
                              ? ListView(
                                  children: [
                                    _EmptyState(isToday: _tabIndex == 0),
                                  ],
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                                  itemCount: _filteredReadings.length,
                                  itemBuilder: (_, i) => _ReadingCard(
                                    reading: _filteredReadings[i],
                                    showDate: _tabIndex == 1,
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

// ── Tab button ────────────────────────────────────────────────────────────────

class _TabButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 40,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              color: active ? AppColors.teal : Colors.grey[500],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Reading card ──────────────────────────────────────────────────────────────

class _ReadingCard extends StatelessWidget {
  final Reading reading;
  final bool showDate;

  const _ReadingCard({required this.reading, required this.showDate});

  Color get _accentColor => switch (reading.type) {
        ReadingType.bp => const Color(0xFF4A90D9),
        ReadingType.sugar => const Color(0xFFFF9500),
        ReadingType.pulse => AppColors.pinkRed,
        ReadingType.weight => const Color(0xFF9B59B6),
      };

  String get _displayName => switch (reading.type) {
        ReadingType.bp => 'Blood Pressure',
        ReadingType.sugar => 'Blood Glucose',
        ReadingType.pulse => 'Heart Rate',
        ReadingType.weight => 'Weight',
      };

  ({String label, Color color}) get _status {
    switch (reading.type) {
      case ReadingType.bp:
        final parts = reading.value.split('/');
        if (parts.length == 2) {
          final sys = int.tryParse(parts[0].trim()) ?? 0;
          if (sys < 90) return (label: 'Low', color: const Color(0xFF4A90D9));
          if (sys <= 120) return (label: 'Normal', color: const Color(0xFF27AE60));
          return (label: 'High', color: AppColors.pinkRed);
        }
        return (label: 'Normal', color: const Color(0xFF27AE60));
      case ReadingType.sugar:
        final val = double.tryParse(reading.value) ?? 0;
        if (val < 70) return (label: 'Low', color: const Color(0xFF4A90D9));
        if (val <= 140) return (label: 'Normal', color: const Color(0xFF27AE60));
        return (label: 'High', color: AppColors.pinkRed);
      case ReadingType.pulse:
        final val = int.tryParse(reading.value) ?? 0;
        if (val < 60) return (label: 'Low', color: const Color(0xFF4A90D9));
        if (val <= 100) return (label: 'Normal', color: const Color(0xFF27AE60));
        return (label: 'High', color: AppColors.pinkRed);
      case ReadingType.weight:
        return (label: 'Recorded', color: const Color(0xFF9B59B6));
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _status;
    final timeStr = _formatTime(reading.date);
    final subtitle = showDate
        ? '${reading.unit} · ${_formatShortDate(reading.date)} · $timeStr'
        : '${reading.unit} · Today $timeStr';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Colored left border
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: _accentColor,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(14),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _displayName,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            reading.value,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: _accentColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: status.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: status.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Add reading sheet ─────────────────────────────────────────────────────────

class _AddReadingSheet extends StatefulWidget {
  final ReadingRepository repo;
  final VoidCallback onAdded;

  const _AddReadingSheet({required this.repo, required this.onAdded});

  @override
  State<_AddReadingSheet> createState() => _AddReadingSheetState();
}

class _AddReadingSheetState extends State<_AddReadingSheet> {
  ReadingType _selectedType = ReadingType.bp;
  final _valueController = TextEditingController();
  bool _saving = false;
  String? _validationError;

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  String get _hint => switch (_selectedType) {
        ReadingType.bp => 'e.g. 120/80',
        ReadingType.sugar => 'e.g. 98',
        ReadingType.pulse => 'e.g. 72',
        ReadingType.weight => 'e.g. 68.5',
      };

  String get _label => switch (_selectedType) {
        ReadingType.bp => 'Blood Pressure (mmHg)',
        ReadingType.sugar => 'Blood Glucose (mg/dL)',
        ReadingType.pulse => 'Heart Rate (bpm)',
        ReadingType.weight => 'Weight (kg)',
      };

  Future<void> _save() async {
    final value = _valueController.text.trim();
    if (value.isEmpty) {
      setState(() => _validationError = 'Please enter a value');
      return;
    }
    setState(() { _saving = true; _validationError = null; });
    try {
      await widget.repo.addReading(type: _selectedType, value: value);
      if (mounted) {
        Navigator.of(context).pop();
        widget.onAdded();
      }
    } catch (e) {
      if (mounted) {
        setState(() { _saving = false; _validationError = e.toString(); });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Add Health Reading',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 20),
          // Type selector
          const Text(
            'Type',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF555555),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: ReadingType.values.map((type) {
              final selected = _selectedType == type;
              final label = switch (type) {
                ReadingType.bp => 'BP',
                ReadingType.sugar => 'Glucose',
                ReadingType.pulse => 'Heart Rate',
                ReadingType.weight => 'Weight',
              };
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _selectedType = type;
                    _valueController.clear();
                    _validationError = null;
                  }),
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.teal.withValues(alpha: 0.12)
                          : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(10),
                      border: selected
                          ? Border.all(color: AppColors.teal, width: 1.5)
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: selected ? AppColors.teal : Colors.grey[500],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          // Value input
          Text(
            _label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF555555),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _valueController,
            keyboardType: _selectedType == ReadingType.bp
                ? TextInputType.text
                : const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: _hint,
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.teal, width: 1.5),
              ),
              errorText: _validationError,
            ),
          ),
          const SizedBox(height: 24),
          // Save button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      'Save Reading',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool isToday;

  const _EmptyState({required this.isToday});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                color: AppColors.teal,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isToday ? 'No readings today' : 'No history yet',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isToday
                  ? 'Tap + to log your first reading'
                  : 'Your past readings will appear here',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
              ),
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
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13),
            ),
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
