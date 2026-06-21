class UserModel {
  final int id;
  final String fullName;
  final String username;
  final String phone;
  final String role;
  final String createdAt;

  UserModel({
    required this.id,
    required this.fullName,
    required this.username,
    required this.phone,
    required this.role,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int,
      fullName: map['full_name'] as String,
      username: map['username'] as String,
      phone: map['phone'] as String,
      role: map['role'] as String,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'username': username,
      'phone': phone,
      'role': role,
      'created_at': createdAt,
    };
  }
}