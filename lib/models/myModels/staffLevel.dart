class StaffLevel {
  final int staffLevelNo;
  final String description;

  StaffLevel({
    required this.staffLevelNo,
    required this.description,
  });

  factory StaffLevel.fromJson(Map<String, dynamic> json) {
    return StaffLevel(
      staffLevelNo: json['Staff_Level_No'],
      description: json['Description'],
    );
  }
}
