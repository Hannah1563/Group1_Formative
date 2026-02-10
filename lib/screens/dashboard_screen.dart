import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../models/assignment.dart';
import '../models/session.dart';

// Dashboard Screen - shows the main overview for students
// Shows today's date, sessions, upcoming assignments, and attendance
// By Hannah (hannah-dashboard branch)
class DashboardScreen extends StatelessWidget {
  // these come from main.dart
  final List<Assignment> assignments;
  final List<Session> sessions;

  const DashboardScreen({
    super.key,
    required this.assignments,
    required this.sessions,
  });

  // figure out what week we're in (semester started Jan 20)
  int _getAcademicWeek() {
    final semesterStart = DateTime(2026, 1, 20);
    final today = DateTime.now();
    final daysDifference = today.difference(semesterStart).inDays;
    final weekNumber = (daysDifference / 7).floor() + 1;
    return weekNumber.clamp(1, 16); // keep between 1-16
  }

  // get only the sessions happening today
  List<Session> _getTodaySessions() {
    final today = DateTime.now();
    return sessions.where((session) {
      return session.date.year == today.year &&
          session.date.month == today.month &&
          session.date.day == today.day;
    }).toList()
      ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
  }

  // get assignments due in next 7 days that aren't done yet
  List<Assignment> _getUpcomingAssignments() {
    final today = DateTime.now();
    final sevenDaysLater = today.add(const Duration(days: 7));
    
    return assignments.where((assignment) {
      return !assignment.isCompleted &&
          assignment.dueDate.isAfter(today.subtract(const Duration(days: 1))) &&
          assignment.dueDate.isBefore(sevenDaysLater.add(const Duration(days: 1)));
    }).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  // calculate attendance % based on sessions marked present/absent
  double _calculateAttendancePercentage() {
    final recordedSessions = sessions.where(
      (session) => session.attendanceStatus != null
    ).toList();
    
    if (recordedSessions.isEmpty) {
      return 100.0; // no sessions recorded yet
    }
    
    final presentCount = recordedSessions.where(
      (session) => session.attendanceStatus == AttendanceStatus.present
    ).length;
    
    return (presentCount / recordedSessions.length) * 100;
  }

  // count incomplete assignments
  int _getPendingAssignmentCount() {
    return assignments.where((a) => !a.isCompleted).length;
  }

  @override
  Widget build(BuildContext context) {
    // grab all the data we need
    final todaySessions = _getTodaySessions();
    final upcomingAssignments = _getUpcomingAssignments();
    final attendancePercentage = _calculateAttendancePercentage();
    final pendingCount = _getPendingAssignmentCount();
    final academicWeek = _getAcademicWeek();
    final todayFormatted = DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.navy,
      // App bar with Dashboard title
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      // Main body with scrollable content
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // date and week at top
              _buildDateSection(todayFormatted, academicWeek),
              
              const SizedBox(height: 20),
              
              // show warning if attendance below 75%
              if (attendancePercentage < 75)
                _buildAttendanceWarningBanner(attendancePercentage),
              
              if (attendancePercentage < 75) const SizedBox(height: 16),
              
              // attendance and pending count cards
              _buildStatsSummaryRow(attendancePercentage, pendingCount),
              
              const SizedBox(height: 24),
              
              // today's sessions
              _buildSectionHeader('Today\'s Sessions', todaySessions.length),
              const SizedBox(height: 12),
              _buildTodaySessionsList(todaySessions),
              
              const SizedBox(height: 24),
              
              // assignments due soon
              _buildSectionHeader('Due This Week', upcomingAssignments.length),
              const SizedBox(height: 12),
              _buildUpcomingAssignmentsList(upcomingAssignments),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // date section with week badge
  Widget _buildDateSection(String dateString, int weekNumber) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navyDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Today',
                  style: TextStyle(
                    color: AppColors.mutedWhite,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateString,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // week badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.yellow,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Week $weekNumber',
              style: const TextStyle(
                color: AppColors.navyDark,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // red warning banner for low attendance
  Widget _buildAttendanceWarningBanner(double percentage) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.red.withAlpha(38),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.red, width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.red,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Low Attendance Warning!',
                  style: TextStyle(
                    color: AppColors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your attendance is ${percentage.toStringAsFixed(1)}%. '
                  'You need at least 75% to stay on track.',
                  style: TextStyle(
                    color: AppColors.red.withAlpha(230),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // row with attendance and pending count cards
  Widget _buildStatsSummaryRow(double attendance, int pendingCount) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.check_circle_outline,
            label: 'Attendance',
            value: '${attendance.toStringAsFixed(1)}%',
            valueColor: attendance < 75 ? AppColors.red : AppColors.statusGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.assignment_outlined,
            label: 'Pending Tasks',
            value: pendingCount.toString(),
            valueColor: pendingCount > 0 ? AppColors.yellow : AppColors.statusGreen,
          ),
        ),
      ],
    );
  }

  // reusable stat card
  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navyDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.mutedWhite, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.mutedWhite,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // section title with count badge
  Widget _buildSectionHeader(String title, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.yellow.withAlpha(51),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: const TextStyle(
              color: AppColors.yellow,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  // list of today's sessions (or empty message)
  Widget _buildTodaySessionsList(List<Session> todaySessions) {
    if (todaySessions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.navyDark,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(
                Icons.event_available,
                color: AppColors.mutedWhite,
                size: 40,
              ),
              SizedBox(height: 12),
              Text(
                'No sessions scheduled for today',
                style: TextStyle(
                  color: AppColors.mutedWhite,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: todaySessions.map((session) => _buildSessionCard(session)).toList(),
    );
  }

  // single session card
  Widget _buildSessionCard(Session session) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.navyDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // time box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.yellow.withAlpha(38),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  session.startTime,
                  style: const TextStyle(
                    color: AppColors.yellow,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Text(
                  '-',
                  style: TextStyle(
                    color: AppColors.mutedWhite,
                    fontSize: 10,
                  ),
                ),
                Text(
                  session.endTime,
                  style: const TextStyle(
                    color: AppColors.yellow,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          // session info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.title,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    // location if set
                    if (session.location.isNotEmpty) ...[
                      const Icon(
                        Icons.location_on_outlined,
                        color: AppColors.mutedWhite,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        session.location,
                        style: const TextStyle(
                          color: AppColors.mutedWhite,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    // type badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.yellow.withAlpha(51),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        sessionTypeLabels[session.sessionType] ?? 'Session',
                        style: TextStyle(
                          color: AppColors.yellow,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // attendance icon if recorded
          if (session.attendanceStatus != null)
            Icon(
              session.attendanceStatus == AttendanceStatus.present
                  ? Icons.check_circle
                  : Icons.cancel,
              color: session.attendanceStatus == AttendanceStatus.present
                  ? AppColors.statusGreen
                  : AppColors.red,
              size: 24,
            ),
        ],
      ),
    );
  }

  // list of upcoming assignments (or empty message)
  Widget _buildUpcomingAssignmentsList(List<Assignment> upcomingAssignments) {
    if (upcomingAssignments.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.navyDark,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(
                Icons.celebration,
                color: AppColors.yellow,
                size: 40,
              ),
              SizedBox(height: 12),
              Text(
                'No assignments due this week!',
                style: TextStyle(
                  color: AppColors.mutedWhite,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: upcomingAssignments
          .map((assignment) => _buildAssignmentCard(assignment))
          .toList(),
    );
  }

  // single assignment card
  Widget _buildAssignmentCard(Assignment assignment) {
    final daysUntilDue = assignment.dueDate.difference(DateTime.now()).inDays;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.navyDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // priority bar
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: _getPriorityColor(assignment.priority),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 14),
          // assignment info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignment.title,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  assignment.courseName,
                  style: const TextStyle(
                    color: AppColors.mutedWhite,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // due date badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: daysUntilDue <= 1
                  ? AppColors.red.withAlpha(51)
                  : AppColors.yellow.withAlpha(38),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  _getDueDateText(daysUntilDue),
                  style: TextStyle(
                    color: daysUntilDue <= 1 ? AppColors.red : AppColors.yellow,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  DateFormat('MMM d').format(assignment.dueDate),
                  style: TextStyle(
                    color: daysUntilDue <= 1
                        ? AppColors.red.withAlpha(204)
                        : AppColors.mutedWhite,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // convert days to text like "Today" or "In 3 days"
  String _getDueDateText(int daysUntilDue) {
    if (daysUntilDue < 0) return 'Overdue';
    if (daysUntilDue == 0) return 'Today';
    if (daysUntilDue == 1) return 'Tomorrow';
    return 'In $daysUntilDue days';
  }

  // priority colors: high=red, medium=yellow, low=green
  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return AppColors.red;
      case Priority.medium:
        return AppColors.yellow;
      case Priority.low:
        return AppColors.statusGreen;
    }
  }
}
