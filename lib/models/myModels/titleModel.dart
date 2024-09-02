import 'dart:convert';
import 'package:http/http.dart' as http;

class  ClientTitle{
  final int titleId;
  final String description;

  ClientTitle({
    required this.titleId,
    required this.description,
  });

  factory ClientTitle.fromJson(Map<String, dynamic> json) {
    return ClientTitle(
      titleId: json['Title_Id'],
      description: json['Description'],
    );
  }
}
