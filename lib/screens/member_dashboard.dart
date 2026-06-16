import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/sacco_database.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart' as tx;
import 'deposit_screen.dart';
import 'withdraw_screen.dart';
import 'transfer_screen.dart';
import 'loan_screen.dart';

class MemberDashboard extends StatefulWidget {
  const MemberDashboard({super.key});

  @override
  State<MemberDashboard> createState() => _MemberDashboardState();
}

class _MemberDashboardState extends State<MemberDashboard> {
  final SaccoDatabase _db = SaccoDatabase();
  User? _currentUser;
  List<tx.Transaction> _recentTransactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('loggedInUserId');
    
    if (userId != null) {
      var stats = await _db.getDashboardStats(userId);
      setState(() {
        _currentUser = stats['user'];
        _recentTransactions = stats['recentTransactions'];
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    if (_currentUser != null) {
      await _db.logout(_currentUser!.id!);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  void _viewTransactionLog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transaction History'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: _recentTransactions.isEmpty
              ? const Center(child: Text('No transactions yet'))
              : ListView.builder(
                  itemCount: _recentTransactions.length,
                  itemBuilder: (context, index) {
                    final tx = _recentTransactions[index];
                    return ListTile(
                      title: Text(tx.description),
                      subtitle: Text('${tx.date.day}/${tx.date.month}/${tx.date.year}'),
                      trailing: Text(
                        tx.getFormattedAmount(),
                        style: TextStyle(color: tx.getColor(), fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('2NK SACCO'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _viewTransactionLog,
            tooltip: 'Transaction History',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.green,
                        child: Text(
                          _currentUser?.fullName[0].toUpperCase() ?? 'U',
                          style: const TextStyle(fontSize: 24, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome, ${_currentUser?.fullName ?? 'Member'}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text('Member #: ${_currentUser?.memberNumber}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Balance Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text('Total Savings', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 8),
                      Text(
                        'KES ${_currentUser?.savingsBalance.toStringAsFixed(2) ?? '0.00'}',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Quick Actions
              const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildActionCard(Icons.send, 'Deposit', Colors.green, () => _navigateTo(DepositScreen(user: _currentUser!)))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildActionCard(Icons.receipt, 'Withdraw', Colors.orange, () => _navigateTo(WithdrawScreen(user: _currentUser!)))),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildActionCard(Icons.swap_horiz, 'Transfer', Colors.blue, () => _navigateTo(TransferScreen(user: _currentUser!)))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildActionCard(Icons.credit_score, 'Apply Loan', Colors.purple, () => _navigateTo(LoanScreen(user: _currentUser!)))),
                ],
              ),
              const SizedBox(height: 24),
              
              // Recent Transactions
              const Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _recentTransactions.isEmpty
                  ? const Card(child: Padding(padding: EdgeInsets.all(20), child: Center(child: Text('No transactions yet'))))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _recentTransactions.length > 5 ? 5 : _recentTransactions.length,
                      itemBuilder: (context, index) {
                        final transaction = _recentTransactions[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: transaction.getColor().withOpacity(0.1),
                              child: Icon(transaction.getIcon(), color: transaction.getColor()),
                            ),
                            title: Text(transaction.description),
                            subtitle: Text('${transaction.date.day}/${transaction.date.month}/${transaction.date.year}'),
                            trailing: Text(
                              transaction.getFormattedAmount(),
                              style: TextStyle(color: transaction.getColor(), fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen))
        .then((_) => _loadUserData());
  }

  Widget _buildActionCard(IconData icon, String label, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}