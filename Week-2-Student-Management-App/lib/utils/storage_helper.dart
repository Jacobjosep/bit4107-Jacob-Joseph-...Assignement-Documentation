import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/student_model.dart';

class StorageHelper {
  static const String _studentsKey = 'students';
  static const String _currentStudentKey = 'current_student';
  static const String _isLoggedInKey = 'is_logged_in';

  // Get all students
  static Future<List<Student>> getStudents() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? studentsJson = prefs.getStringList(_studentsKey);
    if (studentsJson == null) return [];
    return studentsJson.map((json) => Student.fromJson(jsonDecode(json))).toList();
  }

  // Save all students
  static Future<void> saveStudents(List<Student> students) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> studentsJson = students.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList(_studentsKey, studentsJson);
  }

  // Add new student
  static Future<bool> addStudent(Student student) async {
    final students = await getStudents();
    if (students.any((s) => s.studentId == student.studentId)) {
      return false; // Student ID already exists
    }
    students.add(student);
    await saveStudents(students);
    return true;
  }

  // Update student
  static Future<bool> updateStudent(Student updatedStudent) async {
    final students = await getStudents();
    final index = students.indexWhere((s) => s.id == updatedStudent.id);
    if (index == -1) return false;
    students[index] = updatedStudent;
    await saveStudents(students);
    return true;
  }

  // Delete student
  static Future<bool> deleteStudent(String id) async {
    final students = await getStudents();
    students.removeWhere((s) => s.id == id);
    await saveStudents(students);
    return true;
  }

  // Get student by ID and password
  static Future<Student?> authenticate(String studentId, String password) async {
    final students = await getStudents();
    try {
      return students.firstWhere(
        (s) => s.studentId == studentId && s.password == password,
      );
    } catch (e) {
      return null;
    }
  }

  // Set current logged in student
  static Future<void> setCurrentStudent(Student student) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentStudentKey, jsonEncode(student.toJson()));
    await prefs.setBool(_isLoggedInKey, true);
  }

  // Get current student
  static Future<Student?> getCurrentStudent() async {
    final prefs = await SharedPreferences.getInstance();
    final String? studentJson = prefs.getString(_currentStudentKey);
    if (studentJson == null) return null;
    return Student.fromJson(jsonDecode(studentJson));
  }

  // Check login status
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentStudentKey);
    await prefs.setBool(_isLoggedInKey, false);
  }

  // Get student count
  static Future<int> getStudentCount() async {
    final students = await getStudents();
    return students.length;
  }
}