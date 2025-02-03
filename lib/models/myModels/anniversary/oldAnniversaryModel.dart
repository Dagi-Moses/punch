import 'dart:convert';
import 'dart:typed_data';

class OldAnniversary {
  String? id;
  int? anniversaryNo;
  String? name;
  int? anniversaryTypeId;
  DateTime? date;
  String? placedByName;
  String? placedByAddress;
  String? placedByPhone;
  String? friends;
  String? associates;
  int ? paperId;
  int? anniversaryYear;
  Uint8List? image; // Base64 encoded image
  String? description; // Description for the image

  OldAnniversary({
    this.id,
    this.anniversaryNo,
    this.name,
   this.anniversaryTypeId,
    this.date,
    this.placedByName,
    this.placedByAddress,
    this.placedByPhone,
    this.friends,
    this.associates,
   this.paperId,
    this.anniversaryYear,
   this.image,
    this.description,
  });

  // Deserialize JSON to OldAnniversary object
  factory OldAnniversary.fromJson(Map<String, dynamic> json) {
   
    return OldAnniversary(
      id: json['_id'] as String?,
      anniversaryNo: json['Anniversary_No'] as int?,
      name: json['Name'] as String?,
      anniversaryTypeId: json['Anniversary_Type_Id'] as int?,
      date: json['Date'] != null
          ? DateTime.parse(json['Date'] as String).toLocal()
          : null,

      placedByName: json['Placed_By_Name'] as String?,
      placedByAddress: json['Placed_By_Address'] as String?,
      placedByPhone: json['Placed_By_Phone'] as String?,
      friends: json['Friends'] as String?,
      associates: json['Associates'] as String?,
      paperId: json['Paper_Id'] as int?,
      anniversaryYear: json['Anniversary_Year'] as int?,
       image: (json['Image'] is Map && json['Image']['data'] != null)
          ? Uint8List.fromList(List<int>.from(json['Image']['data']))
          : (json['Image'] is String
              ? base64Decode(json['Image'] as String)
              : null),
      description: json['Description'] as String?,
    );
  }

  // Serialize OldAnniversary object to JSON
  Map<String, dynamic> toJson() {
    return {
      //'_id': id,
      'Anniversary_No': anniversaryNo,
      'Name': name,
      'Anniversary_Type_Id': anniversaryTypeId,
      'Date': date?.toIso8601String(),
      'Placed_By_Name': placedByName,
      'Placed_By_Address': placedByAddress,
      'Placed_By_Phone': placedByPhone,
      'Friends': friends,
      'Associates': associates,
      'Paper_Id': paperId,
     'Image': image != null ? base64Encode(image!) : null, 
      'Description': description,
     // 'Anniversary_Year': anniversaryYear,
    };
  }
}




