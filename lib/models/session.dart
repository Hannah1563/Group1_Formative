import 'dart:convert';

enum SessionType { classSession, masterySession, studyGroup, pslMeeting }

// labels for the dropdown
const Map<SessionType, String> sessionTypeLabels = {
  SessionType.classSession: 'Class',
  SessionType.masterySession: 'Mastery Session',
  SessionType.studyGroup: 'Study Group',
  SessionType.pslMeeting: 'PSL Meeting',
};

enum AttendanceStatus { present, absent }

// Session model - represents a class, study group, etc.
class Session {
  final String id;
  final String title;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String location;
  final SessionType sessionType;
  final AttendanceStatus? attendanceStatus;

  Session({
    required this.id,
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.sessionType,
    this.attendanceStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'location': location,
      'sessionType': sessionType.index,
      'attendanceStatus': attendanceStatus?.index,
    };
  }

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] as String,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      location: json['location'] as String,
      sessionType: SessionType.values[json['sessionType'] as int],
      attendanceStatus: json['attendanceStatus'] != null
          ? AttendanceStatus.values[json['attendanceStatus'] as int]
          : null,
    );
  }

  static String encodeList(List<Session> sessions) {
    return jsonEncode(sessions.map((s) => s.toJson()).toList());
  }

  static List<Session> decodeList(String jsonString) {
    final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList
        .map((json) => Session.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
