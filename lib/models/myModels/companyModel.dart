import 'dart:convert';

class Company {
  String? id;
  int? companyNo;
  String? name;
  int ?companySectorId;
  DateTime? date;
  String? address;
  String? email;
  String? phone;
  String? fax;
  DateTime? startDate;

  Company({
    this.id,
    this.companyNo,
    this.name,
    this.companySectorId,
    this.date,
    this.address,
    this.email,
    this.phone,
    this.fax,
    this.startDate,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    
    return Company(
      id: json['_id'] as String? ,
      companyNo: json['Company_No'] as int?,
      name: json['Name'] as String? ,
      companySectorId: json['Company_Sector_Id'] as int?,
      date:
          json['Date'] != null ? DateTime.parse(json['Date'] as String).toLocal() : null,
      address: json['Address'] as String? ,
      email: json['Email'] as String? ,
      phone: json['Phone'] as String? ,
      fax: json['Fax'] as String? ,
      startDate: json['Start_Date'] != null
          ? DateTime.parse(json['Start_Date']).toLocal()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
     // '_id': id,
     'Company_No': companyNo,
      'Name': name,
      'Company_Sector_Id': companySectorId,
      'Date': date?.toIso8601String(),
      'Address': address,
      'Email': email,
      'Phone': phone,
      'Fax': fax,
      'Start_Date': startDate?.toIso8601String(),
    };
  }
}
