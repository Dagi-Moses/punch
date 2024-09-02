import 'dart:convert';
import 'package:http/http.dart' as http;

class Papers {
 
  final int paperId;
  final String description;

  Papers({
   
    required this.paperId,
    required this.description,
  });

  factory Papers.fromJson(Map<String, dynamic> json) {
    return Papers(
     
      paperId: json['Paper_Id'],
      description: json['Description'],
    );
  }
}

