import 'package:flutter/material.dart';
import '../database/sacco_database.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';

class WithdrawScreen extends StatefulWidget {
  final User user;
  const WithdrawScreen({super.key, required this.user});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final SaccoDatabase _db = SaccoDatabase();
  final TextEditingController _amountController = TextEditingController();
  bool _isLoading = false;

  Future<void> _withdraw() async {
    double? amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount'), backgroundColor: Colors.red),
      );
      return;
    }
    
    if (amount > widget.user.savingsBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient balance'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    bool success = await _db.updateBalance(widget.user.id!, amount, false);
    
    if (success) {
      await _db.addTransaction(Transaction(
        userId: widget.user.id!,
        amount: amount,
        type: TransactionType.withdraw,
        description: 'Withdrawal',
        date: DateTime.now(),
        balanceAfter: widget.user.savingsBalance - amount,
      ));
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Withdrawal successful!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Withdrawal failed'), backgroundColor: Colors.red),
      );
    }
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Withdraw Funds'), backgroundColor: Colors.orange),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text('Available Balance', style: TextStyle(color: Colors.grey)),
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
                labelText: 'Amount to Withdraw (KES)',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _withdraw,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('CONFIRM WITHDRAWAL', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}