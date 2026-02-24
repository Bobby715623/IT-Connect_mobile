import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/myscholarship.dart';
import 'auth_service.dart';

class ScholarshipService {
  static const String baseUrl = 'http://10.0.2.2:3000';

  static Future<List<ScholarshipApplication>> getMyHistory(int userId) async {
    final token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/api/scholarship/history/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('โหลดข้อมูลไม่สำเร็จ (${response.statusCode})');
    }

    final List data = jsonDecode(response.body);
    return data.map((e) => ScholarshipApplication.fromJson(e)).toList();
  }

  static Future<ScholarshipApplication> getApplicationDetail(
    int applicationId,
  ) async {
    final token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/api/scholarship/application/$applicationId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('โหลดรายละเอียดไม่สำเร็จ (${response.statusCode})');
    }

    final data = jsonDecode(response.body);

    return ScholarshipApplication.fromJson(data);
  }
}
