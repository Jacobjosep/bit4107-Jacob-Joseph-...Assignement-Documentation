class Student {
  final String id;
  final String fullName;
  final String studentId;
  final String course;
  final String year;
  final String phone;
  final String email;
  final String password;

  Student({
    required this.id,
    required this.fullName,
    required this.studentId,
    required this.course,
    required this.year,
    required this.phone,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'studentId': studentId,
    'course': course,
    'year': year,
    'phone': phone,
    'email': email,
    'password': password,
  };

  factory Student.fromJson(Map<String, dynamic> json) => Student(
    id: json['id'],
    fullName: json['fullName'],
    studentId: json['studentId'],
    course: json['course'],
    year: json['year'],
    phone: json['phone'],
    email: json['email'],
    password: json['password'],
  );
}