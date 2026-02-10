import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/session.dart';

class ScheduleScreen extends StatelessWidget {
  final List<Session> sessions;
  final Function(List<Session>) onSessionsChanged;

  const ScheduleScreen({
    super.key,
    required this.sessions,
    required this.onSessionsChanged,
  });

  /// Opens form to create or edit a session
  void _openSessionForm(BuildContext context, {Session? existingSession}) {
    final titleController = TextEditingController(
      text: existingSession?.title ?? '',
    );
    final locationController = TextEditingController(
      text: existingSession?.location ?? '',
    );

    DateTime selectedDate = existingSession?.date ?? DateTime.now();
    TimeOfDay startTime = TimeOfDay.now();
    TimeOfDay endTime = TimeOfDay.now();

    SessionType selectedType =
        existingSession?.sessionType ?? SessionType.classSession;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(existingSession == null ? 'Add Session' : 'Edit Session'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                /// Title input
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Session Title *'),
                ),

                /// Location input
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                ),

                const SizedBox(height: 10),

                /// Date picker
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedDate = picked);
                    }
                  },
                  child: Text('Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                ),

                /// Start time picker
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: startTime,
                    );
                    if (picked != null) {
                      setDialogState(() => startTime = picked);
                    }
                  },
                  child: Text('Start: ${startTime.format(context)}'),
                ),

                /// End time picker
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: endTime,
                    );
                    if (picked != null) {
                      setDialogState(() => endTime = picked);
                    }
                  },
                  child: Text('End: ${endTime.format(context)}'),
                ),

                /// Session type dropdown
                DropdownButton<SessionType>(
                  value: selectedType,
                  isExpanded: true,
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
              onPressed: () {
                if (titleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a session title'),
                      backgroundColor: AppColors.red,
                    ),
                  );
                  return;
                }

                final newSession = Session(
                  id:
                      existingSession?.id ??
                      DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text.trim(),
                  date: selectedDate,
                  startTime: startTime.format(context),
                  endTime: endTime.format(context),
                  location: locationController.text.trim(),
                  sessionType: selectedType,
                  attendanceStatus: existingSession?.attendanceStatus,
                );

                final updatedSessions = [...sessions];

                if (existingSession != null) {
                  final index = sessions.indexOf(existingSession);
                  updatedSessions[index] = newSession;
                } else {
                  updatedSessions.add(newSession);
                }

                onSessionsChanged(updatedSessions);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        title: const Text('Schedule', style: TextStyle(color: AppColors.white)),
      ),

      /// Session list
      body: sessions.isEmpty
          ? const Center(
              child: Text(
                'No sessions scheduled',
                style: TextStyle(color: AppColors.mutedWhite),
              ),
            )
          : ListView.builder(
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];

                return Card(
                  child: ListTile(
                    title: Text(session.title),
                    subtitle: Text(
                      '${sessionTypeLabels[session.sessionType]} • '
                      '${session.startTime} - ${session.endTime}',
                    ),

                    /// Attendance toggle
                    trailing: Switch(
                      value:
                          session.attendanceStatus == AttendanceStatus.present,
                      onChanged: (value) {
                        final updatedSessions = [...sessions];
                        updatedSessions[index] = Session(
                          id: session.id,
                          title: session.title,
                          date: session.date,
                          startTime: session.startTime,
                          endTime: session.endTime,
                          location: session.location,
                          sessionType: session.sessionType,
                          attendanceStatus: value
                              ? AttendanceStatus.present
                              : AttendanceStatus.absent,
                        );
                        onSessionsChanged(updatedSessions);
                      },
                    ),

                    /// Edit on tap
                    onTap: () =>
                        _openSessionForm(context, existingSession: session),

                    /// Delete on long press
                    onLongPress: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Delete Session'),
                          content: Text('Delete "${session.title}"?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                final updatedSessions = [...sessions]..removeAt(index);
                                onSessionsChanged(updatedSessions);
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.red,
                              ),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),

      /// Add new session
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.yellow,
        onPressed: () => _openSessionForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
