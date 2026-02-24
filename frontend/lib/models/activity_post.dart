class ActivityPost {
  final int activityPostID;
  final String? title;
  final String? description;
  final int? hourOfActivity;
  final String? location;
  final DateTime? datetimeOfActivity;
  final String? picture;

  ActivityPost({
    required this.activityPostID,
    this.title,
    this.description,
    this.hourOfActivity,
    this.location,
    this.datetimeOfActivity,
    this.picture,
  });

  factory ActivityPost.fromJson(Map<String, dynamic> json) {
    return ActivityPost(
      activityPostID: json['ActivityPostID'],
      title: json['Title'],
      description: json['Description'],
      hourOfActivity: json['HourofActivity'],
      location: json['Location'],
      datetimeOfActivity: json['DatetimeofActivity'] != null
          ? DateTime.parse(json['DatetimeofActivity'])
          : null,
      picture: json['Picture'],
    );
  }
}
