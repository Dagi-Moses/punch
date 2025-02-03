import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:punch/models/myModels/healthStatus.dart';
import 'package:punch/models/myModels/sex.dart';

import 'package:punch/src/const.dart';

class HealthStatusProvider with ChangeNotifier {
  HealthStatusProvider() {
    fetchHealthStatuses();
  }

  Map<String, String> _healthStatuses = {}; // Map to store type descriptions
  Map<String, String> get healthStatuses => _healthStatuses;

  Future<void> fetchHealthStatuses() async {
    try {
      final response = await http.get(Uri.parse(Const. healthStatusUrl));

      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);

        for (var item in jsonData) {
          var healthStatuses = HealthStatus.fromJson(item);
          _healthStatuses[healthStatuses.statusCode] = healthStatuses.healthStatus;
        }

        notifyListeners();
      } else {
        throw Exception(response.body);
      }
    } catch (error) {
      print('Error fetching title: $error');
    }
  }

  String getHealthStatus(String? statusCode) {
    return _healthStatuses[statusCode] ?? 'Unknown';
  }

  Future<void> addSex(HealthStatus sex) async {
    if (sex.healthStatus.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse(Const.sexUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(sex.toJson()),
      );

      if (response.statusCode == 201) {
        fetchHealthStatuses();
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

  Future<void> deleteSex(BuildContext context, String statusCode) async {
    try {
      final response = await http.delete(
        Uri.parse('${Const.sexUrl}/$statusCode'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        await healthStatuses.remove(statusCode);
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
