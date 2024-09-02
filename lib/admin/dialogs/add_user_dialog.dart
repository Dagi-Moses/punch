import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:punch/models/myModels/anniversaryModel.dart';
import 'package:punch/models/myModels/userModel.dart';
import 'package:punch/providers/anniversaryProvider.dart';
import 'package:punch/providers/authProvider.dart';
class AddUserPage extends StatefulWidget {
  const AddUserPage({super.key});

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passWordController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController staffNoController = TextEditingController();
  final TextEditingController loginDateTimeController = TextEditingController();
  final TextEditingController computerNameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  UserRole? selectedUserRole;

  void clearSelectedType() {
    setState(() {
      selectedUserRole = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add User'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800), // 60% width
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      controller: userNameController,
                      label: "Username",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a username';
                        }
                        return null;
                      },
                    ),
                    DropdownButtonFormField<UserRole>(
                      value: selectedUserRole,
                      onChanged: (UserRole? newValue) {
                        setState(() {
                          selectedUserRole = newValue!;
                        });
                      },
                      items: UserRole.values.map((UserRole type) {
                        return DropdownMenuItem<UserRole>(
                          value: type,
                          child: Text(type.name),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: "User Role",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    _buildTextField(
                      controller: firstNameController,
                      label: "First Name",
                    ),
                    _buildTextField(
                      controller: lastNameController,
                      label: "Last Name",
                    ),
                    _buildTextField(
                      controller: passWordController,
                      label: "Password",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        return null;
                      },
                    ),
                    _buildTextField(
                      controller: staffNoController,
                      label: "Staff No",
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        // Allow null value
                        if (value == null || value.isEmpty) {
                          return null; // Return null if no value provided, allowing the field to be empty
                        }
                        // Regular expression to check if the value contains only digits
                        final digitRegex = RegExp(r'^[0-9]+$');
                        if (!digitRegex.hasMatch(value)) {
                          return 'Staff number must be only digits';
                        }
                        return null; // Return
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        hoverColor: Colors.teal[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        onPressed: Provider.of<AuthProvider>(context).loading
            ? null
            : () async {
                // Validate form before proceeding
                if (_formKey.currentState!.validate()) {
                  final newUser = User(
                    //anniversaryNo: int.tryParse(anniversaryNoController.text),
                    username: userNameController.text,
                    loginId: selectedUserRole,
                    firstName: firstNameController.text,
                    lastName: lastNameController.text,
                    password: passWordController.text,
                    staffNo: int.tryParse(staffNoController.text),
                  );
                  await Provider.of<AuthProvider>(context, listen: false)
                      .addUser(
                          newUser,
                          [
                            // anniversaryNoController,
                            userNameController,
                            firstNameController,
                            lastNameController,
                            passWordController,
                            staffNoController,
                          ],
                          clearSelectedType);
                }
              },
        child: Provider.of<AuthProvider>(context).loading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.add),
      ),
    );
  }
}

Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  TextInputType keyboardType = TextInputType.text,
  bool enabled = true,
  String? Function(String?)? validator,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      keyboardType: keyboardType,
      enabled: enabled,
      validator: validator,
    ),
  );
}

Widget _buildDatePicker({
  required DateTime? selectedDate,
  required ValueChanged<DateTime?> onDateSelected,
  required BuildContext context,
}) {
  return Row(
    children: [
      Expanded(
        child: Text(
          "Date: ${selectedDate != null ? DateFormat('dd/MM/yyyy').format(selectedDate) : 'Not selected'}",
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
      ),
      IconButton(
        icon: const Icon(Icons.calendar_today, color: Colors.black),
        onPressed: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
          );
          onDateSelected(pickedDate);
        },
      ),
    ],
  );
}
