import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:punch/models/myModels/anniversaryModel.dart';
import 'package:punch/providers/anniversaryProvider.dart';
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
  final TextEditingController descriptionController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    final anniversaryProvider = Provider.of<AnniversaryProvider>(context);
    return Scaffold(
      appBar: AppBar(
            automaticallyImplyLeading: false,
        title: const Text('Add Anniversary'),
        backgroundColor: Colors.teal,
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
                  buildTextField(
                    controller: nameController,
                    label: "Name",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<int>(
                    value: anniversaryProvider.selectedType,
                    onChanged: (int? newValue) {
                      anniversaryProvider.selectedType = newValue;
                    },
                    items: anniversaryProvider.anniversaryTypes.entries
                        .map((entry) {
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
                      labelText: "Anniversary Type",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  DropdownButtonFormField<int>(
                    value: anniversaryProvider.selectedPaperType,
                    onChanged: (int? newValue) {
                      anniversaryProvider.selectedPaperType = newValue;
                    },
                    items: anniversaryProvider.paperTypes.entries.map((entry) {
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
                      labelText: "Paper",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  buildTextField(
                      controller: placedByNameController,
                      label: "Placed By Name",
                      keyboardType: TextInputType.multiline,
                      maxLines: null),
                  buildTextField(
                      controller: placedByAddressController,
                      label: "Placed By Address",
                      maxLines: null),
                  buildTextField(
                    controller: placedByPhoneController,
                    label: "Placed By Phone",
                  ),
                  buildTextField(
                      controller: friendsController,
                      label: "Friends",
                      keyboardType: TextInputType.multiline,
                      maxLines: null),
                  buildTextField(
                      controller: associatesController,
                      label: "Associates",
                      keyboardType: TextInputType.multiline,
                      maxLines: null),
                  _buildDatePicker(
                    selectedDate: anniversaryProvider.selectedDate,
                    context: context,
                    onDateSelected: (DateTime? date) {
                      if (date != null) {
                        anniversaryProvider.setDate(date);
                      }
                    },
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  buildTextField(
                    controller: anniversaryYearController
                      ..text =
                          anniversaryProvider.anniversaryYear?.toString() ?? "",
                    label: "Anniversary Year",
                    keyboardType: TextInputType.number,
                    enabled: false,
                  ),
                    buildTextField(
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
        backgroundColor: Colors.teal,
        hoverColor: Colors.teal[200],
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
    );
  }



Widget _buildDatePicker({
  required DateTime? selectedDate,
  required ValueChanged<DateTime?> onDateSelected,
  required BuildContext context,
}) {
  return Container(
    padding: const EdgeInsets.all(5.0),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey, width: 1.0),
      borderRadius: BorderRadius.circular(8.0), // Optional: Rounded corners
    ),
    child: Row(
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
    ),
  );
}
}