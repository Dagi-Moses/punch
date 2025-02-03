import 'dart:convert';
import 'package:http/http.dart' as http;

class AnniversaryType {
  final int anniversaryTypeId;
  final String description;

  AnniversaryType({
    required this.anniversaryTypeId,
    required this.description,
  });

  factory AnniversaryType.fromJson(Map<String, dynamic> json) {
    return AnniversaryType(
      anniversaryTypeId: json['Anniversary_Type_Id'],
      description: json['Description'],
    );
  }
}
