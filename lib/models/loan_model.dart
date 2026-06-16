import 'package:flutter/material.dart';

enum LoanStatus { pending, approved, rejected, disbursed, completed }

class Loan {
  int? id;
  int userId;
  double amount;
  double interestRate;
  int durationMonths;
  String purpose;
  LoanStatus status;
  DateTime applicationDate;
  DateTime? approvalDate;
  DateTime? disbursementDate;
  double amountPaid;
  double remainingBalance;

  Loan({
    this.id,
    required this.userId,
    required this.amount,
    this.interestRate = 12.0,
    required this.durationMonths,
    required this.purpose,
    this.status = LoanStatus.pending,
    required this.applicationDate,
    this.approvalDate,
    this.disbursementDate,
    this.amountPaid = 0.0,
    required this.remainingBalance,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'interestRate': interestRate,
      'durationMonths': durationMonths,
      'purpose': purpose,
      'status': status.index,
      'applicationDate': applicationDate.toIso8601String(),
      'approvalDate': approvalDate?.toIso8601String(),
      'disbursementDate': disbursementDate?.toIso8601String(),
      'amountPaid': amountPaid,
      'remainingBalance': remainingBalance,
    };
  }

  factory Loan.fromMap(Map<String, dynamic> map) {
    return Loan(
      id: map['id'],
      userId: map['userId'],
      amount: map['amount'],
      interestRate: map['interestRate'],
      durationMonths: map['durationMonths'],
      purpose: map['purpose'],
      status: LoanStatus.values[map['status']],
      applicationDate: DateTime.parse(map['applicationDate']),
      approvalDate: map['approvalDate'] != null 
          ? DateTime.parse(map['approvalDate']) 
          : null,
      disbursementDate: map['disbursementDate'] != null 
          ? DateTime.parse(map['disbursementDate']) 
          : null,
      amountPaid: map['amountPaid'],
      remainingBalance: map['remainingBalance'],
    );
  }

  double getMonthlyPayment() {
    double monthlyRate = interestRate / 100 / 12;
    if (monthlyRate == 0) return amount / durationMonths;
    return amount * monthlyRate * 
           (1 + monthlyRate) * durationMonths / 
           ((1 + monthlyRate) * durationMonths - 1);
  }

  String getStatusText() {
    switch (status) {
      case LoanStatus.pending:
        return 'Pending Approval';
      case LoanStatus.approved:
        return 'Approved';
      case LoanStatus.rejected:
        return 'Rejected';
      case LoanStatus.disbursed:
        return 'Disbursed';
      case LoanStatus.completed:
        return 'Completed';
    }
  }

  Color getStatusColor() {
    switch (status) {
      case LoanStatus.pending:
        return Colors.orange;
      case LoanStatus.approved:
        return Colors.blue;
      case LoanStatus.rejected:
        return Colors.red;
      case LoanStatus.disbursed:
        return Colors.green;
      case LoanStatus.completed:
        return Colors.teal;
    }
  }
}