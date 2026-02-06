import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UploadDocumentPage extends StatefulWidget {
  final int scholarshipId; // ⭐ รับมาจากหน้า detail

  const UploadDocumentPage({super.key, required this.scholarshipId});

  @override
  State<UploadDocumentPage> createState() => _UploadDocumentPageState();
}

class _UploadDocumentPageState extends State<UploadDocumentPage> {
  List<PlatformFile> files = [];
  bool isLoading = false;

  // ===============================
  // เลือกไฟล์จากเครื่อง
  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg'],
      withData: true, // ⭐ สำคัญ
    );

    if (result != null) {
      setState(() {
        files.addAll(result.files);
      });
    }
  }

  // ===============================
  // ดึง token (ตัวอย่าง)
  Future<String> getAccessToken() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'access_token');
    return token ?? '';
  }

  // ===============================
  // ส่งข้อมูล + ไฟล์ไป backend
  Future<void> submitApplication() async {
    if (files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาแนบไฟล์อย่างน้อย 1 ไฟล์')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final uri = Uri.parse('http://10.0.2.2:3000/api/scholarship/apply');

      final request = http.MultipartRequest('POST', uri);

      // ===== fields =====
      request.fields['ScholarshipID'] = widget.scholarshipId.toString();

      request.fields['Submissions'] = jsonEncode([
        {"RequirementID": 1},
        {"RequirementID": 2},
      ]);

      // ===== แนบไฟล์ =====
      for (final file in files) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'files',
            file.bytes!,
            filename: file.name,
          ),
        );
      }

      // ===== แนบ token =====
      final token = await getAccessToken();
      request.headers['Authorization'] = 'Bearer $token';

      final response = await request.send();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('ส่งเอกสารสำเร็จ')));
        setState(() {
          files.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ส่งไม่สำเร็จ (status: ${response.statusCode})'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // ===============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== HEADER =====
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: const [
                  _TabButton(title: 'ALL SCHOLARSHIP', isActive: true),
                  SizedBox(width: 8),
                  _TabButton(title: 'MY SCHOLARSHIP', isActive: false),
                ],
              ),
            ),

            // ===== BACK =====
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
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
            ),

            const SizedBox(height: 12),

            // ===== CONTENT =====
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ยื่นเอกสารขอทุนช่วยเหลือค่าใช้จ่ายทางการศึกษาแบบฉุกเฉิน',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('ไฟล์เอกสาร', style: TextStyle(fontSize: 12)),
                      const SizedBox(height: 12),

                      // ===== FILE GRID =====
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          ...files.map((file) => _FileItem(name: file.name)),
                          GestureDetector(
                            onTap: _pickFile,
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.add),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: isLoading ? null : submitApplication,
                          child: isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Submit',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== TAB BUTTON =====
class _TabButton extends StatelessWidget {
  final String title;
  final bool isActive;

  const _TabButton({required this.title, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? Colors.blueAccent : Colors.grey.shade300,
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
    );
  }
}

// ===== FILE ITEM =====
class _FileItem extends StatelessWidget {
  final String name;

  const _FileItem({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(
          name.toLowerCase().endsWith('.pdf')
              ? Icons.picture_as_pdf
              : Icons.image,
          color: Colors.red,
        ),
      ),
    );
  }
}
