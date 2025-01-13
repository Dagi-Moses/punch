import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:punch/models/myModels/clientExtraModel.dart';
import 'package:punch/models/myModels/clientModel.dart';
import 'package:punch/providers/clientProvider.dart';
import 'package:punch/widgets/inputs/imagePickerWidget.dart';
import 'package:punch/widgets/text-form-fields/custom_styled_text_field.dart';

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
  TextEditingController addressController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
            automaticallyImplyLeading: false,
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

                      buildTextField(
                          label: 'FirstName', controller: firstNameController),

                      buildTextField(
                          label: 'MiddleName',
                          controller: middleNameController),

                      buildTextField(
                          label: 'LastName', controller: lastNameController),

                      DropdownButtonFormField<int>(
                        value: clientProvider.selectedType,
                        onChanged: (int? newValue) {
                          clientProvider.selectedType = newValue;
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
                      const SizedBox(height: 8),
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

                      buildTextField(
                          label: 'Age',
                          controller: ageController
                            ..text = clientProvider.age?.toString() ?? "",
                          keyboardType: TextInputType.number,
                          enabled: false),

                      buildTextField(
                          label: 'Place Of Work',
                          controller: placeOfWorkController,
                          keyboardType: TextInputType.multiline,
                          maxLines: null),

                      buildTextField(
                          label: 'Email',
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress),

                      buildTextField(
                          label: 'TelePhone',
                          controller: telephoneController,
                          keyboardType: TextInputType.phone),

                      buildTextField(
                          label: 'Address',
                          controller: addressController,
                          keyboardType: TextInputType.multiline,
                          maxLines: null),
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

                      buildTextField(
                          label: 'Companies',
                          controller: companiesController,
                          keyboardType: TextInputType.multiline,
                          maxLines: null),

                      buildTextField(
                          label: 'Hobbies',
                          controller: hobbiesController,
                          keyboardType: TextInputType.multiline,
                          maxLines: null),

                      buildTextField(
                          label: 'Present Position',
                          controller: presentPositionController,
                          keyboardType: TextInputType.multiline,
                          maxLines: null),

                      buildTextField(
                          label: 'Political Party',
                          controller: politicalPartyController,
                          keyboardType: TextInputType.multiline,
                          maxLines: null),

                      buildTextField(
                          controller: friendsController,
                          label: 'Friends',
                          keyboardType: TextInputType.multiline,
                          maxLines: null),

                      buildTextField(
                        controller: associatesController,
                        label: 'Associates',
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                      ),

                      buildTextField(
                          controller: descriptionController,
                          label: "Image Description",
                          keyboardType: TextInputType.multiline,
                          maxLines: null),

                      _buildImagePicker(clientProvider),
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
              address: addressController.text.replaceAll('\n', '<br>'),
              associates: associatesController.text.replaceAll('\n', '<br>'),
              dateOfBirth: Provider.of<ClientProvider>(context, listen: false)
                  .selectedDate,
              email: emailController.text,
              firstName: firstNameController.text,
              friends: friendsController.text.replaceAll('\n', '<br>'),
              lastName: lastNameController.text,
              middleName: middleNameController.text,
              placeOfWork: placeOfWorkController.text.replaceAll('\n', '<br>'),
              telephone: telephoneController.text,
              titleId: clientProvider.selectedType,
              description: descriptionController.text.replaceAll('\n', '<br>'),
              image: clientProvider.compressedImage);

          final clientExtra = ClientExtra(
            companies: companiesController.text.replaceAll('\n', '<br>'),
            hobbies: hobbiesController.text.replaceAll('\n', '<br>'),
            politicalParty:
                politicalPartyController.text.replaceAll('\n', '<br>'),
            presentPosition:
                presentPositionController.text.replaceAll('\n', '<br>'),
          );
          if (!clientProvider.loading) {
            await clientProvider.addClient(
              client,
              clientExtra,
              [
                addressController,
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
            );
          }
        },
      ),
    );
  }

  Widget _buildImagePicker(ClientProvider clientProvider) {
    return ImagePickerWidget(
      onTap: clientProvider.pickImage,
      imageBytes: clientProvider.compressedImage,
      placeholderText: "Select a client image",
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
