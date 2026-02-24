import 'dart:convert';
import 'package:http/http.dart' as http;

class ActivityService {
  static const String baseUrl = "http://10.0.2.2:3000";

  static Future<int> createActivity({
    required int portId,
    required String activityName,
    required String description,
    required int hour,
    required String location,
    required DateTime datetime,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/Activityport/$portId/createactivity'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "ActivityName": activityName,
        "Description": description,
        "HourofActivity": hour,
        "Location": location,
        "DatetimeofActivity": datetime.toIso8601String(),
        "Status": "waitforprocess",
        "Comment": null,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to create activity");
    }

    final data = jsonDecode(response.body);
    return data["ActivityID"];
  }
}
