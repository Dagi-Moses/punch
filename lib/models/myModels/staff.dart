class Staff {
  String? id;
  String? staffNo;
  String? lastName;
  String? firstName;
  String? middleName;
  DateTime? dateOfBirth;
  String? sex; // Use "M" or "F"
  String? religion;
  String? healthStatus;
  String? nationality;
  String? townOfOrigin;
  String? stateOfOrigin;
  String? localGovernmentArea;
  String? formerLastName;
  int? maritalStatus;
  int? numberOfChildren;
  int? title;
  int? type;
  int? level;
  double? target; // For Decimal128
  int? age;

  Staff(
      {this.id,
      this.staffNo,
      this.lastName,
      this.firstName,
      this.middleName,
      this.dateOfBirth,
      this.sex,
      this.religion,
      this.healthStatus,
      this.nationality,
      this.townOfOrigin,
      this.stateOfOrigin,
      this.localGovernmentArea,
      this.formerLastName,
      this.maritalStatus,
      this.numberOfChildren,
      this.title,
      this.type,
      this.level,
      this.target,
      this.age});

  // Factory constructor for JSON deserialization
  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['_id'] as String?,
      staffNo: json['Staff_No'] as String,
      lastName: json['Last_Name'] as String?,
      firstName: json['First_Name'] as String?,
      middleName: json['Middle_Name'] as String?,
      dateOfBirth: json['Date_of_Birth'] != null
          ? DateTime.parse(json['Date_of_Birth'])
          : null,
      sex: json['Sex'] as String?,
      religion: json['Religion'] as String?,
      healthStatus: json['Health_Status'] as String?,
      nationality: json['Nationality'] as String?,
      townOfOrigin: json['Town_Of_Origin'] as String?,
      stateOfOrigin: json['State_Of_Origin'] as String?,
      localGovernmentArea: json['Local_Government_Area'] as String?,
      formerLastName: json['Former_Last_Name'] as String?,
      maritalStatus: json['Marital_Status'] as int?,
      numberOfChildren: json['No_Of_Children'] as int?,
      title: json['Title'] as int?,
      type: json['Type'] as int?,
      level: json['Level'] as int?,
      target: json['Target'] != null
          ? double.tryParse(json['Target'].toString())
          : null,
      age: json['Age'] as int?,
    );
  }

  // Method for JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'Staff_No': staffNo,
      'Last_Name': lastName,
      'First_Name': firstName,
      'Middle_Name': middleName,
      'Date_of_Birth': dateOfBirth?.toIso8601String(),
      'Sex': sex,
      'Religion': religion,
      'Health_Status': healthStatus,
      'Nationality': nationality,
      'Town_Of_Origin': townOfOrigin,
      'State_Of_Origin': stateOfOrigin,
      'Local_Government_Area': localGovernmentArea,
      'Former_Last_Name': formerLastName,
      'Marital_Status': maritalStatus,
      'No_Of_Children': numberOfChildren,
      'Title': title,
      'Type': type,
      'Level': level,
      'Target': target,
    };
  }
}
