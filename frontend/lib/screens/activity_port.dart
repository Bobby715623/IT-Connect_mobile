import 'package:flutter/material.dart';
import '../models/activity_port.dart';
import '../services/activity_port_service.dart';
import 'activity_port_detail.dart';

class ActivityPage extends StatefulWidget {
  final VoidCallback onGoHome;

  const ActivityPage({super.key, required this.onGoHome});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  late Future<List<ActivityPort>> _future;

  @override
  void initState() {
    super.initState();
    _future = ActivityPortService.fetchByUser(3);
    // 👆 ใส่ userId จาก login จริงภายหลัง
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
              const Text(
                "MY ACTIVITY PORT",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                        double percent = 0.0;
                        if (p.hourNeed != null && p.hourNeed! > 0) {
                          percent = 0.5; // ใส่ logic จริงภายหลัง
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ActivityPortDetailPage(portId: p.id),
                                ),
                              );
                            },
                            child: ActivityCard(
                              title: p.portname ?? "",
                              percent: percent,
                              date: p.endDate != null
                                  ? "${p.endDate!.day}/${p.endDate!.month}/${p.endDate!.year}"
                                  : "-",
                              gradientColors: p.type == "Scholarship"
                                  ? const [Color(0xFFA18CD1), Color(0xFFFBC2EB)]
                                  : const [
                                      Color(0xFFFF9A9E),
                                      Color(0xFFFAD0C4),
                                    ],
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
  final List<Color> gradientColors;

  const ActivityCard({
    super.key,
    required this.title,
    required this.percent,
    required this.date,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "วันหมดอายุ $date",
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: percent,
                  strokeWidth: 8,
                  backgroundColor: Colors.white.withOpacity(0.5),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                ),
                Text(
                  "${(percent * 100).toInt()}%",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
