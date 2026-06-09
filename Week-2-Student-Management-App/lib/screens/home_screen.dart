import 'package:flutter/material.dart';
import '../utils/storage_helper.dart';
import '../models/student_model.dart';
import 'add_student_screen.dart';
import 'student_details_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Student? _currentStudent;
  List<Student> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    _currentStudent = await StorageHelper.getCurrentStudent();
    _students = await StorageHelper.getStudents();
    setState(() => _isLoading = false);
  }

  Future<void> _logout() async {
    await StorageHelper.logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  Future<void> _deleteStudent(String id) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: const Text('Are you sure you want to delete this student?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await StorageHelper.deleteStudent(id);
              _loadData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Student deleted successfully')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${_currentStudent?.fullName.split(' ').first ?? 'Student'}'),
        backgroundColor: const Color(0xFF1565C0),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Stats Card
                Card(
                  margin: const EdgeInsets.all(16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Icon(Icons.people, size: 40, color: Color(0xFF1565C0)),
                            const SizedBox(height: 8),
                            Text('${_students.length}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            const Text('Total Students', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                        Container(width: 1, height: 50, color: Colors.grey.shade300),
                        Column(
                          children: [
                            const Icon(Icons.school, size: 40, color: Color(0xFF1565C0)),
                            const SizedBox(height: 8),
                            Text('${_students.where((s) => s.year == 'Year 1').length}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            const Text('Year 1', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Student List Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Student List', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('${_students.length} records', style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Student List
                Expanded(
                  child: _students.isEmpty
                      ? const Center(child: Text('No students registered yet'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _students.length,
                          itemBuilder: (context, index) {
                            final student = _students[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: const Color(0xFF1565C0),
                                  child: Text(student.fullName[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                                ),
                                title: Text(student.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('${student.studentId} • ${student.course} • ${student.year}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.visibility, color: Colors.blue),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => StudentDetailsScreen(student: student)),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteStudent(student.id),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddStudentScreen()),
          ).then((_) => _loadData());
        },
        backgroundColor: const Color(0xFF1565C0),
        child: const Icon(Icons.add),
      ),
    );
  }
}