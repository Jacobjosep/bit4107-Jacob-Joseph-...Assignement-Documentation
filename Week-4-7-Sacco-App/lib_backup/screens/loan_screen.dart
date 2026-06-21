import 'package:flutter/material.dart';
import '../database/sacco_database.dart';
import '../models/user_model.dart';
import '../models/loan_model.dart';

class LoanScreen extends StatefulWidget {
  final User user;
  const LoanScreen({super.key, required this.user});

  @override
  State<LoanScreen> createState() => _LoanScreenState();
}

class _LoanScreenState extends State<LoanScreen> {
  final SaccoDatabase _db = SaccoDatabase();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();
  int _durationMonths = 6;
  bool _isLoading = false;

  Future<void> _applyForLoan() async {
    double? amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid loan amount'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    Loan loan = Loan(
      userId: widget.user.id!,
      amount: amount,
      durationMonths: _durationMonths,
      purpose: _purposeController.text.isEmpty ? 'General purpose' : _purposeController.text,
      applicationDate: DateTime.now(),
      remainingBalance: amount,
    );

    int result = await _db.applyForLoan(loan);
    
    if (result > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loan application submitted! Awaiting approval'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loan application failed'), backgroundColor: Colors.red),
      );
    }
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Apply for Loan'), backgroundColor: Colors.purple),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              color: Colors.purple.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('Loan Information', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Interest Rate: 12% per annum'),
                    Text('Maximum Loan: 3x your savings'),
                    Text('Repayment: Monthly installments'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Loan Amount (KES)',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _purposeController,
              decoration: const InputDecoration(
                labelText: 'Loan Purpose',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            const Text('Repayment Period', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildDurationButton(3, '3 Months'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDurationButton(6, '6 Months'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDurationButton(12, '12 Months'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _applyForLoan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('SUBMIT APPLICATION', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationButton(int months, String label) {
    return FilterChip(
      label: Text(label),
      selected: _durationMonths == months,
      onSelected: (selected) {
        setState(() {
          if (selected) _durationMonths = months;
        });
      },
      selectedColor: Colors.purple.shade100,
    );
  }
}