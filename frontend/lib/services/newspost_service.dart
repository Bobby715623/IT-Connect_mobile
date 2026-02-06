import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/newspost.dart';

class PostService {
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  Future<List<Post>> getPosts() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Post.fromJson(e)).toList();
    } else {
      throw Exception('โหลดโพสต์ไม่สำเร็จ');
    }
  }
}
