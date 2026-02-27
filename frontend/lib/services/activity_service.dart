import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

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

  static Future<void> updateActivity({
    required int activityId,
    required String activityName,
    required String description,
    required int hour,
    required String location,
    required DateTime datetime,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/activity/$activityId'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "ActivityName": activityName,
        "Description": description,
        "HourofActivity": hour,
        "Location": location,
        "DatetimeofActivity": datetime.toIso8601String(),
      }),
    );

    if (response.statusCode != 200) {
      print(response.body);
      throw Exception("Failed to update activity");
    }
  }

  static Future<bool> submitActivityFromPost({
    required int postId,
    required int userId,
    required String description,
    required List<File> images,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("http://10.0.2.2:3000/api/Activitypost/$postId/submit"),
    );

    request.fields['UserID'] = userId.toString();
    request.fields['Description'] = description;

    for (var image in images) {
      request.files.add(
        await http.MultipartFile.fromPath('images', image.path),
      );
    }

    final response = await request.send();
    return response.statusCode == 200;
  }
}
