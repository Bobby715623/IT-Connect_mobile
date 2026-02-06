import 'package:flutter/material.dart';
import 'package:myproject/screens/scholarship_detail_page.dart';
import 'package:myproject/screens/myscholarship.dart';
import 'package:myproject/models/scholarship.dart';
import 'package:myproject/services/scholarship_service.dart';

class ScholarshipPage extends StatefulWidget {
  final VoidCallback onGoHome;

  const ScholarshipPage({super.key, required this.onGoHome});

  @override
  State<ScholarshipPage> createState() => _ScholarshipPageState();
}

class _ScholarshipPageState extends State<ScholarshipPage> {
  late Future<List<Scholarship>> _scholarshipsFuture;

  @override
  void initState() {
    super.initState();
    _scholarshipsFuture = ScholarshipService.fetchScholarships();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Tabs =====
              Row(
                children: [
                  const _TabButton(title: 'ALL SCHOLARSHIP', isActive: true),
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

              const SizedBox(height: 12),

              // ===== HOME =====
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: GestureDetector(
                  onTap: widget.onGoHome,
                  child: Row(
                    children: const [
                      Icon(Icons.arrow_back_ios, size: 14, color: Colors.blue),
                      SizedBox(width: 4),
                      Text(
                        'HOME',
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

              const SizedBox(height: 8),

              // ===== Scholarship List (API) =====
              Expanded(
                child: FutureBuilder<List<Scholarship>>(
                  future: _scholarshipsFuture,
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

                    final scholarships = snapshot.data!;

                    if (scholarships.isEmpty) {
                      return const Center(child: Text('ยังไม่มีทุนการศึกษา'));
                    }

                    return ListView.builder(
                      itemCount: scholarships.length,
                      itemBuilder: (context, index) {
                        final s = scholarships[index];
                        return _ScholarshipItem(
                          title: s.name,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ScholarshipDetailPage(scholarshipId: s.id),
                              ),
                            );
                          },
                        );
                      },
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

class _ScholarshipItem extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const _ScholarshipItem({required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(title, style: const TextStyle(fontSize: 14)),
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
