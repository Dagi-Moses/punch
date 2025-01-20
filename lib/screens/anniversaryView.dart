import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:punch/controllers/anniversaryDetailController.dart';

import 'package:punch/functions/downloadImage.dart';
import 'package:punch/models/myModels/anniversaryModel.dart';
import 'package:punch/models/myModels/userModel.dart';
import 'package:punch/providers/anniversaryProvider.dart';
import 'package:punch/providers/authProvider.dart';

import 'package:punch/widgets/dropDowns/editableDropDown.dart';
import 'package:punch/widgets/inputs/dateFields.dart';
import 'package:punch/widgets/inputs/editableImagePicker.dart';
import 'package:punch/widgets/tabbedScaffold.dart';
import 'package:punch/widgets/text-form-fields/html_form_field_widget.dart';
import 'package:responsive_framework/responsive_framework.dart';

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

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final anniversaryProvider = Provider.of<AnniversaryProvider>(context);
    controller = AnniversaryDetailController(
      anniversary: widget.anniversary,
      anniversaryProvider: anniversaryProvider,
     
    );
    final auth = Provider.of<AuthProvider>(context);
    final isUser = auth.user?.loginId == UserRole.user;
    return TabbedScaffold(
      tabTitles: const ["Anniversary Details", "Image"],
      tabViews: [
        SingleChildScrollView(child: _buildHeaderSection(anniversaryProvider)),
        SingleChildScrollView(child: _buildImageSection(anniversaryProvider)),
      ],
      isUser: isUser,
      isLoading: anniversaryProvider.updateloading,
      isEditing: anniversaryProvider.isEditing,
      onEditPressed: () {
        controller.saveAnniversary(context);
      },
    );

  }

  Widget _buildDate(AnniversaryProvider anniversaryProvider) {
    return EditableDateField(
      label: "Date",
      isEditing: anniversaryProvider.isEditing,
      selectedDate: widget.anniversary.date,
      controller: controller.dateController,
      onDateChanged: (newDate) {
        setState(() {
          widget.anniversary.date = newDate;
          controller.dateController.text =
              DateFormat('dd/MM/yyyy').format(newDate);
          final aniyr = DateTime.now().year - newDate.year;
          widget.anniversary.anniversaryYear = aniyr;
          controller.anniversaryYearController.text = aniyr.toString();
        });
      },
    );
  }
  

  Widget _buildPaperType(AnniversaryProvider anniversaryProvider) {
    return CustomEditableDropdown(
      label: "Paper",
      valueListenable: controller.paperIdNotifier,
      items: anniversaryProvider.paperTypes.map(
        (key, value) =>
            MapEntry(key, anniversaryProvider.getPaperTypeDescription(key)),
      ),
      isEditing: anniversaryProvider.isEditing,
      onChanged: (newTypeId) {
        if (newTypeId != null) {
          controller.paperIdNotifier.value = newTypeId;
          widget.anniversary.paperId = newTypeId;
        }
      },
    );
  }

  Widget _buildAnniversaryType(AnniversaryProvider anniversaryProvider) {
    return CustomEditableDropdown(
      label: "Anniversary Type",
      valueListenable: controller.anniversaryTypeNotifier,
      items: anniversaryProvider.anniversaryTypes.map(
        (key, value) => MapEntry(
            key, anniversaryProvider.getAnniversaryTypeDescription(key)),
      ),
      isEditing: anniversaryProvider.isEditing,
      onChanged: (newTypeId) {
        if (newTypeId != null) {
          controller.anniversaryTypeNotifier.value = newTypeId;
          widget.anniversary.anniversaryTypeId = newTypeId;
          // Save changes to the database
        }
      },
    );
  }

  Widget _buildHeaderSection(AnniversaryProvider anniversaryProvider) {
    return Center(
      child: ResponsiveWrapper(
        maxWidth: 800,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
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
                    controller: controller.nameController,
                    label: "Name",
                    maxLines: 1,
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: _buildAnniversaryType(anniversaryProvider)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: buildTextField(
                          isEditing: anniversaryProvider.isEditing,
                          controller: controller.placedByPhoneController,
                          label: 'Placed by Phone',
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: _buildPaperType(anniversaryProvider)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: _buildDate(anniversaryProvider)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: buildTextField(
                            isEditing: anniversaryProvider.isEditing,
                            controller: controller.anniversaryYearController,
                            label: "Anniversary Year",
                            maxLines: 1,
                            enabled: false),
                      ),
                    ],
                  ),
                  buildTextField(
                    isEditing:  anniversaryProvider.isEditing,
                    controller: controller.placedByNameController,
                    label: "Placed by Name",
                  ),
                  buildTextField(
                    isEditing: anniversaryProvider.isEditing,
                    controller: controller.placedByAddressController,
                    label: 'Placed by Address',
                  ),
                  buildTextField(
                    isEditing:  anniversaryProvider.isEditing,
                    controller: controller.friendsController,
                    label: 'Friends',
                  ),
                  buildTextField(
                    isEditing: anniversaryProvider.isEditing,
                    controller: controller.associatesController,
                    label: 'Associates',
                  ),
                  const SizedBox(height: 8.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(AnniversaryProvider anniversaryProvider) {
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
                  isEditing:  anniversaryProvider.isEditing,
                  controller: controller.imageDescriptionController,
                  label: 'Image Description',
                ),
                const SizedBox(height: 8.0),
                _buildImagePicker(anniversaryProvider),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker(AnniversaryProvider anniversaryProvider) {

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
          downloadImage(widget.anniversary.image!, "${controller.anniversary.name}.png");
        }
      },
    );
  }
}
