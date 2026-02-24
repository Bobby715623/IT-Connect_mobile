import 'dart:io';
import 'package:http/http.dart' as http;

class ActivityEvidenceService {
  static const String baseUrl = "http://10.0.2.2:3000";

  // 🔹 UPLOAD EVIDENCE
  static Future<void> uploadEvidence({
    required int activityId,
    required List<File> images,
  }) async {
    final uri = Uri.parse('$baseUrl/api/Activity/$activityId/evidence');

    final request = http.MultipartRequest("POST", uri);

    for (var img in images) {
      request.files.add(await http.MultipartFile.fromPath("images", img.path));
    }

    final response = await request.send();

    if (response.statusCode != 200) {
      throw Exception("Failed to upload evidence");
    }
  }
}
