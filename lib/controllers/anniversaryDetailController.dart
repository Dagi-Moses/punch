import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:punch/models/myModels/anniversary/anniversaryModel.dart';
import 'package:punch/models/myModels/anniversary/placedBy.dart';
import 'package:punch/providers/anniversaryProvider.dart';
import 'package:punch/utils/html%20handler.dart';

class AnniversaryDetailController extends ChangeNotifier {
  Anniversary anniversary;
  final AnniversaryProvider anniversaryProvider;
  final formKey = GlobalKey<FormState>();

  late TextEditingController placedByNameController;
  late TextEditingController placedByAddressController;
  late TextEditingController placedByPhoneController;
  late TextEditingController nameController;
  late TextEditingController anniversaryYearController;
  late TextEditingController dateController;
  late TextEditingController imageDescriptionController;

  int? selectedPaperId;
  DateTime? selectedDate;
  List<DateTime> availableDates = [];
  PlacedBy? selectedPlacedBy;
  List<PlacedBy>? placedBys = [];
  List<String>? friends = [];
  List<String>? associates = [];

  // Value Notifiers
  late ValueNotifier<int?> anniversaryTypeNotifier;

  //text handlers
  late HtmlTextHandler descriptionHandler;

  void initializeSelectedValues() {
    if (placedBys != null && placedBys!.isNotEmpty) {
      final validPlacedBy = placedBys!
          .where((item) => item.paperId != null && item.date != null)
          .toList();
      if (validPlacedBy.isNotEmpty) {
        validPlacedBy.sort((a, b) {
          return b.date!.compareTo(a.date!);
        });

        final latestPlacedBy = validPlacedBy.first;

        selectedPaperId = latestPlacedBy.paperId;
        selectedDate = latestPlacedBy.date;
        initSelectPaper(selectedPaperId!);
        selectDate(selectedDate!);
      } else {
        print("No valid placedBy entries found.");
      }
    } else {
      print("placedBy is null or empty.");
    }
  }

  AnniversaryDetailController({
    required this.anniversary,
    required this.anniversaryProvider,
  }) {
    nameController = TextEditingController(text: anniversary.name ?? "");
    placedBys = anniversary.placedBy;
    friends = anniversary.friends;
    associates = anniversary.associates;
    imageDescriptionController = TextEditingController(
        text: _convertHtmlToText(anniversary.description ?? ""));
    anniversaryYearController =
        TextEditingController(text: anniversary.anniversaryYear.toString());
    dateController = TextEditingController(
        text: anniversary.date != null
            ? DateFormat('dd/MM/yyyy').format(anniversary.date!)
            : "N/A");
    anniversaryTypeNotifier =
        ValueNotifier<int?>(anniversary.anniversaryTypeId);

    placedByNameController =
        TextEditingController(text: selectedPlacedBy?.placedByName ?? "");
    placedByAddressController =
        TextEditingController(text: selectedPlacedBy?.placedByAddress ?? "");
    placedByPhoneController =
        TextEditingController(text: selectedPlacedBy?.placedByPhone ?? "");

    placedByNameController.addListener(() {
      if (selectedPlacedBy != null) {
        // First, update selectedPlacedBy
        selectedPlacedBy = selectedPlacedBy!.copyWith(
          placedByName: placedByNameController.text,
        );

        // Then, update the corresponding item in the list
        int index =
            placedBys?.indexWhere((p) => p.id == selectedPlacedBy!.id) ?? -1;
        if (index != -1) {
          placedBys![index] = selectedPlacedBy!;
          notifyListeners();
        }
      }
    });

    placedByPhoneController.addListener(() {
      if (selectedPlacedBy != null) {
        // Update selectedPlacedBy
        selectedPlacedBy = selectedPlacedBy!.copyWith(
          placedByPhone: placedByPhoneController.text,
        );

        // Update the list
        int index =
            placedBys?.indexWhere((p) => p.id == selectedPlacedBy!.id) ?? -1;
        if (index != -1) {
          placedBys![index] = selectedPlacedBy!;
          notifyListeners();
        }
      }
    });

    placedByAddressController.addListener(() {
      if (selectedPlacedBy != null) {
        // Update selectedPlacedBy
        selectedPlacedBy = selectedPlacedBy!.copyWith(
          placedByAddress: placedByAddressController.text,
        );

        // Update the list
        int index =
            placedBys?.indexWhere((p) => p.id == selectedPlacedBy!.id) ?? -1;
        if (index != -1) {
          placedBys![index] = selectedPlacedBy!;
          notifyListeners();
        }
      }
    });

    descriptionHandler = HtmlTextHandler(
      controller: imageDescriptionController,
      onTextChanged: (text) {
        anniversary.description = text;
      },
      initialText: imageDescriptionController.text,
    );

    initializeSelectedValues();
    //  initializeSelectedValues();
  }

  Future<void> saveAnniversary(BuildContext context) async {
    if (anniversaryProvider.isEditing) {
       if (!formKey.currentState!.validate()) {
        // If any field fails validation, return early and don't save
        print("Validation failed");
        return;
      }

      
      DateTime? selectedDate;
      try {
        selectedDate = DateFormat('dd/MM/yyyy').parse(dateController.text);
      } catch (e) {}
      Anniversary updatedAnniversary = Anniversary(
          id: anniversary.id,
          anniversaryNo: anniversary.anniversaryNo,
          name: nameController.text,
          placedBy: placedBys,
          description: imageDescriptionController.text.replaceAll('\n', '<br>'),
          friends: friends,
          associates: associates,
          date: selectedDate,
          anniversaryTypeId: anniversaryTypeNotifier.value,
          image: anniversaryProvider.compressedImage);

      await anniversaryProvider.updateAnniversary(updatedAnniversary, context,
          () {
        anniversary = updatedAnniversary;
      });
      anniversaryProvider.isEditing = false;
    } else {
      anniversaryProvider.isEditing = true;
    }
  }

  void selectPaper(int paperId) {
    selectedPaperId = paperId;
    availableDates = placedBys!
        .where((placedBy) => placedBy.paperId == paperId)
        .map((placedBy) => placedBy.date!)
        .toSet()
        .toList();
    DateTime? mostRecentDate = availableDates.isNotEmpty
        ? availableDates.reduce((a, b) => a.isAfter(b) ? a : b)
        : null;

    selectDate(mostRecentDate);
    notifyListeners();
  }

  void initSelectPaper(int paperId) {
    selectedPaperId = paperId;
    availableDates = placedBys!
        .where((placedBy) => placedBy.paperId == paperId)
        .map((placedBy) => placedBy.date!)
        .toSet()
        .toList();
    notifyListeners();
  }

  void selectDate(DateTime? date) {
    selectedDate = date;
    selectedPlacedBy = placedBys?.firstWhere(
      (placedBy) =>
          placedBy.paperId == selectedPaperId && placedBy.date == date,
      orElse: () => PlacedBy(),
    );
    placedByNameController.text = selectedPlacedBy!.placedByName ?? "";
    placedByAddressController.text = selectedPlacedBy!.placedByAddress ?? "";
    placedByPhoneController.text = selectedPlacedBy!.placedByPhone ?? "";
    notifyListeners();
  }

  void selectPlacedBy(int index) {
    if (index >= 0 && index < placedBys!.length) {
      selectedPlacedBy = placedBys![index];
    } else {
      selectedPlacedBy = null;
    }
    notifyListeners();
  }

// Update the currently selected PlacedBy record, including Paper ID
 void updateSelectedPlacedBy({
    String? name,
    String? address,
    String? phone,
    int? newPaperId,
    DateTime? newDate,
  }) {
    if (selectedPlacedBy != null) {
      // Update selectedPlacedBy with new values
      selectedPlacedBy = selectedPlacedBy!.copyWith(
        placedByName: name ?? selectedPlacedBy!.placedByName,
        placedByAddress: address ?? selectedPlacedBy!.placedByAddress,
        placedByPhone: phone ?? selectedPlacedBy!.placedByPhone,
        paperId: newPaperId ?? selectedPlacedBy!.paperId,
        date: newDate ?? selectedPlacedBy!.date, // Update the date
      );

      // Ensure placedBys is not null
      if (placedBys != null) {
        int index = placedBys!
            .indexWhere((placedBy) => placedBy.id == selectedPlacedBy!.id);
        if (index != -1) {
          placedBys![index] =
              selectedPlacedBy!; // Update the placedBy record in the list
          print('Updated PlacedBy: ${placedBys![index].toMap()}');
        } else {
          print('PlacedBy record not found for update.');
        }
      }

      // Notify listeners so UI can be updated
      notifyListeners();
    } else {
      print('No selectedPlacedBy to update.');
    }
  }

  void deleteSelectedPlacedBy() {
    if (selectedPlacedBy != null) {
      placedBys?.remove(selectedPlacedBy);
      selectedPlacedBy = null;
      notifyListeners();
    }
  }

  void addNewPlacedBy(DateTime date) async {
    PlacedBy newPlacedBy = PlacedBy(
      paperId: selectedPaperId,
      date: date,
      placedByName: "",
      placedByAddress: "",
      placedByPhone: "",
    );
    placedBys!.add(newPlacedBy);

    selectDate(date);
    notifyListeners();
  }

  void addFriend(String friend) {
    friends ??= [];
    if (!friends!.contains(friend)) {
      friends!.add(friend);
    }

    notifyListeners();
  }

  void editFriend(String oldFriend, String newFriend) {
    if (friends!.contains(oldFriend)) {
      int index = friends!.indexOf(oldFriend);
      friends![index] = newFriend;

      notifyListeners();
    }
  }

  void deleteFriend(String friend) {
    friends?.remove(friend);

    notifyListeners();
  }

  void addAssociate(String associate) {
    associates ??= [];
    if (!associates!.contains(associate)) {
      associates!.add(associate);
    }
    notifyListeners();
  }

  void editAssociate(String oldAssociate, String newAssociate) {
    if (associates!.contains(oldAssociate)) {
      int index = associates!.indexOf(oldAssociate);
      associates![index] = newAssociate;

      notifyListeners();
    }
  }

  void deleteAssociate(String associate) {
    associates?.remove(associate);
    notifyListeners();
  }

  // Method to dispose of resources
  void dispose() {
    super.dispose();
    nameController.dispose();
    anniversaryYearController.dispose();
    dateController.dispose();
    imageDescriptionController.dispose();
    anniversaryTypeNotifier.dispose();
  }
}

String _convertHtmlToText(String htmlText) {
  return htmlText.replaceAll(RegExp(r'<br\s*/?>'), '\n');
}
