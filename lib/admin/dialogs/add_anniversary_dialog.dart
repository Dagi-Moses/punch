import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:punch/admin/core/constants/color_constants.dart';
import 'package:punch/models/myModels/anniversaryModel.dart';
import 'package:punch/providers/anniversaryProvider.dart';
import 'package:punch/widgets/dropDowns/inputDropDown.dart';
import 'package:punch/widgets/inputs/dateFields.dart';
import 'package:punch/widgets/inputs/imagePickerWidget.dart';
import 'package:punch/widgets/text-form-fields/custom_styled_text_field.dart';

class AddAnniversaryPage extends StatefulWidget {
  const AddAnniversaryPage({super.key});

  @override
  State<AddAnniversaryPage> createState() => _AddAnniversaryPageState();
}

class _AddAnniversaryPageState extends State<AddAnniversaryPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController placedByNameController = TextEditingController();
  final TextEditingController placedByAddressController =
      TextEditingController();
  final TextEditingController placedByPhoneController = TextEditingController();
  final TextEditingController friendsController = TextEditingController();
  final TextEditingController associatesController = TextEditingController();
  final TextEditingController anniversaryYearController =
      TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final anniversaryProvider = Provider.of<AnniversaryProvider>(context);
    return Scaffold(
      appBar: AppBar(
          backgroundColor: punchRed, // Sets the AppBar background color
        foregroundColor: Colors.white, // Sets the text/icon color
        elevation: 4, 
        automaticallyImplyLeading: false,
        title: const Text('Add Anniversary'),
      
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800), // 60% width
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomInputTextField(
                    controller: nameController,
                    label: "Name",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  CustomInputDropdown<int>(
                    value: anniversaryProvider.selectedType,
                    label: "Anniversary Type",
                    items: anniversaryProvider.anniversaryTypes,
                    onChanged: (int? newValue) {
                      anniversaryProvider.selectedType = newValue;
                    },
                  ),
                  CustomInputDropdown<int>(
                    value: anniversaryProvider.selectedPaperType,
                    label: "Paper",
                    items: anniversaryProvider.paperTypes,
                    onChanged: (int? newValue) {
                      anniversaryProvider.selectedPaperType = newValue;
                    },
                  ),
                  CustomInputTextField(
                      controller: placedByNameController,
                      label: "Placed By Name",
                      keyboardType: TextInputType.multiline,
                      maxLines: null),
                  CustomInputTextField(
                      controller: placedByAddressController,
                      label: "Placed By Address",
                      maxLines: null),
                 CustomInputTextField(
                    controller: placedByPhoneController,
                    label: "Placed By Phone",
                  ),
                  CustomInputTextField(
                      controller: friendsController,
                      label: "Friends",
                      keyboardType: TextInputType.multiline,
                      maxLines: null),
                  CustomInputTextField(
                      controller: associatesController,
                      label: "Associates",
                      keyboardType: TextInputType.multiline,
                      maxLines: null),
                  inputDatePicker(
                    selectedDate: anniversaryProvider.selectedDate,
                    context: context,
                    onDateSelected: (DateTime? date) {
                      if (date != null) {
                        anniversaryProvider.setDate(date);
                      }
                    },
                  ),
                  CustomInputTextField(
                    controller: anniversaryYearController
                      ..text =
                          anniversaryProvider.anniversaryYear?.toString() ?? "",
                    label: "Anniversary Year",
                    keyboardType: TextInputType.number,
                    enabled: false,
                  ),
                   CustomInputTextField(
                      controller: descriptionController,
                      label: "Image Description",
                      keyboardType: TextInputType.multiline,
                      maxLines: null),
                  _buildImagePicker(anniversaryProvider),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
      
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        onPressed: anniversaryProvider.loading
            ? null
            : () async {
                final newAnniversary = Anniversary(
                    //anniversaryNo: int.tryParse(anniversaryNoController.text),
                    name: nameController.text,
                    anniversaryTypeId: anniversaryProvider.selectedType,
                    date: anniversaryProvider.selectedDate,
                    placedByName:
                        placedByNameController.text.replaceAll('\n', '<br>'),
                    placedByAddress: placedByAddressController.text,
                    placedByPhone: placedByPhoneController.text,
                    friends: friendsController.text.replaceAll('\n', '<br>'),
                    associates:
                        associatesController.text.replaceAll('\n', '<br>'),
                    description:
                        descriptionController.text.replaceAll('\n', '<br>'),
                    paperId: anniversaryProvider.selectedPaperType,
                    anniversaryYear:
                        int.tryParse(anniversaryYearController.text),
                    image: anniversaryProvider.compressedImage);
                await anniversaryProvider.addAnniversary(
                  newAnniversary,
                  [
                    descriptionController,
                    nameController,
                    placedByNameController,
                    placedByAddressController,
                    placedByPhoneController,
                    friendsController,
                    associatesController,
                    anniversaryYearController,
                  ],
                );
              },
        child: anniversaryProvider.loading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.add),
      ),
    );
  }

  Widget _buildImagePicker(AnniversaryProvider anniversaryProvider) {
    return ImagePickerWidget(
      onTap: anniversaryProvider.pickImage,
      imageBytes: anniversaryProvider.compressedImage,
      placeholderText: "Select an anniversary image",
       isLoading: anniversaryProvider.imageLoading, // Pass the loading state
    );
  }
}
