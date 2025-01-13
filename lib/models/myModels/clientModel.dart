

import 'dart:convert';
import 'dart:typed_data';

class Client {
 String? id;
  int? clientNo;
  int? titleId;
  String? lastName;
  String? firstName;
  String? middleName;
  DateTime? dateOfBirth;
  String? telephone;
  String? email;
  String? placeOfWork;
  String? associates;
  String? friends;
  String? address;
  int? age;
  Uint8List? image; 
  String? description;

  Client({
    this.id,
    this.clientNo,
    this.titleId,
    this.lastName,
    this.firstName,
    this.middleName,
    this.dateOfBirth,
    this.telephone,
    this.email,
    this.placeOfWork,
    this.associates,
    this.friends,
    this.address,
    this.age,
    this.image,
    this.description
  });

  // Factory method to create a Client object from a JSON map
  factory Client.fromJson(Map<String, dynamic> json) {
      
    return Client(
      id: json['_id'] as String?,
      clientNo: json['Client_No'] as int?,
      titleId: json['Title_Id'] as int?,
      lastName: json['Last_Name'] as String?,
      firstName: json['First_Name'] as String?,
      middleName: json['Middle_Name'] as String?,
      dateOfBirth: json['Date_Of_Birth'] != null
          ? DateTime.parse(json['Date_Of_Birth']).toLocal()
          : null,
      telephone: json['Telephone'] as String?,
      email: json['Email'] as String?,
      placeOfWork: json['Place_Of_Work']as String?,
      associates: json['Associates'] as String?,
      friends: json['Friends'] as String?,
      address: json['Address'] as String?,
      age: json['Age']as int?,
       image: (json['Image'] is Map && json['Image']['data'] != null)
          ? Uint8List.fromList(List<int>.from(json['Image']['data']))
          : (json['Image'] is String
              ? base64Decode(json['Image'] as String)
              : null),
      description: json['Description'] as String?,
    );
  }

  // Method to convert a Client object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      //'_id': id,
      'Client_No': clientNo,
      'Title_Id': titleId,
      'Last_Name': lastName,
      'First_Name': firstName,
      'Middle_Name': middleName,
      'Date_Of_Birth': dateOfBirth?.toIso8601String(),
      'Telephone': telephone,
      'Email': email,
      'Place_Of_Work': placeOfWork,
      'Associates': associates,
      'Friends': friends,
      'Address': address,
      'Image': image != null ? base64Encode(image!) : null,
      'Description': description,
    };
  }
 
}
