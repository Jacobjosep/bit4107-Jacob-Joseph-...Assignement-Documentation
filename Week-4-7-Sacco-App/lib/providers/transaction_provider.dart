// File: lib/providers/transaction_provider.dart
import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/mpesa_service.dart';

class TransactionProvider extends ChangeNotifier {
  List<TransactionModel> _transactions = [];
  List<TransactionModel> _flaggedTransactions = [];
  bool _isLoading = false;

  List<TransactionModel> get transactions => _transactions;
  List<TransactionModel> get flaggedTransactions => _flaggedTransactions;
  bool get isLoading => _isLoading;

  TransactionProvider() {
    _loadSampleTransactions();
  }

  void _loadSampleTransactions() {
    _transactions = [
      TransactionModel(
        id: 'TRX001',
        userId: 'USR001',
        userName: 'John Doe',
        type: 'deposit',
        amount: 5000.0,
        transactionDate: DateTime.now().subtract(const Duration(days: 1)),
        status: 'completed',
        reference: 'DEP2024001',
        mpesaCode: 'SIM123456789',
        description: 'Monthly savings deposit',
      ),
      TransactionModel(
        id: 'TRX002',
        userId: 'USR002',
        userName: 'Jane Smith',
        type: 'withdrawal',
        amount: 2000.0,
        transactionDate: DateTime.now().subtract(const Duration(hours: 5)),
        status: 'flagged',
        reference: 'WTH2024001',
        description: 'Suspicious withdrawal attempt',
      ),
      TransactionModel(
        id: 'TRX003',
        userId: 'USR001',
        userName: 'John Doe',
        type: 'loan_disbursement',
        amount: 25000.0,
        transactionDate: DateTime.now().subtract(const Duration(days: 2)),
        status: 'completed',
        reference: 'LOAN2024001',
        description: 'Emergency loan disbursement',
      ),
    ];

    _flaggedTransactions = _transactions
        .where((t) => t.status == 'flagged')
        .toList();
  }

  Future<Map<String, dynamic>> initiateMpesaPayment({
    required String phoneNumber,
    required double amount,
    required String description,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await MpesaService.simulateSTKPush(
      phoneNumber: phoneNumber,
      amount: amount,
      accountReference: '2NK-${DateTime.now().millisecondsSinceEpoch}',
      transactionDesc: description,
    );

    if (result['success'] == true) {
      final confirmation = await MpesaService.simulatePaymentConfirmation(
        checkoutRequestID: result['CheckoutRequestID'],
      );

      if (confirmation['success'] == true) {
        _transactions.insert(0, TransactionModel(
          id: 'TRX${DateTime.now().millisecondsSinceEpoch}',
          userId: 'USR001',
          userName: 'Current User',
          type: 'mpesa_receive',
          amount: amount,
          transactionDate: DateTime.now(),
          status: 'completed',
          reference: confirmation['MpesaReceiptNumber']!,
          mpesaCode: confirmation['MpesaReceiptNumber'],
          description: description,
        ));
      }
    }

    _isLoading = false;
    notifyListeners();
    return result;
  }

  List<TransactionModel> getTransactionsByDateRange(
      DateTime start, DateTime end) {
    return _transactions.where((t) =>
        t.transactionDate.isAfter(start) && t.transactionDate.isBefore(end)).toList();
  }

  List<TransactionModel> getWeeklyTransactions() {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return getTransactionsByDateRange(weekAgo, DateTime.now());
  }

  List<TransactionModel> getMonthlyTransactions() {
    final monthAgo = DateTime.now().subtract(const Duration(days: 30));
    return getTransactionsByDateRange(monthAgo, DateTime.now());
  }

  List<TransactionModel> getAnnualTransactions() {
    final yearAgo = DateTime.now().subtract(const Duration(days: 365));
    return getTransactionsByDateRange(yearAgo, DateTime.now());
  }

  void flagTransaction(String transactionId) {
    final index = _transactions.indexWhere((t) => t.id == transactionId);
    if (index != -1) {
      _transactions[index] = TransactionModel(
        id: _transactions[index].id,
        userId: _transactions[index].userId,
        userName: _transactions[index].userName,
        type: _transactions[index].type,
        amount: _transactions[index].amount,
        transactionDate: _transactions[index].transactionDate,
        status: 'flagged',
        reference: _transactions[index].reference,
        mpesaCode: _transactions[index].mpesaCode,
        description: _transactions[index].description,
      );
      _flaggedTransactions.add(_transactions[index]);
      notifyListeners();
    }
  }
}