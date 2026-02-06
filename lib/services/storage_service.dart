import 'package:shared_preferences/shared_preferences.dart';
import '../models/assignment.dart';
import '../models/session.dart';

// handles saving/loading data with shared_preferences
class StorageService {
  static const String _assignmentsKey = 'assignments';
  static const String _sessionsKey = 'sessions';

  static Future<void> saveAssignments(List<Assignment> assignments) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = Assignment.encodeList(assignments);
    await prefs.setString(_assignmentsKey, jsonString);
  }

  static Future<List<Assignment>> loadAssignments() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_assignmentsKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    return Assignment.decodeList(jsonString);
  }

  static Future<void> saveSessions(List<Session> sessions) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = Session.encodeList(sessions);
    await prefs.setString(_sessionsKey, jsonString);
  }

  static Future<List<Session>> loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_sessionsKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    return Session.decodeList(jsonString);
  }
}
