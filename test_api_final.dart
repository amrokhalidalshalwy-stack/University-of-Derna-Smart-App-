import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final baseUrl = 'http://localhost:8080/v1/projects/demo-dusps/databases/(default)/documents';

  String getToken(String uid) {
    final payload = {"uid": uid, "user_id": uid, "sub": uid};
    final headerStr = base64UrlEncode(utf8.encode('{"alg":"none","typ":"JWT"}')).replaceAll('=', '');
    final payloadStr = base64UrlEncode(utf8.encode(jsonEncode(payload))).replaceAll('=', '');
    return '$headerStr.$payloadStr.';
  }

  // --- SEEDING DATA ---
  // Create faculty_1 (Assigned)
  await http.patch(Uri.parse('$baseUrl/users/faculty_1'), headers: {'Authorization': 'Bearer owner'}, body: jsonEncode({'fields': {'role': {'stringValue': 'faculty'}}}));
  // Create course_1 (assigned to faculty_1)
  await http.patch(Uri.parse('$baseUrl/courses/course_1'), headers: {'Authorization': 'Bearer owner'}, body: jsonEncode({'fields': {'assigned_professors': {'arrayValue': {'values': [{'stringValue': 'faculty_1'}]}}}}));
  // Enroll student_1 in course_1
  await http.patch(Uri.parse('$baseUrl/users/student_1/enrollments/course_1'), headers: {'Authorization': 'Bearer owner'}, body: jsonEncode({'fields': {'status': {'stringValue': 'active'}}}));
  
  // Clear any existing grade
  await http.delete(Uri.parse('$baseUrl/grades/course_1_student_1_invalid'), headers: {'Authorization': 'Bearer owner'});
  await http.delete(Uri.parse('$baseUrl/grades/course_1_student_1_valid'), headers: {'Authorization': 'Bearer owner'});

  // --- RUNNING TESTS ---

  Future<void> runTest(String testName, Future<http.Response> Function() action, int expectedStatus) async {
    await action();
    // $testName | Expected: $expectedStatus | Actual: ${res.statusCode} | ${pass ? "✅ PASS" : "❌ FAIL"}
    // Body: ${res.body}
  }

  // 1. grades create — final_exam فاسد (-50)
  await runTest('grades create — final_exam فاسد (-50)', () => http.patch(
    Uri.parse('$baseUrl/grades/course_1_student_1_invalid'),
    headers: {'Authorization': 'Bearer ${getToken("faculty_1")}'},
    body: jsonEncode({
      'fields': {
        'course_id': {'stringValue': 'course_1'}, 
        'student_id': {'stringValue': 'student_1'}, 
        'total_score': {'doubleValue': 95.0},
        'final_exam': {'doubleValue': -50.0}
      }
    })
  ), 403);

  // 2. grades create — happy path (إعادة تأكيد بعد آخر تعديل)
  await runTest('grades create — happy path', () => http.patch(
    Uri.parse('$baseUrl/grades/course_1_student_1_valid'),
    headers: {'Authorization': 'Bearer ${getToken("faculty_1")}'},
    body: jsonEncode({
      'fields': {
        'course_id': {'stringValue': 'course_1'}, 
        'student_id': {'stringValue': 'student_1'}, 
        'total_score': {'doubleValue': 95.0},
        'final_exam': {'doubleValue': 45.0},
        'percentage': {'doubleValue': 95.0}
      }
    })
  ), 200);

}
