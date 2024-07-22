import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:punch/models/anniversaryModel.dart';
import 'package:punch/providers/anniversaryProvider.dart';

void showAddAnniversaryDialog(BuildContext context) {
  final TextEditingController anniversaryNoController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController typeIdController = TextEditingController();
  final TextEditingController placedByNameController = TextEditingController();
  final TextEditingController placedByAddressController =
      TextEditingController();
  final TextEditingController placedByPhoneController = TextEditingController();
  final TextEditingController friendsController = TextEditingController();
  final TextEditingController associatesController = TextEditingController();
  final TextEditingController paperIdController = TextEditingController();
  final TextEditingController anniversaryYearController =
      TextEditingController();

  bool isLoading = false;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Add Anniversary"),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Container(
              width: MediaQuery.of(context).size.width * 0.6, // 60% width
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      controller: anniversaryNoController,
                      label: "Anniversary Number",
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a number';
                        }
                        return null;
                      },
                    ),
                    _buildTextField(
                      controller: nameController,
                      label: "Name",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    _buildTextField(
                      controller: typeIdController,
                      label: "Type ID",
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a type ID';
                        }
                        return null;
                      },
                    ),
                    _buildTextField(
                      controller: placedByNameController,
                      label: "Placed By Name",
                    ),
                    _buildTextField(
                      controller: placedByAddressController,
                      label: "Placed By Address",
                    ),
                    _buildTextField(
                      controller: placedByPhoneController,
                      label: "Placed By Phone",
                    ),
                    _buildTextField(
                      controller: friendsController,
                      label: "Friends",
                    ),
                    _buildTextField(
                      controller: associatesController,
                      label: "Associates",
                    ),
                    _buildTextField(
                      controller: paperIdController,
                      label: "Paper ID",
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    Consumer<AnniversaryProvider>(
                      builder: (context, anniversaryProvider, child) {
                        return Column(
                          children: [
                            _buildDatePicker(
                              selectedDate: anniversaryProvider.selectedDate,
                              context: context,
                              onDateSelected: (DateTime? date) {
                                if (date != null) {
                                  anniversaryProvider.setDate(date);
                                  anniversaryYearController.text =
                                      date.year.toString();
                                }
                              },
                            ),
                            _buildTextField(
                              controller: anniversaryYearController,
                              label: "Anniversary Year",
                              keyboardType: TextInputType.number,
                              enabled: false, // Prevent manual editing
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "Done",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        setState(() {
                          isLoading = true;
                        });

                        final newAnniversary = Anniversary(
                          anniversaryNo:
                              int.tryParse(anniversaryNoController.text),
                          name: nameController.text,
                          anniversaryTypeId:
                              int.tryParse(typeIdController.text) ?? 0,
                          date: Provider.of<AnniversaryProvider>(context,
                                  listen: false)
                              .selectedDate,
                          placedByName: placedByNameController.text,
                          placedByAddress: placedByAddressController.text,
                          placedByPhone: placedByPhoneController.text,
                          friends: friendsController.text,
                          associates: associatesController.text,
                          paperId: int.tryParse(paperIdController.text),
                          anniversaryYear:
                              int.tryParse(anniversaryYearController.text),
                        );
                        await Provider.of<AnniversaryProvider>(context,
                                listen: false)
                            .addAnniversary(
                          newAnniversary,
                          [
                            anniversaryNoController,
                            nameController,
                            typeIdController,
                            placedByNameController,
                            placedByAddressController,
                            placedByPhoneController,
                            friendsController,
                            associatesController,
                            paperIdController,
                            anniversaryYearController,
                          ], 
                        );

                        setState(() {
                          isLoading = false;
                        });
                      },
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Add"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Background color
                  foregroundColor: Colors.white, // Text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
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
