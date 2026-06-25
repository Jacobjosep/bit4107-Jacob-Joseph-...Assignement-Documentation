// File: lib/models/transaction_model.dart
class TransactionModel {
  final String id;
  final String userId;
  final String userName;
  final String type; // 'deposit', 'withdrawal', 'loan_disbursement', 'loan_repayment', 'mpesa_send', 'mpesa_receive'
  final double amount;
  final DateTime transactionDate;
  final String status; // 'completed', 'pending', 'failed', 'flagged'
  final String reference;
  final String? mpesaCode;
  final String? description;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.type,
    required this.amount,
    required this.transactionDate,
    required this.status,
    required this.reference,
    this.mpesaCode,
    this.description,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'userName': userName,
        'type': type,
        'amount': amount,
        'transactionDate': transactionDate.toIso8601String(),
        'status': status,
        'reference': reference,
        'mpesaCode': mpesaCode,
        'description': description,
      };

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      TransactionModel(
        id: json['id'],
        userId: json['userId'],
        userName: json['userName'],
        type: json['type'],
        amount: json['amount'].toDouble(),
        transactionDate: DateTime.parse(json['transactionDate']),
        status: json['status'],
        reference: json['reference'],
        mpesaCode: json['mpesaCode'],
        description: json['description'],
      );
}