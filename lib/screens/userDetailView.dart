import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:punch/models/myModels/userModel.dart';
import 'package:punch/models/myModels/userRecordModel.dart';
import 'package:punch/providers/authProvider.dart';

class UserDetailView extends StatefulWidget {
  User user;

  UserDetailView({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<UserDetailView> createState() => _UserDetailViewState();
}

class _UserDetailViewState extends State<UserDetailView> {
  bool isEditing = false;
  late TextEditingController userNameController;
  late TextEditingController passWordController;
  late TextEditingController lastNameController;
  late TextEditingController firstNameController;
  late ValueNotifier<UserRole?> _userRoleNotifier;
   late Future<List<UserRecord>> userRecordsFuture ;

  @override
  void initState() {
    super.initState();
    userNameController =
        TextEditingController(text: widget.user.username ?? "");
    passWordController =
        TextEditingController(text: widget.user.password ?? "");
    lastNameController =
        TextEditingController(text: widget.user.lastName ?? "");
    firstNameController =
        TextEditingController(text: widget.user.firstName ?? "");
    _userRoleNotifier = ValueNotifier(widget.user.loginId);

    // Load user records after navigation
   
      userRecordsFuture = fetchUserRecords();
    
   
 
  }

  Future<List<UserRecord>> fetchUserRecords() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Fetch user records; if null, initialize to an empty list
   await  Future.delayed(Duration(seconds: 1), () async {});
    final List<UserRecord> userRecords =
        await authProvider.getUserRecordsByStaffNo(widget.user.staffNo) ?? [];

    // Sort the records if the list is not empty
    userRecords.sort((a, b) {
      if (a.loginDateTime == null && b.loginDateTime == null) return 0;
      if (a.loginDateTime == null) return 1; // Puts nulls at the end
      if (b.loginDateTime == null) return -1; // Puts nulls at the end
      return b.loginDateTime!.compareTo(a.loginDateTime!);
    });

    return userRecords;
  }

  @override
  void dispose() {
    userNameController.dispose();
    passWordController.dispose();
    lastNameController.dispose();
    firstNameController.dispose();
    _userRoleNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit),
            onPressed: () async {
              if (isEditing) {
                User updatedUser = User(
                  firstName: firstNameController.text,
                  id: widget.user.id,
                  lastName: lastNameController.text,
                  loginId: _userRoleNotifier.value,
                  password: passWordController.text,
                  staffNo: widget.user.staffNo,
                  username: userNameController.text,
                );

                await Provider.of<AuthProvider>(context, listen: false)
                    .updateUser(updatedUser, () {
                  setState(() {
                    widget.user = updatedUser;
                    isEditing = false;
                  });
                }, context);
              } else {
                setState(() {
                  isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildHeaderSection(),
            const SizedBox(height: 16.0),
            _buildDetailSection(),
            const SizedBox(height: 16.0),
            if (!isEditing)
              FutureBuilder<List<UserRecord>>(
                future: userRecordsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error loading records.'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('No user records available.'));
                  } else {
                    return _buildUserRecordHistory(snapshot.data!);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_circle, size: 20),
                const SizedBox(width: 8.0),
                isEditing
                    ? Expanded(
                        child: TextFormField(
                          controller: userNameController,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      )
                    : Text(
                        'Username: ${widget.user.username}',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Icon(Icons.vpn_key, size: 20),
                const SizedBox(width: 8.0),
                isEditing
                    ? Expanded(
                        child: TextFormField(
                          controller: passWordController,
                          decoration: InputDecoration(
                            labelText: 'PassWord',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      )
                    : Text(
                        'Password: ${widget.user.password}',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Icon(Icons.admin_panel_settings, size: 20),
                const SizedBox(width: 8.0),
                isEditing
                    ? Expanded(
                        child: ValueListenableBuilder<UserRole?>(
                          valueListenable: _userRoleNotifier,
                          builder: (context, value, child) {
                            return DropdownButtonFormField<UserRole>(
                              value: value,
                              decoration: InputDecoration(
                                labelText: 'User Role',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              items: UserRole.values.map((UserRole type) {
                                return DropdownMenuItem<UserRole>(
                                  value: type,
                                  child: Text(type.name),
                                );
                              }).toList(),
                              onChanged: (UserRole? newType) {
                                if (newType != null) {
                                  _userRoleNotifier.value = newType;
                                  widget.user.loginId = newType;
                                  print("selected user role" +
                                      newType.toString());
                                  Future.delayed(Duration.zero, () {
                                    print("user role value" +
                                        _userRoleNotifier.value.toString());
                                  });
                                }
                              },
                            );
                          },
                        ),
                      )
                    : RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: 'UserRole: ',
                              style: TextStyle(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                color: Colors.amber,
                              ),
                            ),
                            TextSpan(
                              text: getUserEvent(widget.user.loginId),
                              style: const TextStyle(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
              ],
            ),
            const SizedBox(height: 8.0),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection() {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Icon(Icons.face, size: 20),
                const SizedBox(width: 8.0),
                isEditing
                    ? Expanded(
                        child: TextFormField(
                          controller: lastNameController,
                          decoration: InputDecoration(
                            labelText: 'Last Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      )
                    : Text(
                        'LastName: ${widget.user.lastName}',
                        style: const TextStyle(fontSize: 16),
                      ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Icon(Icons.face, size: 20),
                const SizedBox(width: 8.0),
                isEditing
                    ? Expanded(
                        child: TextField(
                          controller: firstNameController,
                          decoration: InputDecoration(
                            labelText: 'First Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      )
                    : Text(
                        'First Name: ${widget.user.firstName}',
                        style: const TextStyle(fontSize: 16),
                      ),
              ],
            ),
            const SizedBox(height: 8.0),
            if (!isEditing)
              Row(
                children: [
                  const Icon(Icons.badge, size: 20),
                  const SizedBox(width: 8.0),
                  Text(
                    'Staff No: ${widget.user.staffNo}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserRecordHistory(List<UserRecord> userRecords) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Record History',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: userRecords.length,
              itemBuilder: (context, index) {
                final record = userRecords[index];
                return ListTile(
                  leading: const Icon(Icons.history),
                  title: RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Login Date Time: ',
                          style: TextStyle(color: Colors.black),
                        ),
                        TextSpan(
                          text:
                              '${record.loginDateTime != null ? DateFormat('hh:mm a dd/MM/yyyy').format(record.loginDateTime!) : 'N/A'}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  subtitle: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Computer Name: '),
                      Text(
                        ' ${record.computerName ?? "N/A"}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
