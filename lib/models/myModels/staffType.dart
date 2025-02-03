class StaffType {
  final int typeId;
  final String description;

  StaffType({
    required this.typeId,
    required this.description,
  });

  factory StaffType.fromJson(Map<String, dynamic> json) {
    return StaffType(
      typeId: json['Type_Id'],
      description: json['Description'],
    );
  }
}
