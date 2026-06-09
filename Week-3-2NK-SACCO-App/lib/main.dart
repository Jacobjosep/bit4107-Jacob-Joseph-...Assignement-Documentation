import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2NK SACCO',
      theme: ThemeData(
        primaryColor: Colors.green,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _memberController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  String _error = '';

  void _login() {
    if (_memberController.text == '12345' && _pinController.text == '1234') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      setState(() {
        _error = 'Invalid Member Number or PIN. Try: 12345 / 1234';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green, Colors.greenAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.account_balance,
                      size: 64,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '2NK SACCO',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const Text(
                      'Mobile Banking',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _memberController,
                      decoration: const InputDecoration(
                        labelText: 'Member Number',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _pinController,
                      decoration: const InputDecoration(
                        labelText: 'PIN',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'LOGIN',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    if (_error.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          _error,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
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

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('2NK SACCO'),
        backgroundColor: Colors.green,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: const [
                    Text(
                      'Total Savings',
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'KES 200,000',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text('FOSA', style: TextStyle(color: Colors.grey)),
                            Text('KES 150,000', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          children: [
                            Text('BOSA', style: TextStyle(color: Colors.grey)),
                            Text('KES 50,000', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(Icons.send, 'Deposit', Colors.green, context),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(Icons.receipt, 'Withdraw', Colors.orange, context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(Icons.swap_horiz, 'Transfer', Colors.blue, context),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(Icons.credit_score, 'Apply Loan', Colors.purple, context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Recent Transactions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildTransactionItem('Salary Deposit', 'Jan 15, 2024', '+ KES 50,000', true),
            _buildTransactionItem('Loan Repayment', 'Jan 10, 2024', '- KES 8,500', false),
            _buildTransactionItem('M-Pesa Deposit', 'Jan 5, 2024', '+ KES 10,000', true),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(IconData icon, String label, Color color, BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$label feature coming soon')),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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

  Widget _buildTransactionItem(String title, String date, String amount, bool isPositive) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isPositive ? Colors.green.shade100 : Colors.red.shade100,
          child: Icon(
            isPositive ? Icons.arrow_downward : Icons.arrow_upward,
            color: isPositive ? Colors.green : Colors.red,
          ),
        ),
        title: Text(title),
        subtitle: Text(date),
        trailing: Text(
          amount,
          style: TextStyle(
            color: isPositive ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}