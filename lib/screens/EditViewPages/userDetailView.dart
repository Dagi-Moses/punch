import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:punch/controllers/userDetailContoller.dart';
import 'package:punch/models/myModels/userModel.dart';
import 'package:punch/models/myModels/userRecordModel.dart';
import 'package:punch/providers/authProvider.dart';
import 'package:punch/widgets/dropDowns/editableDropDown.dart';
import 'package:punch/widgets/tabbedScaffold.dart';
import 'package:punch/widgets/text-form-fields/html_form_field_widget.dart';
import 'package:responsive_framework/responsive_wrapper.dart';

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
  late UserDetailController controller;
  

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    controller =
        UserDetailController(user: widget.user, authProvider: authProvider);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
        final auth = Provider.of<AuthProvider>(context);
        final isUser = auth.user?.loginId == UserRole.user;
    return TabbedScaffold(
      tabTitles: const ["User Details", "User Record"],
      tabViews: [
        SingleChildScrollView(child: _buildHeaderSection(auth)),
        SingleChildScrollView(child: _buildRecord()),
      ],
      isUser: isUser,
      isLoading: auth.updateloading,
      isEditing: auth.isEditing,
      onEditPressed: () {
        controller.saveUser(context);
      },
    );
  }

  Widget _buildRecord(){
    return FutureBuilder<List<UserRecord>>(
                future: controller.userRecordsFuture,
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
              );
  }

  
  Widget _buildHeaderSection(AuthProvider authProvider) {
    return Center(
      child: ResponsiveWrapper(
        maxWidth: 800,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Card(
            elevation: 4.0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child:  buildTextField(
                          isEditing: authProvider.isEditing,
                          controller: controller.userNameController,
                          label: 'Username',
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: buildTextField(
                          isEditing: authProvider.isEditing,
                          controller: controller.passWordController,
                          label: 'Password',
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                 
                 
                  buildTextField(
                    isEditing: authProvider.isEditing,
                    controller: controller.lastNameController,
                    label: 'Last Name',
                    maxLines: 1,
                  ),
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: buildTextField(
                          isEditing: authProvider.isEditing,
                          controller: controller.staffNoController,
                          label: 'Staff Number',
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildUserRole(authProvider),
                      ),
                    ],
                  ),
                 
                  
                 
                 
             
                  

               
                
                  const SizedBox(height: 8.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

Widget _buildUserRole(AuthProvider authProvider) {
    return CustomEditableDropdown<UserRole>(
      label: 'User Role',
      valueListenable: controller.userRoleNotifier,
      items: controller.userRoleMap.map(
        (key, value) => MapEntry(UserRole.values[key], value),
      ),
      isEditing: authProvider.isEditing,
       onChanged: (UserRole? newType) {
        if (newType != null) {
          controller.userRoleNotifier.value = newType;
            widget.user.loginId = newType;
       
        }
      },
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
