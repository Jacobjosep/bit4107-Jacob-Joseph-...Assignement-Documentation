import 'package:flutter/material.dart';
import '../database/sacco_database.dart';
import '../models/loan_model.dart';

class LoanManagement extends StatefulWidget {
  const LoanManagement({super.key});

  @override
  State<LoanManagement> createState() => _LoanManagementState();
}

class _LoanManagementState extends State<LoanManagement> {
  List<LoanModel> loans = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLoans();
  }

  void _loadLoans() async {
    final db = SaccoDatabase();
    final data = await db.getAllLoans();
    setState(() {
      loans = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan Management'),
        actions: [
          DropdownButton<String>(
            value: 'all',
            icon: const Icon(Icons.filter_list),
            dropdownColor: Colors.white,
            onChanged: (value) {},
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All Loans')),
              DropdownMenuItem(value: 'pending', child: Text('Pending')),
              DropdownMenuItem(value: 'approved', child: Text('Approved')),
              DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
            ],
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : loans.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.request_quote, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No loan applications'),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: loans.length,
                  itemBuilder: (context, index) {
                    final loan = loans[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  loan.memberName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: loan.status == 'approved'
                                        ? Colors.green
                                        : loan.status == 'pending'
                                        ? Colors.orange
                                        : Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    loan.status.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Amount: KES ${loan.amount.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Purpose: ${loan.purpose}',
                              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Date: ${loan.date}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                            ),
                            if (loan.status == 'pending') ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _updateLoanStatus(loan.id, 'approved');
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                      ),
                                      child: const Text('Approve'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _updateLoanStatus(loan.id, 'rejected');
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: const Text('Reject'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _updateLoanStatus(int loanId, String status) async {
    final db = SaccoDatabase();
    await db.updateLoanStatus(loanId, status);
    _loadLoans();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Loan ${status.toUpperCase()} successfully'),
        backgroundColor: status == 'approved' ? Colors.green : Colors.red,
      ),
    );
  }
}