import 'package:flutter/material.dart';
import 'package:well_paw/core/theme/app_colors.dart';
import 'package:well_paw/core/theme/app_typography.dart';
import 'package:well_paw/features/activity/presentation/pages/activity_create_event_page.dart';
import 'package:well_paw/features/auth/data/storage/token_storage.dart';
import 'package:well_paw/features/food/presentation/pages/food_home_page.dart';
import 'package:well_paw/features/health/presentation/pages/health_page.dart';
import 'package:well_paw/features/home/presentation/pages/home_page.dart';
import 'package:well_paw/features/profile/data/models/pet_models.dart';
import 'package:well_paw/features/profile/data/services/pet_api_service.dart';
import 'package:well_paw/features/profile/data/services/user_api_service.dart';
import 'package:well_paw/features/profile/presentation/pages/profile_page.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  final _tokenStorage = const TokenStorage();
  final _petApi = PetApiService();
  final _userApi = UserApiService();

  bool _isLoading = true;
  bool _isTogglingCalendar = false;
  String? _error;

  List<PetProfileData> _pets = const [];
  int _selectedPetIndex = 0;
  bool? _calendarNotificationEnabled;
  DateTime _selectedCalendarDate = DateTime(2026, 2, 28);
  final List<ActivityEventDraft> _customEvents = [];

  PetProfileData? get _selectedPet {
    if (_selectedPetIndex < 0 || _selectedPetIndex >= _pets.length) {
      return null;
    }
    return _pets[_selectedPetIndex];
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await _tokenStorage.readAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('ไม่พบโทเคนสำหรับเข้าสู่ระบบ');
      }

      final pets = await _petApi.fetchMyPets(accessToken: token);
      if (!mounted) return;

      setState(() {
        _pets = pets;
        if (_selectedPetIndex >= pets.length) {
          _selectedPetIndex = pets.isEmpty ? 0 : pets.length - 1;
        }
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'โหลดข้อมูลกิจกรรมไม่สำเร็จ: $e';
      });
    }
  }

  Future<void> _toggleCalendarNotification() async {
    if (_isTogglingCalendar) {
      return;
    }

    setState(() {
      _isTogglingCalendar = true;
    });

    try {
      final token = await _tokenStorage.readAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('ไม่พบโทเคนสำหรับเข้าสู่ระบบ');
      }

      final toggled = await _userApi.toggleCalendarNotification(
        accessToken: token,
      );

      if (!mounted) return;

      setState(() {
        _calendarNotificationEnabled =
            toggled ?? !(_calendarNotificationEnabled ?? false);
      });

      final status = _calendarNotificationEnabled == true ? 'เปิด' : 'ปิด';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('แจ้งเตือนปฏิทิน$statusแล้ว')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('สลับแจ้งเตือนปฏิทินไม่สำเร็จ: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isTogglingCalendar = false;
        });
      }
    }
  }

  Future<void> _openCreateEvent({DateTime? initialDate}) async {
    if (_pets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ยังไม่มีสัตว์เลี้ยงสำหรับสร้างกิจกรรม')),
      );
      return;
    }

    final draft = await Navigator.of(context).push<ActivityEventDraft>(
      MaterialPageRoute(
        builder: (_) => ActivityCreateEventPage(
          pets: _pets,
          initialDate: initialDate ?? _selectedCalendarDate,
          initialPetName: _selectedPet?.name,
        ),
      ),
    );

    if (!mounted || draft == null) {
      return;
    }

    setState(() {
      _customEvents.add(draft);
      _selectedCalendarDate = DateTime(
        draft.date.year,
        draft.date.month,
        draft.date.day,
      );
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('เพิ่มกิจกรรมเรียบร้อยแล้ว')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEFF4),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(child: Text(_error!))
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ActivityHeader(
                      onToggleNotification: _toggleCalendarNotification,
                      notificationEnabled: _calendarNotificationEnabled,
                      isTogglingNotification: _isTogglingCalendar,
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: _CalendarCard(
                        selectedDate: _selectedCalendarDate,
                        onAddPressed: (date) =>
                            _openCreateEvent(initialDate: date),
                        onDateTap: (date) {
                          setState(() {
                            _selectedCalendarDate = DateTime(
                              date.year,
                              date.month,
                              date.day,
                            );
                          });
                          _openCreateEvent(initialDate: date);
                        },
                      ),
                    ),
                    const SizedBox(height: 18),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: _UpcomingSection(events: _customEvents),
                    ),
                    const SizedBox(height: 18),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: _MonthlySummaryCard(),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: _ActivityBottomNav(
        currentIndex: 3,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          } else if (index == 1) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const FoodHomePage()),
            );
          } else if (index == 2) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HealthPage()),
            );
          } else if (index == 4) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            );
          }
        },
      ),
    );
  }
}

class _ActivityHeader extends StatelessWidget {
  const _ActivityHeader({
    required this.onToggleNotification,
    required this.notificationEnabled,
    required this.isTogglingNotification,
  });

  final VoidCallback onToggleNotification;
  final bool? notificationEnabled;
  final bool isTogglingNotification;

  @override
  Widget build(BuildContext context) {
    final statusText = notificationEnabled == null
        ? 'ยังไม่ซิงก์สถานะ'
        : notificationEnabled == true
        ? 'แจ้งเตือน: เปิด'
        : 'แจ้งเตือน: ปิด';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 22),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ปฏิทิน',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppTypography.headline,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Calendar & Events',
                  style: TextStyle(
                    color: Color(0xFFDCE6FA),
                    fontSize: AppTypography.body,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  statusText,
                  style: const TextStyle(
                    color: Color(0xFFE9EFFB),
                    fontSize: AppTypography.bodyCompact,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: isTogglingNotification ? null : onToggleNotification,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFE9A8DD),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.16),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: isTogglingNotification
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      notificationEnabled == true
                          ? Icons.notifications_active_outlined
                          : Icons.notifications_off_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({
    required this.selectedDate,
    required this.onDateTap,
    required this.onAddPressed,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateTap;
  final ValueChanged<DateTime> onAddPressed;

  @override
  Widget build(BuildContext context) {
    const days = [
      ['1', '2', '3', '4', '5', '6', '7'],
      ['8', '9', '10', '11', '12', '13', '14'],
      ['15', '16', '17', '18', '19', '20', '21'],
      ['22', '23', '24', '25', '26', '27', '28'],
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F8),
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.chevron_left, color: AppColors.primaryBlue),
              const Expanded(
                child: Text(
                  'กุมภาพันธ์ 2569',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: AppTypography.subheading,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.primaryBlue),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => onAddPressed(selectedDate),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              _WeekdayText('อา'),
              _WeekdayText('จ'),
              _WeekdayText('อ'),
              _WeekdayText('พ'),
              _WeekdayText('พฤ'),
              _WeekdayText('ศ'),
              _WeekdayText('ส'),
            ],
          ),
          const SizedBox(height: 10),
          for (final row in days) ...[
            Row(
              children: row.map((day) {
                final dayInt = int.tryParse(day) ?? 1;
                final thisDay = DateTime(2026, 2, dayInt);
                final selected =
                    thisDay.year == selectedDate.year &&
                    thisDay.month == selectedDate.month &&
                    thisDay.day == selectedDate.day;
                return Expanded(
                  child: Center(
                    child: GestureDetector(
                      onTap: () => onDateTap(thisDay),
                      child: Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primaryBlue
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          day,
                          style: TextStyle(
                            color: selected
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontSize: AppTypography.body,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
          ],
          const Divider(color: Color(0xFFE3E5EA), height: 20),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _LegendDot(color: AppColors.primaryBlue, label: 'วัคซีน'),
              _LegendDot(color: Color(0xFFE9A8DD), label: 'ยา'),
              _LegendDot(color: Color(0xFFF2A007), label: 'พบหมอ'),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeekdayText extends StatelessWidget {
  const _WeekdayText(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF757575),
            fontSize: AppTypography.body,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: AppTypography.body,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _UpcomingSection extends StatelessWidget {
  const _UpcomingSection({required this.events});

  final List<ActivityEventDraft> events;

  String _formatTime(TimeOfDay value) {
    final hh = value.hour.toString().padLeft(2, '0');
    final mm = value.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  String _chipText(DateTime date) {
    final today = DateTime.now();
    final a = DateTime(today.year, today.month, today.day);
    final b = DateTime(date.year, date.month, date.day);
    final diff = b.difference(a).inDays;
    if (diff == 0) return 'วันนี้';
    if (diff == 1) return 'พรุ่งนี้';
    if (diff > 1) return 'อีก $diff วัน';
    return 'ผ่านมาแล้ว';
  }

  _EventCardData _mapDraft(ActivityEventDraft item) {
    switch (item.type) {
      case ActivityEventType.vaccine:
        return _EventCardData(
          title: item.title,
          time: _formatTime(item.time),
          petName: item.petName,
          chipText: _chipText(item.date),
          icon: Icons.vaccines_outlined,
          iconColor: AppColors.primaryBlue,
          iconBg: const Color(0xFFDCE5F5),
          chipColor: AppColors.primaryBlue,
          chipBg: const Color(0xFFDFE8F8),
        );
      case ActivityEventType.medication:
        return _EventCardData(
          title: item.title,
          time: _formatTime(item.time),
          petName: item.petName,
          chipText: _chipText(item.date),
          icon: Icons.medication_outlined,
          iconColor: const Color(0xFFE9A8DD),
          iconBg: const Color(0xFFF8EAF4),
          chipColor: const Color(0xFFE9A8DD),
          chipBg: const Color(0xFFF9EDF5),
        );
      case ActivityEventType.doctor:
        return _EventCardData(
          title: item.title,
          time: _formatTime(item.time),
          petName: item.petName,
          chipText: _chipText(item.date),
          icon: Icons.medical_services_outlined,
          iconColor: const Color(0xFFF2A007),
          iconBg: const Color(0xFFFBF0DE),
          chipColor: const Color(0xFFF2A007),
          chipBg: const Color(0xFFFEF3DF),
        );
      case ActivityEventType.other:
        return _EventCardData(
          title: item.title,
          time: _formatTime(item.time),
          petName: item.petName,
          chipText: _chipText(item.date),
          icon: Icons.event_note_outlined,
          iconColor: const Color(0xFF4E9A77),
          iconBg: const Color(0xFFE2F4EA),
          chipColor: const Color(0xFF4E9A77),
          chipBg: const Color(0xFFE9F7EE),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dynamicEvents = events.map(_mapDraft).toList();
    const fallbackEvents = <_EventCardData>[
      _EventCardData(
        title: 'วัคซีนป้องกันโรคพิษสุนัขบ้า',
        time: '10:00',
        petName: 'มิโกะ',
        chipText: 'วันนี้',
        icon: Icons.vaccines_outlined,
        iconColor: AppColors.primaryBlue,
        iconBg: Color(0xFFDCE5F5),
        chipColor: AppColors.primaryBlue,
        chipBg: Color(0xFFDFE8F8),
      ),
      _EventCardData(
        title: 'ให้ยากันเห็บหมัด',
        time: '18:00',
        petName: 'โมโม่',
        chipText: 'วันนี้',
        icon: Icons.medication_outlined,
        iconColor: Color(0xFFE9A8DD),
        iconBg: Color(0xFFF8EAF4),
        chipColor: Color(0xFFE9A8DD),
        chipBg: Color(0xFFF9EDF5),
      ),
      _EventCardData(
        title: 'นัดตรวจสุขภาพ',
        time: '14:30',
        petName: 'โคโค่',
        chipText: 'พรุ่งนี้',
        icon: Icons.medical_services_outlined,
        iconColor: Color(0xFFF2A007),
        iconBg: Color(0xFFFBF0DE),
        chipColor: Color(0xFFF2A007),
        chipBg: Color(0xFFFEF3DF),
      ),
    ];
    final merged = [...dynamicEvents, ...fallbackEvents];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'กิจกรรมที่กำลังจะมาถึง',
          style: TextStyle(
            color: AppColors.primaryBlue,
            fontSize: AppTypography.headline,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        for (int i = 0; i < merged.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          _EventCard(
            title: merged[i].title,
            time: merged[i].time,
            petName: merged[i].petName,
            chipText: merged[i].chipText,
            icon: merged[i].icon,
            iconColor: merged[i].iconColor,
            iconBg: merged[i].iconBg,
            chipColor: merged[i].chipColor,
            chipBg: merged[i].chipBg,
          ),
        ],
      ],
    );
  }
}

class _EventCardData {
  const _EventCardData({
    required this.title,
    required this.time,
    required this.petName,
    required this.chipText,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.chipColor,
    required this.chipBg,
  });

  final String title;
  final String time;
  final String petName;
  final String chipText;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Color chipColor;
  final Color chipBg;
}

class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.title,
    required this.time,
    required this.petName,
    required this.chipText,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.chipColor,
    required this.chipBg,
  });

  final String title;
  final String time;
  final String petName;
  final String chipText;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Color chipColor;
  final Color chipBg;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F8),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE5E7ED)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(icon, color: iconColor, size: 38),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: AppTypography.subheading,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 24,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          time,
                          style: const TextStyle(
                            fontSize: AppTypography.body,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: Color(0xFF24A0CC),
                child: Icon(Icons.pets, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  petName,
                  style: const TextStyle(
                    fontSize: AppTypography.body,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: chipBg,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  chipText,
                  style: TextStyle(
                    color: chipColor,
                    fontSize: AppTypography.body,
                    fontWeight: FontWeight.w500,
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

class _MonthlySummaryCard extends StatelessWidget {
  const _MonthlySummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F8),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE5E7ED)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'สรุปกิจกรรมเดือนนี้',
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontSize: AppTypography.headline,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  icon: Icons.vaccines_outlined,
                  iconColor: AppColors.primaryBlue,
                  iconBg: Color(0xFFDCE5F5),
                  count: '2',
                  label: 'วัคซีน',
                ),
              ),
              Expanded(
                child: _SummaryItem(
                  icon: Icons.medication_outlined,
                  iconColor: Color(0xFFE9A8DD),
                  iconBg: Color(0xFFF8EAF4),
                  count: '5',
                  label: 'ยา',
                ),
              ),
              Expanded(
                child: _SummaryItem(
                  icon: Icons.medical_services_outlined,
                  iconColor: Color(0xFFF2A007),
                  iconBg: Color(0xFFFBF0DE),
                  count: '1',
                  label: 'พบหมอ',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.count,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 74,
          height: 74,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Icon(icon, color: iconColor, size: 38),
        ),
        const SizedBox(height: 10),
        Text(
          count,
          style: TextStyle(
            fontSize: AppTypography.headline,
            color: iconColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: AppTypography.body,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ActivityBottomNav extends StatelessWidget {
  const _ActivityBottomNav({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: AppColors.primaryBlue,
      unselectedItemColor: AppColors.textHint,
      type: BottomNavigationBarType.fixed,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Food'),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          label: 'Health',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month),
          label: 'Calendar',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
