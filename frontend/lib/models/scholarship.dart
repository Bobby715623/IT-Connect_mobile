class Scholarship {
  final int id;
  final String name;
  final String description;
  final int activityHourNeeded;
  final String? picture;

  Scholarship({
    required this.id,
    required this.name,
    required this.description,
    required this.activityHourNeeded,
    this.picture,
  });

  factory Scholarship.fromJson(Map<String, dynamic> json) {
    return Scholarship(
      id: json['ScholarshipID'],
      name: json['Scholarshipname'] ?? '',
      description: json['Description'] ?? '',
      activityHourNeeded: json['ActivityHourNeeded'] ?? 0,
      picture: json['Picture'],
    );
  }
}
