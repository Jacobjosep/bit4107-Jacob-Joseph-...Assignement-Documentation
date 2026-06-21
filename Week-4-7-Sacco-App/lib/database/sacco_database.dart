import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';
import '../models/loan_model.dart';

class SaccoDatabase {
  static final SaccoDatabase _instance = SaccoDatabase._internal();
  static Database? _database;

  factory SaccoDatabase() => _instance;

  SaccoDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'sacco_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        full_name TEXT NOT NULL,
        username TEXT UNIQUE NOT NULL,
        phone TEXT NOT NULL,
        password TEXT NOT NULL,
        role TEXT DEFAULT 'member',
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Create transactions table
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        description TEXT NOT NULL,
        reference TEXT NOT NULL,
        date TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Create loans table
    await db.execute('''
      CREATE TABLE loans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        member_name TEXT NOT NULL,
        amount REAL NOT NULL,
        purpose TEXT NOT NULL,
        status TEXT DEFAULT 'pending',
        date TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Insert default admin
    await db.insert('users', {
      'full_name': 'Admin User',
      'username': 'admin',
      'phone': '0700000000',
      'password': 'admin123',
      'role': 'admin',
    });

    // Insert test member
    await db.insert('users', {
      'full_name': 'John Member',
      'username': 'john',
      'phone': '0712345678',
      'password': 'member123',
      'role': 'member',
    });
  }

  // ============ USER METHODS ============

  Future<UserModel?> getUser(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  Future<UserModel?> getUserByUsername(String username) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  Future<List<UserModel>> getAllUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return maps.map((map) => UserModel.fromMap(map)).toList();
  }

  Future<int> createUser({
    required String fullName,
    required String username,
    required String phone,
    required String password,
    String role = 'member',
  }) async {
    final db = await database;
    return await db.insert('users', {
      'full_name': fullName,
      'username': username,
      'phone': phone,
      'password': password,
      'role': role,
    });
  }

  Future<bool> loginUser(String username, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return maps.isNotEmpty;
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============ TRANSACTION METHODS ============

  Future<int> createTransaction({
    required int userId,
    required String type,
    required double amount,
    required String description,
    required String reference,
  }) async {
    final db = await database;
    return await db.insert('transactions', {
      'user_id': userId,
      'type': type,
      'amount': amount,
      'description': description,
      'reference': reference,
    });
  }

  Future<List<TransactionModel>> getUserTransactions(
    int userId, {
    int limit = 999,
  }) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
      limit: limit,
    );
    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'date DESC',
    );
    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  // ============ LOAN METHODS ============

  Future<int> createLoan({
    required int userId,
    required String memberName,
    required double amount,
    required String purpose,
  }) async {
    final db = await database;
    return await db.insert('loans', {
      'user_id': userId,
      'member_name': memberName,
      'amount': amount,
      'purpose': purpose,
      'status': 'pending',
    });
  }

  Future<List<LoanModel>> getUserLoans(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'loans',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    return maps.map((map) => LoanModel.fromMap(map)).toList();
  }

  Future<List<LoanModel>> getAllLoans() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'loans',
      orderBy: 'date DESC',
    );
    return maps.map((map) => LoanModel.fromMap(map)).toList();
  }

  Future<int> updateLoanStatus(int loanId, String status) async {
    final db = await database;
    return await db.update(
      'loans',
      {'status': status},
      where: 'id = ?',
      whereArgs: [loanId],
    );
  }
}