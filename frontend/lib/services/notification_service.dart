import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification.dart';

class NotificationService {
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  static Future<List<AppNotification>> getMyNotifications(int userId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/notifications/user/$userId'),
      headers: {'Authorization': 'Bearer YOUR_TOKEN'},
    );

    if (res.statusCode == 200) {
      final List data = json.decode(res.body);
      return data.map((e) => AppNotification.fromJson(e)).toList();
    } else {
      throw Exception('โหลด notification ไม่สำเร็จ');
    }
  }
}
