import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedPeriod = 'Weekly';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Statements'),
        backgroundColor: const Color(0xFF1B5E20),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['Weekly', 'Monthly', 'Annual'].map((period) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPeriod = period;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedPeriod == period
                          ? const Color(0xFF1B5E20)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: const Color(0xFF1B5E20)),
                    ),
                    child: Text(
                      period,
                      style: TextStyle(
                        color: _selectedPeriod == period
                            ? Colors.white
                            : const Color(0xFF1B5E20),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: Consumer<TransactionProvider>(
              builder: (context, transactionProvider, child) {
                List transactions;
                String dateRange;

                switch (_selectedPeriod) {
                  case 'Weekly':
                    transactions = transactionProvider.getWeeklyTransactions();
                    dateRange =
                        '${DateFormat('MMM dd').format(DateTime.now().subtract(const Duration(days: 7)))} - ${DateFormat('MMM dd, yyyy').format(DateTime.now())}';
                    break;
                  case 'Monthly':
                    transactions =
                        transactionProvider.getMonthlyTransactions();
                    dateRange =
                        DateFormat('MMMM yyyy').format(DateTime.now());
                    break;
                  case 'Annual':
                    transactions =
                        transactionProvider.getAnnualTransactions();
                    dateRange = DateFormat('yyyy').format(DateTime.now());
                    break;
                  default:
                    transactions = [];
                    dateRange = '';
                }

                final totalDeposits = transactions
                    .where((t) =>
                        t.type == 'deposit' || t.type == 'mpesa_receive')
                    .fold(0.0, (sum, t) => sum + t.amount);

                final totalWithdrawals = transactions
                    .where((t) =>
                        t.type == 'withdrawal' || t.type == 'mpesa_send')
                    .fold(0.0, (sum, t) => sum + t.amount);

                return Column(
                  children: [
                    // Summary Cards
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              'Total Deposits',
                              'KES ${totalDeposits.toStringAsFixed(2)}',
                              Colors.green,
                              Icons.arrow_downward,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildSummaryCard(
                              'Total Withdrawals',
                              'KES ${totalWithdrawals.toStringAsFixed(2)}',
                              Colors.red,
                              Icons.arrow_upward,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Transaction List
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$_selectedPeriod Report: $dateRange',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.print),
                            onPressed: () {
                              _printReport(
                                transactions,
                                totalDeposits,
                                totalWithdrawals,
                                dateRange,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: transactions.isEmpty
                          ? const Center(
                              child: Text('No transactions found'),
                            )
                          : ListView.builder(
                              itemCount: transactions.length,
                              itemBuilder: (context, index) {
                                final transaction = transactions[index];
                                return ListTile(
                                  leading: Icon(
                                    transaction.type == 'deposit' ||
                                            transaction.type == 'mpesa_receive'
                                        ? Icons.arrow_downward
                                        : Icons.arrow_upward,
                                    color: transaction.type == 'deposit' ||
                                            transaction.type == 'mpesa_receive'
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                  title: Text(
                                    transaction.type
                                        .replaceAll('_', ' ')
                                        .toUpperCase(),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  subtitle: Text(
                                    DateFormat('yyyy-MM-dd HH:mm')
                                        .format(transaction.transactionDate),
                                  ),
                                  trailing: Text(
                                    'KES ${transaction.amount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: transaction.type == 'deposit' ||
                                              transaction.type == 'mpesa_receive'
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, String amount, Color color, IconData icon) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 5),
            Text(
              amount,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _printReport(
    List transactions,
    double totalDeposits,
    double totalWithdrawals,
    String dateRange,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '2NK SACCO - $_selectedPeriod Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Period: $dateRange'),
              pw.SizedBox(height: 20),
              pw.Text(
                'Summary',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text('Total Deposits: KES ${totalDeposits.toStringAsFixed(2)}'),
              pw.Text(
                  'Total Withdrawals: KES ${totalWithdrawals.toStringAsFixed(2)}'),
              pw.SizedBox(height: 20),
              pw.Text(
                'Transaction Details',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}