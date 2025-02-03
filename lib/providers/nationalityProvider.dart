import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:punch/models/myModels/country.dart';
import 'package:punch/src/const.dart';

class NationalityProvider with ChangeNotifier {
  NationalityProvider() {
    fetchNationalities();
  }

  Map<String, String> _nationalities = {}; 
  Map<String, String> get nationalities => _nationalities;

  Future<void> fetchNationalities() async {
    try {
      final response = await http.get(Uri.parse(Const.nationalityUrl));

      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);

        for (var item in jsonData) {
          var nationalities = Country.fromJson(item);
          _nationalities[nationalities.countryCode] = nationalities.country;
        }

        notifyListeners();
      } else {
        throw Exception(response.body);
      }
    } catch (error) {
      print('Error fetching title: $error');
    }
  }

  String getCountry(String? countryCode) {
    return _nationalities[countryCode] ?? 'Unknown';
  }

  Future<void> addCountry(Country sex) async {
    if (sex.country.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse(Const.nationalityUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(sex.toJson()),
      );

      if (response.statusCode == 201) {
        fetchNationalities();
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

  Future<void> deleteSex(BuildContext context, String countryCode) async {
    try {
      final response = await http.delete(
        Uri.parse('${Const.nationalityUrl}/$countryCode'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        await nationalities.remove(countryCode);
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
