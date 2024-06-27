class User {
  final String username;
  final String password;
   final String ?lastName ;
   final String ? firstName;
  final  int ? loginId;
  final  int ?staffNo;
  final String role;

  User({
    required this.username,
    required this.password,
     this.lastName,
    this.firstName,
     this.loginId,
     this.staffNo,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      password: json['password'] ??'',
      lastName: json['last_name'] ?? '',
      firstName: json['first_name'] ?? '',
      loginId: json['login_id'] ?? '',
      staffNo: json['staff_no'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'last_name': lastName,
      'first_name': firstName,
      'login_id': loginId,
      'staff_no': staffNo,
      'role': role,
    };
  }
}
