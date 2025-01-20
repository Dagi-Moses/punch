import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:punch/models/myModels/userModel.dart';
import 'package:punch/models/myModels/userRecordModel.dart';
import 'package:punch/providers/authProvider.dart';

class UserDetailController {
  final User user;
  final AuthProvider authProvider;

  // Text Controllers
  late TextEditingController userNameController;
  late TextEditingController passWordController;
  late TextEditingController lastNameController;
  late TextEditingController firstNameController;
  late TextEditingController staffNoController;

  // Value Notifiers
  late ValueNotifier<UserRole?> userRoleNotifier;

  // User Records Future
  late Future<List<UserRecord>> userRecordsFuture;

  UserDetailController({
    required this.user,
    required this.authProvider,
  }) {
    userNameController =
        TextEditingController(text: user.username ?? "");
    staffNoController =
        TextEditingController(text: user.staffNo.toString() );
    passWordController =
        TextEditingController(text: user.password ?? "");
    lastNameController =
        TextEditingController(text:user.lastName ?? "");
    firstNameController =
        TextEditingController(text: user.firstName ?? "");
    userRoleNotifier = ValueNotifier(user.loginId);

    // Load user records after navigation
    userRecordsFuture = _fetchUserRecords();
    
  }

  
  Future<List<UserRecord>> _fetchUserRecords() async {
  

    // Fetch user records; if null, initialize to an empty list
    await Future.delayed(Duration(seconds: 1), () async {});
    final List<UserRecord> userRecords =
        await authProvider.getUserRecordsByStaffNo(user.staffNo) ?? [];

    // Sort the records if the list is not empty
    userRecords.sort((a, b) {
      if (a.loginDateTime == null && b.loginDateTime == null) return 0;
      if (a.loginDateTime == null) return 1; // Puts nulls at the end
      if (b.loginDateTime == null) return -1; // Puts nulls at the end
      return b.loginDateTime!.compareTo(a.loginDateTime!);
    });

    return userRecords;
  }

  
  // Handle saving updated anniversary
  Future<void> saveUser(BuildContext context) async {
      if (authProvider.isEditing) {
      User updatedUser = User(
        firstName: firstNameController.text,
        id: user.id,
        lastName: lastNameController.text,
        loginId: userRoleNotifier.value,
        password: passWordController.text,
        staffNo: user.staffNo,
        username: userNameController.text,
      );

      await authProvider
          .updateUser(updatedUser,  context);
          authProvider.isEditing =false;
    } else {
      authProvider.isEditing =  true;
    }
  }
final Map<int, String> userRoleMap = {
    for (var role in UserRole.values) role.index: role.name,
  };

  // Method to dispose resources
  void dispose() {
    userNameController.dispose();
    passWordController.dispose();
    lastNameController.dispose();
    firstNameController.dispose();
    userRoleNotifier.dispose();
  }
}
