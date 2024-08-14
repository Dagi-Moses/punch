class UserRecord {
  String? id;

  String? recordId;
  int? staffNo;
  DateTime? loginDateTime;
  String? computerName;

  UserRecord({
    this.id,
    this.recordId,
    this.staffNo,
    this.loginDateTime,
    this.computerName,
  });

  factory UserRecord.fromJson(Map<String, dynamic> json) {
    return UserRecord(
      id: json['_id'] as String? ?? "N/A",
      recordId: json['Record_Id'] ?? 'N/A',
      staffNo: json['staff_no'] ?? "N/A",
      loginDateTime: json['login_date_time'] != null
          ? DateTime.parse(json['login_date_time'] as String)
          : null,
      computerName: json['computer_name'] ?? "N/A",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'Record_Id': recordId,
      'staff_no': staffNo,
      'login_date_time': loginDateTime?.toIso8601String(),
      'computer_name': computerName,
    };
  }
}