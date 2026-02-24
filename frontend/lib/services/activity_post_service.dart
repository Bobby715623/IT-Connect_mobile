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
}
