import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:punch/models/myModels/anniversary/oldAnniversaryModel.dart';
import 'package:punch/models/myModels/staff.dart';
import 'package:punch/providers/staffprovider.dart';

import 'package:punch/utils/html%20handler.dart';

class StaffDetailController {
  final Staff staff;
  final StaffProvider staffProvider;

  // Text Controllers
  late TextEditingController lastNameController = TextEditingController();
  late TextEditingController firstNameController = TextEditingController();
  late TextEditingController middleNameController = TextEditingController();
  late TextEditingController dateOfBirthController = TextEditingController();
  late TextEditingController townOfOriginController = TextEditingController();
  late TextEditingController stateOfOriginController = TextEditingController();
  late TextEditingController localGovernmentAreaController =TextEditingController();
  late TextEditingController formerLastNameController = TextEditingController();
  late TextEditingController noOfChildrenController = TextEditingController();
  late TextEditingController targetController = TextEditingController();
  late TextEditingController ageController = TextEditingController();

  // Value Notifiers
  late ValueNotifier<String?> sexNotifier;
  late ValueNotifier<String?> healthStatusNotifier;
  late ValueNotifier<String?> nationalityNotifier;
  late ValueNotifier<String?> religionNotifier;
  late ValueNotifier<int?> typeNotifier;
  late ValueNotifier<int?> levelNotifier;
  late ValueNotifier<int?> titleNotifier;
  late ValueNotifier<int?> maritalStatusNotifier;

  StaffDetailController({
    required this.staff,
    required this.staffProvider,
  }) {
    // Initialize TextEditingControllers
    lastNameController = TextEditingController(text: staff.lastName ?? "");
    firstNameController = TextEditingController(text: staff.firstName ?? "");
    middleNameController = TextEditingController(text: staff.middleName ?? "");
    dateOfBirthController = TextEditingController(
      text: staff.dateOfBirth != null
          ? DateFormat('dd/MM/yyyy').format(staff.dateOfBirth!)
          : 'N/A',
    );
    townOfOriginController =
        TextEditingController(text: staff.townOfOrigin ?? "");
    stateOfOriginController =
        TextEditingController(text: staff.stateOfOrigin ?? "");
    localGovernmentAreaController =
        TextEditingController(text: staff.localGovernmentArea ?? "");
    formerLastNameController =
        TextEditingController(text: staff.formerLastName ?? "");
    noOfChildrenController =
        TextEditingController(text: staff.numberOfChildren?.toString() ?? "");
    targetController =
        TextEditingController(text: staff.target?.toString() ?? "");
    ageController =
        TextEditingController(text: staff.age?.toString() ?? "");

    // Initialize ValueNotifiers
    sexNotifier = ValueNotifier<String?>(staff.sex);
    healthStatusNotifier = ValueNotifier<String?>(staff.healthStatus);
    nationalityNotifier = ValueNotifier<String?>(staff.nationality);
    religionNotifier = ValueNotifier<String?>(staff.religion);
    typeNotifier = ValueNotifier<int?>(staff.type);
    levelNotifier = ValueNotifier<int?>(staff.level);
    titleNotifier = ValueNotifier<int?>(staff.title);
    maritalStatusNotifier = ValueNotifier<int?>(staff.maritalStatus);
  }

  Future<void> saveStaff(BuildContext context) async {
    if (staffProvider.isEditing) {
      DateTime? selectedDate;

      try {
        selectedDate =
            DateFormat('dd/MM/yyyy').parse(dateOfBirthController.text);
      } catch (e) {
        print("Error parsing date: $e");
      }

      Staff updatedStaff = Staff(
          id: staff.id,
          dateOfBirth: selectedDate,
          firstName: firstNameController.text,
          staffNo: staff.staffNo,
          formerLastName: firstNameController.text,
          healthStatus: healthStatusNotifier.value,
          lastName: lastNameController.text,
          level: levelNotifier.value,
          localGovernmentArea: localGovernmentAreaController.text,
          maritalStatus: maritalStatusNotifier.value,
          middleName: middleNameController.text,
          nationality: nationalityNotifier.value,
          numberOfChildren:int.tryParse(noOfChildrenController.text),   
          religion: religionNotifier.value,
          sex: sexNotifier.value,
          stateOfOrigin: stateOfOriginController.text,
          target: double.tryParse(targetController.text),
          title: titleNotifier.value,
          townOfOrigin: townOfOriginController.text
          ,
          type: typeNotifier.value
          );

      await staffProvider.updateStaff(updatedStaff, context);
      staffProvider.isEditing = false;
    } else {
      staffProvider.isEditing = true;
    }
  }


  void dispose() {
    lastNameController.dispose();
    firstNameController.dispose();
    middleNameController.dispose();
    dateOfBirthController.dispose();
    townOfOriginController.dispose();
    stateOfOriginController.dispose();
    localGovernmentAreaController.dispose();
    formerLastNameController.dispose();
    noOfChildrenController.dispose();
    targetController.dispose();
    sexNotifier.dispose();
    healthStatusNotifier.dispose();
    nationalityNotifier.dispose();
    religionNotifier.dispose();
    typeNotifier.dispose();
    levelNotifier.dispose();
    titleNotifier.dispose();
    maritalStatusNotifier.dispose();

   
  }

}
