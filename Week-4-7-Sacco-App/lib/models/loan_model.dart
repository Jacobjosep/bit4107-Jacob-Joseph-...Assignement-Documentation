class LoanModel {
  final int id;
  final int userId;
  final String memberName;
  final double amount;
  final String purpose;
  final String status;
  final String date;

  LoanModel({
    required this.id,
    required this.userId,
    required this.memberName,
    required this.amount,
    required this.purpose,
    required this.status,
    required this.date,
  });

  factory LoanModel.fromMap(Map<String, dynamic> map) {
    return LoanModel(
      id: map['id'] as int,
      userId: map['user_id'] as int,
      memberName: map['member_name'] as String,
      amount: (map['amount'] as num).toDouble(),
      purpose: map['purpose'] as String,
      status: map['status'] as String,
      date: map['date'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'member_name': memberName,
      'amount': amount,
      'purpose': purpose,
      'status': status,
      'date': date,
    };
  }
}