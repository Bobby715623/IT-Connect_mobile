class Scholarship {
  final int id;
  final String name;
  final String description;
  final int activityHourNeeded;
  final String? picture;

  final DateTime? activityDeadline;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? announceInterviewDate;
  final DateTime? interviewDate;
  final DateTime? winnerAnnounceDate;

  final List<ScholarshipRequirement> requirements;

  Scholarship({
    required this.id,
    required this.name,
    required this.description,
    required this.activityHourNeeded,
    this.picture,
    this.startDate,
    this.endDate,

    this.activityDeadline,
    this.announceInterviewDate,
    this.interviewDate,
    this.winnerAnnounceDate,
    required this.requirements,
  });

  factory Scholarship.fromJson(Map<String, dynamic> json) {
    return Scholarship(
      id: json['ScholarshipID'],
      name: json['Scholarshipname'] ?? '',
      description: json['Description'] ?? '',
      activityHourNeeded: json['ActivityHourNeeded'] ?? 0,
      picture: json['Picture'],

      activityDeadline: json['ActivityDeadline'] != null
          ? DateTime.parse(json['ActivityDeadline'])
          : null,

      startDate: json['Startdate'] != null
          ? DateTime.parse(json['Startdate'])
          : null,

      endDate: json['Enddate'] != null ? DateTime.parse(json['Enddate']) : null,

      interviewDate: json['Interviewday'] != null
          ? DateTime.parse(json['Interviewday'])
          : null,

      announceInterviewDate: json['AnnouceStudentInterviewday'] != null
          ? DateTime.parse(json['AnnouceStudentInterviewday'])
          : null,

      winnerAnnounceDate: json['WinnerAnnouceday'] != null
          ? DateTime.parse(json['WinnerAnnouceday'])
          : null,

      // ⭐ ใส่ส่วนนี้เพิ่ม
      requirements: json['ScholarshipRequirement'] != null
          ? (json['ScholarshipRequirement'] as List)
                .map((e) => ScholarshipRequirement.fromJson(e))
                .toList()
          : [],
    );
  }
}

// ================= REQUIREMENT =================

class ScholarshipRequirement {
  final int id;
  final String name;
  final String type;
  final bool require;

  ScholarshipRequirement({
    required this.id,
    required this.name,
    required this.type,
    required this.require,
  });

  factory ScholarshipRequirement.fromJson(Map<String, dynamic> json) {
    return ScholarshipRequirement(
      id: json['RequirementID'],
      name: json['Name'] ?? '',
      type: json['Type'] ?? '',
      require: json['Require'] ?? false,
    );
  }
}
