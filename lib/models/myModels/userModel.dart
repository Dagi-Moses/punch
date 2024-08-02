enum UserRole { user, admin, library }

class User {
  String? id;
  String? username;
  String? password;
  String? lastName;
  String? firstName;
  int? loginId;
  int? staffNo;
  UserRole? role;
  String? token;

  User({
    this.id,
    this.username,
    this.password,
    this.lastName,
    this.firstName,
    this.loginId,
    this.staffNo,
    this.token,
    this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] as String? ?? "",
      username: json['username'] as String? ?? "N/A",
      password: json['password'] as String? ?? 'N/A',
      lastName: json['last_name'] as String? ?? 'N/A',
      firstName: json['first_name'] as String? ?? 'N/A',
      loginId: json['login_id'] as int? ?? 0,
      staffNo: json['staff_no'] as int? ?? 0,
      token: json['token'] as String? ?? 'N/A',
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${json['role']}',
        orElse: () => UserRole.user,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'password': password,
      'last_name': lastName,
      'first_name': firstName,
      'login_id': loginId,
      'staff_no': staffNo,
      'token': token,
      'role': role.toString().split('.').last,
    };
  }
}
