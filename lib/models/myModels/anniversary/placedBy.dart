class PlacedBy {
  String? id;
  int? paperId;
  DateTime? date;
  String? placedByName;
  String? placedByAddress;
  String? placedByPhone;

  PlacedBy({
    this.id,
    this.paperId,
    this.date,
    this.placedByName,
    this.placedByAddress,
    this.placedByPhone,
  });

  // Convert a PlacedBy to a Map (for easy serialization)

  // Convert Map to PlacedBy instance
  factory PlacedBy.fromjson(Map<String, dynamic> json) {
    return PlacedBy(
      id: json['_id'] as String?,
      paperId: json['Paper_Id'] as int?,
      date: json['Date'] != null
          ? DateTime.parse(json['Date'] as String).toLocal()
          : null,
      placedByName: json['Placed_By_Name'] as String?,
      placedByAddress: json['Placed_By_Address'] as String?,
      placedByPhone: json['Placed_By_Phone'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'Paper_Id': paperId,
      'Date': date?.toIso8601String(),
      'Placed_By_Name': placedByName,
      'Placed_By_Address': placedByAddress,
      'Placed_By_Phone': placedByPhone,
    };
  }
  PlacedBy copyWith({
    String? id,
    String? placedByName,
    String? placedByAddress,
    String? placedByPhone,
    int? paperId,
    DateTime? date,
  }) {
    return PlacedBy(
      id: id ?? this.id,
      placedByName: placedByName ?? this.placedByName,
      placedByAddress: placedByAddress ?? this.placedByAddress,
      placedByPhone: placedByPhone ?? this.placedByPhone,
      paperId: paperId ?? this.paperId,
      date: date ?? this.date,
    );
  }

}
