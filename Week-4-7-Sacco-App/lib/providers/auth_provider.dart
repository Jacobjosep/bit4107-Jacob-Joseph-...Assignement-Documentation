import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  List<Map<String, String>> _users = [];

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  List<Map<String, String>> get allUsers => _users;

  AuthProvider() {
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('registered_users');

    if (usersJson != null) {
      final List<dynamic> decoded = json.decode(usersJson);
      _users = decoded.map((u) => Map<String, String>.from(u)).toList();
    } else {
      // Default users for first launch
      _users = [
        {
          'email': 'admin@2nk.co.ke',
          'password': 'admin123',
          'role': 'admin',
          'name': 'Admin User',
          'phone': '254700000000',
          'idNumber': '12345678',
          'memberNumber': '2NK-ADMIN-001',
        },
        {
          'email': 'customer@2nk.co.ke',
          'password': 'customer123',
          'role': 'customer',
          'name': 'John Doe',
          'phone': '254712345678',
          'idNumber': '87654321',
          'memberNumber': '2NK-MEM-001',
        },
      ];
      await _saveUsers();
    }
    notifyListeners();
  }

  Future<void> _saveUsers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('registered_users', json.encode(_users));
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    try {
      final user = _users.firstWhere(
        (u) => u['email'] == email && u['password'] == password,
      );

      _currentUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fullName: user['name']!,
        email: user['email']!,
        phoneNumber: user['phone']!,
        idNumber: user['idNumber']!,
        memberNumber: user['memberNumber']!,
        role: user['role']!,
        accountBalance: user['role'] == 'admin' ? 500000.0 : 15000.0,
        savingsBalance: user['role'] == 'admin' ? 1000000.0 : 25000.0,
        registrationDate: DateTime.now(),
      );

      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String idNumber,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    // Check if email already exists
    final existingUser = _users.where((u) => u['email'] == email);
    if (existingUser.isNotEmpty) {
      _isLoading = false;
      notifyListeners();
      return false;
    }

    final newUser = {
      'email': email,
      'password': password,
      'role': 'customer',
      'name': fullName,
      'phone': phone,
      'idNumber': idNumber,
      'memberNumber': '2NK-MEM-${(_users.length + 1).toString().padLeft(3, '0')}',
    };

    _users.add(newUser);
    await _saveUsers();

    _isLoading = false;
    notifyListeners();
    return true;
  }

  void deposit(double amount) {
    if (_currentUser != null) {
      _currentUser!.accountBalance += amount;
      notifyListeners();
    }
  }

  bool withdraw(double amount) {
    if (_currentUser != null && _currentUser!.accountBalance >= amount) {
      _currentUser!.accountBalance -= amount;
      notifyListeners();
      return true;
    }
    return false;
  }

  bool transfer(String recipientPhone, double amount) {
    if (_currentUser != null && _currentUser!.accountBalance >= amount) {
      _currentUser!.accountBalance -= amount;
      notifyListeners();
      return true;
    }
    return false;
  }

  void saveToSavings(double amount) {
    if (_currentUser != null && _currentUser!.accountBalance >= amount) {
      _currentUser!.accountBalance -= amount;
      _currentUser!.savingsBalance += amount;
      notifyListeners();
    }
  }

  void updateProfilePicture(String? path) {
    if (_currentUser != null) {
      _currentUser!.profilePicturePath = path;
      notifyListeners();
    }
  }

  void updateProfile({
    String? fullName,
    String? phone,
    String? email,
  }) {
    if (_currentUser != null) {
      if (fullName != null) _currentUser!.fullName = fullName;
      if (phone != null) _currentUser!.phoneNumber = phone;
      if (email != null) _currentUser!.email = email;
      notifyListeners();
    }
  }

  void logout() {
    _currentUser = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
