import 'package:flutter/material.dart';
import 'package:myproject/screens/upload_document.dart';
import 'package:myproject/screens/myscholarship.dart';
import 'package:myproject/models/scholarship.dart';
import 'package:myproject/services/scholarship_service.dart';

class ScholarshipDetailPage extends StatelessWidget {
  final int scholarshipId;

  const ScholarshipDetailPage({super.key, required this.scholarshipId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<Scholarship>(
          future: ScholarshipService.fetchScholarshipById(scholarshipId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'เกิดข้อผิดพลาด: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            final scholarship = snapshot.data!;

            return Column(
              children: [
                // ===== Tabs =====
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const _TabButton(
                        title: 'ALL SCHOLARSHIP',
                        isActive: true,
                      ),
                      const SizedBox(width: 8),
                      _TabButton(
                        title: 'MY SCHOLARSHIP',
                        isActive: false,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MyScholarshipPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // ===== BACK =====
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.arrow_back_ios,
                          size: 14,
                          color: Colors.blue,
                        ),
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

                // ===== CONTENT =====
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          scholarship.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          scholarship.description,
                          style: const TextStyle(fontSize: 13, height: 1.6),
                        ),
                      ],
                    ),
                  ),
                ),

                // ===== BOTTOM BAR =====
                _BottomBar(scholarship: scholarship),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final Scholarship scholarship;

  const _BottomBar({super.key, required this.scholarship});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: const [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.red,
                    child: Icon(
                      Icons.picture_as_pdf,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'ใบสมัครขอรับทุน',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      UploadDocumentPage(scholarshipId: scholarship.id),
                ),
              );
            },
            child: const Text(
              'ยื่นทุน',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
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
