import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:punch/admin/core/constants/color_constants.dart';
import 'package:punch/controllers/anniversaryDetailController.dart';
import 'package:punch/functions/downloadImage.dart'; 
import 'package:punch/models/myModels/userModel.dart';
import 'package:punch/providers/anniversaryProvider.dart';
import 'package:punch/providers/authProvider.dart';
import 'package:punch/widgets/dropDowns/editableDropDown.dart';
import 'package:punch/widgets/editableList.dart';
import 'package:punch/widgets/inputs/dateFields.dart';
import 'package:punch/widgets/inputs/editableImagePicker.dart';
import 'package:punch/widgets/tabbedScaffold.dart';
import 'package:punch/widgets/text-form-fields/html_form_field_widget.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../models/myModels/anniversary/anniversaryModel.dart';

class AnniversaryDetailView extends StatefulWidget {
  Anniversary anniversary;
  AnniversaryDetailView({
    Key? key,
    required this.anniversary,
  }) : super(key: key);
  @override
  State<AnniversaryDetailView> createState() => _AnniversaryDetailViewState();
}

class _AnniversaryDetailViewState extends State<AnniversaryDetailView> {
  late AnniversaryDetailController controller;
  late AnniversaryProvider anniversaryProvider;

  @override
  void initState() {
    super.initState();
    final prov = Provider.of<AnniversaryProvider>(context, listen: false);
    controller = AnniversaryDetailController(
      anniversary: widget.anniversary,
      anniversaryProvider: prov,
    );
    prov.isEditing = false;
    controller.initializeSelectedValues();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("Building AnniversaryDetailView...");
    anniversaryProvider = Provider.of<AnniversaryProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final isUser = auth.user?.loginId == UserRole.user;
    return TabbedScaffold(
      tabTitles: const ["Anniversary Details", "Image"],
      tabViews: [
        SingleChildScrollView(child: _buildHeaderSection()),
        SingleChildScrollView(child: _buildImageSection()),
      ],
      isUser: isUser,
      isLoading: anniversaryProvider.updateloading,
      isEditing: anniversaryProvider.isEditing,
      onEditPressed: () {
        controller.saveAnniversary(context);
      },
    );
  }

  Widget _buildDate() {
    return EditableDateField(
      label: "Anniversary Date",
      isEditing: anniversaryProvider.isEditing,
      selectedDate: widget.anniversary.date,
      controller: controller.dateController,
      onDateChanged: (newDate) {
        setState(() {
          widget.anniversary.date = newDate;
          controller.dateController.text =
              DateFormat('dd/MM/yyyy').format(newDate);
          final aniyr = DateTime.now().year - newDate.year;
          controller.anniversaryYearController.text = aniyr.toString();
        });
      },
    );
  }

  Widget _buildAnniversaryType() {
    final types = anniversaryProvider.anniversaryTypes;
    Map<int, String> getTypesWithDescriptions() {
      final typeDescriptions = {...types}; // Make a copy of the existing map
      if (!typeDescriptions
          .containsKey(controller.anniversaryTypeNotifier.value)) {
        typeDescriptions[controller.anniversaryTypeNotifier.value!] =
            "Unknown"; // Add "Unknown" if the value is missing
      }
      return typeDescriptions;
    }
    return CustomEditableDropdown(
      label: "Anniversary Type",
      valueListenable: controller.anniversaryTypeNotifier,
      items:
          getTypesWithDescriptions(), // Pass the map of types with descriptions
      isEditing: anniversaryProvider.isEditing,
      onChanged: (newTypeId) {
        if (newTypeId != null) {
          controller.anniversaryTypeNotifier.value = newTypeId;
          widget.anniversary.anniversaryTypeId = newTypeId;
        }
      },
    );
  }

  Widget _buildPaperType(bool selectPaper) {
    return CustomEditableDropdown<int>(
      label: "Papers",
      valueListenable: ValueNotifier<int?>(controller.selectedPaperId),
      items: anniversaryProvider.paperTypes,
      isEditing: true,
      itemBuilder: (key, value) {
        final hasData = controller.anniversary.placedBy!
            .any((placedBy) => placedBy.paperId == key);
        final isSelected = controller.selectedPaperId == key;
        return DropdownMenuItem<int>(
          value: key,
          child: Text(
            value,
            style: TextStyle(
              color: isSelected
                  ? (hasData
                      ? punchRed
                      : Colors.grey[
                          800]) 
                  : (hasData
                      ? Colors.blue
                      : Colors
                          .black), 
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        );
      },
      onChanged: (value) {
        if (value != null) {
          if (selectPaper) {
            controller.selectPaper(value);
          } else {
            controller.updateSelectedPlacedBy(newPaperId: value);
          }
        }
      },
    );
  }

  Widget _buildPlacedByDates() {
    return Stack(
      children: [
        CustomEditableDropdown<DateTime>(
          label: "Placed Dates",
          valueListenable: ValueNotifier<DateTime?>(controller.selectedPlacedBy?.date),
          itemBuilder: (key, value) {
            return DropdownMenuItem(
              value: key,
              alignment: Alignment.centerRight,
              child: Slidable(
                closeOnScroll: true,
                key: ValueKey(value),
                enabled: anniversaryProvider.isEditing,
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) async {
                        DateTime? newDate = await showDatePicker(
                          context: context,
                          initialDate:
                              controller.selectedPlacedBy?.date ?? DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2100),
                        );
                        try{
                        if (newDate != null) {
                          controller.updateSelectedPlacedBy(newDate: newDate);
                        }}catch(e){
                          print("error from updating date: ${e.toString()}");
                        }
                        
                      },
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      icon: Icons.edit,
                      label: 'Edit',
                    ),
                    SlidableAction(
                      onPressed: (context) async {
                        await showDialog<int?>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Edit Paper ID'),
                              content: _buildPaperType(false),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(
                                        context); // Close without saving
                                  },
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(
                                        context,
                                        controller
                                            .selectedPaperId); // Return selected paperId
                                  },
                                  child: const Text('Save'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      backgroundColor: Colors.greenAccent,
                      foregroundColor: Colors.white,
                      icon: Icons.library_books,
                      label: 'Change Paper ID',
                    ),
                    SlidableAction(
                      onPressed: (context) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Delete Placed By"),
                              content: const Text(
                                  "Are you sure you want to delete this entry?"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Cancel"),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    controller.deleteSelectedPlacedBy();
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Text("Delete"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    SizedBox(
                        height: 50,
                        child: Center(
                            child: Text(
                          value,
                        ))),
                  ],
                ),
              ),
            );
          },
          items: Map.fromEntries(
            (controller.availableDates.toList()
                  ..sort((a, b) => b.compareTo(a)) 
                )
                .map((date) => MapEntry(date,
                    DateFormat('dd/MM/yyyy').format(date))),
          ),

          isEditing: true, 
          onChanged: (value) {
            if (value != null) {
              controller.selectDate(value);
            }
          },
        ),
        if (anniversaryProvider.isEditing)
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.add_circle, color: punchRed),
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  if (!controller.availableDates.contains(pickedDate)) {
                    controller.availableDates.add(pickedDate);
                  }
                  controller.addNewPlacedBy(pickedDate); // Add a new PlacedBy
                }
              },
            ),
          ),
      ],
    );
  }

  Widget _buildC() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTextField(
          isEditing: anniversaryProvider.isEditing,
          controller: controller.placedByNameController,
          label: "Placed By Name",
        ),
        buildTextField(
          isEditing: anniversaryProvider.isEditing,
          controller: controller.placedByAddressController,
          label: "Placed By Address",
        ),
      ],
    );
  }

  Widget _buildAssociates() {
    return EditableList(
      title: "Associates",
      items: controller.associates ?? [],
      isEditing: anniversaryProvider.isEditing,
      onAdd: (value) => controller.addAssociate(value),
      onDelete: (value) => controller.deleteAssociate(value),
      onEdit: (oldValue, newValue) =>
          controller.editAssociate(oldValue, newValue),
    );
  }

  Widget _buildFriends() {
    return EditableList(
      title: "Friends",
      items: controller.friends ?? [],
      isEditing: anniversaryProvider.isEditing,
      onAdd: (value) => controller.addFriend(value),
      onDelete: (value) => controller.deleteFriend(value),
      onEdit: (oldValue, newValue) => controller.editFriend(oldValue, newValue),
    );
  }

  Widget _buildHeaderSection() {
    return ChangeNotifierProvider.value(
      value: controller,
      child: Consumer<AnniversaryDetailController>(
          builder: (context, controller, child) {
        return Center(
          child: ResponsiveWrapper(
            maxWidth: 800,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child:
                        Form(
                      key: controller.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildTextField(
                            isEditing: anniversaryProvider.isEditing,
                            controller: controller.nameController,
                            label: "Name",
                            maxLines: 1,
                          ),
                          const SizedBox(height: 8.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: _buildDate()),
                              const SizedBox(width: 16),
                              Expanded(child: _buildAnniversaryType()),
                              const SizedBox(width: 16),
                              Expanded(
                                child: buildTextField(
                                    isEditing: anniversaryProvider.isEditing,
                                    controller: controller.anniversaryYearController,
                                    label: "Anniversary Year",
                                    maxLines: 1,
                                    enabled: false),
                              ),
                              const SizedBox(width: 16),
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: _buildPaperType(true)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildPlacedByDates()),
                              const SizedBox(width: 16),
                              Expanded(
                                child: buildTextField(
                                  isEditing: anniversaryProvider.isEditing,
                                  controller:
                                      controller.placedByPhoneController,
                                  label: "Placed By Phone",
                                  validator: (value) {
                                    const phonePattern = r'^\+?[0-9]{10,15}$';
                                    final regExp = RegExp(phonePattern);
                                    if (value != null &&
                                        value.isNotEmpty &&
                                        !regExp.hasMatch(value)) {
                                      return 'Enter a valid phone number (10-15 digits, optional "+" for country code)';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          _buildC(),
                          const SizedBox(height: 8),  
                          _buildFriends(),
                          _buildAssociates(),
                          const SizedBox(height: 8.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildImageSection() {
    return Center(
      child: ResponsiveWrapper(
        maxWidth: 800,
        child: Card(
          elevation: 4.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildTextField(
                  isEditing: anniversaryProvider.isEditing,
                  controller: controller.imageDescriptionController,
                  label: 'Image Description',
                ),
                const SizedBox(height: 8.0),
                _buildImagePicker(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return EditableImagePicker(
      label: "Image",
      isEditing: anniversaryProvider.isEditing,
      image: widget.anniversary.image,
      onPickImage: anniversaryProvider.pickImage,
      onImageChanged: (newImage) {
        setState(() {
          widget.anniversary.image = newImage;
        });
      },
      onRemoveImage: () {
        setState(() {
          widget.anniversary.image = null;
          anniversaryProvider.compressedImage = null;
        });
      },
      onDownloadImage: () {
        if (widget.anniversary.image != null) {
          downloadImage(
              widget.anniversary.image!, "${controller.anniversary.name}.png");
        }
      },
    );
  }
}
