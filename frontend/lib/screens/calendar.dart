import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'create_personal_event_page.dart';
import '../services/personal_event_service.dart';
import '../models/personal_event.dart';

class CalendarPage extends StatefulWidget {
  final int userId;

  const CalendarPage({super.key, required this.userId});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Map<DateTime, List<PersonalEvent>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _loadEvents();
  }

  // 🔹 โหลด event จาก backend
  Future<void> _loadEvents() async {
    final data = await PersonalEventService.getEventsByUser(widget.userId);

    Map<DateTime, List<PersonalEvent>> groupedEvents = {};

    for (var event in data) {
      if (event.deadline != null) {
        final date = DateTime(
          event.deadline!.year,
          event.deadline!.month,
          event.deadline!.day,
        );

        if (groupedEvents[date] == null) {
          groupedEvents[date] = [];
        }

        groupedEvents[date]!.add(event);
      }
    }

    setState(() {
      _events = groupedEvents;
    });
  }

  List<PersonalEvent> _getEventsForDay(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    return _events[date] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ปฏิทินกิจกรรม"), centerTitle: true),
      body: Column(
        children: [
          /// 📅 Calendar
          TableCalendar<PersonalEvent>(
            focusedDay: _focusedDay,
            firstDay: DateTime(2020),
            lastDay: DateTime(2100),
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            eventLoader: _getEventsForDay,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: const CalendarStyle(
              markerDecoration: BoxDecoration(
                color: Colors.purple,
                shape: BoxShape.circle,
              ),
            ),
          ),

          const SizedBox(height: 10),

          /// ➕ ปุ่มเพิ่ม Event
          if (_selectedDay != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("เพิ่ม Personal Event"),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreatePersonalEventPage(
                          userId: widget.userId,
                          preselectedDate: _selectedDay,
                        ),
                      ),
                    );

                    if (result == true) {
                      await _loadEvents(); // 🔥 refresh จริง ๆ
                    }
                  },
                ),
              ),
            ),

          const SizedBox(height: 20),

          /// 📌 แสดง Event ใต้ปฏิทิน
          Expanded(
            child: _selectedDay == null
                ? const Center(child: Text("กรุณาเลือกวันที่"))
                : _getEventsForDay(_selectedDay!).isEmpty
                ? const Center(child: Text("ไม่มีรายการในวันนี้"))
                : ListView.builder(
                    itemCount: _getEventsForDay(_selectedDay!).length,
                    itemBuilder: (context, index) {
                      final PersonalEvent event = _getEventsForDay(
                        _selectedDay!,
                      )[index];

                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 50,
                              color: Colors.purple,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event.title ?? "",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    event.deadline?.toString().substring(
                                          0,
                                          16,
                                        ) ??
                                        "",
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
