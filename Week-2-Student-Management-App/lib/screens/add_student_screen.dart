import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../utils/storage_helper.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _addStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final newStudent = Student(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fullName: _nameController.text.trim(),
      studentId: _idController.text.trim(),
      course: _courseController.text.trim(),
      year: _yearController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    final success = await StorageHelper.addStudent(newStudent);
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student added successfully!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student ID already exists!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Student'),
        backgroundColor: const Color(0xFF1565C0),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.person_add, size: 50, color: Color(0xFF1565C0)),
                  const SizedBox(height: 16),
                  const Text('Student Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Enter name' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _idController,
                    decoration: const InputDecoration(labelText: 'Student ID', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Enter student ID' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _courseController,
                    decoration: const InputDecoration(labelText: 'Course', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Enter course' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _yearController.text.isEmpty ? null : _yearController.text,
                    decoration: const InputDecoration(labelText: 'Year of Study', border: OutlineInputBorder()),
                    items: ['Year 1', 'Year 2', 'Year 3', 'Year 4'].map((year) {
                      return DropdownMenuItem(value: year, child: Text(year));
                    }).toList(),
                    onChanged: (value) => _yearController.text = value!,
                    validator: (v) => v == null ? 'Select year' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Enter phone' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty || !v.contains('@') ? 'Enter valid email' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (v) => v!.length < 4 ? 'Password must be 4+ chars' : null,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _addStudent,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0)),
                      child: _isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('ADD STUDENT', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}