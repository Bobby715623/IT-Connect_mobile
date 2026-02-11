import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/activity_port_service.dart';

class CreateActivityPage extends StatefulWidget {
  final int portId;

  const CreateActivityPage({super.key, required this.portId});

  @override
  State<CreateActivityPage> createState() => _CreateActivityPageState();
}

class _CreateActivityPageState extends State<CreateActivityPage> {
  final nameController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();
  final detailController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  final ImagePicker _picker = ImagePicker();
  List<File> images = [];

  bool isLoading = false;

  // 📅 เลือกวัน
  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );

    if (date != null) {
      setState(() => selectedDate = date);
    }
  }

  // ⏰ เลือกเวลา
  Future<void> pickTime(bool isStart) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        if (isStart) {
          startTime = time;
        } else {
          endTime = time;
        }
      });
    }
  }

  // 🖼 เลือกรูป
  Future<void> pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        images.add(File(picked.path));
      });
    }
  }

  // ✅ SUBMIT
  Future<void> submit() async {
    if (nameController.text.isEmpty ||
        locationController.text.isEmpty ||
        selectedDate == null ||
        startTime == null ||
        endTime == null) {
      _showMessage("กรุณากรอกข้อมูลให้ครบ");
      return;
    }

    final startDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      startTime!.hour,
      startTime!.minute,
    );

    final endDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      endTime!.hour,
      endTime!.minute,
    );

    if (endDateTime.isBefore(startDateTime)) {
      _showMessage("เวลาจบต้องมากกว่าเวลาเริ่ม");
      return;
    }

    final duration = endDateTime.difference(startDateTime).inMinutes;

    final hour = (duration / 60).ceil();

    try {
      setState(() => isLoading = true);

      await ActivityPortService.createActivity(
        portId: widget.portId,
        activityName: nameController.text,
        description: descriptionController.text,
        hour: hour,
        location: locationController.text,
        datetime: startDateTime,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      _showMessage("เกิดข้อผิดพลาด");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(title: const Text("เพิ่มชั่วโมงกิจกรรม")),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              _buildLabel("ชื่อโครงการ / กิจกรรม"),
              _buildInput(nameController),

              _buildLabel("สถานที่"),
              _buildInput(locationController),

              _buildLabel("วันที่"),
              GestureDetector(
                onTap: pickDate,
                child: _greyBox(
                  selectedDate == null
                      ? "เลือกวันที่"
                      : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                ),
              ),

              _buildLabel("เวลา"),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => pickTime(true),
                      child: _greyBox(
                        startTime == null
                            ? "เวลาเริ่ม"
                            : startTime!.format(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => pickTime(false),
                      child: _greyBox(
                        endTime == null ? "เวลาจบ" : endTime!.format(context),
                      ),
                    ),
                  ),
                ],
              ),

              _buildLabel("ลักษณะของกิจกรรม"),
              _buildInput(descriptionController),

              _buildLabel("รายละเอียด"),
              _buildInput(detailController),

              _buildLabel("รูปภาพหลักฐาน"),

              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                children: [
                  ...images.map(
                    (img) => Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: FileImage(img),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                images.remove(img);
                              });
                            },
                            child: const Icon(Icons.close, color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: pickImage,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Submit"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }

  Widget _greyBox(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text),
    );
  }
}
