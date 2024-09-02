import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:punch/models/myModels/anniversaryModel.dart';
import 'package:punch/models/myModels/companyExtraModel.dart';
import 'package:punch/models/myModels/companyModel.dart';
import 'package:punch/providers/companyProvider.dart';

class AddCompanyPage extends StatefulWidget {
  @override
  State<AddCompanyPage> createState() => _AddCompanyPageState();
}

class _AddCompanyPageState extends State<AddCompanyPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController companyNoController = TextEditingController();

  final TextEditingController nameController = TextEditingController();

  final TextEditingController companySectorIdController =
      TextEditingController();

  final TextEditingController dateController = TextEditingController();

  final TextEditingController addressController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController phoneController = TextEditingController();

  final TextEditingController faxController = TextEditingController();

  final TextEditingController startDateController = TextEditingController();

  final TextEditingController managingDirectorController =
      TextEditingController();

  final TextEditingController corporateAffairsController =
      TextEditingController();

  final TextEditingController mediaManagerController = TextEditingController();

  final TextEditingController friendsController = TextEditingController();

  final TextEditingController competitorsController = TextEditingController();

  final TextEditingController directorsController = TextEditingController();

  int? selectedType;
  void clearSelectedType() {
    setState(() {
      selectedType = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Company'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Form(
                key: _formKey,
                child: Consumer<CompanyProvider>(
                    builder: (context, companyProvider, child) {
                  return Column(
                    children: [
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          'Company Details',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      _buildTextField(
                          'Name', 'Enter company name', nameController),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: selectedType,
                        onChanged: (int? newValue) {
                          setState(() {
                            selectedType = newValue!;
                          });
                        },
                        items:
                            companyProvider.companySectors.entries.map((entry) {
                          return DropdownMenuItem<int>(
                            value: entry.key,
                            child: Text(
                              entry.value,
                              overflow: TextOverflow.clip,
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          labelText: "Company Sector",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      //  _buildDateField(context, 'Date', DateController),
                      _buildDateField(
                        controller: dateController,
                        label: "Date",
                        selectedDate: companyProvider.selectedDate,
                        context: context,
                        onDateSelected: (DateTime? date) {
                          if (date != null) {
                            companyProvider.setDate(date);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField('Address', 'Enter company address',
                          addressController),
                      const SizedBox(height: 16),
                      _buildTextField('Email', 'Enter company email',
                          emailController, TextInputType.emailAddress),
                      const SizedBox(height: 16),
                      _buildTextField('Fax', 'Enter company fax', faxController,
                          TextInputType.phone),
                      const SizedBox(height: 16),
                      _buildTextField('Phone', 'Enter company Phone Number',
                          phoneController, TextInputType.phone),
                      const SizedBox(height: 16),
                      _buildDateField(
                        controller: startDateController,
                        label: "Start Date",
                        selectedDate: companyProvider.selectedStartDate,
                        context: context,
                        onDateSelected: (DateTime? date) {
                          if (date != null) {
                            companyProvider.setStartDate(date);
                          }
                        },
                      ),

                      const SizedBox(height: 32),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: const Text(
                          'Company Extras',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                          'Managing Director',
                          'Enter managing director\'s name',
                          managingDirectorController),
                      const SizedBox(height: 16),
                      _buildTextField(
                          'Corporate Affairs',
                          'Enter corporate affairs details',
                          corporateAffairsController),
                      const SizedBox(height: 16),
                      _buildTextField(
                          'Media Manager',
                          'Enter media manager\'s name',
                          mediaManagerController),
                      const SizedBox(height: 16),
                      _buildTextField('Friends', 'Enter friends details',
                          friendsController),
                      const SizedBox(height: 16),
                      _buildTextField('Competitors',
                          'Enter competitors details', competitorsController),
                      const SizedBox(height: 16),
                      _buildTextField('Directors', 'Enter directors details',
                          directorsController),
                      const SizedBox(height: 32),
                    ],
                  );
                }),
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
        child: Provider.of<CompanyProvider>(context).loading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.add),
        onPressed: () async {
          final companyProvider =
              Provider.of<CompanyProvider>(context, listen: false);

          final newCompany = Company(
            name: nameController.text,
            companySectorId: selectedType!,
            date: companyProvider.selectedDate,
            startDate: companyProvider.selectedStartDate,
            email: emailController.text,
            address: addressController.text,
            phone: phoneController.text,
            fax: faxController.text,
          );
          final newCompanyExtra = CompanyExtra(
              managingDirector: managingDirectorController.text,
              corporateAffairs: corporateAffairsController.text,
              mediaManager: mediaManagerController.text,
              friends: friendsController.text,
              competitors: competitorsController.text,
              directors: directorsController.text);
          if (!companyProvider.loading) {
            await companyProvider.addCompany(
                newCompany,
                newCompanyExtra,
                [
                  nameController,
                  emailController,
                  addressController,
                  phoneController,
                  faxController,
                  managingDirectorController,
                  corporateAffairsController,
                  mediaManagerController,
                  friendsController,
                  competitorsController,
                  directorsController,
                  startDateController,
                  dateController
                ],
                clearSelectedType);
          }
        },
      ),
    );
  }

  Widget _buildTextField(
      String label, String hint, TextEditingController controller,
      [TextInputType keyboardType = TextInputType.text]) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.teal),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required DateTime? selectedDate,
    required ValueChanged<DateTime?> onDateSelected,
    required BuildContext context,
    required String label,
  }) {
    return GestureDetector(
      onTap: () async {
        // Show the date picker when the field is tapped
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );

        if (pickedDate != null) {
          onDateSelected(pickedDate); // Notify the date change
          controller.text = DateFormat('dd/MM/yyyy')
              .format(pickedDate); // Update the text field
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          readOnly: true, // Make the field read-only
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.teal),
            ),
            suffixIcon: const Icon(Icons.calendar_today, color: Colors.teal),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select $label';
            }
            return null;
          },
        ),
      ),
    );
  }
}
