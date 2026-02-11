import 'package:flutter/material.dart';
import '../models/activity_port.dart';

class ActivityDetailPage extends StatelessWidget {
  final Activity activity;

  const ActivityDetailPage({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    Color statusColor;

    switch (activity.status) {
      case "approve":
        statusColor = Colors.green;
        break;
      case "reject":
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              /// BACK
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

              const SizedBox(height: 20),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: ListView(
                    children: [
                      /// HEADER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "รายละเอียดกิจกรรม",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              activity.status ?? "",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      _buildField("ชื่อกิจกรรม", activity.name ?? ""),

                      _buildField("สถานที่", activity.location ?? ""),

                      _buildField("ลักษณะกิจกรรม", activity.description ?? ""),

                      _buildField("จำนวนชั่วโมง", "${activity.hour ?? 0}"),

                      _buildField(
                        "รายละเอียดเพิ่มเติม",
                        activity.comment ?? "-",
                      ),

                      const SizedBox(height: 20),

                      /// รูปภาพ
                      if (activity.evidences != null &&
                          activity.evidences!.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "รูปภาพหลักฐาน",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              children: activity.evidences!
                                  .map(
                                    (e) => Image.network(
                                      e.picture ?? "",
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
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
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
