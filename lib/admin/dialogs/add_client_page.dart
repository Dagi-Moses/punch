import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:punch/admin/core/constants/color_constants.dart';
import 'package:punch/models/myModels/clientExtraModel.dart';
import 'package:punch/models/myModels/clientModel.dart';
import 'package:punch/providers/clientProvider.dart';
import 'package:punch/providers/titleProvider.dart';
import 'package:punch/widgets/dropDowns/inputDropDown.dart';
import 'package:punch/widgets/inputs/dateFields.dart';
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

  TextEditingController addressController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
        final titles = Provider.of<TitleProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: punchRed, // Sets the AppBar background color
        foregroundColor: Colors.white, // Sets the text/icon color
        elevation: 4,
        automaticallyImplyLeading: false,
        title: const Text('Add Client'),
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
                            color: punchRed,
                          ),
                        ),
                      ),
                    CustomInputTextField(
                          label: 'FirstName', controller: firstNameController),
                     CustomInputTextField(
                          label: 'MiddleName',
                          controller: middleNameController),
                     CustomInputTextField(
                          label: 'LastName', controller: lastNameController),
                      CustomInputDropdown<int>(
                        value: clientProvider.selectedType,
                        label: "Title",
                        items: titles.titles,
                        onChanged: (int? newValue) {
                          clientProvider.selectedType = newValue;
                        },
                      ),
                      inputDatePicker(
                        label: "Date Of Birth",
                        selectedDate: clientProvider.selectedDate,
                        context: context,
                        onDateSelected: (DateTime? date) {
                          if (date != null) {
                            clientProvider.setDate(date);
                          }
                        },
                      ),
                  CustomInputTextField(
                          label: 'Age',
                          controller: ageController
                            ..text = clientProvider.age?.toString() ?? "",
                          keyboardType: TextInputType.number,
                          enabled: false),
                     CustomInputTextField(
                          label: 'Place Of Work',
                          controller: placeOfWorkController,
                          keyboardType: TextInputType.multiline,
                          maxLines: null),
                     CustomInputTextField(
                          label: 'Email',
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress),
                    CustomInputTextField(
                          label: 'TelePhone',
                          controller: telephoneController,
                          keyboardType: TextInputType.phone),
                    CustomInputTextField(
                          label: 'Address',
                          controller: addressController,
                          keyboardType: TextInputType.multiline,
                          maxLines: null),
                      const SizedBox(height: 24),
                      const Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          'Client Extras',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: punchRed,
                          ),
                        ),
                      ),
                    CustomInputTextField(
                          label: 'Companies',
                          controller: companiesController,
                          keyboardType: TextInputType.multiline,
                          maxLines: null),
                    CustomInputTextField(
                          label: 'Hobbies',
                          controller: hobbiesController,
                          keyboardType: TextInputType.multiline,
                          maxLines: null),
                   CustomInputTextField(
                          label: 'Present Position',
                          controller: presentPositionController,
                          keyboardType: TextInputType.multiline,
                          maxLines: null),
                      CustomInputTextField(
                          label: 'Political Party',
                          controller: politicalPartyController,
                          keyboardType: TextInputType.multiline,
                          maxLines: null),
                      CustomInputTextField(
                          controller: friendsController,
                          label: 'Friends',
                          keyboardType: TextInputType.multiline,
                          maxLines: null),
                    CustomInputTextField(
                        controller: associatesController,
                        label: 'Associates',
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                      ),
                     CustomInputTextField(
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
}
