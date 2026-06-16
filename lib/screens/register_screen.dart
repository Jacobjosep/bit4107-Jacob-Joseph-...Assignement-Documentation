import 'package:flutter/material.dart';
import '../database/sacco_database.dart';
import '../models/user_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final SaccoDatabase _db = SaccoDatabase();
  
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _memberNumberController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePin = true;
  bool _obscureConfirmPin = true;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      if (_pinController.text != _confirmPinController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PINs do not match'), backgroundColor: Colors.red),
        );
        return;
      }

      setState(() => _isLoading = true);

      final user = User(
        fullName: _fullNameController.text.trim(),
        memberNumber: _memberNumberController.text.trim(),
        idNumber: _idNumberController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        pin: _pinController.text,
        registrationDate: DateTime.now(),
      );

      try {
        int result = await _db.registerUser(user);
        if (result > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration successful! Awaiting admin approval.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration failed'), backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Member number or ID already exists'), backgroundColor: Colors.red),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Member Registration'),
        backgroundColor: Colors.green,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildTextField(_fullNameController, 'Full Name', Icons.person, false, TextInputType.text),
              const SizedBox(height: 12),
              _buildTextField(_memberNumberController, 'Member Number', Icons.numbers, false, TextInputType.text),
              const SizedBox(height: 12),
              _buildTextField(_idNumberController, 'ID Number', Icons.badge, false, TextInputType.text),
              const SizedBox(height: 12),
              _buildTextField(_phoneController, 'Phone Number', Icons.phone, false, TextInputType.phone),
              const SizedBox(height: 12),
              _buildTextField(_emailController, 'Email', Icons.email, false, TextInputType.emailAddress),
              const SizedBox(height: 12),
              _buildTextField(_pinController, 'PIN', Icons.lock, _obscurePin, TextInputType.number),
              const SizedBox(height: 12),
              _buildTextField(_confirmPinController, 'Confirm PIN', Icons.lock_outline, _obscureConfirmPin, TextInputType.number),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('REGISTER', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    bool obscure,
    TextInputType type,
  ) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: (label == 'PIN' || label == 'Confirm PIN')
            ? IconButton(
                icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    if (label == 'PIN') {
                      _obscurePin = !_obscurePin;
                    } else {
                      _obscureConfirmPin = !_obscureConfirmPin;
                    }
                  });
                },
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      keyboardType: type,
      obscureText: obscure,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter $label';
        if (label == 'PIN' && value.length != 4) return 'PIN must be 4 digits';
        if (label == 'Confirm PIN' && value.length != 4) return 'PIN must be 4 digits';
        return null;
      },
    );
  }
}