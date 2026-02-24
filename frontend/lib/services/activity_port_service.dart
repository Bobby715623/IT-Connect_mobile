import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/activity_port.dart';

class ActivityPortService {
  static const String baseUrl = "http://10.0.2.2:3000";

  // 🔹 ดึงตาม user
  static Future<List<ActivityPort>> fetchByUser(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/Activityport/user/$userId'),
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => ActivityPort.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load activity ports");
    }
  }

  // 🔹 ดึง single port
  static Future<ActivityPort> fetchSingle(int portId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/Activityport/$portId'),
    );

    if (response.statusCode == 200) {
      return ActivityPort.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to load activity port detail");
    }
  }
}
