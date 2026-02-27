import 'package:flutter/material.dart';
import '../models/activity_port.dart';
import '../services/activity_port_service.dart';
import '../services/activity_post_service.dart';
import 'create_activity_page.dart';
import 'activity_detail_page.dart';
import 'activity_history_page.dart';
import 'activity_post_page.dart';

class ActivityPortDetailPage extends StatefulWidget {
  final int portId;
  final int userId;

  const ActivityPortDetailPage({
    super.key,
    required this.portId,
    required this.userId,
  });

  @override
  State<ActivityPortDetailPage> createState() => _ActivityPortDetailPageState();
}

class _ActivityPortDetailPageState extends State<ActivityPortDetailPage> {
  late Future<ActivityPort> _future;
  late Future<List<dynamic>> _postFuture;

  int selectedTab = 0; // 0 = MY, 1 = ALL

  @override
  void initState() {
    super.initState();
    _future = ActivityPortService.fetchSingle(widget.portId);
    _postFuture = ActivityPostService.fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
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
              filteredActivities = activities
                  .where((a) => a.status == ActivityStatus.approve)
                  .toList();
            } else {
              filteredActivities = activities;
            }

            /// 🔥 progress นับเฉพาะ approve
            int totalHour = activities
                .where((a) => a.status == ActivityStatus.approve)
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
                      const _TabButton(title: 'MY ACTIVITY', isActive: true),
                      const SizedBox(width: 8),
                      _TabButton(
                        title: 'ACTIVITY',
                        isActive: false,
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ActivityPostPage(
                                portId: widget.portId,
                                userId: widget.userId,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      _TabButton(
                        title: 'HISTORY',
                        isActive: false,
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ActivityHistoryPage(
                                portId: widget.portId,
                                userId: widget.userId,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

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

                  /// CIRCLE (Green + Grey Overlay Style)
                  if (selectedTab == 0) ...[
                    Center(
                      child: SizedBox(
                        width: 230,
                        height: 230,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            /// 🔹 วงพื้นหลังสีเทาเต็ม 100%
                            SizedBox(
                              width: 230,
                              height: 230,
                              child: CircularProgressIndicator(
                                value: 1,
                                strokeWidth: 24,
                                backgroundColor: const Color(0xFFE5E5EA),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFFE5E5EA),
                                ),
                              ),
                            ),

                            /// 🔹 วงสีเขียวทับด้านบน
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: percent),
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) {
                                return SizedBox(
                                  width: 230,
                                  height: 230,
                                  child: CircularProgressIndicator(
                                    value: value,
                                    strokeWidth: 24,
                                    backgroundColor: Colors.transparent,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          Color(0xFF34C759), // iOS Green
                                        ),
                                  ),
                                );
                              },
                            ),

                            /// 🔹 ตัวเลขกลางวง
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "$totalHour",
                                  style: const TextStyle(
                                    fontSize: 56,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -1,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "/ ${port.hourNeed ?? 0} ชั่วโมง",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF8E8E93),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 10),

                  //ปุ่มเพิ่มกิจกรรม
                  if (selectedTab == 0) ...[
                    const SizedBox(height: 18),

                    GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CreateActivityPage(
                              portId: widget.portId,
                              userId: widget.userId,
                            ),
                          ),
                        );

                        if (result == true) {
                          setState(() {
                            selectedTab = 2;
                            _future = ActivityPortService.fetchSingle(
                              widget.portId,
                            );
                          });
                        }
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, size: 18, color: Color(0xFF007AFF)),
                          SizedBox(width: 6),
                          Text(
                            "เพิ่มกิจกรรม",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF007AFF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),

                  /// LIST
                  Expanded(
                    child: selectedTab == 1
                        ? FutureBuilder<List<dynamic>>(
                            future: _postFuture,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              final posts = snapshot.data!;

                              return ListView.builder(
                                itemCount: posts.length,
                                itemBuilder: (context, index) {
                                  final p = posts[index];

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 18),
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(26),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.04),
                                          blurRadius: 25,
                                          offset: const Offset(0, 12),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: const [
                                            CircleAvatar(
                                              radius: 16,
                                              backgroundColor: Color(
                                                0xFFE5E5EA,
                                              ),
                                              child: Icon(
                                                Icons.person,
                                                size: 16,
                                                color: Colors.black54,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              "STAFF",
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF8E8E93),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 14),
                                        Text(
                                          p["Title"] ?? "",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          p["Description"] ?? "",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF3C3C43),
                                          ),
                                        ),
                                        if (p["Picture"] != null &&
                                            p["Picture"]
                                                .toString()
                                                .isNotEmpty) ...[
                                          const SizedBox(height: 14),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                            child: Image.network(
                                              p["Picture"],
                                              height: 180,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          )
                        : ListView.builder(
                            itemCount: filteredActivities.length,
                            itemBuilder: (context, index) {
                              final a = filteredActivities[index];
                              final status = a.status;
                              final statusColor = status.color;
                              final statusLabel = status.label;

                              return InkWell(
                                borderRadius: BorderRadius.circular(24),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ActivityDetailPage(
                                        activityId: a.id!,
                                        userId: widget.userId,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 14),
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 25,
                                        offset: const Offset(0, 12),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      /// LEFT SIDE
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              a.name ?? "",
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 8),

                                            /// STATUS BADGE (เด่นขึ้น)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: statusColor.withOpacity(
                                                  0.12,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                              ),
                                              child: Text(
                                                statusLabel,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                  color: statusColor,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      /// RIGHT SIDE (HOUR เด่นขึ้น)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            "${a.hour ?? 0}",
                                            style: const TextStyle(
                                              fontSize: 26,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          const Text(
                                            "hrs",
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF8E8E93),
                                            ),
                                          ),
                                        ],
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
