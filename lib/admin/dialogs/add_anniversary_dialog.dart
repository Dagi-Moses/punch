import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:punch/models/myModels/anniversaryModel.dart';
import 'package:punch/providers/anniversaryProvider.dart';

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

  int? selectedType;
  int? selectedPaperType;

  void clearSelectedType() {
    setState(() {
      selectedPaperType = null;
      selectedType = null;
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Anniversary'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800), // 60% width
              child: Consumer<AnniversaryProvider>(
                  builder: (context, anniversaryProvider, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      DropdownButtonFormField<int>(
                        value: selectedType,
                        onChanged: (int? newValue) {
                          setState(() {
                            selectedType = newValue!;
                          });
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
                      SizedBox(height: 8,),
                      DropdownButtonFormField<int>(
                        value: selectedPaperType,
                        onChanged: (int? newValue) {
                          setState(() {
                            selectedPaperType = newValue!;
                          });
                        },
                      items: anniversaryProvider.paperTypes.entries
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
                          labelText: "Paper",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      _buildTextField(
                        controller: placedByNameController,
                        label: "Placed By Name",
                        keyboardType: TextInputType.multiline,
                        maxLines: null
                      ),
                      _buildTextField(
                        controller: placedByAddressController,
                        label: "Placed By Address",
                        maxLines: null
                      ),
                      _buildTextField(
                        controller: placedByPhoneController,
                        label: "Placed By Phone",
                      ),
                      _buildTextField(
                        controller: friendsController,
                        label: "Friends",
                        keyboardType: TextInputType.multiline,
                        maxLines: null
                      ),
                      _buildTextField(
                        controller: associatesController,
                        label: "Associates",
                        keyboardType: TextInputType.multiline,  
                        maxLines: null
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
                  );
                }
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
        onPressed: Provider.of<AnniversaryProvider>(context).loading
            ? null
            : () async {
              
                final newAnniversary = Anniversary(
                  //anniversaryNo: int.tryParse(anniversaryNoController.text),
                  name: nameController.text,
                  anniversaryTypeId: selectedType,
                  date: Provider.of<AnniversaryProvider>(context, listen: false)
                      .selectedDate,
                  placedByName: placedByNameController.text.replaceAll('\n', '<br>'),
                  placedByAddress: placedByAddressController.text,
                  placedByPhone: placedByPhoneController.text,
                  friends: friendsController.text.replaceAll('\n', '<br>'),
                  associates: associatesController.text.replaceAll('\n', '<br>'),
                  paperId: selectedPaperType,
                  anniversaryYear: int.tryParse(anniversaryYearController.text),
                );
                await Provider.of<AnniversaryProvider>(context, listen: false)
                    .addAnniversary(
                        newAnniversary,
                        [
                          nameController,
                          placedByNameController,
                          placedByAddressController,
                          placedByPhoneController,
                          friendsController,
                          associatesController,
                          anniversaryYearController,
                        ],
                        clearSelectedType);
              },
        child: Provider.of<AnniversaryProvider>(context).loading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.add),
      ),
    );
  }
}

Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  bool enabled = true,
  String? Function(String?)? validator,
   TextInputType keyboardType = TextInputType.text,
  int? maxLines = 1
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextFormField(
      maxLines: maxLines,
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
