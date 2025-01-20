import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:punch/models/myModels/companyExtraModel.dart';

import 'package:punch/models/myModels/companyModel.dart';
import 'package:punch/providers/companyProvider.dart';
import 'package:punch/utils/html%20handler.dart';

class CompanyDetailController {
  final Company company;
  final CompanyProvider companyProvider;

  // Text Controllers
  late TextEditingController nameController;
  late TextEditingController dateController;
  late TextEditingController addressController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController faxController;
  late TextEditingController startDateController;
  late TextEditingController managingDirectorController;
  late TextEditingController corporateAffairsController;
  late TextEditingController mediaManagerController;
  late TextEditingController friendsController;
  late TextEditingController competitorsController;
  late TextEditingController directorsController;
  late TextEditingController imageDescriptionController;
  late TextEditingController companyNoController;

  // Value Notifiers
  late ValueNotifier<int?> companySectorTypeNotifier;

  // HTML Handlers
  late HtmlTextHandler managingDirectorHandler;
  late HtmlTextHandler corporateAffairsHandler;
  late HtmlTextHandler mediaManagerHandler;
  late HtmlTextHandler friendsHandler;
  late HtmlTextHandler competitorsHandler;
  late HtmlTextHandler directorsHandler;
  late HtmlTextHandler descriptionHandler;
  // Company Extra
  CompanyExtra? companyExtra;

  CompanyDetailController({
    required this.company,
    required VoidCallback onUpdate,
    required this.companyProvider,
  }) {
 init(onUpdate);
  }
  void init(VoidCallback onUpdate)async{
    _initializeControllers();
   await _fetchCompanyExtra(onUpdate);
    _initializeHtmlHandlers(onUpdate);
    
  }

  void _initializeControllers() {
    companyNoController = TextEditingController(text: company.companyNo.toString());
    imageDescriptionController = TextEditingController(
        text: _convertHtmlToText(company.description ?? ""));
    nameController =
        TextEditingController(text: _convertHtmlToText(company.name ?? ""));
    dateController = TextEditingController(
      text: company.date != null
          ? DateFormat('dd/MM/yyyy').format(company.date!)
          : 'N/A',
    );
    addressController =
        TextEditingController(text: _convertHtmlToText(company.address ?? ""));
    emailController =
        TextEditingController(text: _convertHtmlToText(company.email ?? ""));
    phoneController =
        TextEditingController(text: _convertHtmlToText(company.phone ?? ""));
    faxController =
        TextEditingController(text: _convertHtmlToText(company.fax ?? ""));
    startDateController = TextEditingController(
      text: company.startDate != null
          ? DateFormat('dd/MM/yyyy').format(company.startDate!)
          : 'N/A',
    );
    managingDirectorController = TextEditingController();
    corporateAffairsController = TextEditingController();
    mediaManagerController = TextEditingController();
    friendsController = TextEditingController();
    competitorsController = TextEditingController();
    directorsController = TextEditingController();

    companySectorTypeNotifier = ValueNotifier(company.companySectorId);
  }

  void _initializeHtmlHandlers(VoidCallback onUpdate) {
    managingDirectorHandler = HtmlTextHandler(
      controller: managingDirectorController,
      onTextChanged: (text) {
        companyExtra?.managingDirector = text;
       
      },
      initialText: managingDirectorController.text
    );

    corporateAffairsHandler = HtmlTextHandler(
      controller: corporateAffairsController,
      onTextChanged: (text) {
        companyExtra?.corporateAffairs = text;
      
      },
      initialText: corporateAffairsController.text
    );

    mediaManagerHandler = HtmlTextHandler(
      controller: mediaManagerController,
      onTextChanged: (text) {
        companyExtra?.mediaManager = text;
      
      },
      initialText: mediaManagerController.text
    );

    friendsHandler = HtmlTextHandler(
      controller: friendsController,
      onTextChanged: (text) {
        companyExtra?.friends = text;
      
      },
      initialText: friendsController.text
    );

    competitorsHandler = HtmlTextHandler(
      controller: competitorsController,
      onTextChanged: (text) {
        companyExtra?.competitors = text;
      
      },
      initialText: competitorsController.text
    );

    directorsHandler = HtmlTextHandler(
      controller: directorsController,
      onTextChanged: (text) {
        companyExtra?.directors = text;
       
      },
      initialText: directorsController.text
    );
    
    descriptionHandler = HtmlTextHandler(
      controller: imageDescriptionController,
      onTextChanged: (text) {
        company.description = text;
      },
      initialText: imageDescriptionController.text,
    );
  }

  Future<void> _fetchCompanyExtra(VoidCallback onUpdate) async {
    companyExtra =
        await companyProvider.getCompanyExtraByCompanyNo(company.companyNo!);
    if (companyExtra != null) {
      managingDirectorController.text =
          _convertHtmlToText(companyExtra?.managingDirector ?? "");
      corporateAffairsController.text =
          _convertHtmlToText(companyExtra?.corporateAffairs ?? "");
      mediaManagerController.text =
          _convertHtmlToText(companyExtra?.mediaManager ?? "");
      friendsController.text = _convertHtmlToText(companyExtra?.friends ?? "");
      competitorsController.text =
          _convertHtmlToText(companyExtra?.competitors ?? "");
      directorsController.text =
          _convertHtmlToText(companyExtra?.directors ?? "");
      onUpdate();
    }
  }

  String _convertHtmlToText(String htmlText) {
    return htmlText.replaceAll(RegExp(r'<br\s*/?>'), '\n');
  }




  // Handle saving updated anniversary
  Future<void> saveCompany(BuildContext context) async {
    if (companyProvider.isEditing) {
      DateTime? selectedDate;
      DateTime? selectedStartDate;

      try {
        if (dateController.text.isNotEmpty) {
          selectedDate =
              DateFormat('dd/MM/yyyy').parse(dateController.text);
        }
      } catch (e) {
        selectedDate = null;
      }

      try {
        if (startDateController.text.isNotEmpty) {
          selectedStartDate = DateFormat('dd/MM/yyyy')
              .parse(startDateController.text);
        }
      } catch (e) {
        selectedStartDate = null;
      }

      Company _company = Company(
        id: company.id,
        companyNo:company.companyNo,
        name: nameController.text,
        address: addressController.text,
        email: emailController.text,
        fax: faxController.text,
        phone: phoneController.text,
        startDate: selectedStartDate,
        date: selectedDate,
        description: imageDescriptionController.text.replaceAll('\n', '<br>'),
         image: companyProvider.compressedImage,
        companySectorId: companySectorTypeNotifier.value,
      );

      CompanyExtra _companyExtra = CompanyExtra(
        companyNo:company.companyNo,
        competitors:competitorsController.text.replaceAll('\n', '<br>'),
        corporateAffairs:corporateAffairsController.text.replaceAll('\n', '<br>'),
        directors: directorsController.text.replaceAll('\n', '<br>'),
        friends: friendsController.text.replaceAll('\n', '<br>'),
        id: companyExtra?.id,
        managingDirector:managingDirectorController.text.replaceAll('\n', '<br>'),
        mediaManager:mediaManagerController.text.replaceAll('\n', '<br>'),
      );

      await companyProvider.updateCompany(_company, _companyExtra, context);
       companyProvider.isEditing = false;
    } else {
      companyProvider.isEditing = true;
     
    }
  }
  void dispose() {
    nameController.dispose();
    dateController.dispose();
    addressController.dispose();
    emailController.dispose();
    phoneController.dispose();
    faxController.dispose();
    startDateController.dispose();
    managingDirectorController.dispose();
    corporateAffairsController.dispose();
    mediaManagerController.dispose();
    friendsController.dispose();
    competitorsController.dispose();
    directorsController.dispose();
    companySectorTypeNotifier.dispose();
  }
}
