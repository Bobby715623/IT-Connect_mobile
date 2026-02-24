import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'create_personal_event_page.dart';
import '../services/personal_event_service.dart';
import '../models/personal_event.dart';
import 'personal_event_detail_page.dart';

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

  static const Color backgroundColor = Color(0xFFF8F9FB);

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _loadEvents();
  }

  Future<void> _selectMonthYear() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _focusedDay,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDatePickerMode: DatePickerMode.year,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blueAccent, // header + selected
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.blueAccent),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _focusedDay = picked;
        _selectedDay = picked;
      });
    }
  }

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

        groupedEvents.putIfAbsent(date, () => []);
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

  void _removeEvent(PersonalEvent event) {
    final dateKey = DateTime(
      event.deadline!.year,
      event.deadline!.month,
      event.deadline!.day,
    );

    setState(() {
      _events[dateKey]?.removeWhere(
        (e) => e.personalEventID == event.personalEventID,
      );

      if (_events[dateKey]?.isEmpty ?? false) {
        _events.remove(dateKey);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔵 HEADER
              const Text(
                "ปฏิทินกิจกรรม",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {
                      setState(() {
                        _focusedDay = DateTime(
                          _focusedDay.year,
                          _focusedDay.month - 1,
                        );
                      });
                    },
                  ),

                  GestureDetector(
                    onTap: _selectMonthYear,
                    child: Text(
                      "${_focusedDay.month}/${_focusedDay.year}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
                      setState(() {
                        _focusedDay = DateTime(
                          _focusedDay.year,
                          _focusedDay.month + 1,
                        );
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              /// 📅 CALENDAR CARD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: TableCalendar<PersonalEvent>(
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
                  headerVisible: false,
                  calendarStyle: CalendarStyle(
                    selectedDecoration: const BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),

                    /// 🔵 วันนี้ (ถ้าไม่ถูกเลือก)
                    todayDecoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent, // ❗ ไม่มีวงกลม
                    ),
                    todayTextStyle: const TextStyle(
                      color: Colors.blueAccent, // เปลี่ยนเป็นสีตัวเลขแทน
                      fontWeight: FontWeight.w600,
                    ),

                    markerDecoration: const BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// ➕ ADD BUTTON (Minimal)
              if (_selectedDay != null) ...[
                const SizedBox(height: 18),

                Center(
                  child: GestureDetector(
                    onTap: () async {
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
                        await _loadEvents();
                      }
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 18, color: Colors.blueAccent),
                        SizedBox(width: 8),
                        Text(
                          "เพิ่ม Personal Event",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              /// 📌 EVENT LIST
              Expanded(
                child: _selectedDay == null
                    ? const Center(child: Text("กรุณาเลือกวันที่"))
                    : _getEventsForDay(_selectedDay!).isEmpty
                    ? const Center(child: Text("ไม่มีรายการในวันนี้"))
                    : ListView.builder(
                        itemCount: _getEventsForDay(_selectedDay!).length,
                        itemBuilder: (context, index) {
                          final event = _getEventsForDay(_selectedDay!)[index];

                          return InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      PersonalEventDetailPage(event: event),
                                ),
                              );

                              if (result == "deleted") {
                                _removeEvent(event);
                              }

                              if (result == "edited") {
                                await _loadEvents(); // reload เพื่ออัปเดตข้อมูล
                              }
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
                                  Container(
                                    width: 4,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.blueAccent,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          event.title ?? "",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          event.deadline?.toString().substring(
                                                0,
                                                16,
                                              ) ??
                                              "",
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF8E8E93),
                                          ),
                                        ),
                                      ],
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
        ),
      ),
    );
  }
}
