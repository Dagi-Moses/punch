class Country {
  final String countryCode;
  final String country;

  Country({
    required this.countryCode,
    required this.country,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      countryCode: json['country_code'],
      country: json['Country'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'country_code': countryCode,
      'Country': country,
    };
  }
}
