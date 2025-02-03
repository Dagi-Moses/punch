class Sex {
  final String sexCode;
  final String gender;

  Sex({
    required this.sexCode,
    required this.gender,
  });

  factory Sex.fromJson(Map<String, dynamic> json) {
    return Sex(
      sexCode: json['Sex_Code'],
      gender: json['Gender'],
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'Sex_Code': sexCode,
      'Gender': gender,
    };
  }
}
