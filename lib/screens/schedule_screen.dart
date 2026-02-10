import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../models/session.dart';

class ScheduleScreen extends StatefulWidget {
  final List<Session> sessions;
  final Function(List<Session>) onSessionsChanged;

  const ScheduleScreen({
    super.key,
    required this.sessions,
    required this.onSessionsChanged,
  });

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int _weekOffset = 0; // 0 = current week

  DateTime _startOfWeek(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    // Monday = 1, Sunday = 7
    final monday = d.subtract(Duration(days: d.weekday - DateTime.monday));
    return DateTime(monday.year, monday.month, monday.day);
  }

  DateTime get _weekStart => _startOfWeek(DateTime.now()).add(
        Duration(days: 7 * _weekOffset),
      );

  DateTime get _weekEnd => _weekStart.add(const Duration(days: 6));

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  int _minutes(TimeOfDay t) => t.hour * 60 + t.minute;

  TimeOfDay _timeOfDayFromMinutes(int minutes) {
    final m = minutes.clamp(0, 1439);
    return TimeOfDay(hour: m ~/ 60, minute: m % 60);
  }

  String _formatDateShort(DateTime d) => DateFormat('EEE, MMM d').format(d);

  String _formatWeekRange(DateTime start, DateTime end) {
    final s = DateFormat('MMM d').format(start);
    final e = DateFormat('MMM d').format(end);
    return '$s - $e';
  }

  List<Session> _sessionsInWeek() {
    final start = _weekStart;
    final end = _weekEnd;
    return widget.sessions.where((s) {
      final d = DateTime(s.date.year, s.date.month, s.date.day);
      return !d.isBefore(start) && !d.isAfter(end);
    }).toList()
      ..sort((a, b) {
        final byDate = a.date.compareTo(b.date);
        if (byDate != 0) return byDate;
        return a.startMinutes.compareTo(b.startMinutes);
      });
  }

  Future<void> _openSessionForm({Session? existing}) async {
    final titleController = TextEditingController(text: existing?.title ?? '');
    final locationController = TextEditingController(
      text: existing?.location ?? '',
    );

    var selectedDate = existing?.date ?? DateTime.now();
    var start = existing != null
        ? _timeOfDayFromMinutes(existing.startMinutes)
        : TimeOfDay.now();
    var end = existing != null
        ? _timeOfDayFromMinutes(existing.endMinutes)
        : _timeOfDayFromMinutes(_minutes(TimeOfDay.now()) + 60);
    var selectedType = existing?.sessionType ?? SessionType.classSession;

    await showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          Future<void> pickDate() async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
            );
            if (picked != null) {
              setDialogState(() => selectedDate = picked);
            }
          }

          Future<void> pickStart() async {
            final picked = await showTimePicker(
              context: context,
              initialTime: start,
            );
            if (picked != null) {
              setDialogState(() => start = picked);
            }
          }

          Future<void> pickEnd() async {
            final picked = await showTimePicker(
              context: context,
              initialTime: end,
            );
            if (picked != null) {
              setDialogState(() => end = picked);
            }
          }

          void save() {
            if (titleController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Session title is required'),
                  backgroundColor: AppColors.red,
                ),
              );
              return;
            }

            final startM = _minutes(start);
            final endM = _minutes(end);
            if (endM <= startM) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('End time must be after start time'),
                  backgroundColor: AppColors.red,
                ),
              );
              return;
            }

            final startLabel = start.format(context);
            final endLabel = end.format(context);

            final newSession = Session(
              id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
              title: titleController.text.trim(),
              date: selectedDate,
              startMinutes: startM,
              endMinutes: endM,
              startTime: startLabel,
              endTime: endLabel,
              location: locationController.text.trim(),
              sessionType: selectedType,
              attendanceStatus: existing?.attendanceStatus,
            );

            final updated = List<Session>.from(widget.sessions);
            if (existing != null) {
              final idx = updated.indexWhere((s) => s.id == existing.id);
              if (idx != -1) {
                updated[idx] = newSession;
              }
            } else {
              updated.add(newSession);
            }

            widget.onSessionsChanged(updated);
            Navigator.pop(context);
          }

          return AlertDialog(
            backgroundColor: AppColors.cardBackground,
            title: Text(
              existing == null ? 'Add Session' : 'Edit Session',
              style: const TextStyle(
                color: AppColors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Session Title *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.navy),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: locationController,
                    decoration: InputDecoration(
                      labelText: 'Location (optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.navy),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: pickDate,
                          icon: const Icon(Icons.calendar_today_outlined),
                          label: Text(_formatDateShort(selectedDate)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: pickStart,
                          child: Text('Start: ${start.format(context)}'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: pickEnd,
                          child: Text('End: ${end.format(context)}'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<SessionType>(
                    initialValue: selectedType,
                    decoration: InputDecoration(
                      labelText: 'Session Type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: SessionType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(sessionTypeLabels[type]!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => selectedType = value);
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.yellow,
                  foregroundColor: AppColors.navyDark,
                ),
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _deleteSession(Session session) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Delete Session'),
        content: Text('Delete "${session.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updated =
                  widget.sessions.where((s) => s.id != session.id).toList();
              widget.onSessionsChanged(updated);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _setAttendance(Session session, AttendanceStatus status) {
    final updated = List<Session>.from(widget.sessions);
    final idx = updated.indexWhere((s) => s.id == session.id);
    if (idx == -1) return;

    updated[idx] = Session(
      id: session.id,
      title: session.title,
      date: session.date,
      startMinutes: session.startMinutes,
      endMinutes: session.endMinutes,
      startTime: session.startTime,
      endTime: session.endTime,
      location: session.location,
      sessionType: session.sessionType,
      attendanceStatus: status,
    );
    widget.onSessionsChanged(updated);
  }

  Widget _buildWeekHeader() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.navyDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => setState(() => _weekOffset -= 1),
            icon: const Icon(Icons.chevron_left, color: AppColors.yellow),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Weekly Schedule',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatWeekRange(_weekStart, _weekEnd),
                  style: const TextStyle(
                    color: AppColors.mutedWhite,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _weekOffset += 1),
            icon: const Icon(Icons.chevron_right, color: AppColors.yellow),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySection(DateTime day, List<Session> daySessions) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.navyDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('EEEE, MMM d').format(day),
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          ...daySessions.map(_buildSessionCard),
        ],
      ),
    );
  }

  Widget _buildSessionCard(Session session) {
    final attendance = session.attendanceStatus;
    final attendanceText = attendance == null
        ? 'Not recorded'
        : attendance == AttendanceStatus.present
            ? 'Present'
            : 'Absent';
    final attendanceColor = attendance == null
        ? AppColors.mutedWhite
        : attendance == AttendanceStatus.present
            ? AppColors.statusGreen
            : AppColors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.title,
                      style: const TextStyle(
                        color: AppColors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${sessionTypeLabels[session.sessionType]} • ${session.startTime} - ${session.endTime}',
                      style: TextStyle(color: Colors.grey[700], fontSize: 12),
                    ),
                    if (session.location.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Location: ${session.location}',
                        style: TextStyle(color: Colors.grey[700], fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _openSessionForm(existing: session),
                icon: const Icon(Icons.edit, color: AppColors.navy),
              ),
              IconButton(
                onPressed: () => _deleteSession(session),
                icon: const Icon(Icons.delete, color: AppColors.red),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Attendance: $attendanceText',
                style: TextStyle(
                  color: attendanceColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              ChoiceChip(
                label: const Text('Present'),
                selected: attendance == AttendanceStatus.present,
                onSelected: (_) => _setAttendance(session, AttendanceStatus.present),
                selectedColor: AppColors.statusGreen.withAlpha(51),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Absent'),
                selected: attendance == AttendanceStatus.absent,
                onSelected: (_) => _setAttendance(session, AttendanceStatus.absent),
                selectedColor: AppColors.red.withAlpha(51),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final weekSessions = _sessionsInWeek();
    final weekDays = List<DateTime>.generate(
      7,
      (i) => _weekStart.add(Duration(days: i)),
    );

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        title: const Text(
          'Schedule',
          style: TextStyle(color: AppColors.white),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildWeekHeader(),
              const SizedBox(height: 16),
              Expanded(
                child: weekSessions.isEmpty
                    ? const Center(
                        child: Text(
                          'No sessions scheduled for this week',
                          style: TextStyle(color: AppColors.mutedWhite),
                        ),
                      )
                    : ListView(
                        children: weekDays.map((day) {
                          final daySessions = weekSessions
                              .where((s) => _isSameDay(s.date, day))
                              .toList()
                            ..sort((a, b) =>
                                a.startMinutes.compareTo(b.startMinutes));
                          if (daySessions.isEmpty) return const SizedBox.shrink();
                          return _buildDaySection(day, daySessions);
                        }).where((w) => w is! SizedBox).toList(),
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.yellow,
        onPressed: () => _openSessionForm(),
        child: const Icon(Icons.add, color: AppColors.navyDark),
      ),
    );
  }
}
