import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/personal_event_service.dart';
import 'package:flutter/cupertino.dart';
import '../models/personal_event.dart';

class CreatePersonalEventPage extends StatefulWidget {
  final int userId;
  final DateTime? preselectedDate;
  final PersonalEvent? event;

  const CreatePersonalEventPage({
    super.key,
    required this.userId,
    this.preselectedDate,
    this.event,
  });

  @override
  State<CreatePersonalEventPage> createState() =>
      _CreatePersonalEventPageState();
}

class _CreatePersonalEventPageState extends State<CreatePersonalEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  static const Color backgroundColor = Color(0xFFF8F9FB);

  DateTime? selectedDateTime;
  int remindBeforeDays = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    if (widget.event != null) {
      /// 🔄 EDIT MODE
      _titleController.text = widget.event!.title ?? "";
      _descriptionController.text = widget.event!.description ?? "";
      selectedDateTime = widget.event!.deadline;
    } else if (widget.preselectedDate != null) {
      /// ➕ CREATE FROM CALENDAR
      selectedDateTime = widget.preselectedDate;
    }
  }

  /// 📅 เลือกวัน
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blueAccent,
              onPrimary: Colors.white,
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
        selectedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          selectedDateTime?.hour ?? 0,
          selectedDateTime?.minute ?? 0,
        );
      });
    }
  }

  /// ⏰ เลือกเวลา
  Future<void> _pickTime() async {
    DateTime tempPicked = selectedDateTime ?? DateTime.now();

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              /// Header bar (iOS style)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFE5E5EA))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: Color(0xFF8E8E93),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDateTime = tempPicked;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Done",
                        style: TextStyle(
                          color: Color(0xFF007AFF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// Cupertino Time Picker
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: selectedDateTime ?? DateTime.now(),
                  use24hFormat: true,
                  onDateTimeChanged: (value) {
                    tempPicked = DateTime(
                      tempPicked.year,
                      tempPicked.month,
                      tempPicked.day,
                      value.hour,
                      value.minute,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedDateTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("กรุณาเลือกวันและเวลา")));
      return;
    }

    setState(() => isLoading = true);

    if (widget.event != null) {
      /// 🔄 EDIT MODE
      final updatedEvent = await PersonalEventService.updateEvent(
        id: widget.event!.personalEventID,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        deadline: selectedDateTime,
      );

      setState(() => isLoading = false);

      if (updatedEvent != null) {
        Navigator.pop(context, updatedEvent);
      }
    } else {
      /// ➕ CREATE MODE
      final newEvent = await PersonalEventService.createEvent(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        deadline: selectedDateTime,
        userID: widget.userId,
      );

      setState(() => isLoading = false);

      if (newEvent != null) {
        Navigator.pop(context, newEvent);
      }
    }
  }

  Widget _gradientButton() {
    return GestureDetector(
      onTap: isLoading ? null : _createEvent,
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [Color(0xFF5B8CFF), Color(0xFF3A6BEA)],
          ),
        ),
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  "Submit",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      /// 🔙 BACK
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.arrow_back_ios,
                                size: 14,
                                color: Color(0xFF007AFF),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'BACK',
                                style: TextStyle(
                                  color: Color(0xFF007AFF),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        "เพิ่ม Personal Event",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 24),

                      /// 📦 CARD
                      Container(
                        padding: const EdgeInsets.all(20),
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
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _titleController,
                              decoration: const InputDecoration(
                                labelText: "ชื่อกิจกรรม",
                                border: UnderlineInputBorder(),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? "กรุณากรอกชื่อกิจกรรม"
                                  : null,
                            ),

                            const SizedBox(height: 20),

                            TextFormField(
                              controller: _descriptionController,
                              decoration: const InputDecoration(
                                labelText: "รายละเอียด",
                                border: UnderlineInputBorder(),
                              ),
                              maxLines: 3,
                            ),

                            const SizedBox(height: 28),

                            /// 📅 DATE
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text("วันที่"),
                              subtitle: Text(
                                selectedDateTime == null
                                    ? "เลือกวันที่"
                                    : DateFormat(
                                        'dd MMM yyyy',
                                      ).format(selectedDateTime!),
                              ),
                              trailing: const Icon(Icons.calendar_today),
                              onTap: _pickDate,
                            ),

                            const Divider(),

                            /// ⏰ TIME
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text("เวลา"),
                              subtitle: Text(
                                selectedDateTime == null
                                    ? "เลือกเวลา"
                                    : DateFormat(
                                        'HH:mm',
                                      ).format(selectedDateTime!),
                              ),
                              trailing: const Icon(Icons.access_time),
                              onTap: _pickTime,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      /// 🔵 SAVE BUTTON
                      _gradientButton(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
