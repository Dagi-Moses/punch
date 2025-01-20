import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:punch/models/myModels/anniversaryModel.dart';
import 'package:punch/providers/anniversaryProvider.dart';
import 'package:punch/utils/html%20handler.dart';

class AnniversaryDetailController {
  final Anniversary anniversary;
  final AnniversaryProvider anniversaryProvider;
  // Text Controllers
  late TextEditingController nameController;
  late TextEditingController placedByNameController;
  late TextEditingController placedByAddressController;
  late TextEditingController placedByPhoneController;
  late TextEditingController friendsController;
  late TextEditingController associatesController;
  late TextEditingController anniversaryYearController;
  late TextEditingController dateController;
  late TextEditingController imageDescriptionController;

  // Value Notifiers
 
  late ValueNotifier<int?> anniversaryTypeNotifier;
  late ValueNotifier<int?> paperIdNotifier;

  // Html Handlers
  late HtmlTextHandler associatesHandler;
  late HtmlTextHandler placedByHandler;
  late HtmlTextHandler friendsHandler;
  late HtmlTextHandler descriptionHandler;

  AnniversaryDetailController({
    required this.anniversary,
    
    required this.anniversaryProvider,
  }) {
    // Initialize TextEditingControllers
    nameController = TextEditingController(text: anniversary.name ?? "");
    imageDescriptionController = TextEditingController(
        text: _convertHtmlToText(anniversary.description ?? ""));
    placedByNameController = TextEditingController(
        text: _convertHtmlToText(anniversary.placedByName ?? ""));
    placedByAddressController =
        TextEditingController(text: anniversary.placedByAddress ?? "");
    placedByPhoneController =
        TextEditingController(text: anniversary.placedByPhone ?? "");
    friendsController = TextEditingController(
        text: _convertHtmlToText(anniversary.friends ?? ""));
    associatesController = TextEditingController(
        text: _convertHtmlToText(anniversary.associates ?? ""));
    anniversaryYearController =
        TextEditingController(text: anniversary.anniversaryYear.toString());
    dateController = TextEditingController(
      text: anniversary.date != null
          ? DateFormat('dd/MM/yyyy').format(anniversary.date!)
          : 'N/A',
    );

    // Initialize ValueNotifiers
    anniversaryTypeNotifier =
        ValueNotifier<int?>(anniversary.anniversaryTypeId);
    paperIdNotifier = ValueNotifier<int?>(anniversary.paperId);

    // Initialize Html Handlers
    associatesHandler = HtmlTextHandler(
      controller: associatesController,
      onTextChanged: (text) {
        anniversary.associates = text;
      
      },
      initialText: associatesController.text,
    );

    placedByHandler = HtmlTextHandler(
      controller: placedByNameController,
      onTextChanged: (text) {
        anniversary.placedByName = text;
       
      },
      initialText: placedByNameController.text,
    );

    friendsHandler = HtmlTextHandler(
      controller: friendsController,
      onTextChanged: (text) {
        anniversary.friends = text;
       
      },
      initialText: friendsController.text,
    );

    descriptionHandler = HtmlTextHandler(
      controller: imageDescriptionController,
      onTextChanged: (text) {
        anniversary.description = text;
    
      },
      initialText: imageDescriptionController.text,
    );
  }

// Toggle editing mode
 

  // Handle saving updated anniversary
  Future<void> saveAnniversary(BuildContext context) async {
    if (anniversaryProvider.isEditing) {
      DateTime? selectedDate;

      try {
        selectedDate = DateFormat('dd/MM/yyyy').parse(dateController.text);
      } catch (e) {
        // Handle parsing error
        print("Error parsing date: $e");
      }

      Anniversary updatedAnniversary = Anniversary(
          id: anniversary.id,
          anniversaryNo: anniversary.anniversaryNo,
          name: nameController.text,
          placedByName: placedByNameController.text.replaceAll('\n', '<br>'),
          description: imageDescriptionController.text.replaceAll('\n', '<br>'),
          placedByAddress: placedByAddressController.text,
          placedByPhone: placedByPhoneController.text,
          friends: friendsController.text.replaceAll('\n', '<br>'),
          associates: associatesController.text.replaceAll('\n', '<br>'),
          anniversaryYear: int.tryParse(anniversaryYearController.text),
          paperId: paperIdNotifier.value,
          date: selectedDate,
          anniversaryTypeId: anniversaryTypeNotifier.value,
          image: anniversaryProvider.compressedImage);

      await anniversaryProvider.updateAnniversary(updatedAnniversary, context);
       anniversaryProvider.isEditing = false;
    

    }else{
       anniversaryProvider.isEditing = true;
    
    }
  }

  // Method to dispose of resources
  void dispose() {
    nameController.dispose();
    placedByNameController.dispose();
    placedByAddressController.dispose();
    placedByPhoneController.dispose();
    friendsController.dispose();
    associatesController.dispose();
    anniversaryYearController.dispose();
    dateController.dispose();
    imageDescriptionController.dispose();
    anniversaryTypeNotifier.dispose();
    paperIdNotifier.dispose();
  }
}

String _convertHtmlToText(String htmlText) {
  return htmlText.replaceAll(RegExp(r'<br\s*/?>'), '\n');
}
