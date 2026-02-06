import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../models/assignment.dart';
import '../models/session.dart';

/// DashboardScreen - Main overview screen for ALU Academic Assistant
/// 
/// This screen displays:
/// - Today's date and current academic week number
/// - Today's scheduled sessions (classes, study groups, etc.)
/// - Assignments due within the next 7 days
/// - Overall attendance percentage with warning if below 75%
/// - Count of pending (incomplete) assignments
/// 
/// Author: Hannah
/// Branch: hannah-dashboard
class DashboardScreen extends StatelessWidget {
  // List of all assignments passed from parent (HomeWrapper in main.dart)
  final List<Assignment> assignments;
  // List of all sessions passed from parent
  final List<Session> sessions;

  const DashboardScreen({
    super.key,
    required this.assignments,
    required this.sessions,
  });

  /// Calculates the current academic week number
  /// ALU semester typically starts in late January
  /// Week 1 starts from semester begin date
  int _getAcademicWeek() {
    // Assuming Spring 2026 semester started Jan 20, 2026
    final semesterStart = DateTime(2026, 1, 20);
    final today = DateTime.now();
    // Calculate difference in days and convert to weeks
    final daysDifference = today.difference(semesterStart).inDays;
    // Add 1 because week 1 is the first week, not week 0
    final weekNumber = (daysDifference / 7).floor() + 1;
    // Return at least week 1, max week 16 (typical semester length)
    return weekNumber.clamp(1, 16);
  }

  /// Filters sessions to get only today's sessions
  /// Compares year, month, and day to check if session is today
  List<Session> _getTodaySessions() {
    final today = DateTime.now();
    return sessions.where((session) {
      // Check if session date matches today's date
      return session.date.year == today.year &&
          session.date.month == today.month &&
          session.date.day == today.day;
    }).toList()
      // Sort by start time so earliest sessions appear first
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  /// Gets assignments due within the next 7 days that are not completed
  /// Used to show upcoming deadlines on the dashboard
  List<Assignment> _getUpcomingAssignments() {
    final today = DateTime.now();
    // Calculate date 7 days from now
    final sevenDaysLater = today.add(const Duration(days: 7));
    
    return assignments.where((assignment) {
      // Include if: not completed AND due date is between today and 7 days later
      return !assignment.isCompleted &&
          assignment.dueDate.isAfter(today.subtract(const Duration(days: 1))) &&
          assignment.dueDate.isBefore(sevenDaysLater.add(const Duration(days: 1)));
    }).toList()
      // Sort by due date - earliest deadline first
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  /// Calculates overall attendance percentage
  /// Only counts sessions where attendance has been recorded (present or absent)
  /// Returns percentage as double (0-100)
  double _calculateAttendancePercentage() {
    // Filter sessions that have attendance recorded
    final recordedSessions = sessions.where(
      (session) => session.attendanceStatus != null
    ).toList();
    
    // Avoid division by zero if no sessions recorded yet
    if (recordedSessions.isEmpty) {
      return 100.0; // Default to 100% if no attendance recorded
    }
    
    // Count sessions marked as present
    final presentCount = recordedSessions.where(
      (session) => session.attendanceStatus == AttendanceStatus.present
    ).length;
    
    // Calculate percentage: (present / total recorded) * 100
    return (presentCount / recordedSessions.length) * 100;
  }

  /// Counts assignments that are not yet completed
  /// Used for the pending assignments summary badge
  int _getPendingAssignmentCount() {
    return assignments.where((a) => !a.isCompleted).length;
  }

  @override
  Widget build(BuildContext context) {
    // Get all the calculated values we need for display
    final todaySessions = _getTodaySessions();
    final upcomingAssignments = _getUpcomingAssignments();
    final attendancePercentage = _calculateAttendancePercentage();
    final pendingCount = _getPendingAssignmentCount();
    final academicWeek = _getAcademicWeek();
    
    // Format today's date for display (e.g., "Thursday, February 6, 2026")
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
              // ========== DATE AND WEEK SECTION ==========
              // Shows today's date and current academic week number
              _buildDateSection(todayFormatted, academicWeek),
              
              const SizedBox(height: 20),
              
              // ========== ATTENDANCE WARNING BANNER ==========
              // Only shows if attendance is below 75% threshold
              if (attendancePercentage < 75)
                _buildAttendanceWarningBanner(attendancePercentage),
              
              if (attendancePercentage < 75) const SizedBox(height: 16),
              
              // ========== STATS SUMMARY ROW ==========
              // Shows attendance % and pending assignments count
              _buildStatsSummaryRow(attendancePercentage, pendingCount),
              
              const SizedBox(height: 24),
              
              // ========== TODAY'S SESSIONS SECTION ==========
              // List of sessions scheduled for today
              _buildSectionHeader('Today\'s Sessions', todaySessions.length),
              const SizedBox(height: 12),
              _buildTodaySessionsList(todaySessions),
              
              const SizedBox(height: 24),
              
              // ========== UPCOMING ASSIGNMENTS SECTION ==========
              // Assignments due within next 7 days
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

  /// Builds the date and academic week display section
  /// Shows formatted date and "Week X" indicator
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
          // Today's date column
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
          // Academic week badge
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

  /// Builds the red warning banner when attendance is below 75%
  /// This is a critical alert to help students stay on track
  Widget _buildAttendanceWarningBanner(double percentage) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.red.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.red, width: 1.5),
      ),
      child: Row(
        children: [
          // Warning icon
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.red,
            size: 28,
          ),
          const SizedBox(width: 12),
          // Warning message
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
                    color: AppColors.red.withOpacity(0.9),
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

  /// Builds the summary row with attendance percentage and pending assignments
  /// Uses card-style containers with ALU branding colors
  Widget _buildStatsSummaryRow(double attendance, int pendingCount) {
    return Row(
      children: [
        // Attendance percentage card
        Expanded(
          child: _buildStatCard(
            icon: Icons.check_circle_outline,
            label: 'Attendance',
            value: '${attendance.toStringAsFixed(1)}%',
            // Use red if below 75%, green otherwise
            valueColor: attendance < 75 ? AppColors.red : AppColors.statusGreen,
          ),
        ),
        const SizedBox(width: 12),
        // Pending assignments card
        Expanded(
          child: _buildStatCard(
            icon: Icons.assignment_outlined,
            label: 'Pending Tasks',
            value: pendingCount.toString(),
            // Use yellow to indicate work to do
            valueColor: pendingCount > 0 ? AppColors.yellow : AppColors.statusGreen,
          ),
        ),
      ],
    );
  }

  /// Helper widget to build individual stat cards
  /// Used for attendance and pending count display
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
          // Icon and label row
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
          // Large value display
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

  /// Builds section header with title and count badge
  /// Reusable for "Today's Sessions" and "Due This Week" sections
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
        // Count badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.yellow.withOpacity(0.2),
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

  /// Builds the list of today's sessions
  /// Shows session title, time, location, and type
  /// Displays empty state message if no sessions today
  Widget _buildTodaySessionsList(List<Session> todaySessions) {
    // Empty state when no sessions scheduled for today
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

    // List of session cards
    return Column(
      children: todaySessions.map((session) => _buildSessionCard(session)).toList(),
    );
  }

  /// Builds individual session card
  /// Displays session details with time, title, location, and type
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
          // Time column on the left
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.yellow.withOpacity(0.15),
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
          // Session details column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Session title
                Text(
                  session.title,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                // Location and type row
                Row(
                  children: [
                    // Location with icon
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
                    // Session type badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getSessionTypeColor(session.sessionType)
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        sessionTypeLabels[session.sessionType] ?? 'Session',
                        style: TextStyle(
                          color: _getSessionTypeColor(session.sessionType),
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
          // Attendance status indicator
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

  /// Returns color based on session type for visual distinction
  Color _getSessionTypeColor(SessionType type) {
    switch (type) {
      case SessionType.classSession:
        return AppColors.yellow;
      case SessionType.masterySession:
        return AppColors.statusGreen;
      case SessionType.studyGroup:
        return const Color(0xFF64B5F6); // Light blue
      case SessionType.pslMeeting:
        return const Color(0xFFBA68C8); // Purple
    }
  }

  /// Builds the list of upcoming assignments (due within 7 days)
  /// Shows assignment title, course, due date, and priority
  Widget _buildUpcomingAssignmentsList(List<Assignment> upcomingAssignments) {
    // Empty state when no assignments due soon
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

    // List of assignment cards
    return Column(
      children: upcomingAssignments
          .map((assignment) => _buildAssignmentCard(assignment))
          .toList(),
    );
  }

  /// Builds individual assignment card
  /// Shows assignment details with due date countdown
  Widget _buildAssignmentCard(Assignment assignment) {
    // Calculate days until due for urgency indication
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
          // Priority indicator bar on the left
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: _getPriorityColor(assignment.priority),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 14),
          // Assignment details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  assignment.title,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                // Course name
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
          // Due date badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              // Use red background if due today or tomorrow
              color: daysUntilDue <= 1
                  ? AppColors.red.withOpacity(0.2)
                  : AppColors.yellow.withOpacity(0.15),
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
                        ? AppColors.red.withOpacity(0.8)
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

  /// Returns human-readable text for days until due
  String _getDueDateText(int daysUntilDue) {
    if (daysUntilDue < 0) return 'Overdue';
    if (daysUntilDue == 0) return 'Today';
    if (daysUntilDue == 1) return 'Tomorrow';
    return 'In $daysUntilDue days';
  }

  /// Returns color based on assignment priority
  /// High = red, Medium = yellow, Low = green
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
