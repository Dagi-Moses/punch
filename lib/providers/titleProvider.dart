
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:punch/models/myModels/titleModel.dart';
import 'package:punch/src/const.dart';



class TitleProvider with ChangeNotifier {
 TitleProvider() {
  
    fetchTitles();
  }

  Map<int, String> _titles = {}; // Map to store type descriptions
  Map<int, String> get titles => _titles;

  Future<void> fetchTitles() async {
    try {
      final response = await http.get(Uri.parse(Const.titleUrl));

      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);

        for (var item in jsonData) {
          var titles = Titles.fromJson(item);
          _titles[titles.titleId] = titles.description;
        }

        
        notifyListeners();
      } else {
        throw Exception(response.body);
      }
    } catch (error) {
    
      print('Error fetching title: $error');
    }
  }


  String getClientTitleDescription(int? typeId) {
    return _titles[typeId] ?? 'Unknown';
  }

  Future<void> addTitle(TextEditingController descriptionController) async {
    if (descriptionController.text.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse(Const.titleUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'Description': descriptionController.text}),
      );

      if (response.statusCode == 201) {
        fetchTitles();
        descriptionController.clear();
      } else {
        throw Exception(response.body);
      }
    } catch (error) {
      print('Error adding title: $error');
    }
  }

  Future<void> updateTitle(
    int id,
    TextEditingController descriptionController,
    void Function() clearSelectedType,
  ) async {
    if (descriptionController.text.isEmpty) return;

    try {
      final response = await http.patch(
        Uri.parse("${Const.titleUrl}/$id"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'Description': descriptionController.text}),
      );

      if (response.statusCode == 200) {
        fetchTitles();
        descriptionController.clear();
        clearSelectedType();
      } else {
        throw Exception(response.body);
      }
    } catch (error) {
      print('Error updating title: $error');
    }
  }

  Future<void> deleteTitle(BuildContext context, int titleId) async {
    try {
      final response = await http.delete(
        Uri.parse('${Const.titleUrl}/$titleId'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        await titles.remove(titleId);
        notifyListeners();
        Navigator.pop(context);

        print('title deleted successfully');
      } else {
        throw Exception('Failed to title: ${response.body}');
      }
    } catch (error) {
      print('Error deleting title: $error');
      // Handle exceptions here
    }
  }

}

