import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final baseUrl =
      'http://localhost:8080/v1/projects/demo-dusps/databases/(default)/documents';

  String getToken(String uid) {
    final payload = {"uid": uid, "user_id": uid, "sub": uid};
    final headerStr = base64UrlEncode(
      utf8.encode('{"alg":"none","typ":"JWT"}'),
    ).replaceAll('=', '');
    final payloadStr = base64UrlEncode(
      utf8.encode(jsonEncode(payload)),
    ).replaceAll('=', '');
    return '$headerStr.$payloadStr.';
  }

  // Seeding data with Bearer owner...

  // 1. Create faculty_1 user
  await http.patch(
    Uri.parse('$baseUrl/users/faculty_1'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer owner',
    },
    body: jsonEncode({
      'fields': {
        'role': {'stringValue': 'faculty'},
      },
    }),
  );

  // 2. Create course_abc (faculty_1 IS assigned)
  await http.patch(
    Uri.parse('$baseUrl/courses/course_abc'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer owner',
    },
    body: jsonEncode({
      'fields': {
        'assigned_professors': {
          'arrayValue': {
            'values': [
              {'stringValue': 'faculty_1'},
            ],
          },
        },
      },
    }),
  );

  // 3. Create student enrollment (users/student_1/enrollments/course_abc)
  await http.patch(
    Uri.parse('$baseUrl/users/student_1/enrollments/course_abc'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer owner',
    },
    body: jsonEncode({
      'fields': {
        'status': {'stringValue': 'active'},
      },
    }),
  );

  // 4. Attempt to save grade as faculty_1 (Happy Path)
  // Attempting to save grade as faculty_1 (assigned, student enrolled, valid score)...
  final response = await http.patch(
    Uri.parse('$baseUrl/grades/course_abc_student_1'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${getToken("faculty_1")}',
    },
    body: jsonEncode({
      'fields': {
        'course_id': {'stringValue': 'course_abc'},
        'student_id': {'stringValue': 'student_1'},
        'total_score': {'doubleValue': 95.0}, // Using total_score
      },
    }),
  );

  // Grade Write Status Code: ${response.statusCode}
  // Response Body: ${response.body}
  if (response.statusCode == 200) {
    // ✅ HAPPY PATH TEST PASSED!
  } else {
    // ❌ HAPPY PATH TEST FAILED!
  }
}
