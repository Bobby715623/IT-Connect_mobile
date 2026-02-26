import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/welfare.dart';

class WelfareService {
  static const String baseUrl = "http://10.0.2.2:3000";

  static Future<List<Welfare>> fetchWelfares() async {
    final res = await http.get(Uri.parse('$baseUrl/api/welfare'));

    if (res.statusCode == 200) {
      final List data = json.decode(res.body);

      return data.map((e) {
        return Welfare.fromJson(e, baseUrl);
      }).toList();
    } else {
      throw Exception('โหลดข้อมูลสวัสดิการไม่สำเร็จ');
    }
  }

  //เอาไว้เปิดไปหน้า welfare scholarship
  static Future<Welfare?> fetchScholarshipWelfare() async {
    final res = await http.get(Uri.parse('$baseUrl/api/welfare/scholarship'));

    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      if (data == null) return null;
      return Welfare.fromJson(data, baseUrl);
    } else {
      throw Exception('โหลดข้อมูลไม่สำเร็จ');
    }
  }
}
