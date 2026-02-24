import 'package:flutter/material.dart';
import 'package:myproject/models/myscholarship.dart';
import 'package:myproject/screens/navigation_bar.dart';
import 'package:myproject/services/scholarshipApplication_service.dart';
import 'myscholarship_detail_page.dart';
import 'home.dart';

class MyScholarshipPage extends StatefulWidget {
  final VoidCallback onGoHome;
  final int userId;

  const MyScholarshipPage({
    super.key,
    required this.onGoHome,
    required this.userId,
  });

  @override
  State<MyScholarshipPage> createState() => _MyScholarshipPageState();
}

class _MyScholarshipPageState extends State<MyScholarshipPage> {
  late Future<List<ScholarshipApplication>> future;

  @override
  void initState() {
    super.initState();
    future = ScholarshipService.getMyHistory(widget.userId);
    // 👆 ใส่ userId จริงจาก login ตรงนี้
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

              /// ===== HEADER (เหมือนเดิม) =====
              Row(
                children: [
                  _TabButton(
                    title: 'ALL SCHOLARSHIP',
                    isActive: false,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 8),
                  const _TabButton(title: 'MY SCHOLARSHIP', isActive: true),
                ],
              ),

              const SizedBox(height: 12),

              GestureDetector(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MainNavigation(userId: widget.userId),
                    ),
                    (route) => false,
                  );
                },
                child: const Row(
                  children: [
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

              const SizedBox(height: 24),

              /// ===== TITLE =====
              const Text(
                "ทุนที่ฉันสมัคร",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              /// ===== LIST =====
              Expanded(
                child: FutureBuilder<List<ScholarshipApplication>>(
                  future: future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          'ยังไม่เคยยื่นขอทุน',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    final list = snapshot.data!;

                    return ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final item = list[index];
                        return _ModernScholarshipCard(
                          item: item,
                          userId: widget.userId,
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

/// ===============================
/// ITEM
/// ===============================
class _ModernScholarshipCard extends StatelessWidget {
  final ScholarshipApplication item;
  final int userId;

  const _ModernScholarshipCard({required this.item, required this.userId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MyScholarshipDetailPage(
              applicationId: item.applicationID,
              userId: userId,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.school,
                size: 20,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.scholarshipTitle,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'ส่งเอกสารแล้ว ${item.submittedCount} รายการ',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            _ModernStatusBadge(status: item.status),
          ],
        ),
      ),
    );
  }
}

/// ===============================
/// STATUS BADGE
/// ===============================
class _ModernStatusBadge extends StatelessWidget {
  final ApplyStatus status;

  const _ModernStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;

    switch (status) {
      case ApplyStatus.inProgress:
        bgColor = Colors.orange;
        break;
      case ApplyStatus.pass:
        bgColor = Colors.green;
        break;
      case ApplyStatus.fail:
        bgColor = Colors.red;
        break;
      case ApplyStatus.considering:
        bgColor = Colors.blue;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: bgColor,
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
