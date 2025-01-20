import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:punch/controllers/companyDetailContoller.dart';
import 'package:punch/functions/downloadImage.dart';
import 'package:punch/models/myModels/companyModel.dart';
import 'package:punch/models/myModels/userModel.dart';
import 'package:punch/providers/authProvider.dart';
import 'package:punch/providers/companyProvider.dart';
import 'package:punch/widgets/dropDowns/editableDropDown.dart';
import 'package:punch/widgets/inputs/dateFields.dart';
import 'package:punch/widgets/inputs/editableImagePicker.dart';
import 'package:punch/widgets/tabbedScaffold.dart';
import 'package:punch/widgets/text-form-fields/html_form_field_widget.dart';
import 'package:responsive_framework/responsive_wrapper.dart';

class CompanyDetailView extends StatefulWidget {
  Company company;

  CompanyDetailView({
    Key? key,
    required this.company,
  }) : super(key: key);

  @override
  State<CompanyDetailView> createState() => _CompanyDetailViewState();
}

class _CompanyDetailViewState extends State<CompanyDetailView> {
  late CompanyDetailController controller;
  bool isEditing = false;
  @override
  void initState() {
    super.initState();
    controller = CompanyDetailController(
      company: widget.company,
      onUpdate: () {
        setState(() {});
      },
      companyProvider: Provider.of<CompanyProvider>(context, listen: false),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final companyProvider = Provider.of<CompanyProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    final isUser = auth.user?.loginId == UserRole.user;
    return TabbedScaffold(
      tabTitles: const ["Company Details", "Image"],
      tabViews: [
        SingleChildScrollView(child: _buildHeaderSection(companyProvider)),
        SingleChildScrollView(child: _buildImageSection(companyProvider)),
      ],
      isUser: isUser,
      isLoading: companyProvider.updateloading,
      isEditing: companyProvider.isEditing,
      onEditPressed: () {
        controller.saveCompany(context);
      },
    );
  }

  Widget _buildHeaderSection(CompanyProvider companyProvider) {
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
                    isEditing: companyProvider.isEditing,
                    controller: controller.nameController,
                    label: 'Name',
                    maxLines: 1,
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: buildTextField(
                            isEditing: companyProvider.isEditing,
                            controller: controller.companyNoController,
                            label: 'Company Number',
                            maxLines: 1,
                            enabled: false),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: _buildCompanySector(companyProvider)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: _buildDate(companyProvider)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStartDate(companyProvider)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: buildTextField(
                          isEditing: companyProvider.isEditing,
                          controller: controller.faxController,
                          label: 'Fax',
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: buildTextField(
                          isEditing: companyProvider.isEditing,
                          controller: controller.phoneController,
                          label: 'Phone',
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  buildTextField(
                      isEditing: companyProvider.isEditing,
                      controller: controller.emailController,
                      label: 'Email',
                      maxLines: 1),
                  buildTextField(
                    isEditing: companyProvider.isEditing,
                    controller: controller.addressController,
                    label: 'Address',
                  ),
                  buildTextField(
                    isEditing: companyProvider.isEditing,
                    controller: controller.managingDirectorController,
                    label: 'Managing Director',
                  ),
                  buildTextField(
                    isEditing: companyProvider.isEditing,
                    controller: controller.corporateAffairsController,
                    label: 'Corporate Affairs',
                  ),
                  buildTextField(
                    isEditing: companyProvider.isEditing,
                    controller: controller.mediaManagerController,
                    label: 'Media Manager',
                  ),
                  buildTextField(
                    isEditing: companyProvider.isEditing,
                    controller: controller.friendsController,
                    label: 'Friends',
                  ),
                  buildTextField(
                    isEditing: companyProvider.isEditing,
                    controller: controller.competitorsController,
                    label: 'Competitors',
                  ),
                  buildTextField(
                    isEditing: companyProvider.isEditing,
                    controller: controller.directorsController,
                    label: 'Directors',
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

  Widget _buildCompanySector(CompanyProvider companyProvider) {
    return CustomEditableDropdown(
      label: 'Company Sector',
      valueListenable: controller.companySectorTypeNotifier,
      items: companyProvider.companySectors.map(
        (key, value) =>
            MapEntry(key, companyProvider.getCompanySectorDescription(key)),
      ),
      isEditing: companyProvider.isEditing,
      onChanged: (int? newTypeId) {
        if (newTypeId != null) {
          controller.companySectorTypeNotifier.value = newTypeId;
          widget.company.companySectorId = newTypeId;
        }
      },
    );
  }

  Widget _buildDate(CompanyProvider companyProvider) {
    return EditableDateField(
      label: "Date",
      isEditing: companyProvider.isEditing,
      selectedDate: widget.company.date,
      controller: controller.dateController,
      onDateChanged: (newDate) {
        setState(() {
          widget.company.date = newDate;
          controller.dateController.text =
              DateFormat('dd/MM/yyyy').format(newDate);
        });
      },
    );
  }

  Widget _buildStartDate(CompanyProvider companyProvider) {
    return EditableDateField(
      label: "Start Date",
      isEditing: companyProvider.isEditing,
      selectedDate: widget.company.startDate,
      controller: controller.startDateController,
      onDateChanged: (newDate) {
        setState(() {
          widget.company.startDate = newDate;
          controller.startDateController.text =
              DateFormat('dd/MM/yyyy').format(newDate);
        });
      },
    );
  }

  Widget _buildImageSection(CompanyProvider companyProvider) {
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
                  isEditing: companyProvider.isEditing,
                  controller: controller.imageDescriptionController,
                  label: 'Image Description',
                ),
                const SizedBox(height: 8.0),
                _buildImagePicker(companyProvider),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker(CompanyProvider companyProvider) {
    return EditableImagePicker(
      label: "Image",
      isEditing: companyProvider.isEditing,
      image: widget.company.image,
      onPickImage: companyProvider.pickImage,
      onImageChanged: (newImage) {
        setState(() {
          widget.company.image = newImage;
        });
      },
      onRemoveImage: () {
        setState(() {
          widget.company.image = null;
          companyProvider.compressedImage = null;
        });
      },
      onDownloadImage: () {
        if (widget.company.image != null) {
          downloadImage(
              widget.company.image!, "${controller.company.name}.png");
        }
      },
    );
  }
}
