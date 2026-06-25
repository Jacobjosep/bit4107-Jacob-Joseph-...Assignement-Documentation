import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/loan_provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';
import 'loan_application_screen.dart';
import 'mpesa_simulation_screen.dart';
import 'transaction_history_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';
import 'savings_screen.dart';
import 'transfer_screen.dart';
import 'settings_screen.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('2NK SACCO'),
        backgroundColor: const Color(0xFF1B5E20),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No new notifications'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Provider.of<AuthProvider>(context, listen: false).logout();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1B5E20),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.savings), label: 'Save'),
          BottomNavigationBarItem(icon: Icon(Icons.send), label: 'Transfer'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0: return _buildHomeTab();
      case 1: return const SavingsScreen();
      case 2: return const TransferScreen();
      case 3: return const TransactionHistoryScreen();
      case 4: return const ProfileScreen();
      default: return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _currentIndex = 4),
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: const Color(0xFF1B5E20),
                      backgroundImage: user?.profilePicturePath != null
                          ? FileImage(File(user!.profilePicturePath!))
                          : null,
                      child: user?.profilePicturePath == null
                          ? Text(user?.fullName[0].toUpperCase() ?? 'U',
                              style: const TextStyle(fontSize: 28, color: Colors.white))
                          : null,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome, ${user?.fullName ?? "Member"}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
                        Text('Member: ${user?.memberNumber ?? ""}',
                            style: const TextStyle(fontSize: 13, color: Colors.grey)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.grey),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildBalanceCard('Account Balance', 'KES ${user?.accountBalance.toStringAsFixed(2) ?? "0.00"}', Icons.account_balance_wallet, Colors.green)),
              const SizedBox(width: 10),
              Expanded(child: _buildBalanceCard('Savings', 'KES ${user?.savingsBalance.toStringAsFixed(2) ?? "0.00"}', Icons.savings, Colors.blue)),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.0,
            children: [
              _buildQuickAction(Icons.add_circle, 'Deposit', Colors.green, () => _showDepositDialog()),
              _buildQuickAction(Icons.remove_circle, 'Withdraw', Colors.red, () => _showWithdrawDialog()),
              _buildQuickAction(Icons.send, 'Send', Colors.orange, () => setState(() => _currentIndex = 2)),
              _buildQuickAction(Icons.savings, 'Save', Colors.blue, () => setState(() => _currentIndex = 1)),
              _buildQuickAction(Icons.request_page, 'Loan', Colors.purple, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoanApplicationScreen()))),
              _buildQuickAction(Icons.phone_android, 'M-Pesa', Colors.teal, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MpesaSimulationScreen()))),
            ],
          ),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
            TextButton(onPressed: () => setState(() => _currentIndex = 3), child: const Text('See All')),
          ]),
          const SizedBox(height: 10),
          Consumer<TransactionProvider>(
            builder: (context, tp, child) {
              final recent = tp.transactions.take(5).toList();
              if (recent.isEmpty) {
                return const Card(child: Padding(padding: EdgeInsets.all(20), child: Center(child: Text('No transactions yet', style: TextStyle(color: Colors.grey)))));
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recent.length,
                itemBuilder: (context, index) {
                  final t = recent[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(backgroundColor: _getTransactionColor(t.status).withOpacity(0.1), child: Icon(_getTransactionIcon(t.type), color: _getTransactionColor(t.status), size: 20)),
                      title: Text(t.type.replaceAll('_', ' ').toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text(t.reference, style: const TextStyle(fontSize: 12)),
                      trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text('KES ${t.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B5E20), fontSize: 14)),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: _getTransactionColor(t.status).withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Text(t.status.toUpperCase(), style: TextStyle(fontSize: 10, color: _getTransactionColor(t.status), fontWeight: FontWeight.bold))),
                      ]),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(String title, String amount, IconData icon, Color color) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 5),
          Text(amount, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ]),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 55, height: 55, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)), child: Icon(icon, color: color, size: 28)),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 11), textAlign: TextAlign.center),
      ]),
    );
  }

  void _showDepositDialog() {
    final amountCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deposit Funds'),
        content: TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount (KES)', prefixIcon: Icon(Icons.money), border: OutlineInputBorder())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountCtrl.text);
              if (amount != null && amount > 0) {
                Provider.of<AuthProvider>(context, listen: false).deposit(amount);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deposited KES ${amount.toStringAsFixed(2)}'), backgroundColor: Colors.green));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B5E20)),
            child: const Text('Deposit'),
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog() {
    final amountCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Withdraw Funds'),
        content: TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount (KES)', prefixIcon: Icon(Icons.money_off), border: OutlineInputBorder())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountCtrl.text);
              if (amount != null && amount > 0) {
                final success = Provider.of<AuthProvider>(context, listen: false).withdraw(amount);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(success ? 'Withdrawn KES ${amount.toStringAsFixed(2)}' : 'Insufficient balance!'),
                  backgroundColor: success ? Colors.green : Colors.red,
                ));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B5E20)),
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
  }

  IconData _getTransactionIcon(String type) {
    switch (type) {
      case 'deposit': case 'mpesa_receive': return Icons.arrow_downward;
      case 'withdrawal': case 'mpesa_send': return Icons.arrow_upward;
      case 'loan_disbursement': return Icons.monetization_on;
      case 'loan_repayment': return Icons.payment;
      default: return Icons.swap_horiz;
    }
  }

  Color _getTransactionColor(String status) {
    switch (status) {
      case 'completed': return Colors.green;
      case 'pending': return Colors.orange;
      case 'failed': case 'flagged': return Colors.red;
      default: return Colors.grey;
    }
  }
}
