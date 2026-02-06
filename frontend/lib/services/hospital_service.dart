import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/hospital.dart';

class HospitalService {
  static Future<List<Hospital>> fetchHospitals() async {
    final res = await http.get(
      Uri.parse('http://10.0.2.2:3000/api/hospital'),
      // Android emulator ใช้ 10.0.2.2
    );

    if (res.statusCode == 200) {
      final List data = json.decode(res.body);
      return data.map((e) => Hospital.fromJson(e)).toList();
    } else {
      throw Exception('โหลดข้อมูลโรงพยาบาลไม่สำเร็จ');
    }
  }
}
