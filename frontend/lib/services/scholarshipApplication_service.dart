import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myproject/models/myscholarship.dart';

class ScholarshipService {
  static Future<List<ScholarshipApplication>> getMyHistory(int userId) async {
    final res = await http.get(
      Uri.parse('http://10.0.2.2:3000/api/scholarship/history/$userId'),
    );

    final List data = json.decode(res.body);
    return data.map((e) => ScholarshipApplication.fromJson(e)).toList();
  }
}
