// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:punch/controllers/anniversaryDetailController.dart';
// import 'package:punch/controllers/staffDetailContoller.dart';
// import 'package:punch/models/myModels/userModel.dart';
// import 'package:punch/models/myModels/staff.dart';
// import 'package:punch/providers/anniversaryProvider.dart';
// import 'package:punch/providers/authProvider.dart';
// import 'package:punch/providers/healthStatusprovider.dart';
// import 'package:punch/providers/nationalityProvider.dart';
// import 'package:punch/providers/sexProvider.dart';
// import 'package:punch/providers/staffprovider.dart';
// import 'package:punch/widgets/dropDowns/editableDropDown.dart';
// import 'package:punch/widgets/inputs/dateFields.dart';
// import 'package:punch/widgets/tabbedScaffold.dart';
// import 'package:punch/widgets/text-form-fields/html_form_field_widget.dart';
// import 'package:responsive_framework/responsive_framework.dart';

// class StaffDetailView extends StatefulWidget {
//   Staff staff;

//   StaffDetailView({
//     Key? key,
//     required this.staff,
//   }) : super(key: key);

//   @override
//   State<StaffDetailView> createState() => _StaffDetailViewState();
// }

// class _StaffDetailViewState extends State<StaffDetailView> {
//   late StaffDetailController controller;

//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final staffProvider = Provider.of<StaffProvider>(context);
//     controller = StaffDetailController(
//         staff: widget.staff, staffProvider: staffProvider);
//     final auth = Provider.of<AuthProvider>(context);
//     final isUser = auth.user?.loginId == UserRole.user;
//     return TabbedScaffold(
//       tabTitles: const ["Staff Details"],
//       tabViews: [
//         SingleChildScrollView(child: _buildHeaderSection(staffProvider)),
//       ],
//       isUser: isUser,
//       isLoading: staffProvider.updateloading,
//       isEditing: staffProvider.isEditing,
//       onEditPressed: () {
//         controller.saveStaff(context);
//       },
//     );
//   }

//   Widget _buildDate(StaffProvider staffProvider) {
//     return EditableDateField(
//       label: "Date Of Birth",
//       isEditing: staffProvider.isEditing,
//       selectedDate: widget.staff.dateOfBirth,
//       controller: controller.dateOfBirthController,
//       onDateChanged: (newDate) {
//         setState(() {
//           widget.staff.dateOfBirth = newDate;
//           controller.dateOfBirthController.text =
//               DateFormat('dd/MM/yyyy').format(newDate);
//           final aniyr = DateTime.now().year - newDate.year;
//           widget.staff.age = aniyr;
//           controller.ageController.text = aniyr.toString();
//         });
//       },
//     );
//   }
 
    

//     // religionNotifier 
//     // typeNotifier 
//     // levelNotifier 
//     // titleNotifier 
//     // maritalStatusNotifier 

//   Widget _buildSex(StaffProvider staffProvider) {
//     final sexProvider = Provider.of<SexProvider>(context);
//     return CustomEditableDropdown(
//       label: "Gender",
//       valueListenable: controller.sexNotifier,
//       items: sexProvider.sexes.map(
//         (key, value) => MapEntry(key, sexProvider.getSexGender(key)),
//       ),
//       isEditing: staffProvider.isEditing,
//       onChanged: (newTypeId) {
//         if (newTypeId != null) {
//           controller.sexNotifier.value = newTypeId;
//           widget.staff.sex = newTypeId;
//         }
//       },
//     );
//   }
//   Widget _buildHealthStatus(StaffProvider staffProvider) {
//     final healthProvider = Provider.of<HealthStatusProvider>(context);
//     return CustomEditableDropdown(
//       label: "Health Status",
//       valueListenable: controller.healthStatusNotifier,
//       items: healthProvider.healthStatuses.map(
//         (key, value) => MapEntry(key, healthProvider.getHealthStatus(key)),
//       ),
//       isEditing: staffProvider.isEditing,
//       onChanged: (newTypeId) {
//         if (newTypeId != null) {
//           controller.healthStatusNotifier.value = newTypeId;
//           widget.staff.healthStatus = newTypeId;
//         }
//       },
//     );
//   }

//   Widget _buildNationality(StaffProvider staffProvider) {
//     final nationalityProvider = Provider.of<NationalityProvider>(context);
//     return CustomEditableDropdown(
//       label: "Nationality",
//       valueListenable: controller.nationalityNotifier,
//       items: nationalityProvider.nationalities.map(
//         (key, value) => MapEntry(key, nationalityProvider.getCountry(key)),
//       ),
//       isEditing: staffProvider.isEditing,
//       onChanged: (newTypeId) {
//         if (newTypeId != null) {
//           controller.nationalityNotifier.value = newTypeId;
//           widget.staff.nationality = newTypeId;
//         }
//       },
//     );
//   }

  

//   Widget _buildHeaderSection(AnniversaryProvider anniversaryProvider) {
//     return Center(
//       child: ResponsiveWrapper(
//         maxWidth: 800,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 16),
//           child: Card(
//             elevation: 4.0,
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   buildTextField(
//                     isEditing: anniversaryProvider.isEditing,
//                     controller: controller.nameController,
//                     label: "Name",
//                     maxLines: 1,
//                   ),
//                   const SizedBox(height: 8.0),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                           child: _buildAnniversaryType(anniversaryProvider)),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: buildTextField(
//                           isEditing: anniversaryProvider.isEditing,
//                           controller: controller.placedByPhoneController,
//                           label: 'Placed by Phone',
//                           maxLines: 1,
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(child: _buildPaperType(anniversaryProvider)),
//                     ],
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(child: _buildDate(anniversaryProvider)),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: buildTextField(
//                             isEditing: anniversaryProvider.isEditing,
//                             controller: controller.anniversaryYearController,
//                             label: "Anniversary Year",
//                             maxLines: 1,
//                             enabled: false),
//                       ),
//                     ],
//                   ),
//                   buildTextField(
//                     isEditing: anniversaryProvider.isEditing,
//                     controller: controller.placedByNameController,
//                     label: "Placed by Name",
//                   ),
//                   buildTextField(
//                     isEditing: anniversaryProvider.isEditing,
//                     controller: controller.placedByAddressController,
//                     label: 'Placed by Address',
//                   ),
//                   buildTextField(
//                     isEditing: anniversaryProvider.isEditing,
//                     controller: controller.friendsController,
//                     label: 'Friends',
//                   ),
//                   buildTextField(
//                     isEditing: anniversaryProvider.isEditing,
//                     controller: controller.associatesController,
//                     label: 'Associates',
//                   ),
//                   const SizedBox(height: 8.0),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
