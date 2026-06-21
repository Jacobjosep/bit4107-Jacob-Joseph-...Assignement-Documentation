import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/sacco_database.dart';
import '../models/transaction_model.dart';

class TransactionHistory extends StatefulWidget {
  const TransactionHistory({super.key});

  @override
  State<TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {
  List<TransactionModel> transactions = [];
  bool isLoading = true;
  String filterType = 'all';

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('loggedInUserId');
    
    if (userId != null) {
      final db = SaccoDatabase();
      final data = await db.getUserTransactions(userId);
      setState(() {
        transactions = data;
        isLoading = false;
      });
    }
  }

  List<TransactionModel> get filteredTransactions {
    if (filterType == 'all') return transactions;
    return transactions.where((t) => t.type == filterType).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        actions: [
          DropdownButton<String>(
            value: filterType,
            icon: const Icon(Icons.filter_list),
            dropdownColor: Colors.white,
            onChanged: (value) {
              setState(() {
                filterType = value!;
              });
            },
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All')),
              DropdownMenuItem(value: 'deposit', child: Text('Deposits')),
              DropdownMenuItem(value: 'withdraw', child: Text('Withdrawals')),
              DropdownMenuItem(value: 'transfer', child: Text('Transfers')),
            ],
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredTransactions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No transactions found',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredTransactions.length,
                  itemBuilder: (context, index) {
                    final t = filteredTransactions[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: t.type == 'deposit'
                              ? Colors.green
                              : t.type == 'withdraw'
                              ? Colors.red
                              : Colors.blue,
                          child: Icon(
                            t.type == 'deposit'
                                ? Icons.arrow_downward
                                : t.type == 'withdraw'
                                ? Icons.arrow_upward
                                : Icons.swap_horiz,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          t.description,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Reference: ${t.reference}'),
                            Text(
                              t.date,
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        trailing: Text(
                          '${t.type == 'deposit' ? '+' : '-'}KES ${t.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: t.type == 'deposit' ? Colors.green : Colors.red,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}