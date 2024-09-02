import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:punch/models/myModels/clientExtraModel.dart';
import 'package:punch/models/myModels/clientModel.dart';
import 'package:punch/providers/clientProvider.dart';

class AddClientPage extends StatefulWidget {
  @override
  State<AddClientPage> createState() => _AddClientPageState();
}

class _AddClientPageState extends State<AddClientPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController lastNameController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController middleNameController = TextEditingController();
  TextEditingController telephoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController placeOfWorkController = TextEditingController();
  TextEditingController associatesController = TextEditingController();
  TextEditingController friendsController = TextEditingController();
  TextEditingController politicalPartyController = TextEditingController();
  TextEditingController presentPositionController = TextEditingController();
  TextEditingController hobbiesController = TextEditingController();
  TextEditingController companiesController = TextEditingController();
  TextEditingController dateOfBirthController = TextEditingController();

  int? selectedType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Client'),
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
                child: Consumer<ClientProvider>(
                    builder: (context, clientProvider, child) {
                  return Column(
                    children: [
                      const Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          'Client Details',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      _buildTextField(
                          'FirstName', 'Enter first name', firstNameController),
                      const SizedBox(height: 16),
                      _buildTextField('MiddleName', 'Enter middle name',
                          middleNameController),
                      const SizedBox(height: 16),
                      _buildTextField(
                          'LastName', 'Enter last name', lastNameController),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: selectedType,
                        onChanged: (int? newValue) {
                          setState(() {
                            selectedType = newValue;
                          });
                        },
                        items: clientProvider.titles.entries.map((entry) {
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
                          labelText: "Title",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      //  _buildDateField(context, 'Date', DateController),
                      _buildDateField(
                          label: "Date Of Birth",
                          selectedDate: clientProvider.selectedDate,
                          context: context,
                          onDateSelected: (DateTime? date) {
                            if (date != null) {
                              clientProvider.setDate(date);
                              setState(() {
                                dateOfBirthController.text =
                                    DateFormat('dd/MM/yyyy').format(date);
                              });
                            }
                          },
                          controller: dateOfBirthController),
                      const SizedBox(height: 16),
                      _buildTextField('Place Of Work',
                          'Enter client Place Of work', placeOfWorkController),
                      const SizedBox(height: 16),
                      _buildTextField('Email', 'Enter client email',
                          emailController, TextInputType.emailAddress),
                      const SizedBox(height: 16),

                      _buildTextField('TelePhone', 'Enter Client Phone Number',
                          telephoneController, TextInputType.phone),

                      const SizedBox(height: 32),
                      const Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          'Client Extras',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField('Companies', 'Enter client\'s companies',
                          companiesController),
                      const SizedBox(height: 16),
                      _buildTextField('Hobbies', 'Enter client\'s hobbies',
                          hobbiesController),
                      const SizedBox(height: 16),
                      _buildTextField(
                          'Present Position',
                          'Enter client\'s Present Position',
                          presentPositionController),
                      const SizedBox(height: 16),
                      _buildTextField(
                          'Political Party',
                          'Enter client\'s polotical Party',
                          politicalPartyController),
                      const SizedBox(height: 16),
                      _buildTextField('Friends', 'Enter client\'s friends',
                          friendsController),
                      const SizedBox(height: 16),
                      _buildTextField('Associates',
                          'Enter client\'s associates', associatesController),
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
        child: Provider.of<ClientProvider>(context).loading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.add),
        onPressed: () async {
          final clientProvider =
              Provider.of<ClientProvider>(context, listen: false);

          final client = Client(
              associates: associatesController.text,
              dateOfBirth: Provider.of<ClientProvider>(context, listen: false)
                  .selectedDate,
              email: emailController.text,
              firstName: firstNameController.text,
              friends: friendsController.text,
              lastName: lastNameController.text,
              middleName: middleNameController.text,
              placeOfWork: placeOfWorkController.text,
              telephone: telephoneController.text,
              titleId: selectedType);

          final clientExtra = ClientExtra(
              companies: companiesController.text,
              hobbies: hobbiesController.text,
              politicalParty: politicalPartyController.text,
              presentPosition: presentPositionController.text);
          if (!clientProvider.loading) {
            await clientProvider.addClient(
              client,
              clientExtra,
              [
                lastNameController,
                firstNameController,
                middleNameController,
                telephoneController,
                emailController,
                placeOfWorkController,
                associatesController,
                friendsController,
                politicalPartyController,
                presentPositionController,
                hobbiesController,
                companiesController,
              ],
              () {
                setState(() {
                  selectedType = null;
                });
              },
            );
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

  Widget _buildDateField(
      {required DateTime? selectedDate,
      required ValueChanged<DateTime?> onDateSelected,
      required BuildContext context,
      required String label,
      required TextEditingController controller}) {
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
