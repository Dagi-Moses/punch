class HealthStatus {
  final String statusCode;
  final String healthStatus;

  HealthStatus({
    required this.statusCode,
    required this.healthStatus,
  });

  factory HealthStatus.fromJson(Map<String, dynamic> json) {
    return HealthStatus(
      statusCode: json['Health_Status_Code'],
      healthStatus: json['Health_Status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Health_Status_Code': statusCode,
      'Health_Status': healthStatus,
    };
  }
}
