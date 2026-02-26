import 'package:flutter/material.dart';
import 'package:myproject/screens/upload_document.dart';
import 'package:myproject/models/scholarship.dart';
import 'package:myproject/services/scholarship_service.dart';
import 'package:myproject/screens/myscholarship.dart';

class ScholarshipDetailPage extends StatelessWidget {
  final int scholarshipId;
  final int userId;

  const ScholarshipDetailPage({
    super.key,
    required this.scholarshipId,
    required this.userId,
  });

  String formatThaiDate(DateTime? date) {
    if (date == null) return "-";

    final thaiMonths = [
      "",
      "มกราคม",
      "กุมภาพันธ์",
      "มีนาคม",
      "เมษายน",
      "พฤษภาคม",
      "มิถุนายน",
      "กรกฎาคม",
      "สิงหาคม",
      "กันยายน",
      "ตุลาคม",
      "พฤศจิกายน",
      "ธันวาคม",
    ];

    final buddhistYear = date.year + 543;
    return "${date.day} ${thaiMonths[date.month]} $buddhistYear";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ===== HEADER AREA =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      _TabButton(
                        title: 'ALL SCHOLARSHIP',
                        isActive: true,
                        onTap: () => Navigator.pop(context),
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
                                userId: userId,
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

                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Row(
                      children: [
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

                  const SizedBox(height: 20),
                ],
              ),
            ),

            /// ===== CONTENT =====
            Expanded(
              child: FutureBuilder<Scholarship>(
                future: ScholarshipService.fetchScholarshipById(scholarshipId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final scholarship = snapshot.data!;

                  return ListView(
                    padding: const EdgeInsets.only(bottom: 40),
                    children: [
                      /// ===== HERO IMAGE =====
                      Stack(
                        children: [
                          SizedBox(
                            height: 220,
                            width: double.infinity,
                            child:
                                scholarship.picture != null &&
                                    scholarship.picture!.isNotEmpty
                                ? Image.network(
                                    scholarship.picture!,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color: Colors.grey.shade300,
                                    child: const Center(
                                      child: Icon(
                                        Icons.image_not_supported,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                          ),
                          Container(
                            height: 220,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.2),
                                  Colors.black.withOpacity(0.6),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 20,
                            left: 20,
                            right: 20,
                            child: Text(
                              scholarship.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      /// ===== BODY SECTION =====
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            _sectionCard(
                              icon: Icons.description,
                              title: "รายละเอียดทุน",
                              child: Text(
                                scholarship.description,
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.8,
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            _sectionCard(
                              icon: Icons.timer,
                              title: "เงื่อนไขกิจกรรม",
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "ต้องทำกิจกรรมทั้งหมด ${scholarship.activityHourNeeded} ชั่วโมง",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.event_available,
                                        size: 18,
                                        color: Colors.redAccent,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "หมดเขตภายในวันที่ ${formatThaiDate(scholarship.activityDeadline)}",
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            _buildScheduleSection(scholarship),

                            const SizedBox(height: 30),

                            _buildApplyButton(context, scholarship),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blueAccent),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildApplyButton(BuildContext context, Scholarship scholarship) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFF4F8CFF), Color(0xFF3A6FF7)],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UploadDocumentPage(
                  scholarshipId: scholarship.id,
                  requirements: scholarship.requirements,
                  userId: userId,
                ),
              ),
            );
          },
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.upload_file_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text(
                "ยื่นขอรับทุน",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleSection(Scholarship scholarship) {
    return _sectionCard(
      icon: Icons.calendar_today,
      title: "กำหนดการกิจกรรม",
      child: Column(
        children: [
          _ScheduleItem(
            title: "วันเปิดรับสมัคร",
            date: formatThaiDate(scholarship.startDate),
            color: Colors.black87,
          ),
          _ScheduleItem(
            title: "วันปิดรับสมัคร",
            date: formatThaiDate(scholarship.endDate),
            color: Colors.red,
          ),
          _ScheduleItem(
            title: "ประกาศรายชื่อสัมภาษณ์",
            date: formatThaiDate(scholarship.announceInterviewDate),
            color: Colors.blue,
          ),
          _ScheduleItem(
            title: "วันสอบสัมภาษณ์",
            date: formatThaiDate(scholarship.interviewDate),
            color: Colors.purple,
          ),

          if (scholarship.interviewPlace != null &&
              scholarship.interviewPlace!.isNotEmpty)
            _ScheduleItem(
              title: "สถานที่สอบสัมภาษณ์",
              date: scholarship.interviewPlace!,
              color: Colors.purple,
              icon: Icons.location_on, // ⭐ ใส่ icon ตรงนี้
            ),

          _ScheduleItem(
            title: "วันประกาศผล",
            date: formatThaiDate(scholarship.winnerAnnounceDate),
            color: Colors.green,
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

class _ScheduleItem extends StatelessWidget {
  final String title;
  final String date;
  final Color color;
  final IconData? icon; // ⭐ เพิ่ม

  const _ScheduleItem({
    required this.title,
    required this.date,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: color),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(
                    date,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
