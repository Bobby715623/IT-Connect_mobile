import 'package:flutter/material.dart';

import 'package:myproject/services/scholarshipApplication_service.dart';
import 'package:myproject/models/myscholarship.dart';
import 'package:myproject/screens/myscholarship.dart';
import 'package:myproject/screens/scholarship.dart';
import '../config/app_config.dart';
import 'pdf_preview.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class MyScholarshipDetailPage extends StatefulWidget {
  final int applicationId;
  final int userId;

  const MyScholarshipDetailPage({
    super.key,
    required this.applicationId,
    required this.userId,
  });

  @override
  State<MyScholarshipDetailPage> createState() =>
      _MyScholarshipDetailPageState();
}

class _MyScholarshipDetailPageState extends State<MyScholarshipDetailPage> {
  late Future<ScholarshipApplication> future;

  @override
  void initState() {
    super.initState();
    future = ScholarshipService.getApplicationDetail(widget.applicationId);
  }

  Future<void> downloadFile(String url) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final fileName = url.split('/').last;
      final savePath = "${dir.path}/$fileName";

      await Dio().download(url, savePath);

      OpenFilex.open(savePath);
    } catch (e) {
      print("Download error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    //fomat เวลาที่ส่ง
    String formatThaiDateTimeShort(DateTime? date) {
      if (date == null) return "-";

      final thaiYear = date.year + 543;

      final month = DateFormat.MMM('th_TH').format(date);
      final day = date.day;
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');

      return "$day $month $thaiYear เวลา $hour:$minute น.";
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              /// ===== HEADER =====
              Row(
                children: [
                  _TabButton(
                    title: 'ALL SCHOLARSHIP',
                    isActive: false,
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ScholarshipPage(
                            userId: widget.userId,
                            onGoHome: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  const _TabButton(title: 'MY SCHOLARSHIP', isActive: true),
                ],
              ),

              const SizedBox(height: 12),

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
                child: FutureBuilder<ScholarshipApplication>(
                  future: future,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final data = snapshot.data!;

                    return ListView(
                      children: [
                        Text(
                          data.scholarshipTitle,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          "วันที่สมัคร: ${formatThaiDateTimeShort(data.applicationDate)}",
                          style: const TextStyle(color: Colors.grey),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          "เอกสารที่ส่ง",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 12),

                        ...data.submissions.map((doc) {
                          final fileUrl =
                              "${AppConfig.baseUrl}/${doc.studentDocument}";

                          final isPdf = fileUrl.toLowerCase().endsWith(".pdf");
                          final isImage =
                              fileUrl.toLowerCase().endsWith(".jpg") ||
                              fileUrl.toLowerCase().endsWith(".png") ||
                              fileUrl.toLowerCase().endsWith(".jpeg");

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isPdf ? Icons.picture_as_pdf : Icons.image,
                                  color: Colors.blueAccent,
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: Text(doc.requirementName)),

                                /// 👀 Preview
                                IconButton(
                                  icon: const Icon(Icons.visibility),
                                  onPressed: () {
                                    PdfPreview.show(
                                      context,
                                      "${AppConfig.baseUrl}/${doc.studentDocument}",
                                    );
                                  },
                                ),

                                /// ⬇️ Download
                                IconButton(
                                  icon: const Icon(Icons.download),
                                  onPressed: () {
                                    downloadFile(fileUrl);
                                  },
                                ),
                              ],
                            ),
                          );
                        }),

                        const SizedBox(height: 40),
                      ],
                    );
                  },
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
      ),
    );
  }
}
