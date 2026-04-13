import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/theme/app_theme.dart';

// ── Profile Tab (entry point used by HomeShell) ───────────────────────────────

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final meta = user?.userMetadata ?? {};
    final fullName = (meta['full_name'] as String?) ?? 'User';
    final email = user?.email ?? '';
    final initials = fullName
        .split(' ')
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _ProfileHeader(
            initials: initials,
            fullName: fullName,
            email: email,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
              child: Column(
                children: [
                  _MenuCard(
                    items: [
                      _MenuItem(
                        icon: Icons.person_outline_rounded,
                        label: 'Personal Information',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const _PersonalInfoPage(),
                          ),
                        ),
                      ),
                      _MenuItem(
                        icon: Icons.favorite_border_rounded,
                        label: 'Medical History',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const _MedicalHistoryPage(),
                          ),
                        ),
                      ),
                      _MenuItem(
                        icon: Icons.notifications_none_rounded,
                        label: 'Notification Settings',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const _NotificationSettingsPage(),
                          ),
                        ),
                      ),
                      _MenuItem(
                        icon: Icons.emergency_outlined,
                        label: 'Emergency Contacts',
                        isLast: true,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const _EmergencyContactsPage(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _LogOutButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final String initials;
  final String fullName;
  final String email;

  const _ProfileHeader({
    required this.initials,
    required this.fullName,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.teal, AppColors.tealDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
          child: Column(
            children: [
              // Avatar
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.25),
                  border: Border.all(color: Colors.white, width: 3),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                fullName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              // Edit profile chip
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const _PersonalInfoPage(),
                  ),
                ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5), width: 1),
                  ),
                  child: const Text(
                    'Edit Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Menu card ─────────────────────────────────────────────────────────────────

class _MenuCard extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: items),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLast;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: isLast
              ? const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                )
              : BorderRadius.zero,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.teal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppColors.teal, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey[400],
                  size: 22,
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 1,
            indent: 76,
            endIndent: 20,
            color: Colors.grey[100],
          ),
      ],
    );
  }
}

// ── Log out ───────────────────────────────────────────────────────────────────

class _LogOutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _confirmLogout(context),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.pinkRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.logout_rounded,
                    color: AppColors.pinkRed, size: 20),
              ),
              const SizedBox(width: 16),
              const Text(
                'Log Out',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.pinkRed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Log Out',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pinkRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}

// ── Sub-page scaffold helper ──────────────────────────────────────────────────

class _SubPageScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  const _SubPageScaffold({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 16, color: Color(0xFF1A1A2E)),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
        ),
        centerTitle: true,
      ),
      body: body,
    );
  }
}

// ── Personal Information ──────────────────────────────────────────────────────

class _PersonalInfoPage extends StatefulWidget {
  const _PersonalInfoPage();

  @override
  State<_PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<_PersonalInfoPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _dobCtrl;
  String? _gender;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final meta =
        Supabase.instance.client.auth.currentUser?.userMetadata ?? {};
    _nameCtrl =
        TextEditingController(text: meta['full_name'] as String? ?? '');
    _phoneCtrl = TextEditingController(text: meta['phone'] as String? ?? '');
    _dobCtrl =
        TextEditingController(text: meta['date_of_birth'] as String? ?? '');
    final rawGender = meta['gender'] as String?;
    _gender = rawGender != null && rawGender.isNotEmpty
        ? rawGender[0].toUpperCase() + rawGender.substring(1)
        : null;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    DateTime initial = DateTime.now();
    if (_dobCtrl.text.isNotEmpty) {
      try {
        initial = DateTime.parse(_dobCtrl.text.trim());
      } catch (_) {}
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _dobCtrl.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(
          data: {
            'full_name': _nameCtrl.text.trim(),
            'phone': _phoneCtrl.text.trim(),
            'date_of_birth': _dobCtrl.text.trim(),
            if (_gender != null) 'gender': _gender,
          },
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully.'),
            backgroundColor: AppColors.teal,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.pinkRed),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final email =
        Supabase.instance.client.auth.currentUser?.email ?? '';

    return _SubPageScaffold(
      title: 'Personal Information',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _InfoCard(
                child: Column(
                  children: [
                    _FormField(
                      label: 'Full Name',
                      controller: _nameCtrl,
                      icon: Icons.person_outline_rounded,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    _Divider(),
                    _ReadOnlyField(
                      label: 'Email',
                      value: email,
                      icon: Icons.email_outlined,
                    ),
                    _Divider(),
                    _FormField(
                      label: 'Phone Number',
                      controller: _phoneCtrl,
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    _Divider(),
                    GestureDetector(
                      onTap: _pickDate,
                      child: AbsorbPointer(
                        child: _FormField(
                          label: 'Date of Birth',
                          controller: _dobCtrl,
                          icon: Icons.cake_outlined,
                          hint: 'YYYY-MM-DD',
                        ),
                      ),
                    ),
                    _Divider(),
                    _GenderSelector(
                      value: _gender,
                      onChanged: (v) => setState(() => _gender = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _PrimaryButton(
                label: 'Save Changes',
                loading: _saving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Medical History ───────────────────────────────────────────────────────────

class _MedicalHistoryPage extends StatefulWidget {
  const _MedicalHistoryPage();

  @override
  State<_MedicalHistoryPage> createState() => _MedicalHistoryPageState();
}

class _MedicalHistoryPageState extends State<_MedicalHistoryPage> {
  late TextEditingController _conditionsCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final meta =
        Supabase.instance.client.auth.currentUser?.userMetadata ?? {};
    _conditionsCtrl = TextEditingController(
        text: meta['medical_conditions'] as String? ?? '');
  }

  @override
  void dispose() {
    _conditionsCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(
          data: {
            'medical_conditions': _conditionsCtrl.text.trim(),
          },
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medical history updated.'),
            backgroundColor: AppColors.teal,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.pinkRed),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SubPageScaffold(
      title: 'Medical History',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        Icon(Icons.favorite_border_rounded,
                            color: AppColors.teal, size: 18),
                        const SizedBox(width: 10),
                        const Text(
                          'Medical Conditions',
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: TextField(
                      controller: _conditionsCtrl,
                      maxLines: 5,
                      style: const TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        hintText:
                            'e.g. Hypertension, Type 2 Diabetes, Asthma...',
                        hintStyle: TextStyle(
                            color: Colors.grey[400], fontSize: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.grey[200]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.grey[200]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppColors.teal, width: 2),
                        ),
                        filled: true,
                        fillColor: AppColors.background,
                        contentPadding: const EdgeInsets.all(14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _PrimaryButton(
              label: 'Save Changes',
              loading: _saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Notification Settings ─────────────────────────────────────────────────────

class _NotificationSettingsPage extends StatefulWidget {
  const _NotificationSettingsPage();

  @override
  State<_NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState
    extends State<_NotificationSettingsPage> {
  bool _medicationReminders = true;
  bool _missedDoseAlerts = true;
  bool _weeklyReports = false;
  bool _sosAlerts = true;
  bool _loading = true;

  final _client = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) {
      setState(() => _loading = false);
      return;
    }
    final row = await _client
        .from('profiles')
        .select(
            'notif_medications, notif_missed_dose, notif_weekly_reports, notif_sos')
        .eq('id', uid)
        .maybeSingle();

    if (mounted) {
      setState(() {
        _medicationReminders = (row?['notif_medications'] as bool?) ?? true;
        _missedDoseAlerts = (row?['notif_missed_dose'] as bool?) ?? true;
        _weeklyReports = (row?['notif_weekly_reports'] as bool?) ?? false;
        _sosAlerts = (row?['notif_sos'] as bool?) ?? true;
        _loading = false;
      });
    }
  }

  Future<void> _toggle(String column, bool value) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return;
    await _client
        .from('profiles')
        .update({column: value})
        .eq('id', uid);
  }

  @override
  Widget build(BuildContext context) {
    return _SubPageScaffold(
      title: 'Notification Settings',
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.teal))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _InfoCard(
                child: Column(
                  children: [
                    _ToggleTile(
                      icon: Icons.medication_outlined,
                      title: 'Medication Reminders',
                      subtitle: 'Get reminded when it\'s time to take your meds',
                      value: _medicationReminders,
                      onChanged: (v) {
                        setState(() => _medicationReminders = v);
                        _toggle('notif_medications', v);
                      },
                    ),
                    _Divider(),
                    _ToggleTile(
                      icon: Icons.warning_amber_rounded,
                      title: 'Missed Dose Alerts',
                      subtitle: 'Be notified if you miss a scheduled dose',
                      value: _missedDoseAlerts,
                      onChanged: (v) {
                        setState(() => _missedDoseAlerts = v);
                        _toggle('notif_missed_dose', v);
                      },
                    ),
                    _Divider(),
                    _ToggleTile(
                      icon: Icons.bar_chart_rounded,
                      title: 'Weekly Reports',
                      subtitle: 'Receive a weekly adherence summary',
                      value: _weeklyReports,
                      onChanged: (v) {
                        setState(() => _weeklyReports = v);
                        _toggle('notif_weekly_reports', v);
                      },
                    ),
                    _Divider(),
                    _ToggleTile(
                      icon: Icons.emergency_outlined,
                      title: 'SOS Alerts',
                      subtitle: 'Get notified when an SOS is triggered',
                      value: _sosAlerts,
                      isLast: true,
                      onChanged: (v) {
                        setState(() => _sosAlerts = v);
                        _toggle('notif_sos', v);
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLast;

  const _ToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.teal, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey[500])),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.teal,
            activeTrackColor: AppColors.teal.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}

// ── Emergency Contacts ────────────────────────────────────────────────────────

class _EmergencyContactsPage extends StatefulWidget {
  const _EmergencyContactsPage();

  @override
  State<_EmergencyContactsPage> createState() =>
      _EmergencyContactsPageState();
}

class _EmergencyContactsPageState extends State<_EmergencyContactsPage> {
  List<Map<String, String>> _contacts = [];
  bool _loading = true;
  static const _prefsKey = 'emergency_contacts';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey) ?? [];
    setState(() {
      _contacts = raw.map((s) {
        final parts = s.split('||');
        return {'name': parts[0], 'phone': parts.length > 1 ? parts[1] : ''};
      }).toList();
      _loading = false;
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _prefsKey,
      _contacts.map((c) => '${c['name']}||${c['phone']}').toList(),
    );
  }

  void _showAddDialog({int? editIndex}) {
    final nameCtrl = TextEditingController(
        text: editIndex != null ? _contacts[editIndex]['name'] : '');
    final phoneCtrl = TextEditingController(
        text: editIndex != null ? _contacts[editIndex]['phone'] : '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          editIndex != null ? 'Edit Contact' : 'Add Emergency Contact',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: _inputDecoration('Name'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              decoration: _inputDecoration('Phone Number'),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final phone = phoneCtrl.text.trim();
              if (name.isEmpty) return;
              setState(() {
                if (editIndex != null) {
                  _contacts[editIndex] = {'name': name, 'phone': phone};
                } else {
                  _contacts.add({'name': name, 'phone': phone});
                }
              });
              _save();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(editIndex != null ? 'Save' : 'Add'),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.teal, width: 2),
      ),
    );
  }

  void _delete(int index) {
    setState(() => _contacts.removeAt(index));
    _save();
  }

  @override
  Widget build(BuildContext context) {
    return _SubPageScaffold(
      title: 'Emergency Contacts',
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.teal))
          : Column(
              children: [
                Expanded(
                  child: _contacts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.contacts_outlined,
                                  size: 56, color: Colors.grey[200]),
                              const SizedBox(height: 12),
                              Text(
                                'No emergency contacts yet',
                                style: TextStyle(
                                    color: Colors.grey[400], fontSize: 14),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          itemCount: _contacts.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, i) {
                            final c = _contacts[i];
                            final initials = (c['name'] ?? '')
                                .split(' ')
                                .where((p) => p.isNotEmpty)
                                .take(2)
                                .map((p) => p[0].toUpperCase())
                                .join();
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                leading: CircleAvatar(
                                  backgroundColor:
                                      AppColors.teal.withValues(alpha: 0.15),
                                  child: Text(
                                    initials,
                                    style: const TextStyle(
                                        color: AppColors.teal,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14),
                                  ),
                                ),
                                title: Text(
                                  c['name'] ?? '',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15),
                                ),
                                subtitle: Text(
                                  c['phone'] ?? '',
                                  style: TextStyle(
                                      color: Colors.grey[500], fontSize: 13),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit_outlined,
                                          color: AppColors.teal, size: 20),
                                      onPressed: () =>
                                          _showAddDialog(editIndex: i),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete_outline_rounded,
                                          color: AppColors.pinkRed, size: 20),
                                      onPressed: () => _delete(i),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: _PrimaryButton(
                    label: 'Add Contact',
                    icon: Icons.add_rounded,
                    onPressed: () => _showAddDialog(),
                  ),
                ),
              ],
            ),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final Widget child;
  const _InfoCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String? hint;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _FormField({
    required this.label,
    required this.controller,
    required this.icon,
    this.hint,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.teal, size: 18),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                TextFormField(
                  controller: controller,
                  keyboardType: keyboardType,
                  validator: validator,
                  style: const TextStyle(fontSize: 15),
                  decoration: InputDecoration(
                    hintText: hint,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    hintStyle:
                        TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ReadOnlyField({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[400], size: 18),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? '—' : value,
                  style:
                      TextStyle(fontSize: 15, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Icon(Icons.lock_outline_rounded,
              size: 14, color: Colors.grey[300]),
        ],
      ),
    );
  }
}

class _GenderSelector extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const _GenderSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          Icon(Icons.wc_outlined, color: AppColors.teal, size: 18),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gender',
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: value,
                    isDense: true,
                    hint: Text('Select',
                        style: TextStyle(
                            color: Colors.grey[400], fontSize: 14)),
                    style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF1A1A2E),
                        fontFamily: 'Poppins'),
                    items: ['Male', 'Female', 'Other', 'Prefer not to say']
                        .map((g) => DropdownMenuItem(
                              value: g,
                              child: Text(g),
                            ))
                        .toList(),
                    onChanged: onChanged,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
        height: 1,
        thickness: 1,
        indent: 48,
        endIndent: 16,
        color: Colors.grey[100]);
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool loading;
  final IconData? icon;

  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.teal,
          foregroundColor: Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(label,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                ],
              ),
      ),
    );
  }
}
