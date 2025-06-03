import 'dart:convert';

import 'hole.dart';

class Course {
  final String name;
  final List<Hole> holes;

  Course({required this.name, required this.holes});

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      name: json['name'] as String,
      holes: (json['holes'] as List)
          .map((holeJson) => Hole.fromJson(holeJson))
          .toList(),
    );
  }

  static List<Course> decodeJson(String jsonStr) {
    final List<dynamic> jsonList = json.decode(jsonStr);
    return jsonList.map((json) => Course.fromJson(json)).toList();
  }
}
