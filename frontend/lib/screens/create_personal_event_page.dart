import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/personal_event_service.dart';

class CreatePersonalEventPage extends StatefulWidget {
  final int userId;
  final DateTime? preselectedDate;

  const CreatePersonalEventPage({
    super.key,
    required this.userId,
    this.preselectedDate,
  });

  @override
  State<CreatePersonalEventPage> createState() =>
      _CreatePersonalEventPageState();
}

class _CreatePersonalEventPageState extends State<CreatePersonalEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool hasDeadline = false;
  DateTime? selectedDeadline;
  int remindBeforeDays = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    // ถ้ามาจาก Calendar ให้เปิด Deadline อัตโนมัติ
    if (widget.preselectedDate != null) {
      hasDeadline = true;
      selectedDeadline = widget.preselectedDate;
    }
  }

  /// 📅 เลือกวันที่
  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDeadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDeadline = picked;
      });
    }
  }

  /// 🚀 สร้าง Event
  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) return;

    if (hasDeadline && selectedDeadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณาเลือกวันที่ Deadline")),
      );
      return;
    }

    setState(() => isLoading = true);

    final success = await PersonalEventService.createEvent(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      deadline: hasDeadline ? selectedDeadline : null,
      remindBeforeDays: hasDeadline ? remindBeforeDays : null,
      userID: widget.userId,
    );

    setState(() => isLoading = false);

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("บันทึกกิจกรรมสำเร็จ")));
      Navigator.pop(context, true); // ส่งค่า true กลับไป refresh
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("เกิดข้อผิดพลาด")));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("เพิ่ม Personal Event"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    /// 🔹 ชื่อกิจกรรม
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: "ชื่อกิจกรรม",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "กรุณากรอกชื่อกิจกรรม";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    /// 🔹 รายละเอียด
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: "รายละเอียด",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),

                    const SizedBox(height: 24),

                    /// 🔹 เปิด/ปิด Deadline
                    SwitchListTile(
                      title: const Text("มี Deadline"),
                      value: hasDeadline,
                      onChanged: (value) {
                        setState(() {
                          hasDeadline = value;
                          if (!value) {
                            selectedDeadline = null;
                            remindBeforeDays = 0;
                          }
                        });
                      },
                    ),

                    /// 🔹 ส่วนของ Deadline
                    if (hasDeadline) ...[
                      const SizedBox(height: 16),

                      ListTile(
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        title: Text(
                          selectedDeadline == null
                              ? "เลือกวันที่ Deadline"
                              : DateFormat(
                                  'dd/MM/yyyy',
                                ).format(selectedDeadline!),
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: _pickDeadline,
                      ),

                      const SizedBox(height: 16),

                      DropdownButtonFormField<int>(
                        value: remindBeforeDays,
                        decoration: const InputDecoration(
                          labelText: "เตือนก่อนกี่วัน",
                          border: OutlineInputBorder(),
                        ),
                        items: [0, 1, 2, 3, 5, 7]
                            .map(
                              (day) => DropdownMenuItem(
                                value: day,
                                child: Text("$day วัน"),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            remindBeforeDays = value!;
                          });
                        },
                      ),
                    ],

                    const SizedBox(height: 32),

                    /// 🔹 ปุ่มบันทึก
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _createEvent,
                        child: const Text(
                          "บันทึก",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
