import 'package:flutter/material.dart';
import 'package:myproject/models/scholarship.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myproject/screens/myscholarship.dart';
import '../services/welfare_service.dart';
import '../screens/welfare_type_page.dart';

class Requirement {
  final int id;
  final String name;
  final bool required;

  Requirement({required this.id, required this.name, required this.required});
}

class UploadDocumentPage extends StatefulWidget {
  final int scholarshipId;
  final int userId;
  final List<ScholarshipRequirement> requirements;

  const UploadDocumentPage({
    super.key,
    required this.scholarshipId,
    required this.userId,
    required this.requirements,
  });

  @override
  State<UploadDocumentPage> createState() => _UploadDocumentPageState();
}

class _UploadDocumentPageState extends State<UploadDocumentPage> {
  final Map<int, PlatformFile?> selectedFiles = {};
  bool isLoading = false;

  Future<void> pickFile(int requirementId) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg'],
      withData: true,
    );

    if (result != null) {
      setState(() {
        selectedFiles[requirementId] = result.files.first;
      });
    }
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> submitApplication() async {
    // Validate required files
    for (var req in widget.requirements) {
      if (req.require && selectedFiles[req.id] == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('กรุณาแนบไฟล์: ${req.name}')));
        return;
      }
    }

    setState(() => isLoading = true);

    try {
      final uri = Uri.parse('http://10.0.2.2:3000/api/scholarship/apply');

      final request = http.MultipartRequest('POST', uri);

      request.fields['ScholarshipID'] = widget.scholarshipId.toString();

      request.fields['Submissions'] = jsonEncode(
        selectedFiles.entries
            .where((e) => e.value != null)
            .map((e) => {"RequirementID": e.key})
            .toList(),
      );

      for (var entry in selectedFiles.entries) {
        if (entry.value != null) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'files',
              entry.value!.bytes!,
              filename: entry.value!.name,
            ),
          );
        }
      }

      final token = await getAccessToken();

      if (token == null || token.isEmpty) {
        print("NO TOKEN FOUND");
        return;
      }

      request.headers['Authorization'] = 'Bearer $token';

      final response = await request.send();

      if (response.statusCode == 201) {
        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('ส่งเอกสารสำเร็จ')));

        await Future.delayed(const Duration(seconds: 1));

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => MyScholarshipPage(
              userId: widget.userId,
              onGoHome: () {
                Navigator.pop(context);
              },
            ),
          ),
          (route) => false,
        );
      } else if (response.statusCode == 400) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("คุณได้ยื่นทุนนี้ไปแล้ว")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ส่งไม่สำเร็จ (${response.statusCode})')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              /// ===== Tabs =====
              Row(
                children: [
                  _TabButton(
                    title: 'ALL SCHOLARSHIP',
                    isActive: true,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 8),
                  _TabButton(
                    title: 'MY SCHOLARSHIP',
                    isActive: false,
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MyScholarshipPage(
                            userId: widget.userId,
                            onGoHome: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),

              /// ===== HOME =====
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Row(
                  children: [
                    Icon(Icons.arrow_back_ios, size: 14, color: Colors.blue),
                    SizedBox(width: 4),
                    Text(
                      'BACK',
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// ===== CONTENT =====
              Expanded(
                child: ListView(
                  children: [
                    ...widget.requirements.map((req) {
                      final file = selectedFiles[req.id];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    req.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (req.require)
                                  const Text(
                                    "*บังคับ",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            GestureDetector(
                              onTap: () => pickFile(req.id),
                              child: Container(
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: Center(
                                  child: file == null
                                      ? const Icon(Icons.add, size: 30)
                                      : Text(
                                          file.name,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),

                    const SizedBox(height: 8),

                    GestureDetector(
                      onTap: () async {
                        try {
                          final welfare =
                              await WelfareService.fetchScholarshipWelfare();

                          if (welfare != null && context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    WelfareTypePage(welfare: welfare),
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("ไม่สามารถโหลดรายละเอียดได้"),
                            ),
                          );
                        }
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, size: 18, color: Color(0xFF007AFF)),
                          SizedBox(width: 6),
                          Text(
                            "ดาวน์โหลดใบสมัครและแบบฟอร์มที่เกี่ยวข้อง",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF007AFF),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: isLoading
                            ? const LinearGradient(
                                colors: [Color(0xFFB0BEC5), Color(0xFF90A4AE)],
                              )
                            : const LinearGradient(
                                colors: [Color(0xFF4F8CFF), Color(0xFF3A6FF7)],
                              ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: isLoading ? null : submitApplication,
                          child: Center(
                            child: isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.send_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        "Submit",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback? onTap;

  const _TabButton({required this.title, required this.isActive, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.blueAccent : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black87,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
