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
  // Create faculty_2 (Not Assigned)
  await http.patch(Uri.parse('$baseUrl/users/faculty_2'), headers: {'Authorization': 'Bearer owner'}, body: jsonEncode({'fields': {'role': {'stringValue': 'faculty'}}}));
  // Create admin
  await http.patch(Uri.parse('$baseUrl/users/admin_1'), headers: {'Authorization': 'Bearer owner'}, body: jsonEncode({'fields': {'role': {'stringValue': 'admin'}}}));
  
  // Create course_1 (assigned to faculty_1)
  await http.patch(Uri.parse('$baseUrl/courses/course_1'), headers: {'Authorization': 'Bearer owner'}, body: jsonEncode({'fields': {'assigned_professors': {'arrayValue': {'values': [{'stringValue': 'faculty_1'}]}}}}));
  // Create course_2 (assigned to faculty_2)
  await http.patch(Uri.parse('$baseUrl/courses/course_2'), headers: {'Authorization': 'Bearer owner'}, body: jsonEncode({'fields': {'assigned_professors': {'arrayValue': {'values': [{'stringValue': 'faculty_2'}]}}}}));
  
  // Enroll student_1 in course_1
  await http.patch(Uri.parse('$baseUrl/users/student_1/enrollments/course_1'), headers: {'Authorization': 'Bearer owner'}, body: jsonEncode({'fields': {'status': {'stringValue': 'active'}}}));
  
  // Clear any existing grade/attendance
  await http.delete(Uri.parse('$baseUrl/grades/course_1_student_1'), headers: {'Authorization': 'Bearer owner'});
  await http.delete(Uri.parse('$baseUrl/attendance/course_1_student_1'), headers: {'Authorization': 'Bearer owner'});
  await http.delete(Uri.parse('$baseUrl/attendance/course_1_student_2'), headers: {'Authorization': 'Bearer owner'});

  // --- RUNNING MATRIX TESTS ---

  Future<void> runTest(String testName, Future<http.Response> Function() action, int expectedStatus) async {
    final res = await action();
    final pass = res.statusCode == expectedStatus;
    // $testName | Expected: $expectedStatus | Actual: ${res.statusCode} | ${pass ? "✅ PASS" : "❌ FAIL"}
    if (!pass) {
      // Body: ${res.body}
    }
  }

  // 1. grades create — أستاذ غير مُعيَّن (faculty_2 on course_1)
  await runTest('grades create — أستاذ غير مُعيَّن', () => http.patch(
    Uri.parse('$baseUrl/grades/course_1_student_1_reject'),
    headers: {'Authorization': 'Bearer ${getToken("faculty_2")}'},
    body: jsonEncode({'fields': {'course_id': {'stringValue': 'course_1'}, 'student_id': {'stringValue': 'student_1'}, 'total_score': {'doubleValue': 95.0}}})
  ), 403);

  // 2. grades create — طالب غير مسجَّل (student_2 on course_1)
  await runTest('grades create — طالب غير مسجَّل', () => http.patch(
    Uri.parse('$baseUrl/grades/course_1_student_2_reject'),
    headers: {'Authorization': 'Bearer ${getToken("faculty_1")}'},
    body: jsonEncode({'fields': {'course_id': {'stringValue': 'course_1'}, 'student_id': {'stringValue': 'student_2'}, 'total_score': {'doubleValue': 95.0}}})
  ), 403);

  // 3. attendance create — happy path
  await runTest('attendance create — happy path', () => http.patch(
    Uri.parse('$baseUrl/attendance/course_1_student_1'),
    headers: {'Authorization': 'Bearer ${getToken("faculty_1")}'},
    body: jsonEncode({'fields': {'course_id': {'stringValue': 'course_1'}, 'student_id': {'stringValue': 'student_1'}, 'is_present': {'booleanValue': true}}})
  ), 200);

  // 4. attendance create — أستاذ غير مُعيَّن
  await runTest('attendance create — أستاذ غير مُعيَّن', () => http.patch(
    Uri.parse('$baseUrl/attendance/course_1_student_1_rej'),
    headers: {'Authorization': 'Bearer ${getToken("faculty_2")}'},
    body: jsonEncode({'fields': {'course_id': {'stringValue': 'course_1'}, 'student_id': {'stringValue': 'student_1'}, 'is_present': {'booleanValue': true}}})
  ), 403);

  // 5. attendance create — طالب غير مسجَّل
  await runTest('attendance create — طالب غير مسجَّل', () => http.patch(
    Uri.parse('$baseUrl/attendance/course_1_student_2_rej'),
    headers: {'Authorization': 'Bearer ${getToken("faculty_1")}'},
    body: jsonEncode({'fields': {'course_id': {'stringValue': 'course_1'}, 'student_id': {'stringValue': 'student_2'}, 'is_present': {'booleanValue': true}}})
  ), 403);

  // Setup grade for update/delete
  await http.patch(
    Uri.parse('$baseUrl/grades/course_1_student_1'),
    headers: {'Authorization': 'Bearer ${getToken("faculty_1")}'},
    body: jsonEncode({'fields': {'course_id': {'stringValue': 'course_1'}, 'student_id': {'stringValue': 'student_1'}, 'total_score': {'doubleValue': 80.0}}})
  );

  // 6. grades update — تعديل قيمة فقط
  await runTest('grades update — تعديل قيمة فقط', () => http.patch(
    Uri.parse('$baseUrl/grades/course_1_student_1?updateMask.fieldPaths=total_score'),
    headers: {'Authorization': 'Bearer ${getToken("faculty_1")}'},
    body: jsonEncode({'fields': {'total_score': {'doubleValue': 99.0}, 'course_id': {'stringValue': 'course_1'}, 'student_id': {'stringValue': 'student_1'}}})
  ), 200);

  // 7. grades update — تغيير course_id (faculty_1 is assigned to course_1, but tries to change course_id to course_3)
  // Wait, the rule says request.resource.data.course_id == resource.data.course_id.
  await runTest('grades update — تغيير course_id', () => http.patch(
    Uri.parse('$baseUrl/grades/course_1_student_1?updateMask.fieldPaths=course_id'),
    headers: {'Authorization': 'Bearer ${getToken("faculty_1")}'},
    body: jsonEncode({'fields': {'course_id': {'stringValue': 'course_2'}, 'student_id': {'stringValue': 'student_1'}, 'total_score': {'doubleValue': 99.0}}})
  ), 403);

  // 8. grades delete — أستاذ
  await runTest('grades delete — أستاذ', () => http.delete(
    Uri.parse('$baseUrl/grades/course_1_student_1'),
    headers: {'Authorization': 'Bearer ${getToken("faculty_1")}'}
  ), 403);

  // 9. grades delete — admin
  await runTest('grades delete — admin', () => http.delete(
    Uri.parse('$baseUrl/grades/course_1_student_1'),
    headers: {'Authorization': 'Bearer ${getToken("admin_1")}'}
  ), 200);
}
