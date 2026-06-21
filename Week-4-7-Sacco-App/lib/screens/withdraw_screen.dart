import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/sacco_database.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Withdraw Money'),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter Withdrawal Amount',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount (KES)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.money_off),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _withdraw,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Withdraw',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _withdraw() async {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final amount = double.parse(_amountController.text);
      if (amount <= 0) {
        throw Exception('Amount must be greater than 0');
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('loggedInUserId');

      if (userId == null) {
        throw Exception('User not logged in');
      }

      final db = SaccoDatabase();
      
      // Check if user has enough balance
      final transactions = await db.getUserTransactions(userId);
      double balance = 0.0;
      for (var t in transactions) {
        if (t.type == 'deposit') {
          balance += t.amount;
        } else if (t.type == 'withdraw' || t.type == 'transfer') {
          balance -= t.amount;
        }
      }

      if (amount > balance) {
        throw Exception('Insufficient balance. Available: KES ${balance.toStringAsFixed(2)}');
      }

      await db.createTransaction(
        userId: userId,
        type: 'withdraw',
        amount: amount,
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : 'Withdrawal',
        reference: 'WTH${DateTime.now().millisecondsSinceEpoch}',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('KES ${amount.toStringAsFixed(2)} withdrawn successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      _amountController.clear();
      _descriptionController.clear();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}