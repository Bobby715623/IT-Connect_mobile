class ScholarshipApplication {
  final int applicationID;
  final DateTime? applicationDate;
  final ApplyStatus status;
  final String scholarshipTitle;
  final int submittedCount;
  final List<ScholarshipSubmission> submissions;

  ScholarshipApplication({
    required this.applicationID,
    required this.status,
    required this.scholarshipTitle,
    required this.submittedCount,
    this.applicationDate,
    required this.submissions,
  });

  factory ScholarshipApplication.fromJson(Map<String, dynamic> json) {
    return ScholarshipApplication(
      applicationID: json['ApplicationID'],
      applicationDate: json['ApplicationDate'] != null
          ? DateTime.parse(json['ApplicationDate']).toLocal()
          : null,
      status: ApplyStatusExtension.fromString(json['Status']),
      scholarshipTitle: json['Scholarship']?['Scholarshipname'] ?? '-',
      submittedCount: (json['ScholarshipSubmission'] as List?)?.length ?? 0,
      submissions:
          (json['ScholarshipSubmission'] as List?)
              ?.map((e) => ScholarshipSubmission.fromJson(e))
              .toList() ??
          [],
    );
  }
}

/// ===============================
/// ENUM
/// ===============================
enum ApplyStatus { inProgress, pass, fail, considering }

extension ApplyStatusExtension on ApplyStatus {
  static ApplyStatus fromString(String value) {
    switch (value) {
      case 'IN_PROGRESS':
        return ApplyStatus.inProgress;
      case 'PASS':
        return ApplyStatus.pass;
      case 'FAIL':
        return ApplyStatus.fail;
      case 'CONSIDERING':
        return ApplyStatus.considering;
      default:
        return ApplyStatus.inProgress;
    }
  }

  String get label {
    switch (this) {
      case ApplyStatus.inProgress:
        return 'In progress';
      case ApplyStatus.pass:
        return 'Pass';
      case ApplyStatus.fail:
        return 'Fail';
      case ApplyStatus.considering:
        return 'Considering';
    }
  }
}

class ScholarshipSubmission {
  final String requirementName;
  final String? studentDocument;

  ScholarshipSubmission({required this.requirementName, this.studentDocument});

  factory ScholarshipSubmission.fromJson(Map<String, dynamic> json) {
    return ScholarshipSubmission(
      requirementName: json['ScholarshipRequirement']?['Name'] ?? '-',
      studentDocument: json['StudentDocument'],
    );
  }
}
