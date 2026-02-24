class PersonalEvent {
  final int personalEventID;
  final String? title;
  final String? description;
  final DateTime? deadline;
  final bool? notify;
  final DateTime? notifyDatetime;
  final int userID;

  PersonalEvent({
    required this.personalEventID,
    this.title,
    this.description,
    this.deadline,
    this.notify,
    this.notifyDatetime,
    required this.userID,
  });

  factory PersonalEvent.fromJson(Map<String, dynamic> json) {
    return PersonalEvent(
      personalEventID: json['PersonalEventID'],
      title: json['Title'],
      description: json['Description'],
      deadline: json['Deadline'] != null
          ? DateTime.parse(json['Deadline'])
          : null,
      notify: json['Notify'],
      notifyDatetime: json['NotifyDatetime'] != null
          ? DateTime.parse(json['NotifyDatetime'])
          : null,
      userID: json['UserID'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "Title": title,
      "Description": description,
      "Deadline": deadline?.toIso8601String(),
      "UserID": userID,
    };
  }
}
