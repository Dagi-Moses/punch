import 'dart:convert';
import 'dart:typed_data';
import 'package:punch/models/myModels/anniversary/placedBy.dart';

class Anniversary {
  String? id;
  int? anniversaryNo;
  String? name;
  int? anniversaryTypeId;
  DateTime? date;
  List<PlacedBy>? placedBy;
  List<String>? friends;
  List<String>? associates;
  String? description;
  Uint8List? image;
  // int? anniversaryYear;

  Anniversary({
    this.id,
    this.anniversaryNo,
    this.name,
    this.anniversaryTypeId,
    this.date,
    this.placedBy,
    this.friends,
    this.associates,
    this.description,
    this.image,
  });

  int? get anniversaryYear {
    if (date == null) return null;
    int eventYear = date!.year;
    int currentYear = DateTime.now().year;
    return currentYear - eventYear;
  }

  int get paperTypeId {
    // Ensure anniversaryTypeId exists in the valid list of paperTypes
    List<int> validPaperIds = [1, 2, 3, 5, 6]; // Fetch from Provider instead
    return (anniversaryTypeId != null &&
            validPaperIds.contains(anniversaryTypeId!))
        ? anniversaryTypeId!
        : 4; // Default to "Unknown"
  }

  factory Anniversary.fromJson(Map<String, dynamic> json) {
    return Anniversary(
      id: json['_id'] as String?,
      anniversaryNo: json['Anniversary_No'] as int?,
      name: json['Name'] as String?,
      anniversaryTypeId: json['Anniversary_Type_Id'] as int?,
      date: json['Date'] != null
          ? DateTime.parse(json['Date'] as String).toLocal()
          : null,
      placedBy: (json['Placed_By'] as List?)
              ?.map((x) => PlacedBy.fromjson(x))
              .toList() ??
          [],
      friends: List<String>.from(json['Friends'] ?? []),
      associates: List<String>.from(json['Associates'] ?? []),

      image: (json['Image'] is Map && json['Image']['data'] != null)
          ? Uint8List.fromList(List<int>.from(json['Image']['data']))
          : (json['Image'] is String
              ? base64Decode(json['Image'] as String)
              : null),
      description: json['Description'] as String?,
      // anniversaryYear: json['Anniversary_Year'] as int?,
    );
  }

  // Convert an Anniversary to a Map (for easy serialization)
  Map<String, dynamic> toJson() {
    return {
      'Anniversary_No': anniversaryNo,
      'Name': name,
      'Anniversary_Type_Id': anniversaryTypeId,
      'Date': date?.toIso8601String(),
      'Placed_By': placedBy?.map((x) => x.toMap()).toList(),
      'Friends': friends,
      'Associates': associates,
      'Description': description,
      'Image': image,
    };
  }
  // Convert the image (Base64 string) to a byte array (if needed)
  // List<int> getImageBytes() {
  //   return base64Decode(image);
  // }
}
