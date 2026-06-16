import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/loan_model.dart';

// Import transaction with alias to avoid conflict with sqflite's Transaction
import '../models/transaction_model.dart' as tx;

class SaccoDatabase {
  static final SaccoDatabase _instance = SaccoDatabase._internal();
  static Database? _database;

  SaccoDatabase._internal();

  factory SaccoDatabase() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'sacco_app.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fullName TEXT NOT NULL,
        memberNumber TEXT UNIQUE NOT NULL,
        idNumber TEXT UNIQUE NOT NULL,
        phoneNumber TEXT NOT NULL,
        email TEXT,
        pin TEXT NOT NULL,
        status TEXT DEFAULT 'pending',
        registrationDate TEXT NOT NULL,
        role TEXT DEFAULT 'member',
        savingsBalance REAL DEFAULT 0,
        loanBalance REAL DEFAULT 0,
        isLoggedIn INTEGER DEFAULT 0
      )
    ''');

    // Transactions table
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        amount REAL NOT NULL,
        type INTEGER NOT NULL,
        description TEXT,
        date TEXT NOT NULL,
        balanceAfter REAL NOT NULL,
        referenceNumber TEXT,
        recipientId INTEGER,
        FOREIGN KEY(userId) REFERENCES users(id)
      )
    ''');

    // Loans table
    await db.execute('''
      CREATE TABLE loans(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        amount REAL NOT NULL,
        interestRate REAL DEFAULT 12,
        durationMonths INTEGER NOT NULL,
        purpose TEXT,
        status INTEGER DEFAULT 0,
        applicationDate TEXT NOT NULL,
        approvalDate TEXT,
        disbursementDate TEXT,
        amountPaid REAL DEFAULT 0,
        remainingBalance REAL NOT NULL,
        FOREIGN KEY(userId) REFERENCES users(id)
      )
    ''');

    // Insert default admin user
    await db.insert('users', {
      'fullName': 'System Admin',
      'memberNumber': 'ADMIN001',
      'idNumber': 'ADMIN001',
      'phoneNumber': '0700000000',
      'email': 'admin@2nksacco.com',
      'pin': '1234',
      'status': 'approved',
      'registrationDate': DateTime.now().toIso8601String(),
      'role': 'admin',
      'savingsBalance': 0,
      'loanBalance': 0,
      'isLoggedIn': 0,
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migration logic if needed
  }

  // ============ USER OPERATIONS ============
  
  Future<int> registerUser(User user) async {
    Database db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> login(String memberNumber, String pin) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'memberNumber = ? AND pin = ?',
      whereArgs: [memberNumber, pin],
    );
    
    if (maps.isNotEmpty) {
      User user = User.fromMap(maps.first);
      if (user.status == 'approved') {
        await db.update(
          'users',
          {'isLoggedIn': 1},
          where: 'id = ?',
          whereArgs: [user.id],
        );
        return user;
      }
    }
    return null;
  }

  Future<void> logout(int userId) async {
    Database db = await database;
    await db.update(
      'users',
      {'isLoggedIn': 0},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<List<User>> getPendingUsers() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'status = ? AND role = ?',
      whereArgs: ['pending', 'member'],
    );
    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }

  Future<List<User>> getAllMembers() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'role = ?',
      whereArgs: ['member'],
      orderBy: 'fullName ASC',
    );
    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }

  Future<int> approveUser(int userId) async {
    Database db = await database;
    return await db.update(
      'users',
      {'status': 'approved'},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<int> rejectUser(int userId) async {
    Database db = await database;
    return await db.update(
      'users',
      {'status': 'rejected'},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<User?> getUserById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) return User.fromMap(maps.first);
    return null;
  }

  // ============ TRANSACTION OPERATIONS ============
  
  Future<int> addTransaction(tx.Transaction transaction) async {
    Database db = await database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<tx.Transaction>> getUserTransactions(int userId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
      limit: 20,
    );
    return List.generate(maps.length, (i) => tx.Transaction.fromMap(maps[i]));
  }

  // Update user balance
  Future<bool> updateBalance(int userId, double amount, bool isDeposit) async {
    Database db = await database;
    User? user = await getUserById(userId);
    if (user == null) return false;
    
    double newBalance = isDeposit 
        ? user.savingsBalance + amount 
        : user.savingsBalance - amount;
    
    if (newBalance < 0) return false;
    
    int result = await db.update(
      'users',
      {'savingsBalance': newBalance},
      where: 'id = ?',
      whereArgs: [userId],
    );
    return result > 0;
  }

  // ============ LOAN OPERATIONS ============
  
  Future<int> applyForLoan(Loan loan) async {
    Database db = await database;
    return await db.insert('loans', loan.toMap());
  }

  Future<List<Loan>> getUserLoans(int userId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'loans',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'applicationDate DESC',
    );
    return List.generate(maps.length, (i) => Loan.fromMap(maps[i]));
  }

  Future<List<Loan>> getPendingLoans() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'loans',
      where: 'status = ?',
      whereArgs: [0], // 0 = pending
      orderBy: 'applicationDate ASC',
    );
    return List.generate(maps.length, (i) => Loan.fromMap(maps[i]));
  }

  Future<int> updateLoanStatus(int loanId, LoanStatus status, bool disburse) async {
    Database db = await database;
    Map<String, dynamic> updates = {'status': status.index};
    
    if (status == LoanStatus.approved) {
      updates['approvalDate'] = DateTime.now().toIso8601String();
    }
    if (disburse && status == LoanStatus.disbursed) {
      updates['disbursementDate'] = DateTime.now().toIso8601String();
    }
    
    return await db.update(
      'loans',
      updates,
      where: 'id = ?',
      whereArgs: [loanId],
    );
  }

  // ============ DASHBOARD STATS ============
  
  Future<Map<String, dynamic>> getDashboardStats(int userId) async {
    User? user = await getUserById(userId);
    List<tx.Transaction> recentTransactions = await getUserTransactions(userId);
    
    // Get active loans
    List<Loan> loans = await getUserLoans(userId);
    double totalLoanBalance = 0;
    for (var loan in loans) {
      if (loan.status != LoanStatus.rejected && loan.status != LoanStatus.completed) {
        totalLoanBalance += loan.remainingBalance;
      }
    }
    
    return {
      'user': user,
      'savingsBalance': user?.savingsBalance ?? 0,
      'loanBalance': totalLoanBalance,
      'recentTransactions': recentTransactions,
    };
  }

  // ============ TRANSFER ============
  
  Future<bool> transferFunds(int fromUserId, int toUserId, double amount, String description) async {
    Database db = await database;
    
    User? fromUser = await getUserById(fromUserId);
    User? toUser = await getUserById(toUserId);
    
    if (fromUser == null || toUser == null) return false;
    if (fromUser.savingsBalance < amount) return false;
    
    // Deduct from sender
    await db.update(
      'users',
      {'savingsBalance': fromUser.savingsBalance - amount},
      where: 'id = ?',
      whereArgs: [fromUserId],
    );
    
    // Add to recipient
    await db.update(
      'users',
      {'savingsBalance': toUser.savingsBalance + amount},
      where: 'id = ?',
      whereArgs: [toUserId],
    );
    
    // Record transaction for sender
    await addTransaction(tx.Transaction(
      userId: fromUserId,
      amount: amount,
      type: tx.TransactionType.transfer,
      description: description,
      date: DateTime.now(),
      balanceAfter: fromUser.savingsBalance - amount,
      recipientId: toUserId,
    ));
    
    return true;
  }
}