class Religion {
  final String religionCode;
  final String religion;

  Religion({
    required this.religionCode,
    required this.religion,
  });

  factory Religion.fromJson(Map<String, dynamic> json) {
    return Religion(
      religionCode: json['religion_code'],
      religion: json['religion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'religion_code': religionCode,
      'religion': religion,
    };
  }
}
