import 'package:flutter/material.dart';
import '../models/notification.dart';
import '../services/notification_service.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late Future<List<AppNotification>> futureNotifications;

  @override
  void initState() {
    super.initState();
    futureNotifications = NotificationService.getMyNotifications(3);
    // 👆 ใส่ UserID จริงจากตอน login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<List<AppNotification>>(
          future: futureNotifications,
          builder: (context, snapshot) {
            // กำลังโหลด
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // error
            if (snapshot.hasError) {
              return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
            }

            final notifications = snapshot.data!;

            // ไม่มีข้อมูล
            if (notifications.isEmpty) {
              return const Center(child: Text('ไม่มีการแจ้งเตือน'));
            }

            return ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final item = notifications[index];

                return NotificationCard(
                  title: item.title ?? '-',
                  date: item.time != null
                      ? '${item.time!.day}/${item.time!.month}/${item.time!.year}'
                      : '-',
                  time: item.time != null
                      ? '${item.time!.hour.toString().padLeft(2, '0')}:${item.time!.minute.toString().padLeft(2, '0')}'
                      : '',
                  isRead: item.isRead, // เอาไปทำจุดแดง 🔴 ได้
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String title;
  final String date;
  final String time;
  final bool isRead;

  const NotificationCard({
    super.key,
    required this.title,
    required this.date,
    required this.time,
    this.isRead = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(title: Text(title), subtitle: Text('$date • $time')),
        ),

        if (!isRead)
          Positioned(
            top: 12,
            right: 24,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}
