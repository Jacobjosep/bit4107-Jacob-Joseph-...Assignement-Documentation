import 'package:flutter/material.dart';
import '../database/sacco_database.dart';
import '../models/user_model.dart';

class TransferScreen extends StatefulWidget {
  final User user;
  const TransferScreen({super.key, required this.user});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final SaccoDatabase _db = SaccoDatabase();
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;
  User? _recipient;

  Future<void> _searchRecipient() async {
    String search = _recipientController.text.trim();
    if (search.isEmpty) return;
    
    List<User> members = await _db.getAllMembers();
    User? found;
    for (var m in members) {
      if (m.memberNumber == search || m.phoneNumber == search) {
        found = m;
        break;
      }
    }
    
    setState(() => _recipient = found);
    if (found == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member not found'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _transfer() async {
    double? amount = double.tryParse(_amountController.text);
    if (_recipient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid recipient'), backgroundColor: Colors.red),
      );
      return;
    }
    
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

    bool success = await _db.transferFunds(
      widget.user.id!, 
      _recipient!.id!, 
      amount, 
      _descriptionController.text.isEmpty ? 'Transfer to ${_recipient!.fullName}' : _descriptionController.text,
    );
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transfer successful!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transfer failed'), backgroundColor: Colors.red),
      );
    }
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transfer Funds'), backgroundColor: Colors.blue),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text('Your Balance', style: TextStyle(color: Colors.grey)),
                    Text(
                      'KES ${widget.user.savingsBalance.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _recipientController,
                    decoration: const InputDecoration(
                      labelText: 'Recipient (Member # or Phone)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _searchRecipient,
                  child: const Text('Search'),
                ),
              ],
            ),
            if (_recipient != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Sending to: ${_recipient!.fullName} (${_recipient!.memberNumber})')),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
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
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _transfer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('CONFIRM TRANSFER', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}