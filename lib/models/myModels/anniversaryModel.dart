class Anniversary {
   String? id;
  int? anniversaryNo;
  String? name;
  int anniversaryTypeId;
  DateTime? date;
  String? placedByName;
  String? placedByAddress;
  String? placedByPhone;
  String? friends;
  String? associates;
  int? paperId;
  int? anniversaryYear;

  Anniversary({
    this.id,
    this.anniversaryNo,
    this.name,
    required this.anniversaryTypeId,
    this.date,
    this.placedByName,
    this.placedByAddress,
    this.placedByPhone,
    this.friends,
    this.associates,
    this.paperId,
    this.anniversaryYear,
  });

  // Deserialize JSON to Anniversary object
  factory Anniversary.fromJson(Map<String, dynamic> json) {
    return Anniversary(
      id: json['_id'] as String?,
      anniversaryNo: json['Anniversary_No'] as int?,
      name: json['Name'] as String?,
      anniversaryTypeId: json['Anniversary_Type_Id'] as int,
      date:
          json['Date'] != null ? DateTime.parse(json['Date'] as String) : null,
      placedByName: json['Placed_By_Name'] as String?,
      placedByAddress: json['Placed_By_Address'] as String?,
      placedByPhone: json['Placed_By_Phone'] as String?,
      friends: json['Friends'] as String?,
      associates: json['Associates'] as String?,
      paperId: json['Paper_Id'] as int?,
      anniversaryYear: json['Anniversary_Year'] as int?,
    );
  }

  // Serialize Anniversary object to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
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
      'Anniversary_Year': anniversaryYear,
    };
  }
}
