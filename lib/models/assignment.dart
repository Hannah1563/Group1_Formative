import 'dart:convert';

enum Priority { high, medium, low }

// Assignment model - used across the app for tracking student work
class Assignment {
  final String id;
  final String title;
  final DateTime dueDate;
  final String courseName;
  final Priority priority;
  final bool isCompleted;

  Assignment({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.courseName,
    required this.priority,
    required this.isCompleted,
  });

  // convert to map so we can save as JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'dueDate': dueDate.toIso8601String(),
      'courseName': courseName,
      'priority': priority.index,
      'isCompleted': isCompleted,
    };
  }

  // create from JSON map when loading from storage
  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'] as String,
      title: json['title'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      courseName: json['courseName'] as String,
      priority: Priority.values[json['priority'] as int],
      isCompleted: json['isCompleted'] as bool,
    );
  }

  static String encodeList(List<Assignment> assignments) {
    return jsonEncode(assignments.map((a) => a.toJson()).toList());
  }

  static List<Assignment> decodeList(String jsonString) {
    final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList
        .map((json) => Assignment.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
