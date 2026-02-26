import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'activity_port_detail.dart';
import 'activity_history_page.dart';
import 'activity_post_page.dart';
import '../services/activity_port_service.dart';
import '../services/activity_service.dart';
import '../services/activity_evidence_service.dart';
import 'package:flutter/cupertino.dart';
import 'activity_post_page.dart';
import '../models/activity_post.dart';

class CreateActivityPage extends StatefulWidget {
  final int portId;
  final bool fromPost;
  final ActivityPost? post;

  const CreateActivityPage({
    super.key,
    required this.portId,
    this.fromPost = false,
    this.post,
  });

  @override
  State<CreateActivityPage> createState() => _CreateActivityPageState();
}

class _CreateActivityPageState extends State<CreateActivityPage> {
  final nameController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();
  final TextEditingController hourController = TextEditingController();

  DateTime? startDateTime;
  DateTime? endDateTime;
  DateTime? selectedDate;

  final ImagePicker _picker = ImagePicker();
  final List<File> images = [];

  bool isLoading = false;
  bool get isReadOnly => widget.fromPost;

  @override
  void initState() {
    super.initState();

    if (widget.fromPost && widget.post != null) {
      nameController.text = widget.post!.title ?? "";
      locationController.text = widget.post!.location ?? "";

      if (widget.post!.datetimeOfActivity != null) {
        startDateTime = widget.post!.datetimeOfActivity;

        // 🔥 คำนวณเวลาเลิกจากจำนวนชั่วโมง
        if (widget.post!.hourOfActivity != null) {
          endDateTime = startDateTime!.add(
            Duration(hours: widget.post!.hourOfActivity!),
          );
        }
      }

      hourController.text = widget.post!.hourOfActivity?.toString() ?? "";
    }
  }

  // ===================== DATE TIME =====================

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: startDateTime ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
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

    if (date == null) return;

    setState(() {
      startDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        startDateTime?.hour ?? 0,
        startDateTime?.minute ?? 0,
      );
      endDateTime = null;
    });
  }

  Future<void> pickStartTime() async {
    if (startDateTime == null) {
      _showMessage("กรุณาเลือกวันก่อน");
      return;
    }

    DateTime tempPicked = startDateTime!;

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
              /// 🔥 iOS Header Bar
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
                          startDateTime = tempPicked;
                          endDateTime = null; // reset end
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

              /// 🔥 Cupertino Picker
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: true,
                  initialDateTime: startDateTime!,
                  onDateTimeChanged: (value) {
                    tempPicked = DateTime(
                      startDateTime!.year,
                      startDateTime!.month,
                      startDateTime!.day,
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

  Future<void> pickEndTime() async {
    if (startDateTime == null) {
      _showMessage("กรุณาเลือกวันและเวลาเริ่มก่อน");
      return;
    }

    DateTime tempPicked = endDateTime ?? startDateTime!;

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
              /// 🔥 iOS Header
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
                        if (tempPicked.isBefore(startDateTime!)) {
                          _showMessage("เวลาจบต้องมากกว่าเวลาเริ่ม");
                          return;
                        }

                        setState(() {
                          endDateTime = tempPicked;
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

              /// 🔥 Cupertino Picker
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: true,
                  initialDateTime: tempPicked,
                  onDateTimeChanged: (value) {
                    tempPicked = DateTime(
                      startDateTime!.year,
                      startDateTime!.month,
                      startDateTime!.day,
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

  // ===================== IMAGE =====================

  Future<void> pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() {
      images.add(File(picked.path));
    });
  }

  // ===================== SUBMIT =====================

  Future<void> submit() async {
    if (isLoading) return;

    if (nameController.text.trim().isEmpty ||
        locationController.text.trim().isEmpty ||
        startDateTime == null ||
        endDateTime == null) {
      _showMessage("กรุณากรอกข้อมูลให้ครบ");
      return;
    }

    final duration = endDateTime!.difference(startDateTime!).inMinutes;
    final hour = (duration / 60).ceil();

    try {
      setState(() => isLoading = true);

      // 🔹 1️⃣ สร้าง Activity และเอา ID กลับมา
      final activityId = await ActivityService.createActivity(
        portId: widget.portId,
        activityName: nameController.text.trim(),
        description: descriptionController.text.trim(),
        hour: hour,
        location: locationController.text.trim(),
        datetime: startDateTime!,
      );

      // 🔹 2️⃣ ถ้ามีรูป → upload
      if (images.isNotEmpty) {
        await ActivityEvidenceService.uploadEvidence(
          activityId: activityId,
          images: images,
        );
      }

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
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  // ===================== UI =====================

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6F8),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                /// 🔥 TABS
                Row(
                  children: [
                    _TabButton(
                      title: 'MY ACTIVITY',
                      isActive: true,
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ActivityPortDetailPage(portId: widget.portId),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    _TabButton(
                      title: 'ACTIVITY',
                      isActive: false,
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ActivityPostPage(portId: widget.portId),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    _TabButton(
                      title: 'HISTORY',
                      isActive: false,
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ActivityHistoryPage(portId: widget.portId),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// 🔥 BACK
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.arrow_back_ios,
                          size: 14,
                          color: Colors.blue,
                        ),
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

                /// 🔥 TITLE
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "เพิ่มกิจกรรมใหม่",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                ),

                const SizedBox(height: 20),

                /// 🔥 FORM
                Expanded(
                  child: ListView(
                    children: [
                      _softCard(
                        "กิจกรรม",
                        Column(
                          children: [
                            _modernInput(
                              "ชื่อกิจกรรม",
                              nameController,
                              readOnly: widget.fromPost,
                            ),
                            const SizedBox(height: 15),
                            _modernInput(
                              "สถานที่",
                              locationController,
                              readOnly: widget.fromPost,
                            ),
                          ],
                        ),
                      ),

                      _softCard(
                        "วันที่และเวลา",
                        Column(
                          children: [
                            _selector(
                              label: "วันที่",
                              icon: Icons.calendar_today_outlined,
                              text: startDateTime == null
                                  ? "เลือกวันที่"
                                  : DateFormat(
                                      "dd MMM yyyy",
                                    ).format(startDateTime!),
                              onTap: pickDate,
                              readOnly: widget.fromPost,
                            ),
                            const SizedBox(height: 18),
                            _selector(
                              label: "เวลาเริ่ม",
                              icon: Icons.access_time,
                              text: startDateTime == null
                                  ? "เลือกเวลา"
                                  : DateFormat("HH:mm").format(startDateTime!),
                              onTap: pickStartTime,
                              readOnly: widget.fromPost,
                            ),
                            const SizedBox(height: 18),
                            _selector(
                              label: "เวลาสิ้นสุด",
                              icon: Icons.access_time,
                              text: endDateTime == null
                                  ? "เลือกเวลา"
                                  : DateFormat("HH:mm").format(endDateTime!),
                              onTap: pickEndTime,
                              readOnly: widget.fromPost,
                            ),
                          ],
                        ),
                      ),

                      _softCard(
                        "รายละเอียดกิจกรรม",
                        TextField(
                          controller: descriptionController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: "รายละเอียด",
                            filled: true,
                            fillColor: const Color(0xFFF1F3F6),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),

                      _softCard(
                        "รูปภาพหลักฐานการเข้าร่วมกิจกรรม",
                        SizedBox(
                          height: 95,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              ...images.map(
                                (img) => Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(18),
                                    child: Stack(
                                      children: [
                                        Image.file(
                                          img,
                                          width: 90,
                                          height: 90,
                                          fit: BoxFit.cover,
                                        ),
                                        Positioned(
                                          top: 6,
                                          right: 6,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(
                                                () => images.remove(img),
                                              );
                                            },
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                color: Colors.black45,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                size: 18,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: pickImage,
                                child: Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F3F6),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: const Icon(Icons.add),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),
                      _gradientButton(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _softCard(String title, Widget child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _modernInput(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        filled: readOnly,
        fillColor: readOnly ? Colors.grey.shade100 : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _selector({
    required String label,
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool readOnly = false,
  }) {
    return GestureDetector(
      onTap: readOnly ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: readOnly ? Colors.grey.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: readOnly ? Colors.grey : Colors.blueAccent,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: readOnly ? Colors.grey : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gradientButton() {
    return GestureDetector(
      onTap: submit,
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
  void dispose() {
    nameController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}

class _TabButton extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback? onTap;

  const _TabButton({required this.title, required this.isActive, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.blueAccent : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black87,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
