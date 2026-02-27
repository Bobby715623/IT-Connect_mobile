import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/activity_port.dart';
import 'activity_port_detail.dart';
import 'activity_post_page.dart';
import 'activity_history_page.dart';
import 'create_activity_page.dart';

class ActivityDetailPage extends StatefulWidget {
  final int activityId;
  final int userId;

  const ActivityDetailPage({
    super.key,
    required this.activityId,
    required this.userId,
  });

  @override
  State<ActivityDetailPage> createState() => _ActivityDetailPageState();
}

class _ActivityDetailPageState extends State<ActivityDetailPage> {
  Activity? activity;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchActivity();
  }

  Future<void> fetchActivity() async {
    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:3000/api/Activity/${widget.activityId}"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        print("RAW JSON: $data");

        final fetchedActivity = Activity.fromJson(data);

        print("RELATED POST ID: ${fetchedActivity.relatedPostId}");

        setState(() {
          activity = Activity.fromJson(data);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load activity");
      }
    } catch (e) {
      debugPrint("FETCH ERROR: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _confirmDelete() async {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "ลบกิจกรรม",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "คุณแน่ใจหรือไม่ว่าต้องการลบกิจกรรมนี้?",
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "ยกเลิก",
                      style: TextStyle(
                        color: Color(0xFF8E8E93),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context); // ปิด dialog ก่อน
                      await _deleteActivity();
                    },
                    child: const Text(
                      "ลบ",
                      style: TextStyle(
                        color: Color(0xFFFF3B30),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteActivity() async {
    try {
      final response = await http.delete(
        Uri.parse("http://10.0.2.2:3000/api/Activity/${widget.activityId}"),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context, true); // กลับหน้าเดิม
      } else {
        throw Exception("Delete failed");
      }
    } catch (e) {
      debugPrint("DELETE ERROR: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("เกิดข้อผิดพลาดในการลบ")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (activity == null) {
      return const Scaffold(body: Center(child: Text("ไม่พบข้อมูลกิจกรรม")));
    }

    final statusColor = activity!.status.color;
    final statusLabel = activity!.status.label;

    final bool isWaiting = activity!.status == ActivityStatus.waitForProcess;

    final bool canDelete = isWaiting;
    final bool canEdit = isWaiting;

    final evidences = activity!.evidences ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              /// 🔥 TABS
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
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
              ),

              const SizedBox(height: 28),

              /// 🔥 TITLE + STATUS (ใหม่ สวยขึ้น)
              /// CARD HEADER (อยู่ใน card เท่านั้น)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ListView(
                    children: [
                      /// HEADER + STATUS
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "รายละเอียดกิจกรรม",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Row(
                            children: [
                              if (canEdit)
                                GestureDetector(
                                  onTap: () async {
                                    print("ACTIVITY ID: ${activity!.id}");
                                    print(
                                      "ACTIVITY PORT ID: ${activity!.activityPortID}",
                                    );
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => CreateActivityPage(
                                          portId: activity!.activityPortID,
                                          activity: activity,
                                          isEdit: true,
                                          fromPost:
                                              activity!.relatedPostId != null,
                                          userId: widget.userId,
                                        ),
                                      ),
                                    );

                                    if (result == true) {
                                      fetchActivity();
                                    }
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 10),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blueAccent.withOpacity(
                                        0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      "แก้ไข",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blueAccent,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  statusLabel,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      _buildField("ชื่อกิจกรรม", activity!.name ?? ""),
                      _buildField("สถานที่", activity!.location ?? ""),
                      _buildField("รายละเอียด", activity!.description ?? ""),

                      /// TOTAL HOURS (Modern Card Style)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Color(0xFFE5E5EA)),
                            bottom: BorderSide(color: Color(0xFFE5E5EA)),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "จำนวนชั่วโมง",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF8E8E93),
                                letterSpacing: 0.8,
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "${activity!.hour ?? 0}",
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: " hrs",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF8E8E93),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      /// EVIDENCE LABEL
                      _buildFieldLabel("รูปภาพหลักฐาน"),

                      const SizedBox(height: 16),

                      if (evidences.isEmpty)
                        const Text(
                          "ไม่มีรูปภาพ",
                          style: TextStyle(color: Colors.grey),
                        ),

                      if (evidences.isNotEmpty)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: evidences.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 1,
                              ),
                          itemBuilder: (context, index) {
                            final e = evidences[index];
                            final imageUrl =
                                "http://10.0.2.2:3000/uploads/${e.picture}";
                            final heroTag = "image_${e.picture}";

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FullScreenImagePage(
                                      imageUrl: imageUrl,
                                      tag: heroTag,
                                    ),
                                  ),
                                );
                              },
                              child: Hero(
                                tag: heroTag,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 30),

                      if (canDelete)
                        GestureDetector(
                          onTap: _confirmDelete,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF3B30).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Center(
                              child: Text(
                                "ลบการยื่นขอชั่วโมงกิจกรรมนี้",
                                style: TextStyle(
                                  color: Color(0xFFFF3B30),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: Text(
                              "ไม่สามารถลบได้ (อนุมัติแล้ว)",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF8E8E93),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 15, height: 1.4)),
        ],
      ),
    );
  }
}

Widget _buildFieldLabel(String label) {
  return Text(
    label.toUpperCase(),
    style: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: Color(0xFF8E8E93),
      letterSpacing: 0.8,
    ),
  );
}

/// FULLSCREEN IMAGE PREVIEW
class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;
  final String tag;

  const FullScreenImagePage({
    super.key,
    required this.imageUrl,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Hero(
                tag: tag,
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Image.network(imageUrl, fit: BoxFit.contain),
                ),
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, color: Colors.white, size: 28),
              ),
            ),
          ],
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
