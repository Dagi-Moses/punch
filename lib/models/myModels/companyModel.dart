import 'dart:convert';

class Company {
  int? id;
  int? companyNo;
  String? name;
  CompanySectorType companySectorId;
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
    required this.companySectorId,
    this.date,
    this.address,
    this.email,
    this.phone,
    this.fax,
    this.startDate,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    int companySectorTypeIndex = json['Company_Sector_Id'] as int;
    CompanySectorType companySectorTypeId;

    if (companySectorTypeIndex >= 0 &&
        companySectorTypeIndex < CompanySectorType.values.length) {
      companySectorTypeId = CompanySectorType.values[companySectorTypeIndex];
    } else {
      companySectorTypeId = CompanySectorType.other;
    }
    return Company(
      id: json['_id'] as int?,
      companyNo: json['Company_No'] as int?,
      name: json['Name'] as String?,
      companySectorId: companySectorTypeId,
      date:
          json['Date'] != null ? DateTime.parse(json['Date'] as String) : null,
      address: json['Address'] as String?,
      email: json['Email'] as String?,
      phone: json['Phone'] as String?,
      fax: json['Fax'] as String?,
      startDate: json['Start_Date'] != null
          ? DateTime.parse(json['Start_Date'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'Company_No': companyNo,
      'Name': name,
      'Company_Sector_Id': companySectorId.index,
      'Date': {'\$date': date?.toIso8601String()},
      'Address': address,
      'Email': email,
      'Phone': phone,
      'Fax': fax,
      'Start_Date': startDate?.toIso8601String(),
    };
  }
}

enum CompanySectorType {
  other,
  oilAndGas,
  informationTechnology,
  banking,
  insurance,
  manufacturingTradingImportExport,
  aviation,
  automobile,
  education,
  professionalBody,
  homesProperties,
  media,
  printing,
  agriculture,
  health,
  foodAndBeverages,
  informationTechnology2,
  recycling,
  hotelAndTourism,
  conglomerates,
  novelist,
}

extension CompanySectorTypeExtension on CompanySectorType {
  String get description {
    switch (this) {
      case CompanySectorType.oilAndGas:
        return "Oil And Gas";
      case CompanySectorType.informationTechnology:
        return "Information Technology";
      case CompanySectorType.banking:
        return "Banking";
      case CompanySectorType.insurance:
        return "Insurance";
      case CompanySectorType.manufacturingTradingImportExport:
        return "Manufacturing, Trading, Import/export";
      case CompanySectorType.aviation:
        return "Aviation";
      case CompanySectorType.automobile:
        return "Automobile";
      case CompanySectorType.education:
        return "Education";
      case CompanySectorType.professionalBody:
        return "Professional Body";
      case CompanySectorType.homesProperties:
        return "Homes & Properties";
      case CompanySectorType.media:
        return "Media";
      case CompanySectorType.printing:
        return "Printing";
      case CompanySectorType.agriculture:
        return "Agriculture";
      case CompanySectorType.health:
        return "Health";
      case CompanySectorType.foodAndBeverages:
        return "Food & Beverages";
      case CompanySectorType.informationTechnology2:
        return "Information Technology";
      case CompanySectorType.recycling:
        return "Recycling";
      case CompanySectorType.hotelAndTourism:
        return "Hotel & Tourism";
      case CompanySectorType.conglomerates:
        return "Conglomerates";
      case CompanySectorType.novelist:
        return "Novelist";
      case CompanySectorType.other:
        return "N/A";
    }
  }
}

String getCompanySectorEvent(CompanySectorType type) {
  switch (type) {
    case CompanySectorType.oilAndGas:
      return "Oil And Gas";
    case CompanySectorType.informationTechnology:
      return "Information Technology";
    case CompanySectorType.banking:
      return "Banking";
    case CompanySectorType.insurance:
      return "Insurance";
    case CompanySectorType.manufacturingTradingImportExport:
      return "Manufacturing, Trading, Import/export";
    case CompanySectorType.aviation:
      return "Aviation";
    case CompanySectorType.automobile:
      return "Automobile";
    case CompanySectorType.education:
      return "Education";
    case CompanySectorType.professionalBody:
      return "Professional Body";
    case CompanySectorType.homesProperties:
      return "Homes & Properties";
    case CompanySectorType.media:
      return "Media";
    case CompanySectorType.printing:
      return "Printing";
    case CompanySectorType.agriculture:
      return "Agriculture";
    case CompanySectorType.health:
      return "Health";
    case CompanySectorType.foodAndBeverages:
      return "Food & Beverages";
    case CompanySectorType.informationTechnology2:
      return "Information Technology";
    case CompanySectorType.recycling:
      return "Recycling";
    case CompanySectorType.hotelAndTourism:
      return "Hotel & Tourism";
    case CompanySectorType.conglomerates:
      return "Conglomerates";
    case CompanySectorType.novelist:
      return "Novelist";
    case CompanySectorType.other:
      return "N/A";
  }
}
