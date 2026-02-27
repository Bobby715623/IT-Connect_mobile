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

  //remove evidence
  static Future<bool> deleteEvidence(int evidenceId) async {
    final response = await http.delete(
      Uri.parse("http://10.0.2.2:3000/api/evidence/$evidenceId"),
    );

    return response.statusCode == 200;
  }
}
