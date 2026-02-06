import 'package:flutter/material.dart';
import 'package:myproject/models/myscholarship.dart';
import 'package:myproject/services/scholarshipApplication_service.dart';

class MyScholarshipPage extends StatefulWidget {
  const MyScholarshipPage({super.key});

  @override
  State<MyScholarshipPage> createState() => _MyScholarshipPageState();
}

class _MyScholarshipPageState extends State<MyScholarshipPage> {
  late Future<List<ScholarshipApplication>> future;

  @override
  void initState() {
    super.initState();
    future = ScholarshipService.getMyHistory(3);
    // 👆 ใส่ userId จริงจาก login ตรงนี้
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===============================
            // HEADER
            // ===============================
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'MY SCHOLARSHIP',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            // ===============================
            // LIST
            // ===============================
            Expanded(
              child: FutureBuilder<List<ScholarshipApplication>>(
                future: future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล'),
                    );
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
                    padding: const EdgeInsets.all(16),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = list[index];
                      return _ScholarshipItem(item: item);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ===============================
/// ITEM
/// ===============================
class _ScholarshipItem extends StatelessWidget {
  final ScholarshipApplication item;

  const _ScholarshipItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.scholarshipTitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ส่งเอกสารแล้ว ${item.submittedCount} รายการ',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          _StatusBadge(status: item.status),
        ],
      ),
    );
  }
}

/// ===============================
/// STATUS BADGE
/// ===============================
class _StatusBadge extends StatelessWidget {
  final ApplyStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    late Color bgColor;

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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
