import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/sacco_database.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';
import '../models/loan_model.dart';
import 'deposit_screen.dart';
import 'withdraw_screen.dart';
import 'transfer_screen.dart';
import 'loan_screen.dart';
import 'transaction_history.dart';
import 'profile_screen.dart';
import 'savings_screen.dart';
import 'login_screen.dart';

class MemberDashboard extends StatefulWidget {
  const MemberDashboard({super.key});

  @override
  State<MemberDashboard> createState() => _MemberDashboardState();
}

class _MemberDashboardState extends State<MemberDashboard> {
  int _selectedIndex = 0;
  UserModel? currentUser;
  double balance = 0.0;
  int totalTransactions = 0;
  int pendingLoans = 0;
  bool isLoading = true;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const DepositScreen(),
    const WithdrawScreen(),
    const TransferScreen(),
    const LoanScreen(),
    const TransactionHistory(),
    const ProfileScreen(),
    const SavingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('loggedInUserId');
      
      if (userId != null) {
        final db = SaccoDatabase();
        final user = await db.getUser(userId);
        setState(() {
          currentUser = user;
        });
        _loadUserStats(userId);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error loading user data: $e');
    }
  }

  void _loadUserStats(int userId) async {
    try {
      final db = SaccoDatabase();
      final transactions = await db.getUserTransactions(userId);
      final loans = await db.getUserLoans(userId);
      
      double totalBalance = 0.0;
      for (var t in transactions) {
        if (t.type == 'deposit') {
          totalBalance += t.amount;
        } else if (t.type == 'withdraw' || t.type == 'transfer') {
          totalBalance -= t.amount;
        }
      }

      setState(() {
        balance = totalBalance;
        totalTransactions = transactions.length;
        pendingLoans = loans.where((l) => l.status == 'pending').length;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error loading stats: $e');
    }
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('loggedInUserId');
    await prefs.remove('userRole');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('2NK SACCO Mobile Banking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        height: 65,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle),
            label: 'Deposit',
          ),
          NavigationDestination(
            icon: Icon(Icons.remove_circle),
            label: 'Withdraw',
          ),
          NavigationDestination(
            icon: Icon(Icons.send),
            label: 'Transfer',
          ),
          NavigationDestination(
            icon: Icon(Icons.request_quote),
            label: 'Loan',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          NavigationDestination(
            icon: Icon(Icons.savings),
            label: 'Savings',
          ),
        ],
      ),
    );
  }
}

// Dashboard Screen
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double balance = 0.0;
  int totalTransactions = 0;
  int pendingLoans = 0;
  String userName = 'Member';
  List<TransactionModel> recentTransactions = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('loggedInUserId');
      
      if (userId != null) {
        final db = SaccoDatabase();
        final user = await db.getUser(userId);
        final transactions = await db.getUserTransactions(userId);
        final loans = await db.getUserLoans(userId);
        
        double totalBalance = 0.0;
        for (var t in transactions) {
          if (t.type == 'deposit') {
            totalBalance += t.amount;
          } else if (t.type == 'withdraw' || t.type == 'transfer') {
            totalBalance -= t.amount;
          }
        }

        setState(() {
          userName = user?.fullName ?? 'Member';
          balance = totalBalance;
          totalTransactions = transactions.length;
          pendingLoans = loans.where((l) => l.status == 'pending').length;
          recentTransactions = transactions.take(5).toList();
        });
      }
    } catch (e) {
      print('Error loading dashboard: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = context.findAncestorStateOfType<_MemberDashboardState>();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.green, Colors.greenAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back!',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Account Balance',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'KES ${balance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Stats Row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Transactions',
                  totalTransactions.toString(),
                  Icons.history,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Pending Loans',
                  pendingLoans.toString(),
                  Icons.pending_actions,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Quick Actions
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildQuickAction(
                'Deposit',
                Icons.add_circle_outline,
                Colors.green,
                () {
                  dashboard?.setState(() {
                    dashboard._selectedIndex = 1;
                  });
                },
              ),
              _buildQuickAction(
                'Withdraw',
                Icons.remove_circle_outline,
                Colors.red,
                () {
                  dashboard?.setState(() {
                    dashboard._selectedIndex = 2;
                  });
                },
              ),
              _buildQuickAction(
                'Transfer',
                Icons.send_outlined,
                Colors.blue,
                () {
                  dashboard?.setState(() {
                    dashboard._selectedIndex = 3;
                  });
                },
              ),
              _buildQuickAction(
                'Loan',
                Icons.request_quote,
                Colors.orange,
                () {
                  dashboard?.setState(() {
                    dashboard._selectedIndex = 4;
                  });
                },
              ),
              _buildQuickAction(
                'History',
                Icons.history,
                Colors.purple,
                () {
                  dashboard?.setState(() {
                    dashboard._selectedIndex = 5;
                  });
                },
              ),
              _buildQuickAction(
                'Savings',
                Icons.savings_outlined,
                Colors.teal,
                () {
                  dashboard?.setState(() {
                    dashboard._selectedIndex = 7;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Recent Transactions
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          recentTransactions.isEmpty
              ? Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: Text(
                        'No transactions yet',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = recentTransactions[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: transaction.type == 'deposit'
                            ? Colors.green
                            : transaction.type == 'withdraw'
                            ? Colors.red
                            : Colors.blue,
                        child: Icon(
                          transaction.type == 'deposit'
                              ? Icons.arrow_downward
                              : transaction.type == 'withdraw'
                              ? Icons.arrow_upward
                              : Icons.swap_horiz,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      title: Text(transaction.description),
                      subtitle: Text(
                        transaction.date,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      trailing: Text(
                        '${transaction.type == 'deposit' ? '+' : '-'}KES ${transaction.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: transaction.type == 'deposit' ? Colors.green : Colors.red,
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}