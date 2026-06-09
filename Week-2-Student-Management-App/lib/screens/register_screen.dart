import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../utils/storage_helper.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

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
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Registration Successful!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, size: 50, color: Colors.green),
              const SizedBox(height: 16),
              Text('Student ID: ${newStudent.studentId}'),
              const SizedBox(height: 8),
              const Text('Please use this ID to login.'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text('Go to Login'),
            ),
          ],
        ),
      );
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
        title: const Text('Student Registration'),
        backgroundColor: const Color(0xFF1565C0),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(
                    Icons.person_add,
                    size: 50,
                    color: Color(0xFF1565C0),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create Student Account',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (v) => v!.isEmpty ? 'Enter full name' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _idController,
                    decoration: const InputDecoration(
                      labelText: 'Student ID',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.badge),
                    ),
                    validator: (v) => v!.isEmpty ? 'Enter student ID' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _courseController,
                    decoration: const InputDecoration(
                      labelText: 'Course',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.book),
                    ),
                    validator: (v) => v!.isEmpty ? 'Enter course' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _yearController.text.isEmpty ? null : _yearController.text,
                    decoration: const InputDecoration(
                      labelText: 'Year of Study',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Year 1', child: Text('Year 1')),
                      DropdownMenuItem(value: 'Year 2', child: Text('Year 2')),
                      DropdownMenuItem(value: 'Year 3', child: Text('Year 3')),
                      DropdownMenuItem(value: 'Year 4', child: Text('Year 4')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _yearController.text = value!;
                      });
                    },
                    validator: (v) => v == null ? 'Select year' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    validator: (v) => v!.isEmpty ? 'Enter phone' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (v) {
                      if (v!.isEmpty) return 'Enter email';
                      if (!v.contains('@')) return 'Enter valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (v) {
                      if (v!.length < 4) return 'Password must be 4+ characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirm,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirm = !_obscureConfirm;
                          });
                        },
                      ),
                    ),
                    validator: (v) => v!.isEmpty ? 'Confirm password' : null,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'REGISTER',
                              style: TextStyle(fontSize: 16),
                            ),
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