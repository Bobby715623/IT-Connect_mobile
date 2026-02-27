import 'package:flutter/material.dart';

/// ===============================================
/// ACTIVITY PORT
/// ===============================================
class ActivityPort {
  final int id;
  final String? portname;
  final int? hourNeed;
  final String? type;
  final DateTime? endDate;
  final String? status;
  final int? hourofActivity;
  final List<Activity> activities;

  ActivityPort({
    required this.id,
    this.portname,
    this.hourNeed,
    this.type,
    this.endDate,
    this.status,
    this.hourofActivity,
    required this.activities,
  });

  factory ActivityPort.fromJson(Map<String, dynamic> json) {
    return ActivityPort(
      id: json['ActivityPortID'],
      portname: json['Portname'],
      hourNeed: json['HourNeed'],
      type: json['Type'],
      endDate: json['EndDate'] != null ? DateTime.parse(json['EndDate']) : null,
      status: json['Status'],
      hourofActivity: json['HourofActivity'],
      activities:
          (json['Activity'] as List?)
              ?.map((e) => Activity.fromJson(e))
              .toList() ??
          [],
    );
  }
}

/// ===============================================
/// ACTIVITY
/// ===============================================
class Activity {
  final int id;
  final int activityPortID;
  final String? name;
  final String? description;
  final String? location;
  final int? hour;
  final ActivityStatus status;
  final String? comment;
  final List<ActivityEvidence> evidences;
  final int? relatedPostId;
  final DateTime? datetime;

  Activity({
    required this.id,
    required this.activityPortID,
    this.name,
    this.description,
    this.location,
    this.hour,
    required this.status,
    this.comment,
    required this.evidences,
    this.relatedPostId,
    this.datetime,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['ActivityID'],
      activityPortID: json['ActivityPortID'],
      name: json['ActivityName'],
      description: json['Description'],
      location: json['Location'],
      hour: json['HourofActivity'],
      status: ActivityStatusExtension.fromString(
        json['Status'] ?? json['status'] ?? '',
      ),
      comment: json['Comment'],
      evidences:
          (json['ActivityEvidence'] as List?)
              ?.map((e) => ActivityEvidence.fromJson(e))
              .toList() ??
          [],
      relatedPostId: json['RelatedPostID'],
      datetime: json['DatetimeofActivity'] != null
          ? DateTime.parse(json['DatetimeofActivity'])
          : null,
    );
  }
}

/// ===============================================
/// ACTIVITY EVIDENCE
/// ===============================================
class ActivityEvidence {
  final int id;
  final String? picture;

  ActivityEvidence({required this.id, this.picture});

  factory ActivityEvidence.fromJson(Map<String, dynamic> json) {
    return ActivityEvidence(id: json['EvidenceID'], picture: json['Picture']);
  }
}

/// ===============================================
/// ENUM STATUS
/// ===============================================
enum ActivityStatus { waitForProcess, approve, reject }

/// ===============================================
/// EXTENSION
/// ===============================================
extension ActivityStatusExtension on ActivityStatus {
  static ActivityStatus fromString(String value) {
    final normalized = value.toLowerCase().replaceAll("_", "");

    switch (normalized) {
      case "approve":
        return ActivityStatus.approve;
      case "reject":
        return ActivityStatus.reject;
      case "waitforprocess":
        return ActivityStatus.waitForProcess;
      default:
        return ActivityStatus.waitForProcess;
    }
  }

  String get label {
    switch (this) {
      case ActivityStatus.approve:
        return "Approved";
      case ActivityStatus.reject:
        return "Rejected";
      case ActivityStatus.waitForProcess:
        return "Waiting for approval";
    }
  }

  Color get color {
    switch (this) {
      case ActivityStatus.approve:
        return const Color(0xFF34C759);
      case ActivityStatus.reject:
        return const Color(0xFFFF3B30);
      case ActivityStatus.waitForProcess:
        return const Color(0xFFFF9500);
    }
  }
}
