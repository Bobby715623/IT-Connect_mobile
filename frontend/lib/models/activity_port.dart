class ActivityPort {
  final int id;
  final String? portname;
  final int? hourNeed;
  final String? type;
  final DateTime? endDate;
  final String? status;

  // ✅ เพิ่มตัวนี้
  final List<Activity>? activities;

  ActivityPort({
    required this.id,
    this.portname,
    this.hourNeed,
    this.type,
    this.endDate,
    this.status,
    this.activities, // ✅ เพิ่มใน constructor
  });

  factory ActivityPort.fromJson(Map<String, dynamic> json) {
    return ActivityPort(
      id: json['ActivityPortID'],
      portname: json['Portname'],
      hourNeed: json['HourNeed'],
      type: json['Type'],
      endDate: json['EndDate'] != null ? DateTime.parse(json['EndDate']) : null,
      status: json['status'],

      // ✅ map relation Activity จาก backend
      activities: json['Activity'] != null
          ? (json['Activity'] as List).map((e) => Activity.fromJson(e)).toList()
          : [],
    );
  }
}

class Activity {
  final int id;
  final String? name;
  final String? description;
  final String? location;
  final int? hour;
  final String? status;
  final String? comment;
  final List<ActivityEvidence>? evidences;

  Activity({
    required this.id,
    this.name,
    this.description,
    this.location,
    this.hour,
    this.status,
    this.comment,
    this.evidences,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['ActivityID'],
      name: json['ActivityName'],
      description: json['Description'],
      location: json['Location'],
      hour: json['HourofActivity'],
      status: json['Status'],
      comment: json['Comment'],
      evidences: json['ActivityEvidence'] != null
          ? (json['ActivityEvidence'] as List)
                .map((e) => ActivityEvidence.fromJson(e))
                .toList()
          : [],
    );
  }
}

class ActivityEvidence {
  final int id;
  final String? picture;

  ActivityEvidence({required this.id, this.picture});

  factory ActivityEvidence.fromJson(Map<String, dynamic> json) {
    return ActivityEvidence(id: json['EvidenceID'], picture: json['Picture']);
  }
}
