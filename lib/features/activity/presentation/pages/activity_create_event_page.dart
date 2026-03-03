import 'package:flutter/material.dart';
import 'package:well_paw/core/theme/app_colors.dart';
import 'package:well_paw/features/profile/data/models/pet_models.dart';

enum ActivityEventType { vaccine, medication, doctor, other }

class ActivityEventDraft {
  const ActivityEventDraft({
    required this.title,
    required this.petName,
    required this.date,
    required this.time,
    required this.type,
    this.note,
  });

  final String title;
  final String petName;
  final DateTime date;
  final TimeOfDay time;
  final ActivityEventType type;
  final String? note;
}

class ActivityCreateEventPage extends StatefulWidget {
  const ActivityCreateEventPage({
    super.key,
    required this.pets,
    this.initialDate,
    this.initialPetName,
  });

  final List<PetProfileData> pets;
  final DateTime? initialDate;
  final String? initialPetName;

  @override
  State<ActivityCreateEventPage> createState() =>
      _ActivityCreateEventPageState();
}

class _ActivityCreateEventPageState extends State<ActivityCreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late ActivityEventType _selectedType;
  String? _selectedPetName;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate =
        widget.initialDate ?? DateTime(now.year, now.month, now.day);
    _selectedTime = TimeOfDay(hour: now.hour, minute: now.minute);
    _selectedType = ActivityEventType.vaccine;
    _selectedPetName =
        widget.initialPetName ??
        (widget.pets.isNotEmpty ? widget.pets.first.name : null);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
      helpText: 'เลือกวันที่กิจกรรม',
    );
    if (selected == null) return;
    setState(() {
      _selectedDate = DateTime(selected.year, selected.month, selected.day);
    });
  }

  Future<void> _pickTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      helpText: 'เลือกเวลา',
    );
    if (selected == null) return;
    setState(() {
      _selectedTime = selected;
    });
  }

  String _formatDate(DateTime value) {
    const thaiMonths = [
      '',
      'ม.ค.',
      'ก.พ.',
      'มี.ค.',
      'เม.ย.',
      'พ.ค.',
      'มิ.ย.',
      'ก.ค.',
      'ส.ค.',
      'ก.ย.',
      'ต.ค.',
      'พ.ย.',
      'ธ.ค.',
    ];
    return '${value.day} ${thaiMonths[value.month]} ${value.year + 543}';
  }

  String _formatTime(TimeOfDay value) {
    final hh = value.hour.toString().padLeft(2, '0');
    final mm = value.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if ((_selectedPetName ?? '').trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('กรุณาเลือกสัตว์เลี้ยง')));
      return;
    }

    Navigator.of(context).pop(
      ActivityEventDraft(
        title: _titleController.text.trim(),
        petName: _selectedPetName!.trim(),
        date: _selectedDate,
        time: _selectedTime,
        type: _selectedType,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEFF4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F8),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        title: const Text(
          'เพิ่มกิจกรรม',
          style: TextStyle(
            color: AppColors.primaryBlue,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FieldLabel('หัวข้อกิจกรรม'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleController,
                        decoration: _inputDecoration('เช่น นัดฉีดวัคซีน'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'กรุณากรอกหัวข้อกิจกรรม';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      const _FieldLabel('เลือกสัตว์เลี้ยง'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedPetName,
                        decoration: _inputDecoration('เลือกสัตว์เลี้ยง'),
                        items: widget.pets
                            .map(
                              (pet) => DropdownMenuItem(
                                value: pet.name,
                                child: Text(pet.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedPetName = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FieldLabel('ประเภทกิจกรรม'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ActivityEventType.values.map((type) {
                          final selected = _selectedType == type;
                          return ChoiceChip(
                            label: Text(_typeLabel(type)),
                            selected: selected,
                            onSelected: (_) {
                              setState(() {
                                _selectedType = type;
                              });
                            },
                            selectedColor: AppColors.primaryBlue,
                            labelStyle: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _TapField(
                              label: 'วันที่',
                              value: _formatDate(_selectedDate),
                              icon: Icons.calendar_month_outlined,
                              onTap: _pickDate,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _TapField(
                              label: 'เวลา',
                              value: _formatTime(_selectedTime),
                              icon: Icons.access_time_outlined,
                              onTap: _pickTime,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FieldLabel('หมายเหตุ (ไม่บังคับ)'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _noteController,
                        minLines: 3,
                        maxLines: 4,
                        decoration: _inputDecoration('รายละเอียดเพิ่มเติม'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text(
                      'บันทึกกิจกรรม',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _typeLabel(ActivityEventType type) {
    switch (type) {
      case ActivityEventType.vaccine:
        return 'วัคซีน';
      case ActivityEventType.medication:
        return 'ยา';
      case ActivityEventType.doctor:
        return 'พบหมอ';
      case ActivityEventType.other:
        return 'อื่น ๆ';
    }
  }
}

InputDecoration _inputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFDCE2EC)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFDCE2EC)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.primaryBlue),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7ED)),
      ),
      child: child,
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.primaryBlue,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _TapField extends StatelessWidget {
  const _TapField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFDCE2EC)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(icon, color: AppColors.primaryBlue, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
