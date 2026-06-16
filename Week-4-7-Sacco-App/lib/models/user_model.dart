class User {
  int? id;
  String fullName;
  String memberNumber;
  String idNumber;
  String phoneNumber;
  String email;
  String pin;
  String status; // pending, approved, rejected
  DateTime registrationDate;
  String role; // member, admin
  double savingsBalance;
  double loanBalance;
  bool isLoggedIn;

  User({
    this.id,
    required this.fullName,
    required this.memberNumber,
    required this.idNumber,
    required this.phoneNumber,
    required this.email,
    required this.pin,
    this.status = 'pending',
    required this.registrationDate,
    this.role = 'member',
    this.savingsBalance = 0.0,
    this.loanBalance = 0.0,
    this.isLoggedIn = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'memberNumber': memberNumber,
      'idNumber': idNumber,
      'phoneNumber': phoneNumber,
      'email': email,
      'pin': pin,
      'status': status,
      'registrationDate': registrationDate.toIso8601String(),
      'role': role,
      'savingsBalance': savingsBalance,
      'loanBalance': loanBalance,
      'isLoggedIn': isLoggedIn ? 1 : 0,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      fullName: map['fullName'],
      memberNumber: map['memberNumber'],
      idNumber: map['idNumber'],
      phoneNumber: map['phoneNumber'],
      email: map['email'],
      pin: map['pin'],
      status: map['status'],
      registrationDate: DateTime.parse(map['registrationDate']),
      role: map['role'],
      savingsBalance: map['savingsBalance'],
      loanBalance: map['loanBalance'],
      isLoggedIn: map['isLoggedIn'] == 1,
    );
  }
}