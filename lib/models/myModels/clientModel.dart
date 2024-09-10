import 'package:intl/intl.dart';

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
    };
  }
 
}
