enum UserRole { 
  user,
  admin, 
  library,
}

class User {
  String? id;
  String? username;
  String? password;
  String? lastName;
  String? firstName;
  UserRole? loginId;
  int? staffNo;
  String? token;

  User({
    this.id,
   required this.username,
    required this.password,
    this.lastName,
    this.firstName,
    this.loginId,
    this.staffNo,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    int loginIdIndex = json['login_id'] as int;
    UserRole loginTypeId;

    // Adjust the index to match the enum values
    if (loginIdIndex >= 1 && loginIdIndex <= UserRole.values.length) {
      loginTypeId = UserRole.values[loginIdIndex - 1];
    } else {
      loginTypeId = UserRole.user; // Default role
    }

    return User(
      id: json['_id'] as String? ,
      username: json['username'] as String? ,
      password: json['password'] as String? ,
      lastName: json['last_name'] as String? ,
      firstName: json['first_name'] as String? ,
      loginId: loginTypeId,
      staffNo: json['staff_no'] as int? ,
      token: json['token'] as String? ,
    );
  }

  Map<String, dynamic> toJson() {
    int loginIdIndex =
        (loginId != null) ? UserRole.values.indexOf(loginId!) + 1 : 0;

    return {
      '_id': id,
      'username': username,
      'password': password,
      'last_name': lastName,
      'first_name': firstName,
      'login_id': loginIdIndex,
      'staff_no': staffNo,
      'token': token,
    };
  }
}


String getUserEvent(UserRole? type) {
  switch (type) {
    case UserRole.admin:
      return "Admin";
    case UserRole.library:
      return "Library";
    case UserRole.user:
      return "User";
    default:
      return "Unknown"; // Handles null and any unexpected values
  }
}
