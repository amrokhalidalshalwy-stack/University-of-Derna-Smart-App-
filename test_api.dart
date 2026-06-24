import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final baseUrl = 'http://localhost:8080/v1/projects/demo-dusps/databases/(default)/documents';

  String getToken(String uid) {
    final payload = {"user_id": uid};
    final headerStr = base64UrlEncode(utf8.encode('{"alg":"none","typ":"JWT"}')).replaceAll('=', '');
    final payloadStr = base64UrlEncode(utf8.encode(jsonEncode(payload))).replaceAll('=', '');
    return '$headerStr.$payloadStr.';
  }

  // Seeding data with Bearer owner...

  // Create faculty_1 user
  await http.patch(
    Uri.parse('$baseUrl/users/faculty_1'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer owner',
    },
    body: jsonEncode({
      'fields': {
        'role': {'stringValue': 'faculty'}
      }
    }),
  );

  // Create course (faculty_1 is NOT assigned)
  await http.patch(
    Uri.parse('$baseUrl/courses/course_xyz'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer owner',
    },
    body: jsonEncode({
      'fields': {
        'assigned_professors': {
          'arrayValue': {
            'values': [
              {'stringValue': 'faculty_2'} // faculty_1 is NOT assigned
            ]
          }
        }
      }
    }),
  );

  // Attempting to save grade as faculty_1...
  await http.patch(
    Uri.parse('$baseUrl/grades/test_grade_1'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${getToken("faculty_1")}',
    },
    body: jsonEncode({
      'fields': {
        'course_id': {'stringValue': 'course_xyz'},
        'student_id': {'stringValue': 'student_1'},
        'grade': {'doubleValue': 95.0}
      }
    }),
  );

  // Grade Write Status Code: ${response.statusCode}
  // Response Body: ${response.body}
}
