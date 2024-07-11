import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:punch/models/anniversaryModel.dart';

class AnniversaryProvider with ChangeNotifier {
  final String baseUrl = 'http://localhost:3000/anniversaries';
  List<Anniversary> _anniversaries = [];

  List<Anniversary> get anniversaries => _anniversaries;
  AnniversaryProvider() {
   fetchAnniversaries();
  }

  
  Future<void> fetchAnniversaries() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        _anniversaries =
            data.map((json) => Anniversary.fromJson(json)).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to load anniversaries');
      }
    } catch (error) {
      print('Error fetching anniversaries: $error');
      throw error;
    }
  }

  Future<void> addAnniversary(Anniversary anniversary) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(anniversary.toJson()),
      );
      if (response.statusCode == 201) {
        _anniversaries.add(Anniversary.fromJson(jsonDecode(response.body)));
        notifyListeners();
      } else {
        throw Exception('Failed to add anniversary');
      }
    } catch (error) {
      print('Error adding anniversary: $error');
      throw error;
    }
  }

  Future<void> updateAnniversary(String id, Anniversary anniversary) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(anniversary.toJson()),
      );
      if (response.statusCode == 200) {
        int index = _anniversaries
            .indexWhere((a) => a.anniversaryNo == anniversary.anniversaryNo);
        if (index != -1) {
          _anniversaries[index] =
              Anniversary.fromJson(jsonDecode(response.body));
          notifyListeners();
        }
      } else {
        throw Exception('Failed to update anniversary');
      }
    } catch (error) {
      print('Error updating anniversary: $error');
      throw error;
    }
  }

  Future<void> deleteAnniversary(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
      if (response.statusCode == 200) {
        _anniversaries.removeWhere((a) => a.anniversaryNo.toString() == id);
        notifyListeners();
      } else {
        throw Exception('Failed to delete anniversary');
      }
    } catch (error) {
      print('Error deleting anniversary: $error');
      throw error;
    }
  }
}
