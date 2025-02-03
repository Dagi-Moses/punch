class AnniversarySector {
  final String? id;
  final int? anniversarySectorId;
  final int? anniversaryNo;
  final int? subSectorId;

  AnniversarySector({
    required this.id,
    required this.anniversarySectorId,
    required this.anniversaryNo,
    required this.subSectorId,
  });

  factory AnniversarySector.fromJson(Map<String, dynamic> json) {
    return AnniversarySector(
      id: json['_id'] as String?,
      anniversarySectorId: json['anniversary_sector_id'] as int?,
      anniversaryNo: json['anniversary_no'] as int?,
      subSectorId: json['sub_sector_id'] as int?,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'anniversary_sector_id': anniversarySectorId,
      'anniversary_no': anniversaryNo,
      'sub_sector_id': subSectorId,
    };
  }
}
