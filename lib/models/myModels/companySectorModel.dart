class CompanySector {
  final int companySectorId;
  final String description;

  CompanySector({
    required this.companySectorId,
    required this.description,
  });

  // Factory method to create an instance from a JSON map
  factory CompanySector.fromJson(Map<String, dynamic> json) {
    return CompanySector(
      companySectorId: json['Company_Sector_Id'],
      description: json['Description'] ?? '',
    );
  }

  // Method to convert an instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'Company_Sector_Id': companySectorId,
      'Description': description,
    };
  }
}
