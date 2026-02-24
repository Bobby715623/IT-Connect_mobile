import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/personal_event.dart';
import '../services/personal_event_service.dart';
import 'create_personal_event_page.dart';

class PersonalEventDetailPage extends StatefulWidget {
  final PersonalEvent event;

  const PersonalEventDetailPage({super.key, required this.event});

  @override
  State<PersonalEventDetailPage> createState() =>
      _PersonalEventDetailPageState();
}

class _PersonalEventDetailPageState extends State<PersonalEventDetailPage> {
  static const Color backgroundColor = Color(0xFFF2F2F7);
  static const Color iosBlue = Color(0xFF007AFF);
  static const Color secondaryText = Color(0xFF8E8E93);
  static const Color destructiveRed = Color(0xFFFF3B30);
  late PersonalEvent currentEvent;

  bool isDeleting = false;

  @override
  void initState() {
    super.initState();
    currentEvent = widget.event;
  }

  Future<void> _deleteEvent() async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "ลบกิจกรรม",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: const Text(
          "คุณแน่ใจหรือไม่ว่าต้องการลบรายการนี้?",
          style: TextStyle(color: Color(0xFF8E8E93)),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              "ยกเลิก",
              style: TextStyle(
                color: Color(0xFF8E8E93), // 🔘 เทาแทนม่วง
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "ลบ",
              style: TextStyle(
                color: Color(0xFFFF3B30), // 🔴 iOS Red
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => isDeleting = true);

    final success = await PersonalEventService.deleteEvent(
      currentEvent.personalEventID,
    );

    setState(() => isDeleting = false);

    if (success) {
      Navigator.pop(context, "deleted");
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = currentEvent;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔙 BACK + EDIT
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Row(
                      children: [
                        Icon(Icons.arrow_back_ios, size: 14, color: iosBlue),
                        SizedBox(width: 4),
                        Text(
                          'BACK',
                          style: TextStyle(
                            color: iosBlue,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  GestureDetector(
                    onTap: () async {
                      final updatedEvent = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreatePersonalEventPage(
                            userId: currentEvent.userID!,
                            event: currentEvent,
                            preselectedDate: currentEvent.deadline,
                          ),
                        ),
                      );

                      if (updatedEvent != null &&
                          updatedEvent is PersonalEvent) {
                        setState(() {
                          currentEvent = updatedEvent;
                        });
                      }
                    },
                    child: const Text(
                      "Edit",
                      style: TextStyle(
                        color: iosBlue,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              /// 🏷 TITLE
              Text(
                event.title ?? "",
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 12),

              /// 📦 DATE & TIME GROUP
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _infoRow(
                      icon: Icons.calendar_today,
                      label: "Date",
                      value: DateFormat('dd MMM yyyy').format(event.deadline!),
                    ),
                    const Divider(height: 1),
                    _infoRow(
                      icon: Icons.access_time,
                      label: "Time",
                      value: DateFormat('HH:mm').format(event.deadline!),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              /// 📝 NOTES
              if (event.description != null &&
                  event.description!.isNotEmpty) ...[
                const Text(
                  "รายละเอียด",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: secondaryText,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    event.description!,
                    style: const TextStyle(fontSize: 16, height: 1.6),
                  ),
                ),
              ],

              const Spacer(),

              /// 🗑 DELETE BUTTON
              GestureDetector(
                onTap: isDeleting ? null : _deleteEvent,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: destructiveRed.withOpacity(0.1),
                  ),
                  child: Center(
                    child: isDeleting
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: destructiveRed,
                            ),
                          )
                        : const Text(
                            "Delete Event",
                            style: TextStyle(
                              color: destructiveRed,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iosBlue),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 15)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 15, color: secondaryText),
          ),
        ],
      ),
    );
  }
}
