import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:punch/admin/core/constants/color_constants.dart';

import 'package:punch/models/myModels/companyExtraModel.dart';
import 'package:punch/models/myModels/companyModel.dart';
import 'package:punch/providers/companyProvider.dart';
import 'package:punch/widgets/dropDowns/inputDropDown.dart';
import 'package:punch/widgets/inputs/dateFields.dart';
import 'package:punch/widgets/inputs/imagePickerWidget.dart';
import 'package:punch/widgets/text-form-fields/custom_styled_text_field.dart';
import 'package:punch/widgets/texts/alignedHeaderText.dart';

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
  final TextEditingController addressController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController faxController = TextEditingController();
  final TextEditingController managingDirectorController =
      TextEditingController();
  final TextEditingController corporateAffairsController =
      TextEditingController();
  final TextEditingController mediaManagerController = TextEditingController();
  final TextEditingController friendsController = TextEditingController();
  final TextEditingController competitorsController = TextEditingController();
  final TextEditingController directorsController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: punchRed,
        foregroundColor: Colors.white,
        elevation: 4,
        automaticallyImplyLeading: false,
        title: const Text('Add Company'),
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
                      alignedHeaderText(
                        title: 'Company Details',
                      ),
                      CustomInputTextField(
                          label: 'Name', controller: nameController),
                      CustomInputDropdown<int>(
                        value: companyProvider.selectedType,
                        label: "Company Sector",
                        items: companyProvider.companySectors,
                        onChanged: (int? newValue) {
                          companyProvider.selectedType = newValue!;
                        },
                      ),
                      inputDatePicker(
                        selectedDate: companyProvider.selectedDate,
                        context: context,
                        onDateSelected: (DateTime? date) {
                          if (date != null) {
                            companyProvider.setDate(date);
                          }
                        },
                      ),
                     CustomInputTextField(
                          label: 'Address', controller: addressController),
                    CustomInputTextField(
                          label: 'Email',
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress),
                      CustomInputTextField(
                          label: 'Fax',
                          controller: faxController,
                          keyboardType: TextInputType.phone),
                    CustomInputTextField(
                          label: 'Phone',
                          controller: phoneController,
                          keyboardType: TextInputType.phone),
                      inputDatePicker(
                        label: "Start Date",
                        selectedDate: companyProvider.selectedStartDate,
                        context: context,
                        onDateSelected: (DateTime? date) {
                          if (date != null) {
                            companyProvider.setStartDate(date);
                          }
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: alignedHeaderText(
                          title: 'Company Extras',
                        ),
                      ),
                     CustomInputTextField(
                          label: 'Managing Director',
                          controller: managingDirectorController,
                          keyboardType: TextInputType.multiline,
                          maxLines: null),
                     CustomInputTextField(
                          label: 'Corporate Affairs',
                          controller: corporateAffairsController,
                          keyboardType: TextInputType.multiline,
                          maxLines: null),
                    CustomInputTextField(
                          label: 'Media Manager',
                          controller: mediaManagerController,
                          keyboardType: TextInputType.multiline,
                          maxLines: null),
                      CustomInputTextField(
                          label: 'Friends',
                          controller: friendsController,
                          keyboardType: TextInputType.multiline,
                          maxLines: null),
                     CustomInputTextField(
                          label: 'Competitors',
                          controller: competitorsController,
                          keyboardType: TextInputType.multiline,
                          maxLines: null),
                     CustomInputTextField(
                          label: 'Directors',
                          controller: directorsController,
                          keyboardType: TextInputType.multiline,
                          maxLines: null),
                     CustomInputTextField(
                          controller: descriptionController,
                          label: "Image Description",
                          keyboardType: TextInputType.multiline,
                          maxLines: null),
                      _buildImagePicker(companyProvider),
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
            companySectorId: companyProvider.selectedType,
            date: companyProvider.selectedDate,
            startDate: companyProvider.selectedStartDate,
            email: emailController.text,
            address: addressController.text,
            phone: phoneController.text,
            description: descriptionController.text.replaceAll('\n', '<br>'),
            image: companyProvider.compressedImage,
            fax: faxController.text,
          );
          final newCompanyExtra = CompanyExtra(
            managingDirector:
                managingDirectorController.text.replaceAll('\n', '<br>'),
            corporateAffairs:
                corporateAffairsController.text.replaceAll('\n', '<br>'),
            mediaManager: mediaManagerController.text.replaceAll('\n', '<br>'),
            friends: friendsController.text.replaceAll('\n', '<br>'),
            competitors: competitorsController.text.replaceAll('\n', '<br>'),
            directors: directorsController.text.replaceAll('\n', '<br>'),
          );
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
                descriptionController
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildImagePicker(CompanyProvider companyProvider) {
    return ImagePickerWidget(
      onTap: companyProvider.pickImage,
      imageBytes: companyProvider.compressedImage,
      placeholderText: "Select a company image",
    );
  }
}
