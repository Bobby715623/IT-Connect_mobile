import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/welfare.dart';

class WelfareService {
  static Future<List<Welfare>> fetchWelfares() async {
    final res = await http.get(Uri.parse('http://10.0.2.2:3000/api/welfare'));

    if (res.statusCode == 200) {
      final List data = json.decode(res.body);
      return data.map((e) => Welfare.fromJson(e)).toList();
    } else {
      throw Exception('โหลดข้อมูลสวัสดิการไม่สำเร็จ');
    }
  }
}
