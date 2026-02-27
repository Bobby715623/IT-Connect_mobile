import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/activity_post.dart';

class ActivityPostService {
  static const String baseUrl = "http://10.0.2.2:3000/api/Activitypost";

  static Future<List<ActivityPost>> fetchPosts() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => ActivityPost.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load activity posts');
    }
  }

  // static Future<bool> followActivity({
  //   required int activitypostId,
  //   required int userId,
  // }) async {
  //   final response = await http.post(
  //     Uri.parse("$baseUrl/follow/$activitypostId"),
  //     headers: {"Content-Type": "application/json"},
  //     body: jsonEncode({"UserID": userId}),
  //   );

  //   if (response.statusCode == 200) {
  //     return true;
  //   } else {
  //     print(response.body);
  //     return false;
  //   }
  // }

  static Future<bool> toggleFollow({
    required int activitypostId,
    required int userId,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/follow/$activitypostId"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"UserID": userId}),
    );

    final data = jsonDecode(response.body);
    return data["followed"] == true;
  }

  static Future<List<int>> getFollowedActivities(int userId) async {
    final response = await http.get(Uri.parse("$baseUrl/follow/user/$userId"));

    final data = jsonDecode(response.body);

    return List<int>.from(data.map((item) => item["ActivityPostID"]));
  }
}
