import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/sacco_database.dart';
import '../models/user_model.dart';
import '../models/loan_model.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final SaccoDatabase _db = SaccoDatabase();
  List<User> _pendingMembers = [];
  List<Loan> _pendingLoans = [];
  Map<int, User> _loanApplicants = {};
  bool _isLoading = true;
  int _selectedIndex = 0;
  List<String> _logEntries = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _logEntries = prefs.getStringList('admin_logs') ?? [];
    });
  }

  Future<void> _addToLog(String action) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String timestamp = DateTime.now().toString();
    List<String> logs = prefs.getStringList('admin_logs') ?? [];
    logs.add('[$timestamp] $action');
    
    // Keep only last 200 logs
    if (logs.length > 200) {
      logs = logs.sublist(logs.length - 200);
    }
    await prefs.setStringList('admin_logs', logs);
    _loadLogs();
  }

  Future<void> _clearLogs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('admin_logs');
    _loadLogs();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Log book cleared!'), backgroundColor: Colors.orange),
    );
  }

  void _showLogBook() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.history, color: Colors.green),
                const SizedBox(width: 8),
                const Text('Admin Log Book'),
                const Spacer(),
                Text(
                  'Total: ${_logEntries.length}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: 450,
              child: _logEntries.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history, size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No logs yet', style: TextStyle(color: Colors.grey)),
                          Text('Actions will appear here', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _logEntries.length,
                      itemBuilder: (context, index) {
                        final log = _logEntries[_logEntries.length - 1 - index];
                        Color logColor = Colors.black;
                        if (log.contains('APPROVED')) logColor = Colors.green;
                        if (log.contains('REJECTED')) logColor = Colors.red;
                        if (log.contains('DISBURSED')) logColor = Colors.blue;
                        if (log.contains('LOGIN')) logColor = Colors.purple;
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: logColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  log.contains('APPROVED') ? Icons.check_circle :
                                  log.contains('REJECTED') ? Icons.cancel :
                                  log.contains('DISBURSED') ? Icons.payment :
                                  Icons.info,
                                  size: 16,
                                  color: logColor,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    log,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: logColor,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            actions: [
              TextButton.icon(
                onPressed: _clearLogs,
                icon: const Icon(Icons.delete_sweep, color: Colors.red),
                label: const Text('Clear All', style: TextStyle(color: Colors.red)),
              ),
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                label: const Text('Close'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    _pendingMembers = await _db.getPendingUsers();
    _pendingLoans = await _db.getPendingLoans();
    
    _loanApplicants.clear();
    for (var loan in _pendingLoans) {
      User? user = await _db.getUserById(loan.userId);
      if (user != null) _loanApplicants[loan.userId] = user;
    }
    setState(() => _isLoading = false);
  }

  Future<void> _logout() async {
    await _addToLog('LOGOUT: Admin logged out');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _approveMember(User user) async {
    await _db.approveUser(user.id!);
    await _addToLog('APPROVED MEMBER: ${user.fullName} (${user.memberNumber})');
    _loadData();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${user.fullName} approved!'), backgroundColor: Colors.green),
    );
  }

  Future<void> _rejectMember(User user) async {
    await _db.rejectUser(user.id!);
    await _addToLog('REJECTED MEMBER: ${user.fullName} (${user.memberNumber})');
    _loadData();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${user.fullName} rejected!'), backgroundColor: Colors.red),
    );
  }

  Future<void> _approveLoan(Loan loan, User user) async {
    if (loan.amount > user.savingsBalance) {
      _showWarningDialog(loan, user);
      return;
    }
    
    await _db.updateLoanStatus(loan.id!, LoanStatus.approved, false);
    await _addToLog('APPROVED LOAN: KES ${loan.amount.toStringAsFixed(2)} for ${user.fullName} (Savings: KES ${user.savingsBalance.toStringAsFixed(2)})');
    _loadData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Loan approved!'), backgroundColor: Colors.green),
    );
  }

  Future<void> _disburseLoan(Loan loan, User user) async {
    await _db.updateLoanStatus(loan.id!, LoanStatus.disbursed, true);
    await _db.updateBalance(user.id!, loan.amount, true);
    await _addToLog('DISBURSED LOAN: KES ${loan.amount.toStringAsFixed(2)} to ${user.fullName}');
    _loadData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Loan disbursed!'), backgroundColor: Colors.green),
    );
  }

  void _showWarningDialog(Loan loan, User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Loan Approval Warning', style: TextStyle(color: Colors.red)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Loan Amount: KES ${loan.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Member Savings: KES ${user.savingsBalance.toStringAsFixed(2)}'),
            const Divider(),
            const Text('❌ Loan amount exceeds member savings!', style: TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            const Text('Recommendation: Reduce loan amount or reject application.', style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _db.updateLoanStatus(loan.id!, LoanStatus.rejected, false);
              await _addToLog('REJECTED LOAN: KES ${loan.amount.toStringAsFixed(2)} for ${user.fullName} - Insufficient savings');
              _loadData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Loan rejected!'), backgroundColor: Colors.red),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject Loan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.green,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.history),
                onPressed: _showLogBook,
                tooltip: 'View Log Book',
              ),
              if (_logEntries.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${_logEntries.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _selectedIndex == 0 ? _buildMembersTab() : _buildLoansTab(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Members'),
          BottomNavigationBarItem(icon: Icon(Icons.request_page), label: 'Loans'),
        ],
      ),
    );
  }

  Widget _buildMembersTab() {
    if (_pendingMembers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text('No pending member registrations'),
          ],
        ),
      );
    }
    
    return ListView.builder(
      itemCount: _pendingMembers.length,
      itemBuilder: (context, index) {
        final member = _pendingMembers[index];
        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange,
              child: Text(member.fullName[0].toUpperCase()),
            ),
            title: Text(member.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${member.memberNumber} | ${member.phoneNumber}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                  onPressed: () => _approveMember(member),
                  tooltip: 'Approve',
                ),
                IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  onPressed: () => _rejectMember(member),
                  tooltip: 'Reject',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoansTab() {
    if (_pendingLoans.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text('No pending loan applications'),
          ],
        ),
      );
    }
    
    return ListView.builder(
      itemCount: _pendingLoans.length,
      itemBuilder: (context, index) {
        final loan = _pendingLoans[index];
        final user = _loanApplicants[loan.userId];
        final bool exceedsSavings = user != null && loan.amount > user.savingsBalance;
        
        return Card(
          margin: const EdgeInsets.all(8),
          color: exceedsSavings ? Colors.red.shade50 : null,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (exceedsSavings)
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.red.shade100,
                    child: const Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red),
                        SizedBox(width: 8),
                        Text('WARNING: Loan exceeds member savings!', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                Text('Customer: ${user?.fullName ?? "Unknown"}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Member #: ${user?.memberNumber ?? "Unknown"}'),
                Text('Savings: KES ${user?.savingsBalance.toStringAsFixed(2) ?? "0.00"}'),
                const Divider(),
                Text('Loan Amount: KES ${loan.amount.toStringAsFixed(2)}', 
                     style: TextStyle(fontWeight: FontWeight.bold, color: exceedsSavings ? Colors.red : Colors.green)),
                Text('Purpose: ${loan.purpose}'),
                Text('Duration: ${loan.durationMonths} months'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: exceedsSavings ? null : () => _approveLoan(loan, user!),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                        child: const Text('Approve'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _disburseLoan(loan, user!),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: const Text('Disburse'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await _db.updateLoanStatus(loan.id!, LoanStatus.rejected, false);
                          await _addToLog('REJECTED LOAN: KES ${loan.amount.toStringAsFixed(2)} for ${user?.fullName}');
                          _loadData();
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Reject'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}