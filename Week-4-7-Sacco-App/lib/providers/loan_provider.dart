// File: lib/providers/loan_provider.dart
import 'package:flutter/material.dart';
import '../models/loan_model.dart';

class LoanProvider extends ChangeNotifier {
  List<LoanModel> _loans = [];
  bool _isLoading = false;

  List<LoanModel> get loans => _loans;
  List<LoanModel> get pendingLoans =>
      _loans.where((l) => l.status == 'pending').toList();
  List<LoanModel> get activeLoans =>
      _loans.where((l) => l.status == 'active').toList();
  bool get isLoading => _isLoading;

  LoanProvider() {
    _loadSampleLoans();
  }

  void _loadSampleLoans() {
    _loans = [
      LoanModel(
        id: 'LOAN001',
        userId: 'USR001',
        userName: 'John Doe',
        amount: 25000.0,
        interestRate: 12.0,
        durationMonths: 6,
        purpose: 'Emergency medical expenses',
        status: 'active',
        applicationDate: DateTime.now().subtract(const Duration(days: 30)),
        approvalDate: DateTime.now().subtract(const Duration(days: 28)),
        totalRepayment: 26500.0,
        amountPaid: 5000.0,
        guarantorName: 'Jane Smith',
        guarantorPhone: '254712345679',
      ),
      LoanModel(
        id: 'LOAN002',
        userId: 'USR002',
        userName: 'Jane Smith',
        amount: 50000.0,
        interestRate: 10.0,
        durationMonths: 12,
        purpose: 'Business expansion',
        status: 'pending',
        applicationDate: DateTime.now().subtract(const Duration(days: 2)),
        totalRepayment: 55000.0,
        guarantorName: 'John Doe',
        guarantorPhone: '254712345678',
      ),
    ];
  }

  Future<void> applyForLoan({
    required String userId,
    required String userName,
    required double amount,
    required String purpose,
    required int durationMonths,
    required String guarantorName,
    required String guarantorPhone,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    final interestRate = _calculateInterestRate(amount);
    final totalRepayment = amount + (amount * interestRate / 100);

    _loans.add(LoanModel(
      id: 'LOAN${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      userName: userName,
      amount: amount,
      interestRate: interestRate,
      durationMonths: durationMonths,
      purpose: purpose,
      status: 'pending',
      applicationDate: DateTime.now(),
      totalRepayment: totalRepayment,
      guarantorName: guarantorName,
      guarantorPhone: guarantorPhone,
    ));

    _isLoading = false;
    notifyListeners();
  }

  void approveLoan(String loanId) {
    final index = _loans.indexWhere((l) => l.id == loanId);
    if (index != -1) {
      _loans[index] = LoanModel(
        id: _loans[index].id,
        userId: _loans[index].userId,
        userName: _loans[index].userName,
        amount: _loans[index].amount,
        interestRate: _loans[index].interestRate,
        durationMonths: _loans[index].durationMonths,
        purpose: _loans[index].purpose,
        status: 'active',
        applicationDate: _loans[index].applicationDate,
        approvalDate: DateTime.now(),
        totalRepayment: _loans[index].totalRepayment,
        amountPaid: _loans[index].amountPaid,
        guarantorName: _loans[index].guarantorName,
        guarantorPhone: _loans[index].guarantorPhone,
      );
      notifyListeners();
    }
  }

  void rejectLoan(String loanId) {
    final index = _loans.indexWhere((l) => l.id == loanId);
    if (index != -1) {
      _loans[index] = LoanModel(
        id: _loans[index].id,
        userId: _loans[index].userId,
        userName: _loans[index].userName,
        amount: _loans[index].amount,
        interestRate: _loans[index].interestRate,
        durationMonths: _loans[index].durationMonths,
        purpose: _loans[index].purpose,
        status: 'rejected',
        applicationDate: _loans[index].applicationDate,
        approvalDate: DateTime.now(),
        totalRepayment: _loans[index].totalRepayment,
        amountPaid: _loans[index].amountPaid,
        guarantorName: _loans[index].guarantorName,
        guarantorPhone: _loans[index].guarantorPhone,
      );
      notifyListeners();
    }
  }

  double _calculateInterestRate(double amount) {
    if (amount <= 10000) return 8.0;
    if (amount <= 50000) return 10.0;
    if (amount <= 100000) return 12.0;
    return 14.0;
  }
}