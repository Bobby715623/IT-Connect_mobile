import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final DateTime _firstDay = DateTime(1990, 1, 1);
  final DateTime _lastDay = DateTime(2030, 12, 31);

  // ===== normalize วันที่ (ตัดเวลาออก) =====
  DateTime _normalize(DateTime day) {
    return DateTime(day.year, day.month, day.day);
  }

  // ===== ตัวอย่างข้อมูลบันทึก =====
  final Map<DateTime, List<String>> _events = {};

  @override
  void initState() {
    super.initState();
    _events.addAll({
      _normalize(DateTime(2026, 1, 10)): ['กิจกรรมจิตอาสา'],
      _normalize(DateTime(2026, 1, 20)): ['อบรม', 'ประชุม'],
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedEvents = _selectedDay == null
        ? null
        : _events[_normalize(_selectedDay!)];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== HOME =====
            Padding(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back_ios, size: 14, color: Colors.blue),
                    SizedBox(width: 4),
                    Text(
                      'HOME',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ===== CALENDAR =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TableCalendar(
                firstDay: _firstDay,
                lastDay: _lastDay,
                focusedDay: _focusedDay,

                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),

                calendarFormat: CalendarFormat.month,
                startingDayOfWeek: StartingDayOfWeek.monday,

                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },

                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },

                // ⭐ จุดใต้วันที่มีบันทึก
                eventLoader: (day) {
                  return _events[_normalize(day)] ?? [];
                },

                headerStyle: const HeaderStyle(
                  titleCentered: true,
                  formatButtonVisible: false,
                  leftChevronIcon: Icon(Icons.chevron_left),
                  rightChevronIcon: Icon(Icons.chevron_right),
                ),

                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.blue.shade200,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  weekendTextStyle: const TextStyle(color: Colors.black),
                  outsideDaysVisible: true,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ===== EVENT CARD =====
            if (selectedEvents != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: selectedEvents.map((event) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.pink,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
