import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import 'package:intl/intl.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        backgroundColor: const Color(0xFF1B5E20),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  'All',
                  'Deposits',
                  'Withdrawals',
                  'Loans',
                  'M-Pesa'
                ].map((filter) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: _filter == filter,
                      onSelected: (selected) {
                        setState(() {
                          _filter = filter;
                        });
                      },
                      selectedColor:
                          const Color(0xFF1B5E20).withOpacity(0.2),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: Consumer<TransactionProvider>(
              builder: (context, transactionProvider, child) {
                var transactions = transactionProvider.transactions;

                // Apply filter
                if (_filter != 'All') {
                  transactions = transactions.where((t) {
                    switch (_filter) {
                      case 'Deposits':
                        return t.type == 'deposit';
                      case 'Withdrawals':
                        return t.type == 'withdrawal';
                      case 'Loans':
                        return t.type == 'loan_disbursement' ||
                            t.type == 'loan_repayment';
                      case 'M-Pesa':
                        return t.type == 'mpesa_send' ||
                            t.type == 'mpesa_receive';
                      default:
                        return true;
                    }
                  }).toList();
                }

                if (transactions.isEmpty) {
                  return const Center(
                    child: Text('No transactions found'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              _getTransactionColor(transaction.type),
                          child: Icon(
                            _getTransactionIcon(transaction.type),
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          transaction.type
                              .replaceAll('_', ' ')
                              .toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          DateFormat('dd MMM yyyy, HH:mm')
                              .format(transaction.transactionDate),
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'KES ${transaction.amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _getAmountColor(transaction.type),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(transaction.status)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                transaction.status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  color:
                                      _getStatusColor(transaction.status),
                                ),
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          _showTransactionDetails(context, transaction);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTransactionIcon(String type) {
    switch (type) {
      case 'deposit':
      case 'mpesa_receive':
        return Icons.arrow_downward;
      case 'withdrawal':
      case 'mpesa_send':
        return Icons.arrow_upward;
      case 'loan_disbursement':
        return Icons.monetization_on;
      case 'loan_repayment':
        return Icons.payment;
      default:
        return Icons.swap_horiz;
    }
  }

  Color _getTransactionColor(String type) {
    switch (type) {
      case 'deposit':
      case 'mpesa_receive':
      case 'loan_disbursement':
        return Colors.green;
      case 'withdrawal':
      case 'mpesa_send':
        return Colors.red;
      case 'loan_repayment':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  Color _getAmountColor(String type) {
    switch (type) {
      case 'deposit':
      case 'mpesa_receive':
      case 'loan_disbursement':
        return Colors.green;
      case 'withdrawal':
      case 'mpesa_send':
      case 'loan_repayment':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
      case 'flagged':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showTransactionDetails(BuildContext context, transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transaction Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Transaction ID', transaction.id),
            _buildDetailRow('Type',
                transaction.type.replaceAll('_', ' ').toUpperCase()),
            _buildDetailRow(
                'Amount', 'KES ${transaction.amount.toStringAsFixed(2)}'),
            _buildDetailRow(
                'Date',
                DateFormat('yyyy-MM-dd HH:mm:ss')
                    .format(transaction.transactionDate)),
            _buildDetailRow('Status', transaction.status.toUpperCase()),
            _buildDetailRow('Reference', transaction.reference),
            if (transaction.mpesaCode != null)
              _buildDetailRow('M-Pesa Code', transaction.mpesaCode!),
            if (transaction.description != null)
              _buildDetailRow('Description', transaction.description!),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 20),
          Flexible(child: Text(value, textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}