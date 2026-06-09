import 'package:flutter/material.dart';
import '../models/student_model.dart';

class StudentDetailsScreen extends StatelessWidget {
  final Student student;

  const StudentDetailsScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(student.fullName),
        backgroundColor: const Color(0xFF1565C0),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFF1565C0),
                  child: Text(
                    student.fullName[0].toUpperCase(),
                    style: const TextStyle(fontSize: 40, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                Text(student.fullName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(student.studentId, style: const TextStyle(color: Color(0xFF1565C0))),
                ),
                const SizedBox(height: 24),
                const Divider(),
                _buildInfoRow(Icons.book, 'Course', student.course),
                _buildInfoRow(Icons.calendar_today, 'Year', student.year),
                _buildInfoRow(Icons.phone, 'Phone', student.phone),
                _buildInfoRow(Icons.email, 'Email', student.email),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 24, color: const Color(0xFF1565C0)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(value, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }
}