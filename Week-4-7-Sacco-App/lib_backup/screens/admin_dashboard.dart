import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../database/sacco_database.dart';
import '../models/user_model.dart';
import 'login_screen.dart';
import 'member_management.dart';
import 'loan_management.dart';
import 'reports_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  int totalMembers = 0;
  int pendingLoans = 0;
  double totalDeposits = 0.0;

  final List<Widget> _screens = [
    const AdminHomeScreen(),
    const MemberManagement(),
    const LoanManagement(),
    const ReportsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() async {
    final db = SaccoDatabase();
    final members = await db.getAllUsers();
    final loans = await db.getAllLoans();
    final transactions = await db.getAllTransactions();

    double deposits = 0.0;
    for (var t in transactions) {
      if (t.type == 'deposit') {
        deposits += t.amount;
      }
    }

    setState(() {
      totalMembers = members.length;
      pendingLoans = loans.where((l) => l.status == 'pending').length;
      totalDeposits = deposits;
    });
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
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _screens[_selectedIndex],
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
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.people),
            label: 'Members',
          ),
          NavigationDestination(
            icon: Icon(Icons.request_quote),
            label: 'Loans',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics),
            label: 'Reports',
          ),
        ],
      ),
    );
  }
}

// Admin Home Screen with Stats
class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboard = context.findAncestorStateOfType<_AdminDashboardState>();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome Admin!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Here\'s what\'s happening with your SACCO',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildStatCard(
                'Total Members',
                dashboard?.totalMembers.toString() ?? '0',
                Icons.people,
                Colors.blue,
                () {},
              ),
              _buildStatCard(
                'Pending Loans',
                dashboard?.pendingLoans.toString() ?? '0',
                Icons.pending_actions,
                Colors.orange,
                () {
                  // Navigate to loans tab
                  dashboard?.setState(() {
                    dashboard._selectedIndex = 2;
                  });
                },
              ),
              _buildStatCard(
                'Total Deposits',
                'KES ${dashboard?.totalDeposits.toStringAsFixed(2) ?? '0.00'}',
                Icons.trending_up,
                Colors.green,
                () {},
              ),
              _buildStatCard(
                'Active Users',
                ((dashboard?.totalMembers ?? 0) * 0.7).toInt().toString(),
                Icons.person,
                Colors.purple,
                () {},
              ),
            ],
          ),
          const SizedBox(height: 20),
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
                'Members',
                Icons.people,
                Colors.blue,
                () {
                  dashboard?.setState(() {
                    dashboard._selectedIndex = 1;
                  });
                },
              ),
              _buildQuickAction(
                'Loans',
                Icons.request_quote,
                Colors.orange,
                () {
                  dashboard?.setState(() {
                    dashboard._selectedIndex = 2;
                  });
                },
              ),
              _buildQuickAction(
                'Reports',
                Icons.analytics,
                Colors.green,
                () {
                  dashboard?.setState(() {
                    dashboard._selectedIndex = 3;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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