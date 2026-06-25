// File: lib/models/loan_model.dart
class LoanModel {
  final String id;
  final String userId;
  final String userName;
  final double amount;
  final double interestRate;
  final int durationMonths;
  final String purpose;
  final String status; // 'pending', 'approved', 'rejected', 'active', 'completed'
  final DateTime applicationDate;
  final DateTime? approvalDate;
  final double totalRepayment;
  final double amountPaid;
  final String guarantorName;
  final String guarantorPhone;

  LoanModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.amount,
    required this.interestRate,
    required this.durationMonths,
    required this.purpose,
    required this.status,
    required this.applicationDate,
    this.approvalDate,
    required this.totalRepayment,
    this.amountPaid = 0.0,
    required this.guarantorName,
    required this.guarantorPhone,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'userName': userName,
        'amount': amount,
        'interestRate': interestRate,
        'durationMonths': durationMonths,
        'purpose': purpose,
        'status': status,
        'applicationDate': applicationDate.toIso8601String(),
        'approvalDate': approvalDate?.toIso8601String(),
        'totalRepayment': totalRepayment,
        'amountPaid': amountPaid,
        'guarantorName': guarantorName,
        'guarantorPhone': guarantorPhone,
      };

  factory LoanModel.fromJson(Map<String, dynamic> json) => LoanModel(
        id: json['id'],
        userId: json['userId'],
        userName: json['userName'],
        amount: json['amount'].toDouble(),
        interestRate: json['interestRate'].toDouble(),
        durationMonths: json['durationMonths'],
        purpose: json['purpose'],
        status: json['status'],
        applicationDate: DateTime.parse(json['applicationDate']),
        approvalDate: json['approvalDate'] != null
            ? DateTime.parse(json['approvalDate'])
            : null,
        totalRepayment: json['totalRepayment'].toDouble(),
        amountPaid: json['amountPaid']?.toDouble() ?? 0.0,
        guarantorName: json['guarantorName'],
        guarantorPhone: json['guarantorPhone'],
      );
}