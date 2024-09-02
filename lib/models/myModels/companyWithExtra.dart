import 'package:punch/models/myModels/companyExtraModel.dart';
import 'package:punch/models/myModels/companyModel.dart';

class CompanyWithExtra {
  final Company company;
  final CompanyExtra companyExtra;

  CompanyWithExtra({required this.company, required this.companyExtra});
  
  // Factory constructor to create a UserWithRecord object from a JSON map
  factory CompanyWithExtra.fromJson(Map<String, dynamic> json) {
    return CompanyWithExtra(
      company: Company.fromJson(json['company']),
      companyExtra: CompanyExtra.fromJson(json['companyExtra']),
    );
  }

  // Method to convert UserWithRecord to JSON (optional, if needed)
  Map<String, dynamic> toJson() {
    return {
      'company': company.toJson(),
      'companyExtra': companyExtra.toJson(),
    };
  }
}
