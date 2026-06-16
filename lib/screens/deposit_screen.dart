import 'package:flutter/material.dart';
import '../database/sacco_database.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';

class DepositScreen extends StatefulWidget {
  final User user;
  const DepositScreen({super.key, required this.user});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final SaccoDatabase _db = SaccoDatabase();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;

  Future<void> _deposit() async {
    double? amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    bool success = await _db.updateBalance(widget.user.id!, amount, true);
    
    if (success) {
      await _db.addTransaction(Transaction(
        userId: widget.user.id!,
        amount: amount,
        type: TransactionType.deposit,
        description: _descriptionController.text.isEmpty ? 'Deposit' : _descriptionController.text,
        date: DateTime.now(),
        balanceAfter: widget.user.savingsBalance + amount,
      ));
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deposit successful!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deposit failed'), backgroundColor: Colors.red),
      );
    }
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Make Deposit'), backgroundColor: Colors.green),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text('Current Balance', style: TextStyle(color: Colors.grey)),
                    Text(
                      'KES ${widget.user.savingsBalance.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount (KES)',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                prefixIcon: Icon(Icons.note),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _deposit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('CONFIRM DEPOSIT', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}