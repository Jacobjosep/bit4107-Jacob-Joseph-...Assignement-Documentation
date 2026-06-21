import 'package:flutter/material.dart';

enum TransactionType {
  deposit,
  withdraw,
  transfer,
  loanDisbursement,
  loanRepayment,
  interestEarned
}

class Transaction {
  int? id;
  int userId;
  double amount;
  TransactionType type;
  String description;
  DateTime date;
  double balanceAfter;
  String? referenceNumber;
  int? recipientId;

  Transaction({
    this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.description,
    required this.date,
    required this.balanceAfter,
    this.referenceNumber,
    this.recipientId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'type': type.index,
      'description': description,
      'date': date.toIso8601String(),
      'balanceAfter': balanceAfter,
      'referenceNumber': referenceNumber,
      'recipientId': recipientId,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      userId: map['userId'],
      amount: map['amount'],
      type: TransactionType.values[map['type']],
      description: map['description'],
      date: DateTime.parse(map['date']),
      balanceAfter: map['balanceAfter'],
      referenceNumber: map['referenceNumber'],
      recipientId: map['recipientId'],
    );
  }

  String getFormattedAmount() {
    String sign = '';
    if (type == TransactionType.deposit || 
        type == TransactionType.loanDisbursement ||
        type == TransactionType.interestEarned) {
      sign = '+';
    } else if (type == TransactionType.withdraw ||
               type == TransactionType.transfer ||
               type == TransactionType.loanRepayment) {
      sign = '-';
    }
    return '$sign KES ${amount.toStringAsFixed(2)}';
  }

  Color getColor() {
    if (type == TransactionType.deposit || 
        type == TransactionType.loanDisbursement ||
        type == TransactionType.interestEarned) {
      return Colors.green;
    }
    return Colors.red;
  }

  IconData getIcon() {
    switch (type) {
      case TransactionType.deposit:
        return Icons.arrow_downward;
      case TransactionType.withdraw:
        return Icons.arrow_upward;
      case TransactionType.transfer:
        return Icons.swap_horiz;
      case TransactionType.loanDisbursement:
        return Icons.credit_card;
      case TransactionType.loanRepayment:
        return Icons.payment;
      case TransactionType.interestEarned:
        return Icons.trending_up;
    }
  }
}