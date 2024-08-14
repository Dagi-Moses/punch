class CompanyExtra {
   int ?id;
   int ?companyNo;
   String? managingDirector;
  String ?corporateAffairs;
   String? mediaManager;
   String ?friends;
   String ?competitors;
   String ?directors;

  CompanyExtra({
    this.id,
    this.companyNo,
   this.managingDirector,
     this.corporateAffairs,
     this.mediaManager,
     this.friends,
     this.competitors,
    this.directors,
  });

  // Factory method to create an instance from a JSON map
  factory CompanyExtra.fromJson(Map<String, dynamic> json) {
    return CompanyExtra(
      id: json['_id'],
      companyNo: json['Company_No'],
      managingDirector: json['Managing_Director'] ?? '',
      corporateAffairs: json['Corporate_Affairs'] ?? '',
      mediaManager: json['Media_Manager'] ?? '',
      friends: json['Friends'] ?? '',
      competitors: json['Competitors'] ?? '',
      directors: json['Directors'] ?? '',
    );
  }

  // Method to convert an instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'Company_No': companyNo,
      'Managing_Director': managingDirector,
      'Corporate_Affairs': corporateAffairs,
      'Media_Manager': mediaManager,
      'Friends': friends,
      'Competitors': competitors,
      'Directors': directors,
    };
  }
}
