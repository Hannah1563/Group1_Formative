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
  // Stored as minutes since midnight (0-1439) so we can sort/validate reliably.
  final int startMinutes;
  final int endMinutes;
  // Human-readable labels (what the user sees).
  final String startTime;
  final String endTime;
  final String location;
  final SessionType sessionType;
  final AttendanceStatus? attendanceStatus;

  Session({
    required this.id,
    required this.title,
    required this.date,
    required this.startMinutes,
    required this.endMinutes,
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
      'startMinutes': startMinutes,
      'endMinutes': endMinutes,
      'startTime': startTime,
      'endTime': endTime,
      'location': location,
      'sessionType': sessionType.index,
      'attendanceStatus': attendanceStatus?.index,
    };
  }

  static int _parseMinutes(dynamic rawMinutes, dynamic rawLabel) {
    if (rawMinutes is int) return rawMinutes;
    if (rawMinutes is double) return rawMinutes.round();
    if (rawMinutes is String) {
      final parsed = int.tryParse(rawMinutes);
      if (parsed != null) return parsed;
    }

    final label = (rawLabel ?? '').toString().trim();
    if (label.isEmpty) return 0;

    // Supports "HH:mm" and "h:mm AM/PM" (common outputs of TimeOfDay.format()).
    final re = RegExp(r'^(\d{1,2}):(\d{2})(?:\s*([AaPp][Mm]))?$');
    final m = re.firstMatch(label);
    if (m == null) return 0;

    var h = int.parse(m.group(1)!);
    final min = int.parse(m.group(2)!);
    final ampm = m.group(3);
    if (ampm != null) {
      final upper = ampm.toUpperCase();
      if (upper == 'AM') {
        if (h == 12) h = 0;
      } else {
        if (h != 12) h += 12;
      }
    }

    return (h.clamp(0, 23) * 60) + min.clamp(0, 59);
  }

  factory Session.fromJson(Map<String, dynamic> json) {
    final startLabel = json['startTime'] as String? ?? '';
    final endLabel = json['endTime'] as String? ?? '';
    return Session(
      id: json['id'] as String,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      startMinutes: _parseMinutes(json['startMinutes'], startLabel),
      endMinutes: _parseMinutes(json['endMinutes'], endLabel),
      startTime: startLabel,
      endTime: endLabel,
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
