import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/personal_event.dart';

class PersonalEventService {
  static const String baseUrl = "http://10.0.2.2:3000/api/PersonalEvent";

  // 🔹 Create
  static Future<PersonalEvent?> createEvent({
    required String title,
    String? description,
    DateTime? deadline,
    int? remindBeforeDays,
    required int userID,
  }) async {
    final body = {
      "Title": title,
      "Description": description,
      "Deadline": deadline?.toUtc().toIso8601String(),
      "remindBeforeDays": remindBeforeDays,
      "UserID": userID,
    };

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);

      // 🔥 สำคัญมาก ดูว่า backend ส่ง data กลับมาแบบไหน
      return PersonalEvent.fromJson(data["data"] ?? data);
    }

    return null;
  }

  // 🔹 Get All by User
  static Future<List<PersonalEvent>> getEventsByUser(int userId) async {
    final response = await http.get(Uri.parse("$baseUrl/User/$userId"));

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => PersonalEvent.fromJson(e)).toList();
    } else {
      throw Exception("โหลดข้อมูลไม่สำเร็จ");
    }
  }

  // 🔹 Update
  static Future<PersonalEvent?> updateEvent({
    required int id,
    required String title,
    String? description,
    DateTime? deadline,
    bool? notify,
    DateTime? notifyDatetime,
  }) async {
    final body = {
      "Title": title,
      "Description": description,
      "Deadline": deadline?.toIso8601String(),
      "Notify": notify,
      "NotifyDatetime": notifyDatetime?.toUtc().toIso8601String(),
    };

    final response = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return PersonalEvent.fromJson(data["data"]);
    }

    return null;
  }

  // 🔹 Delete
  static Future<bool> deleteEvent(int eventId) async {
    final response = await http.delete(Uri.parse("$baseUrl/$eventId"));

    return response.statusCode == 200;
  }
}
