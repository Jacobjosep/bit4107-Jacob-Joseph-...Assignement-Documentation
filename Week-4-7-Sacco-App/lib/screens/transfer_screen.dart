import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/sacco_database.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer Money'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transfer to Another Member',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _recipientController,
              decoration: const InputDecoration(
                labelText: 'Recipient Username',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount (KES)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.money),
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
                onPressed: _transfer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Transfer',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _transfer() async {
    if (_recipientController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter recipient username')),
      );
      return;
    }

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
      
      // Check if recipient exists
      final recipient = await db.getUserByUsername(_recipientController.text);
      if (recipient == null) {
        throw Exception('Recipient not found');
      }

      // Check sender's balance
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

      // Create transfer transaction
      await db.createTransaction(
        userId: userId,
        type: 'transfer',
        amount: amount,
        description: 'Transfer to ${recipient.fullName}',
        reference: 'TRF${DateTime.now().millisecondsSinceEpoch}',
      );

      // Add to recipient's account
      await db.createTransaction(
        userId: recipient.id,
        type: 'deposit',
        amount: amount,
        description: 'Transfer from sender',
        reference: 'TRF${DateTime.now().millisecondsSinceEpoch}',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('KES ${amount.toStringAsFixed(2)} transferred to ${recipient.fullName} successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      _recipientController.clear();
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
    _recipientController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}