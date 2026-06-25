class UserModel {
  final String id;
  String fullName;
  String email;
  String phoneNumber;
  final String idNumber;
  final String memberNumber;
  final String role;
  double accountBalance;
  double savingsBalance;
  final DateTime registrationDate;
  bool isActive;
  String? profilePicturePath;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.idNumber,
    required this.memberNumber,
    required this.role,
    this.accountBalance = 0.0,
    this.savingsBalance = 0.0,
    required this.registrationDate,
    this.isActive = true,
    this.profilePicturePath,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
        'idNumber': idNumber,
        'memberNumber': memberNumber,
        'role': role,
        'accountBalance': accountBalance,
        'savingsBalance': savingsBalance,
        'registrationDate': registrationDate.toIso8601String(),
        'isActive': isActive,
        'profilePicturePath': profilePicturePath,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        fullName: json['fullName'],
        email: json['email'],
        phoneNumber: json['phoneNumber'],
        idNumber: json['idNumber'],
        memberNumber: json['memberNumber'],
        role: json['role'],
        accountBalance: json['accountBalance']?.toDouble() ?? 0.0,
        savingsBalance: json['savingsBalance']?.toDouble() ?? 0.0,
        registrationDate: DateTime.parse(json['registrationDate']),
        isActive: json['isActive'] ?? true,
        profilePicturePath: json['profilePicturePath'],
      );
}
