import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/scholarship.dart';

class ScholarshipService {
  // ⚠️ ถ้าใช้ Android Emulator ให้เปลี่ยนเป็น 10.0.2.2
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  // ===== GET ALL =====
  static Future<List<Scholarship>> fetchScholarships() async {
    final response = await http.get(Uri.parse('$baseUrl/scholarship'));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Scholarship.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load scholarship');
    }
  }

  // ===== GET BY ID =====
  static Future<Scholarship> fetchScholarshipById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/scholarship/$id'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Scholarship.fromJson(data);
    } else {
      throw Exception('Failed to load scholarship detail');
    }
  }
}
