import 'package:flutter/material.dart';
import '../models/activity_port.dart';
import '../services/activity_port_service.dart';
import 'add_activity_page.dart';
import 'activity_detail_page.dart';

class ActivityPortDetailPage extends StatefulWidget {
  final int portId;

  const ActivityPortDetailPage({super.key, required this.portId});

  @override
  State<ActivityPortDetailPage> createState() => _ActivityPortDetailPageState();
}

class _ActivityPortDetailPageState extends State<ActivityPortDetailPage> {
  late Future<ActivityPort> _future;

  int selectedTab = 0; // 0 = MY, 1 = ALL, 2 = HISTORY

  @override
  void initState() {
    super.initState();
    _future = ActivityPortService.fetchSingle(widget.portId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: FutureBuilder<ActivityPort>(
          future: _future,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final port = snapshot.data!;
            final activities = port.activities ?? [];

            /// 🔥 filter ตาม tab
            List<Activity> filteredActivities;

            if (selectedTab == 0) {
              // MY ACTIVITY → approve
              filteredActivities = activities
                  .where((a) => a.status == "approve")
                  .toList();
            } else if (selectedTab == 1) {
              // 🔥 HISTORY (reject)
              filteredActivities = activities
                  .where((a) => a.status == "reject")
                  .toList();
            } else {
              // 🔥 ACTIVITY (ทั้งหมด)
              filteredActivities = activities;
            }

            /// 🔥 progress นับเฉพาะ approve
            int totalHour = activities
                .where((a) => a.status == "approve")
                .fold(0, (sum, a) => sum + (a.hour ?? 0));

            double percent = 0;
            if (port.hourNeed != null && port.hourNeed! > 0) {
              percent = totalHour / port.hourNeed!;
              if (percent > 1) percent = 1;
            }

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  /// 🔥 TABS
                  Row(
                    children: [
                      _TabButton(
                        title: "MY ACTIVITY",
                        isActive: selectedTab == 0,
                        onTap: () {
                          setState(() => selectedTab = 0);
                        },
                      ),
                      const SizedBox(width: 8),
                      _TabButton(
                        title: "ACTIVITY",
                        isActive: selectedTab == 1,
                        onTap: () {
                          setState(() => selectedTab = 1);
                        },
                      ),
                      const SizedBox(width: 8),
                      _TabButton(
                        title: "HISTORY",
                        isActive: selectedTab == 2,
                        onTap: () {
                          setState(() => selectedTab = 2);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// BACK
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
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
                  ),

                  const SizedBox(height: 20),

                  /// CIRCLE
                  if (selectedTab == 0) ...[
                    SizedBox(
                      width: 230,
                      height: 230,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          /// วงพื้นหลังเทา
                          SizedBox(
                            width: 230,
                            height: 230,
                            child: CircularProgressIndicator(
                              value: 1,
                              strokeWidth: 26,
                              backgroundColor: Colors.grey.shade300,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.grey.shade300,
                              ),
                            ),
                          ),

                          /// วง progress สีเขียว
                          SizedBox(
                            width: 230,
                            height: 230,
                            child: CircularProgressIndicator(
                              value: percent,
                              strokeWidth: 26,
                              backgroundColor: Colors.transparent,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.green,
                              ),
                            ),
                          ),

                          /// ตัวเลขตรงกลาง
                          Text(
                            "$totalHour",
                            style: const TextStyle(
                              fontSize: 60,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),

                  /// LIST
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredActivities.length,
                      itemBuilder: (context, index) {
                        final a = filteredActivities[index];
                        final status = a.status ?? "waitforprocess";

                        Color badgeColor;

                        switch (status) {
                          case "approve":
                            badgeColor = Colors.green.shade200;
                            break;
                          case "reject":
                            badgeColor = Colors.red.shade200;
                            break;
                          default:
                            badgeColor = Colors.orange.shade200;
                        }

                        return InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ActivityDetailPage(activity: a),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 5),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    a.name ?? "",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Text(
                                  "${a.hour ?? 0}",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: badgeColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    status,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateActivityPage(portId: widget.portId),
            ),
          );

          if (result == true) {
            // 🔥 สลับไปหน้า HISTORY (สมมุติ index = 2)
            setState(() {
              selectedTab = 2; // 👈 สำคัญ
              _future = ActivityPortService.fetchSingle(widget.portId);
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// 🔥 Custom Tab Button
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
          color: isActive ? Colors.blue : Colors.grey.shade300,
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
