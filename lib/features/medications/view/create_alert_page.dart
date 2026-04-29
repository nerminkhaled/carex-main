import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/models/medication.dart';
import '../../../core/models/schedule_entry.dart';
import '../../../core/theme/app_theme.dart';
import '../repository/medication_repository.dart';

// ── Dosage data

class _DosageData {
  int doseNumber;
  String doseUnit; // 'Pills' | 'Drops' | 'Tablets' | 'Capsules' | 'mg' | 'ml'
  int hour; // 1–12
  int minute; // 0–59
  String period; // 'AM' | 'PM'
  String mealTiming; // 'before' | 'after'

  _DosageData() // constructor with default values
    : doseNumber = 1, // : Initializer list of default values for each field
      doseUnit = 'Pills',
      hour = 8,
      minute = 0,
      period = 'AM',
      mealTiming = 'after';

  String get doseLabel =>
      '$doseNumber $doseUnit'; // getter to display dose as "2 Pills"

  String get timeLabel {
    // getter to display time as "8:00 AM"
    final m = minute.toString().padLeft(2, '0');
    return '$hour:$m $period';
  }

  /// Returns time as "HH:mm" in 24-hour format for DB storage.
  String get time24 {
    int h = hour;
    if (period == 'AM' && h == 12) h = 0;
    if (period == 'PM' && h != 12) h += 12;
    return '${h.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}'; // e.g. "14:30"
  }
}

// ── Page

class CreateAlertPage extends StatefulWidget {
  final VoidCallback? onCreated; // Callback to refresh parent after creation
  const CreateAlertPage({super.key, this.onCreated});

  @override
  State<CreateAlertPage> createState() => _CreateAlertPageState();
}

class _CreateAlertPageState extends State<CreateAlertPage> {
  final _nameCtrl = TextEditingController();
  File? _image;
  DateTime _startDate = DateTime.now();
  // frequency stored as display string e.g. "Every 1 Day" or "Custom"
  String _frequency = 'Every 1 Day';
  final List<_DosageData> _dosages = [_DosageData()];
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  // ── Image picker
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker(); // create an instance of ImagePicker
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1024,
    );
    if (picked != null && mounted) {
      setState(() => _image = File(picked.path));
    }
  }

  void _showImageOptions() {
    // Show bottom sheet with options to take photo, upload, or remove
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // Wrap content, don't take full height
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  color: AppColors.teal,
                ),
              ),
              title: const Text(
                'Take a photo',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.photo_library_outlined,
                  color: AppColors.teal,
                ),
              ),
              title: const Text(
                'Upload from device',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_image != null)
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.pinkRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.pinkRed,
                  ),
                ),
                title: const Text(
                  'Remove photo',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.pinkRed,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _image = null);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Date picker

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (ctx, child) => Theme(
        data: ThemeData(
          colorScheme: const ColorScheme.light(primary: AppColors.teal),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) setState(() => _startDate = picked);
  }

  // ── Frequency picker ───────────────────────────────────────────────────────

  Future<void> _pickFrequency() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _FrequencySheet(current: _frequency),
    );
    if (result != null && mounted) setState(() => _frequency = result);
  }

  // ── Dose picker ────────────────────────────────────────────────────────────

  Future<void> _pickDose(int idx) async {
    final d = _dosages[idx];
    final result = await showModalBottomSheet<(int, String)>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _DoseSheet(number: d.doseNumber, unit: d.doseUnit),
    );
    if (result != null && mounted) {
      setState(() {
        d.doseNumber = result.$1;
        d.doseUnit = result.$2;
      });
    }
  }

  // ── Time picker ────────────────────────────────────────────────────────────

  Future<void> _pickTime(int idx) async {
    final d = _dosages[idx];
    final result = await showModalBottomSheet<(int, int, String)>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) =>
          _TimeSheet(hour: d.hour, minute: d.minute, period: d.period),
    );
    if (result != null && mounted) {
      setState(() {
        d.hour = result.$1;
        d.minute = result.$2;
        d.period = result.$3;
      });
    }
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a medicine name.')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final repo = MedicationRepository();
      final mealLabel = _dosages.first.mealTiming == 'before'
          ? 'Before meal'
          : 'After meal';

      var med = await repo.addMedication(
        name: name,
        dose: _dosages.first.doseLabel,
        instructions: mealLabel,
      );

      // Upload image and update the medication with the URL
      if (_image != null) {
        try {
          final imageUrl = await repo.uploadMedicationImage(_image!, med.id);
          med = await repo.updateMedication(med.copyWith(imageUrl: imageUrl));
        } catch (_) {
          // Image upload failed — medication still saved, just without photo
        }
      }

      for (final d in _dosages) {
        await repo.addScheduleEntry(
          medicationId: med.id,
          time: d.time24,
          repeatPattern: _frequency,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onCreated?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: AppColors.pinkRed,
          ),
        );
      }
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  String _fmtDate(DateTime d) {
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${m[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('Medicine Info'),
                    const SizedBox(height: 10),
                    _nameField(),
                    const SizedBox(height: 12),
                    _imageBox(),
                    const SizedBox(height: 28),
                    _sectionLabel('Schedule'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _SelectorCard(
                            label: 'Start date',
                            icon: Icons.calendar_today_outlined,
                            value: _fmtDate(_startDate),
                            onTap: _pickDate,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SelectorCard(
                            label: 'Frequency',
                            icon: Icons.repeat_rounded,
                            value: _frequency,
                            onTap: _pickFrequency,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    _sectionLabel('Dose'),
                    const SizedBox(height: 10),
                    ...List.generate(_dosages.length, _buildDosageBlock),
                    const SizedBox(height: 4),
                    _addDosageBtn(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _createBtn(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.fromLTRB(4, 12, 16, 12),
    child: Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        const Expanded(
          child: Text(
            'Create Alert',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 48),
      ],
    ),
  );

  Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
  );

  Widget _nameField() => TextField(
    controller: _nameCtrl,
    style: const TextStyle(fontSize: 14),
    decoration: InputDecoration(
      hintText: 'Enter medicine name',
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
      ),
    ),
  );

  Widget _imageBox() => GestureDetector(
    onTap: _showImageOptions,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 110,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: _image != null
          ? Stack(
              children: [
                SizedBox.expand(
                  child: Image.file(_image!, fit: BoxFit.contain),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: _showImageOptions,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.image_outlined, color: Colors.grey[400], size: 30),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                      children: const [
                        TextSpan(
                          text: 'Take a photo',
                          style: TextStyle(
                            color: AppColors.teal,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(text: ' or upload from device'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'JPG, JPEG, PNG less than 1MB',
                    style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
    ),
  );

  Widget _buildDosageBlock(int i) {
    final d = _dosages[i];
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _SelectorCard(
                  label: 'Dose amount',
                  icon: Icons.medication_outlined,
                  value: d.doseLabel,
                  onTap: () => _pickDose(i),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SelectorCard(
                  label: 'Time',
                  icon: Icons.access_time_outlined,
                  value: d.timeLabel,
                  onTap: () => _pickTime(i),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _MealBtn(
                label: 'Before Meal',
                selected: d.mealTiming == 'before',
                onTap: () => setState(() => d.mealTiming = 'before'),
              ),
              const SizedBox(width: 10),
              _MealBtn(
                label: 'After Meal',
                selected: d.mealTiming == 'after',
                onTap: () => setState(() => d.mealTiming = 'after'),
              ),
              if (_dosages.length > 1) ...[
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() => _dosages.removeAt(i)),
                  child: const Icon(
                    Icons.remove_circle_outline_rounded,
                    color: AppColors.pinkRed,
                    size: 22,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _addDosageBtn() => GestureDetector(
    onTap: () => setState(() => _dosages.add(_DosageData())),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add_rounded,
              color: AppColors.teal,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Add another dosage',
            style: TextStyle(
              color: AppColors.teal,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _createBtn() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
    child: SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _loading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.teal,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.teal.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text(
                'Create Reminder',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
      ),
    ),
  );
}

// ── Edit Alert Page ───────────────────────────────────────────────────────────

class EditAlertPage extends StatefulWidget {
  final Medication medication;
  final List<ScheduleEntry> entries;
  final VoidCallback? onSaved;

  const EditAlertPage({
    super.key,
    required this.medication,
    required this.entries,
    this.onSaved,
  });

  @override
  State<EditAlertPage> createState() => _EditAlertPageState();
}

class _EditAlertPageState extends State<EditAlertPage> {
  late final TextEditingController _nameCtrl;
  File? _image;
  String? _existingImageUrl;
  DateTime _startDate = DateTime.now();
  late String _frequency;
  late List<_DosageData> _dosages;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.medication.name);
    _existingImageUrl = widget.medication.imageUrl;

    // Parse dose e.g. "2 Drops" → number=2, unit="Drops"
    final doseParts = widget.medication.dose.split(' ');
    final doseNumber = int.tryParse(doseParts[0]) ?? 1;
    final doseUnit = doseParts.length > 1 ? doseParts[1] : 'Pills';

    // Parse meal timing from instructions
    final mealTiming =
        (widget.medication.instructions ?? '').toLowerCase().contains('before')
        ? 'before'
        : 'after';

    if (widget.entries.isNotEmpty) {
      _frequency = widget.entries.first.repeatPattern;
      _dosages = widget.entries.map((entry) {
        final d = _DosageData();
        d.doseNumber = doseNumber;
        d.doseUnit = doseUnit;
        d.mealTiming = mealTiming;
        // Parse HH:mm to 12h
        final tp = entry.time.split(':');
        final h24 = int.parse(tp[0]);
        d.minute = int.parse(tp[1]);
        d.period = h24 >= 12 ? 'PM' : 'AM';
        d.hour = h24 > 12 ? h24 - 12 : (h24 == 0 ? 12 : h24);
        return d;
      }).toList();
    } else {
      _frequency = 'Every 1 Day';
      final d = _DosageData();
      d.doseNumber = doseNumber;
      d.doseUnit = doseUnit;
      d.mealTiming = mealTiming;
      _dosages = [d];
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  // ── Image picker ───────────────────────────────────────────────────────────

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1024,
    );
    if (picked != null && mounted) {
      setState(() => _image = File(picked.path));
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  color: AppColors.teal,
                ),
              ),
              title: const Text(
                'Take a photo',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.photo_library_outlined,
                  color: AppColors.teal,
                ),
              ),
              title: const Text(
                'Upload from device',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_image != null)
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.pinkRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.pinkRed,
                  ),
                ),
                title: const Text(
                  'Remove photo',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.pinkRed,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _image = null;
                    _existingImageUrl = null;
                  });
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Date picker ────────────────────────────────────────────────────────────

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (ctx, child) => Theme(
        data: ThemeData(
          colorScheme: const ColorScheme.light(primary: AppColors.teal),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) setState(() => _startDate = picked);
  }

  // ── Frequency picker ───────────────────────────────────────────────────────

  Future<void> _pickFrequency() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _FrequencySheet(current: _frequency),
    );
    if (result != null && mounted) setState(() => _frequency = result);
  }

  // ── Dose picker ────────────────────────────────────────────────────────────

  Future<void> _pickDose(int idx) async {
    final d = _dosages[idx];
    final result = await showModalBottomSheet<(int, String)>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _DoseSheet(number: d.doseNumber, unit: d.doseUnit),
    );
    if (result != null && mounted) {
      setState(() {
        d.doseNumber = result.$1;
        d.doseUnit = result.$2;
      });
    }
  }

  // ── Time picker ────────────────────────────────────────────────────────────

  Future<void> _pickTime(int idx) async {
    final d = _dosages[idx];
    final result = await showModalBottomSheet<(int, int, String)>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) =>
          _TimeSheet(hour: d.hour, minute: d.minute, period: d.period),
    );
    if (result != null && mounted) {
      setState(() {
        d.hour = result.$1;
        d.minute = result.$2;
        d.period = result.$3;
      });
    }
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a medicine name.')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final repo = MedicationRepository();
      final mealLabel = _dosages.first.mealTiming == 'before'
          ? 'Before meal'
          : 'After meal';

      // Upload new image if picked, otherwise keep existing URL
      String? imageUrl = _existingImageUrl;
      if (_image != null) {
        try {
          imageUrl = await repo.uploadMedicationImage(
            _image!,
            widget.medication.id,
          );
        } catch (_) {
          // Upload failed — keep existing URL
        }
      }

      await repo.updateMedication(
        Medication(
          id: widget.medication.id,
          patientId: widget.medication.patientId,
          name: name,
          dose: _dosages.first.doseLabel,
          instructions: mealLabel,
          imageUrl: imageUrl,
          createdAt: widget.medication.createdAt,
        ),
      );

      // Replace all schedule entries
      for (final entry in widget.entries) {
        await repo.deleteScheduleEntry(entry.id);
      }
      for (final d in _dosages) {
        await repo.addScheduleEntry(
          medicationId: widget.medication.id,
          time: d.time24,
          repeatPattern: _frequency,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onSaved?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: AppColors.pinkRed,
          ),
        );
      }
    }
  }

  // ── Delete ─────────────────────────────────────────────────────────────────

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Medication',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Remove "${widget.medication.name}" and all its reminders?',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.pinkRed),
            child: const Text(
              'Delete',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await MedicationRepository().deleteMedication(widget.medication.id);
      if (mounted) {
        Navigator.pop(context);
        widget.onSaved?.call();
      }
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  String _fmtDate(DateTime d) {
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${m[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('Medicine Info'),
                    const SizedBox(height: 10),
                    _nameField(),
                    const SizedBox(height: 12),
                    _imageBox(),
                    const SizedBox(height: 28),
                    _sectionLabel('Schedule'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _SelectorCard(
                            label: 'Start date',
                            icon: Icons.calendar_today_outlined,
                            value: _fmtDate(_startDate),
                            onTap: _pickDate,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SelectorCard(
                            label: 'Frequency',
                            icon: Icons.repeat_rounded,
                            value: _frequency,
                            onTap: _pickFrequency,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    _sectionLabel('Dose'),
                    const SizedBox(height: 10),
                    ...List.generate(_dosages.length, _buildDosageBlock),
                    const SizedBox(height: 4),
                    _addDosageBtn(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _saveBtn(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.fromLTRB(4, 12, 4, 12),
    child: Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        const Expanded(
          child: Text(
            'Edit Alert',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.delete_outline_rounded,
            color: AppColors.pinkRed,
            size: 22,
          ),
          onPressed: _loading ? null : _delete,
        ),
      ],
    ),
  );

  Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
  );

  Widget _nameField() => TextField(
    controller: _nameCtrl,
    style: const TextStyle(fontSize: 14),
    decoration: InputDecoration(
      hintText: 'Enter medicine name',
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
      ),
    ),
  );

  Widget _imageBox() {
    Widget imageContent;
    if (_image != null) {
      imageContent = Image.file(
        _image!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    } else if (_existingImageUrl != null) {
      imageContent = Image.network(
        _existingImageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    } else {
      imageContent = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image_outlined, color: Colors.grey[400], size: 30),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                children: const [
                  TextSpan(
                    text: 'Take a photo',
                    style: TextStyle(
                      color: AppColors.teal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(text: ' or upload from device'),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'JPG, JPEG, PNG less than 1MB',
              style: TextStyle(fontSize: 11, color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    final hasImage = _image != null || _existingImageUrl != null;
    return GestureDetector(
      onTap: _showImageOptions,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 110,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(14),
        ),
        clipBehavior: Clip.antiAlias,
        child: hasImage
            ? Stack(
                fit: StackFit.expand,
                children: [
                  imageContent,
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: _showImageOptions,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : imageContent,
      ),
    );
  }

  Widget _buildDosageBlock(int i) {
    final d = _dosages[i];
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _SelectorCard(
                  label: 'Dose amount',
                  icon: Icons.medication_outlined,
                  value: d.doseLabel,
                  onTap: () => _pickDose(i),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SelectorCard(
                  label: 'Time',
                  icon: Icons.access_time_outlined,
                  value: d.timeLabel,
                  onTap: () => _pickTime(i),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _MealBtn(
                label: 'Before Meal',
                selected: d.mealTiming == 'before',
                onTap: () => setState(() => d.mealTiming = 'before'),
              ),
              const SizedBox(width: 10),
              _MealBtn(
                label: 'After Meal',
                selected: d.mealTiming == 'after',
                onTap: () => setState(() => d.mealTiming = 'after'),
              ),
              if (_dosages.length > 1) ...[
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() => _dosages.removeAt(i)),
                  child: const Icon(
                    Icons.remove_circle_outline_rounded,
                    color: AppColors.pinkRed,
                    size: 22,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _addDosageBtn() => GestureDetector(
    onTap: () => setState(() => _dosages.add(_DosageData())),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add_rounded,
              color: AppColors.teal,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Add another dosage',
            style: TextStyle(
              color: AppColors.teal,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _saveBtn() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
    child: SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _loading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.teal,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.teal.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text(
                'Save Changes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
      ),
    ),
  );
}

// ── Shared wheel picker widget ────────────────────────────────────────────────

class _WheelColumn extends StatelessWidget {
  final List<String> items;
  final FixedExtentScrollController controller;
  final ValueChanged<int> onChanged;
  final double width;

  const _WheelColumn({
    required this.items,
    required this.controller,
    required this.onChanged,
    this.width = 80,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 180,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: 44,
        perspective: 0.003,
        diameterRatio: 1.4,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: onChanged,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: items.length,
          builder: (context, index) {
            return Center(
              child: Text(
                items[index],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

Widget _sheetHandle() => Container(
  width: 36,
  height: 4,
  margin: const EdgeInsets.only(bottom: 4),
  decoration: BoxDecoration(
    color: Colors.grey[300],
    borderRadius: BorderRadius.circular(2),
  ),
);

// ── Time picker sheet ─────────────────────────────────────────────────────────

class _TimeSheet extends StatefulWidget {
  final int hour;
  final int minute;
  final String period;
  const _TimeSheet({
    required this.hour,
    required this.minute,
    required this.period,
  });

  @override
  State<_TimeSheet> createState() => _TimeSheetState();
}

class _TimeSheetState extends State<_TimeSheet> {
  late final FixedExtentScrollController _hourCtrl;
  late final FixedExtentScrollController _minCtrl;
  late final FixedExtentScrollController _periodCtrl;

  // State tracks selection — never rely on controller.selectedItem
  late int _hourIdx;
  late int _minIdx;
  late int _periodIdx;

  static final List<String> _hours = List.generate(
    12,
    (i) => (i + 1).toString().padLeft(2, '0'),
  );
  static final List<String> _minutes = List.generate(
    60,
    (i) => i.toString().padLeft(2, '0'),
  );
  static const List<String> _periods = ['AM', 'PM'];

  @override
  void initState() {
    super.initState();
    _hourIdx = (widget.hour - 1).clamp(0, 11);
    _minIdx = widget.minute.clamp(0, 59);
    _periodIdx = widget.period == 'AM' ? 0 : 1;
    _hourCtrl = FixedExtentScrollController(initialItem: _hourIdx);
    _minCtrl = FixedExtentScrollController(initialItem: _minIdx);
    _periodCtrl = FixedExtentScrollController(initialItem: _periodIdx);
  }

  @override
  void dispose() {
    _hourCtrl.dispose();
    _minCtrl.dispose();
    _periodCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sheetHandle(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select time',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, size: 22),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.teal.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _WheelColumn(
                      items: _hours,
                      controller: _hourCtrl,
                      width: 72,
                      onChanged: (i) => _hourIdx = i,
                    ),
                    const Text(
                      ':',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    _WheelColumn(
                      items: _minutes,
                      controller: _minCtrl,
                      width: 72,
                      onChanged: (i) => _minIdx = i,
                    ),
                    const SizedBox(width: 8),
                    _WheelColumn(
                      items: _periods,
                      controller: _periodCtrl,
                      width: 60,
                      onChanged: (i) => _periodIdx = i,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, (
                    _hourIdx + 1,
                    _minIdx,
                    _periods[_periodIdx],
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Save Time',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Dose picker sheet ─────────────────────────────────────────────────────────

class _DoseSheet extends StatefulWidget {
  final int number;
  final String unit;
  const _DoseSheet({required this.number, required this.unit});

  @override
  State<_DoseSheet> createState() => _DoseSheetState();
}

class _DoseSheetState extends State<_DoseSheet> {
  late final FixedExtentScrollController _numCtrl;
  late final FixedExtentScrollController _unitCtrl;

  late int _numIdx;
  late int _unitIdx;

  static final List<String> _numbers = List.generate(
    30,
    (i) => (i + 1).toString(),
  );
  static const List<String> _units = [
    'Pills',
    'Drops',
    'Tablets',
    'Capsules',
    'mg',
    'ml',
  ];

  @override
  void initState() {
    super.initState();
    _numIdx = (widget.number - 1).clamp(0, _numbers.length - 1);
    final unitI = _units.indexOf(widget.unit);
    _unitIdx = unitI < 0 ? 0 : unitI;
    _numCtrl = FixedExtentScrollController(initialItem: _numIdx);
    _unitCtrl = FixedExtentScrollController(initialItem: _unitIdx);
  }

  @override
  void dispose() {
    _numCtrl.dispose();
    _unitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sheetHandle(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select dose',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, size: 22),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.teal.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _WheelColumn(
                      items: _numbers,
                      controller: _numCtrl,
                      width: 80,
                      onChanged: (i) => _numIdx = i,
                    ),
                    const SizedBox(width: 8),
                    _WheelColumn(
                      items: _units,
                      controller: _unitCtrl,
                      width: 110,
                      onChanged: (i) => _unitIdx = i,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, (_numIdx + 1, _units[_unitIdx]));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Frequency picker sheet ────────────────────────────────────────────────────

class _FrequencySheet extends StatefulWidget {
  final String current;
  const _FrequencySheet({required this.current});

  @override
  State<_FrequencySheet> createState() => _FrequencySheetState();
}

class _FrequencySheetState extends State<_FrequencySheet> {
  late final FixedExtentScrollController _numCtrl;
  late final FixedExtentScrollController _unitCtrl;
  bool _isCustom = false;
  final _customCtrl = TextEditingController();

  late int _numIdx;
  late int _unitIdx;

  static final List<String> _numbers = List.generate(
    24,
    (i) => (i + 1).toString(),
  );
  static const List<String> _units = ['Hour', 'Day', 'Week'];

  @override
  void initState() {
    super.initState();
    _numIdx = 0;
    _unitIdx = 1; // Day default
    if (widget.current.startsWith('Every ')) {
      final parts = widget.current.split(' ');
      if (parts.length >= 3) {
        final parsed = int.tryParse(parts[1]);
        if (parsed != null)
          _numIdx = (parsed - 1).clamp(0, _numbers.length - 1);
        final unitStr = parts[2].replaceAll('s', '');
        final unitI = _units.indexOf(unitStr);
        if (unitI >= 0) _unitIdx = unitI;
      }
    } else if (widget.current.startsWith('Custom')) {
      _isCustom = true;
      _customCtrl.text = widget.current.replaceFirst('Custom: ', '');
    }
    _numCtrl = FixedExtentScrollController(initialItem: _numIdx);
    _unitCtrl = FixedExtentScrollController(initialItem: _unitIdx);
  }

  @override
  void dispose() {
    _numCtrl.dispose();
    _unitCtrl.dispose();
    _customCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sheetHandle(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Set frequency',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, size: 22),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _TabBtn(
                  label: 'Every...',
                  selected: !_isCustom,
                  onTap: () => setState(() => _isCustom = false),
                ),
                const SizedBox(width: 8),
                _TabBtn(
                  label: 'Custom',
                  selected: _isCustom,
                  onTap: () => setState(() => _isCustom = true),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (!_isCustom) ...[
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.teal.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Text(
                          'Every',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      _WheelColumn(
                        items: _numbers,
                        controller: _numCtrl,
                        width: 64,
                        onChanged: (i) => _numIdx = i,
                      ),
                      const SizedBox(width: 4),
                      _WheelColumn(
                        items: _units,
                        controller: _unitCtrl,
                        width: 80,
                        onChanged: (i) => _unitIdx = i,
                      ),
                    ],
                  ),
                ],
              ),
            ] else ...[
              TextField(
                controller: _customCtrl,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'e.g. Twice a week, As needed...',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[200]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[200]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.teal,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  String result;
                  if (_isCustom) {
                    final txt = _customCtrl.text.trim();
                    result = txt.isEmpty ? 'Custom' : 'Custom: $txt';
                  } else {
                    final n = _numIdx + 1;
                    final u = _units[_unitIdx];
                    result = 'Every $n $u';
                  }
                  Navigator.pop(context, result);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabBtn({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: selected ? AppColors.teal : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : Colors.grey[600],
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    ),
  );
}

// ── Shared selector card ──────────────────────────────────────────────────────

class _SelectorCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final VoidCallback onTap;

  const _SelectorCard({
    required this.label,
    required this.icon,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(icon, size: 14, color: Colors.grey[400]),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

// ── Meal toggle button ────────────────────────────────────────────────────────

class _MealBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _MealBtn({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: selected ? AppColors.teal : Colors.white,
        border: Border.all(
          color: selected ? AppColors.teal : Colors.grey[300]!,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : Colors.grey[600],
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
