import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/models/today_dose.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../features/medications/repository/adherence_repository.dart';
import '../../../../features/medications/repository/medication_repository.dart';
import '../../../../features/readings/repository/reading_repository.dart';
import '../../../medications/view/create_alert_page.dart';
import '../../../medications/view/medication_reminder_sheet.dart';
import '../../../patient/repository/sos_repository.dart';
import '../../my_meds/view/my_meds_tab.dart';
import '../../profile/view/profile_page.dart';
import '../../../reports/view/reports_tab.dart';
import '../bloc/patient_home_bloc.dart';
import '../bloc/patient_home_event.dart';
import '../bloc/patient_home_state.dart';
import 'widgets/medication_schedule_card.dart';
import 'widgets/upcoming_reminder_card.dart';
import 'widgets/weekly_streak_card.dart';

class PatientHomePage extends StatelessWidget {
  const PatientHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PatientHomeBloc(
        medRepo: MedicationRepository(),
        adherenceRepo: AdherenceRepository(),
        readingRepo: ReadingRepository(),
        sosRepo: SOSRepository(),
      )..add(const PatientHomeLoadRequested()),
      child: const _HomeShell(),
    );
  }
}

// ── Shell with bottom nav ─────────────────────────────────────────────────────

class _HomeShell extends StatefulWidget {
  const _HomeShell();
  @override
  State<_HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<_HomeShell> {
  int _tab = 0;
  final _myMedsKey = GlobalKey<MyMedsTabState>();

  /// Stored when a notification fires before the bloc has finished loading.
  String? _pendingNotifEntryId;

  @override
  void initState() {
    super.initState();
    NotificationService.instance.onNotificationTap = _onNotificationTap;
    // Check if app was cold-started from a notification tap.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = NotificationService.instance.pendingEntryId;
      if (id != null) {
        NotificationService.instance.pendingEntryId = null;
        _showOrStoreNotif(id);
      }
    });
  }

  @override
  void dispose() {
    // Clear our callback so it doesn't fire after this widget is gone.
    if (NotificationService.instance.onNotificationTap == _onNotificationTap) {
      NotificationService.instance.onNotificationTap = null;
    }
    super.dispose();
  }

  void _onNotificationTap(String entryId) {
    if (mounted) _showOrStoreNotif(entryId);
  }

  void _showOrStoreNotif(String entryId) {
    final state = context.read<PatientHomeBloc>().state;
    if (state.status == PatientHomeStatus.loaded) {
      _showReminderSheet(entryId, state.todayDoses);
    } else {
      _pendingNotifEntryId = entryId;
    }
  }

  void _showReminderSheet(String entryId, List<TodayDose> doses) {
    final dose = doses
        .where((d) => d.entry.id == entryId && d.isPending)
        .cast<TodayDose?>()
        .firstOrNull;
    if (dose == null) return;
    MedicationReminderSheet.show(
      context,
      dose: dose,
      onTaken: () => context
          .read<PatientHomeBloc>()
          .add(const PatientHomeLoadRequested()),
    );
  }

  void _openCreateAlert() {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => CreateAlertPage(
          onCreated: () {
            _myMedsKey.currentState?.load();
            context
                .read<PatientHomeBloc>()
                .add(const PatientHomeLoadRequested());
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PatientHomeBloc, PatientHomeState>(
      listenWhen: (prev, curr) => curr.sosSent && !prev.sosSent,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SOS alert sent to your doctor.'),
            backgroundColor: AppColors.pinkRed,
          ),
        );
      },
      child: BlocListener<PatientHomeBloc, PatientHomeState>(
        listenWhen: (prev, curr) =>
            curr.status == PatientHomeStatus.loaded &&
            prev.status != PatientHomeStatus.loaded,
        listener: (context, state) {
          if (_pendingNotifEntryId != null) {
            final id = _pendingNotifEntryId!;
            _pendingNotifEntryId = null;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _showReminderSheet(id, state.todayDoses);
            });
          }
        },
        child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: IndexedStack(
          index: _tab,
          children: [
            const _HomeTab(),
            MyMedsTab(key: _myMedsKey),
            const ReportsTab(),
            const ProfileTab(),
          ],
        ),
        bottomNavigationBar: _BottomNavBar(
          currentIndex: _tab,
          onTap: (i) => setState(() => _tab = i),
          onAddAlert: _openCreateAlert,
        ),
      ),
      ),
    );
  }
}

// ── Home tab ──────────────────────────────────────────────────────────────────

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientHomeBloc, PatientHomeState>(
      buildWhen: (prev, curr) => prev.status != curr.status,
      builder: (context, state) {
        if (state.status == PatientHomeStatus.error) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.pinkRed, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    state.errorMessage ?? 'Something went wrong',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .read<PatientHomeBloc>()
                        .add(const PatientHomeLoadRequested()),
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

        return Column(
          children: [
            _TealHeader(),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.teal,
                onRefresh: () async => context
                    .read<PatientHomeBloc>()
                    .add(const PatientHomeLoadRequested()),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WeeklyStreakCard(),
                      SizedBox(height: 20),
                      _ScheduleSection(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Teal header ───────────────────────────────────────────────────────────────

class _TealHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final fullName =
        (user?.userMetadata?['full_name'] as String?) ?? 'there';
    final firstName = fullName.split(' ').first;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.teal, AppColors.tealDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    child: Text(
                      firstName[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome 👋',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        fullName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const UpcomingReminderCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Schedule section ──────────────────────────────────────────────────────────

class _ScheduleSection extends StatelessWidget {
  const _ScheduleSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Today's Schedule",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            Row(
              children: [
                _NavArrow(icon: Icons.chevron_left_rounded, onTap: () {}),
                _NavArrow(icon: Icons.chevron_right_rounded, onTap: () {}),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        const _WeekCalendarStrip(),
        const SizedBox(height: 16),
        BlocBuilder<PatientHomeBloc, PatientHomeState>(
          builder: (context, state) {
            if (state.status == PatientHomeStatus.loading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: AppColors.teal),
                ),
              );
            }
            if (state.todayDoses.isEmpty) {
              return const _EmptySchedule();
            }
            return Column(
              children: state.todayDoses
                  .map((dose) => MedicationScheduleCard(
                        dose: dose,
                        onTaken: () => context.read<PatientHomeBloc>().add(
                              PatientHomeDoseTaken(
                                scheduleEntryId: dose.entry.id,
                                scheduledAt: dose.scheduledAt,
                              ),
                            ),
                        onSkipped: () => context.read<PatientHomeBloc>().add(
                              PatientHomeDoseSkipped(
                                scheduleEntryId: dose.entry.id,
                                scheduledAt: dose.scheduledAt,
                              ),
                            ),
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _NavArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavArrow({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 22, color: Colors.grey[500]),
      ),
    );
  }
}

class _WeekCalendarStrip extends StatelessWidget {
  const _WeekCalendarStrip();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final day = weekStart.add(Duration(days: i));
        final isToday = day.day == now.day &&
            day.month == now.month &&
            day.year == now.year;

        return Column(
          children: [
            Text(
              labels[i],
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isToday ? AppColors.teal : Colors.transparent,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '${day.day}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                  color: isToday ? Colors.white : Colors.grey[700],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _EmptySchedule extends StatelessWidget {
  const _EmptySchedule();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Image.asset('assets/images/homescreen/pill.png', width: 44, height: 44, color: Colors.grey[300]),
            const SizedBox(height: 8),
            Text(
              'No medications scheduled for today',
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom nav ────────────────────────────────────────────────────────────────

class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onAddAlert;
  const _BottomNavBar({required this.currentIndex, required this.onTap, required this.onAddAlert});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      elevation: 12,
      padding: EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            assetPath: 'assets/images/bottomnv/home.png',
            label: 'Home',
            active: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          _NavItem(
            assetPath: 'assets/images/bottomnv/pills.png',
            label: 'My Meds',
            active: currentIndex == 1,
            onTap: () => onTap(1),
          ),
          _AddAlertButton(onTap: onAddAlert),
          _NavItem(
            assetPath: 'assets/images/bottomnv/chart.png',
            label: 'Reports',
            active: currentIndex == 2,
            onTap: () => onTap(2),
          ),
          _NavItem(
            assetPath: 'assets/images/bottomnv/profile.png',
            label: 'Profile',
            active: currentIndex == 3,
            onTap: () => onTap(3),
          ),
        ],
      ),
    );
  }
}

class _AddAlertButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddAlertButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.teal,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 2),
          Text(
            'Add Alert',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 10,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String assetPath;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _NavItem({
    required this.assetPath,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.teal : Colors.grey[400]!;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // active indicator line at top
          Container(
            height: 3,
            width: 28,
            decoration: BoxDecoration(
              color: active ? AppColors.teal : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 6),
          ImageIcon(
            AssetImage(assetPath),
            color: color,
            size: 24,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: active ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
