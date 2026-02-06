class AppNotification {
  final int id;
  final String? title;
  final String? message;
  final bool isRead;
  final String? type;
  final String? actionUrl;
  final DateTime? time;

  AppNotification({
    required this.id,
    this.title,
    this.message,
    required this.isRead,
    this.type,
    this.actionUrl,
    this.time,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['NotificationID'],
      title: json['Title'],
      message: json['Message'],
      isRead: json['IsRead'] ?? false,
      type: json['NotificationType'],
      actionUrl: json['ActionURL'],
      time: json['NotificationTime'] != null
          ? DateTime.parse(json['NotificationTime'])
          : null,
    );
  }
}
