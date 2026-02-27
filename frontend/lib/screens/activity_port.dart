import 'package:flutter/material.dart';
import '../models/activity_port.dart';
import '../services/activity_port_service.dart';
import 'activity_port_detail.dart';

class ActivityPage extends StatefulWidget {
  final VoidCallback onGoHome;
  final int userId;

  const ActivityPage({super.key, required this.onGoHome, required this.userId});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  late Future<List<ActivityPort>> _future;

  @override
  void initState() {
    super.initState();
    _future = ActivityPortService.fetchByUser(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "My Activity Port",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),

              GestureDetector(
                onTap: widget.onGoHome,
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

              const SizedBox(height: 16),

              Expanded(
                child: FutureBuilder<List<ActivityPort>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Error: ${snapshot.error}",
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    final ports = snapshot.data!;

                    if (ports.isEmpty) {
                      return const Center(child: Text("ยังไม่มี Activity"));
                    }

                    return ListView.builder(
                      itemCount: ports.length,
                      itemBuilder: (context, index) {
                        final p = ports[index];

                        // ตัวอย่างคำนวณเปอร์เซ็นต์ mock
                        // 🔹 รวมชั่วโมงที่ทำไปแล้ว

                        int hourDone = p.activities
                            .where(
                              (act) => act.status == ActivityStatus.approve,
                            )
                            .fold(0, (sum, act) => sum + (act.hour ?? 0));

                        // 🔹 คำนวณเปอร์เซ็นต์จริง
                        double percent = 0;

                        if (p.hourNeed != null && p.hourNeed! > 0) {
                          percent = hourDone / p.hourNeed!;

                          if (percent > 1) {
                            percent = 1;
                          }
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ActivityPortDetailPage(
                                    portId: p.id,
                                    userId: widget.userId,
                                  ),
                                ),
                              );
                            },
                            child: ActivityCard(
                              title: p.portname ?? "",
                              percent: percent,
                              date: p.endDate != null
                                  ? "${p.endDate!.day}/${p.endDate!.month}/${p.endDate!.year}"
                                  : "-",
                              hourNeed: p.hourNeed ?? 0,
                              hourDone: hourDone,
                            ),
                          ),
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

class ActivityCard extends StatelessWidget {
  final String title;
  final double percent;
  final String date;
  final int hourNeed;
  final int hourDone;

  const ActivityCard({
    super.key,
    required this.title,
    required this.percent,
    required this.date,
    required this.hourNeed,
    required this.hourDone,
  });

  @override
  Widget build(BuildContext context) {
    const Color iosBlue = Color(0xFF007AFF);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Row(
        children: [
          /// TEXT SIDE
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "หมดอายุ $date",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8E8E93),
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  "$hourDone / $hourNeed ชั่วโมง",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          /// PROGRESS RING
          SizedBox(
            width: 70,
            height: 70,
            child: Stack(
              alignment: Alignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: percent),
                  duration: const Duration(milliseconds: 800),
                  builder: (context, value, child) {
                    return CircularProgressIndicator(
                      value: value,
                      strokeWidth: 5,
                      backgroundColor: const Color(0xFFE5E5EA),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF007AFF),
                      ),
                    );
                  },
                ),
                Text(
                  "${(percent * 100).toInt()}%",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: iosBlue,
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
