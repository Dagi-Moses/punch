import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:punch/models/myModels/sex.dart';

import 'package:punch/src/const.dart';

class SexProvider with ChangeNotifier {
  SexProvider() {
    fetchSexes();
  }

  Map<String, String> _sexes = {}; // Map to store type descriptions
  Map<String, String> get sexes => _sexes;

  

  Future<void> fetchSexes() async {
    try {
      final response = await http.get(Uri.parse(Const.sexUrl));

      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);

        for (var item in jsonData) {
          var sexes = Sex.fromJson(item);
          _sexes[sexes.sexCode] = sexes.gender;
        }

        notifyListeners();
      } else {
        throw Exception(response.body);
      }
    } catch (error) {
      print('Error fetching title: $error');
    }
  }

  String getSexGender(String? sexCode) {
    return _sexes[sexCode] ?? 'Unknown';
  }

  Future<void> addSex(Sex sex) async {
    if (sex.gender.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse(Const.sexUrl),
        headers: {'Content-Type': 'application/json'},
        body:  jsonEncode(sex.toJson()),
      );

      if (response.statusCode == 201) {
        fetchSexes();
        //descriptionController.clear();
      } else {
        throw Exception(response.body);
      }
    } catch (error) {
      print('Error adding title: $error');
    }
  }

  // Future<void> updateTitle(
  //   int id,
  //   TextEditingController descriptionController,
  //   void Function() clearSelectedType,
  // ) async {
  //   if (descriptionController.text.isEmpty) return;

  //   try {
  //     final response = await http.patch(
  //       Uri.parse("${Const.titleUrl}/$id"),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({'Description': descriptionController.text}),
  //     );

  //     if (response.statusCode == 200) {
  //       fetchTitles();
  //       descriptionController.clear();
  //       clearSelectedType();
  //     } else {
  //       throw Exception(response.body);
  //     }
  //   } catch (error) {
  //     print('Error updating title: $error');
  //   }
  // }

  Future<void> deleteSex(BuildContext context, String sexCode) async {
    try {
      final response = await http.delete(
        Uri.parse('${Const.sexUrl}/$sexCode'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        await sexes.remove(sexCode);
        notifyListeners();
        Navigator.pop(context);

        print('sex deleted successfully');
      } else {
        throw Exception('Failed to title: ${response.body}');
      }
    } catch (error) {
      print('Error deleting title: $error');
      // Handle exceptions here
    }
  }
}
