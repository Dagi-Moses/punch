import 'dart:convert';
import 'package:http/http.dart' as http;

class  Titles{
  final int titleId;
  final String description;

  Titles({
    required this.titleId,
    required this.description,
  });

  factory Titles.fromJson(Map<String, dynamic> json) {
    return Titles(
      titleId: json['Title_Id'],
      description: json['Description'],
    );
  }
}
