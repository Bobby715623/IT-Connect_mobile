class ScholarshipApplication {
  final int applicationID;
  final ApplyStatus status;
  final String scholarshipTitle;
  final int submittedCount;

  ScholarshipApplication({
    required this.applicationID,
    required this.status,
    required this.scholarshipTitle,
    required this.submittedCount,
  });

  factory ScholarshipApplication.fromJson(Map<String, dynamic> json) {
    return ScholarshipApplication(
      applicationID: json['ApplicationID'],
      status: ApplyStatusExtension.fromString(json['Status']),
      scholarshipTitle: json['Scholarship']['Title'],
      submittedCount: (json['ScholarshipSubmission'] as List).length,
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
