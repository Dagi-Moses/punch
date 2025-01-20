import 'package:flutter/material.dart';

class TextControllerNotifier extends ChangeNotifier {
  TextEditingController descriptionController = TextEditingController();
  int? _selectedId;

  String get descriptionText => descriptionController.text;
  int? get selectedId => _selectedId;

  set selectedId(int? id) {
    _selectedId = id;
    notifyListeners();
  }

  TextControllerNotifier() {
    descriptionController.addListener(() {
      // Notify listeners whenever the text changes
      notifyListeners();
    });
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  void clearSelection() {
    _selectedId = null;
    descriptionController.clear();
    notifyListeners();
  }
}
