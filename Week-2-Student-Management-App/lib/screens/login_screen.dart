import 'package:flutter/material.dart';
import '../utils/storage_helper.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String _error = '';

  Future<void> _login() async {
    final studentId = _studentIdController.text.trim();
    final password = _passwordController.text.trim();

    if (studentId.isEmpty || password.isEmpty) {
      setState(() => _error = 'Enter Student ID and Password');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = '';
    });

    final student = await StorageHelper.authenticate(studentId, password);

    if (student != null) {
      await StorageHelper.setCurrentStudent(student);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } else {
      setState(() => _error = 'Invalid Student ID or Password');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.school,
                      size: 60,
                      color: Color(0xFF1565C0),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Student Management',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Login to Your Account',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _studentIdController,
                      decoration: const InputDecoration(
                        labelText: 'Student ID',
                        prefixIcon: Icon(Icons.badge),
                        border: OutlineInputBorder(),
                        hintText: 'Enter your student ID',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
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
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    if (_error.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          _error,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1565C0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
                                'LOGIN',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account? "),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Register Now',
                            style: TextStyle(color: Color(0xFF1565C0)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}