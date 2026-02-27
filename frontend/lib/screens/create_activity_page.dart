import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';

import 'activity_port_detail.dart';
import 'activity_history_page.dart';
import 'activity_post_page.dart';
import '../services/activity_service.dart';
import '../services/activity_evidence_service.dart';
import '../models/activity_port.dart';
import '../models/activity_post.dart';

class CreateActivityPage extends StatefulWidget {
  final int portId;
  final bool fromPost;
  final ActivityPost? post;
  final Activity? activity;
  final bool isEdit;
  final int userId;

  const CreateActivityPage({
    super.key,
    required this.portId,
    this.fromPost = false,
    this.post,
    this.activity,
    this.isEdit = false,
    required this.userId,
  });

  @override
  State<CreateActivityPage> createState() => _CreateActivityPageState();
}

class _CreateActivityPageState extends State<CreateActivityPage> {
  final nameController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();

  DateTime? startDateTime;
  DateTime? endDateTime;

  final ImagePicker _picker = ImagePicker();
  final List<File> images = [];
  List<ActivityEvidence> existingImages = [];

  bool isLoading = false;
  late bool isWaiting;
  late bool isFromPost;

  // ===================== INIT =====================

  @override
  void initState() {
    super.initState();

    isWaiting = true;

    /// 🔥 ถ้าเป็น edit → เช็คจาก activity.relatedPostId
    if (widget.activity != null) {
      final activity = widget.activity!;

      isWaiting = activity.status == ActivityStatus.waitForProcess;
      isFromPost = activity.relatedPostId != null;

      nameController.text = activity.name ?? "";
      locationController.text = activity.location ?? "";
      descriptionController.text = activity.description ?? "";

      startDateTime = activity.datetime;

      if (activity.datetime != null && activity.hour != null) {
        endDateTime = activity.datetime!.add(Duration(hours: activity.hour!));
      }

      existingImages = List.from(activity.evidences);
    }
    /// 🔥 ถ้าเป็น create จาก post
    else if (widget.post != null) {
      final p = widget.post!;

      isFromPost = true; // 🔥 บังคับ true

      nameController.text = p.title ?? "";
      locationController.text = p.location ?? "";
      descriptionController.text = p.description ?? "";

      startDateTime = p.datetimeOfActivity;

      if (p.datetimeOfActivity != null && p.hourOfActivity != null) {
        endDateTime = p.datetimeOfActivity!.add(
          Duration(hours: p.hourOfActivity!),
        );
      }
    }
    /// 🔥 create ปกติ
    else {
      isFromPost = false;
    }
  }

  // ===================== PERMISSION =====================

  bool canEditField(String field) {
    /// 🔥 ถ้ามาจาก post (ทั้ง create และ edit)
    if (isFromPost) {
      return field == "description" || field == "image";
    }

    /// 🔥 edit ปกติ
    if (widget.isEdit) {
      return isWaiting;
    }

    return true;
  }
  // ===================== DATE =====================

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

  Future<void> pickTime({required bool isStart}) async {
    if (startDateTime == null) {
      _showMessage("กรุณาเลือกวันก่อน");
      return;
    }

    DateTime tempPicked = isStart
        ? startDateTime!
        : (endDateTime ?? startDateTime!);

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
                    /// Cancel
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

                    /// Done
                    GestureDetector(
                      onTap: () {
                        // 🔥 เช็คเวลาสิ้นสุด
                        if (!isStart && tempPicked.isBefore(startDateTime!)) {
                          _showMessage("เวลาจบต้องมากกว่าเวลาเริ่ม");
                          return;
                        }

                        setState(() {
                          if (isStart) {
                            startDateTime = tempPicked;
                            endDateTime = null; // reset end
                          } else {
                            endDateTime = tempPicked;
                          }
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
    print("==== SUBMIT START ====");
    print("IS EDIT: ${widget.isEdit}");
    print("ACTIVITY OBJECT: ${widget.activity}");
    print("PORT ID: ${widget.portId}");
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

      // 🔥 ========= EDIT MODE =========
      if (widget.isEdit && widget.activity != null) {
        await ActivityService.updateActivity(
          activityId: widget.activity!.id,
          activityName: nameController.text.trim(),
          description: descriptionController.text.trim(),
          hour: hour,
          location: locationController.text.trim(),
          datetime: startDateTime!,
        );

        if (images.isNotEmpty) {
          await ActivityEvidenceService.uploadEvidence(
            activityId: widget.activity!.id,
            images: images,
          );
        }

        if (!mounted) return;
        Navigator.pop(context, true);
        return; // 👈 ตัดจบตรงนี้เลย ไม่ให้ลงไป create
      }

      // 🔵 ========= CREATE MODE =========
      if (widget.post != null) {
        // 🔥 สร้างจาก Post
        final success = await ActivityService.submitActivityFromPost(
          postId: widget.post!.activityPostID,
          userId: widget.userId,
          description: descriptionController.text.trim(),
          images: images,
        );

        if (!mounted) return;
        Navigator.pop(context, success);
      } else {
        // 🔵 Create ปกติ
        final activityId = await ActivityService.createActivity(
          portId: widget.portId,
          activityName: nameController.text.trim(),
          description: descriptionController.text.trim(),
          hour: hour,
          location: locationController.text.trim(),
          datetime: startDateTime!,
        );

        if (images.isNotEmpty) {
          await ActivityEvidenceService.uploadEvidence(
            activityId: activityId,
            images: images,
          );
        }

        if (!mounted) return;
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showMessage("เกิดข้อผิดพลาด: $e");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ===================== UI =====================

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FB),
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
                            builder: (_) => ActivityPortDetailPage(
                              portId: widget.portId,
                              userId: widget.userId,
                            ),
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
                            builder: (_) => ActivityPostPage(
                              portId: widget.portId,
                              userId: widget.userId,
                            ),
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
                            builder: (_) => ActivityHistoryPage(
                              portId: widget.portId,
                              userId: widget.userId,
                            ),
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
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.isEdit ? "แก้ไขกิจกรรม" : "เพิ่มกิจกรรมใหม่",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: ListView(
                    children: [
                      /// 🔥 CARD 1 : กิจกรรม
                      _softCard(
                        "กิจกรรม",
                        Column(
                          children: [
                            _modernInput(
                              "ชื่อกิจกรรม",
                              nameController,
                              readOnly: !canEditField("name"),
                            ),
                            const SizedBox(height: 15),
                            _modernInput(
                              "สถานที่",
                              locationController,
                              readOnly: !canEditField("location"),
                            ),
                          ],
                        ),
                      ),

                      /// 🔥 CARD 2 : วันที่และเวลา
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
                              readOnly: !canEditField("datetime"),
                            ),
                            const SizedBox(height: 18),
                            _selector(
                              label: "เวลาเริ่ม",
                              icon: Icons.access_time,
                              text: startDateTime == null
                                  ? "เลือกเวลา"
                                  : DateFormat("HH:mm").format(startDateTime!),
                              onTap: () => pickTime(isStart: true),
                              readOnly: !canEditField("datetime"),
                            ),
                            const SizedBox(height: 18),
                            _selector(
                              label: "เวลาสิ้นสุด",
                              icon: Icons.access_time,
                              text: endDateTime == null
                                  ? "เลือกเวลา"
                                  : DateFormat("HH:mm").format(endDateTime!),
                              onTap: () => pickTime(isStart: false),
                              readOnly: !canEditField("datetime"),
                            ),
                          ],
                        ),
                      ),

                      /// 🔥 CARD 3 : รายละเอียด
                      _softCard(
                        "รายละเอียดกิจกรรม",
                        TextField(
                          controller: descriptionController,
                          maxLines: 4,
                          readOnly: !canEditField("description"),
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

                      /// 🔥 CARD 4 : รูปภาพ
                      _softCard(
                        "รูปภาพหลักฐานการเข้าร่วมกิจกรรม",
                        SizedBox(
                          height: 95,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              /// รูปเก่า
                              ...existingImages.map((e) {
                                final imageUrl =
                                    "http://10.0.2.2:3000/uploads/${e.picture}";

                                return Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(18),
                                    child: Stack(
                                      children: [
                                        Image.network(
                                          imageUrl,
                                          width: 90,
                                          height: 90,
                                          fit: BoxFit.cover,
                                        ),

                                        if (canEditField("image"))
                                          Positioned(
                                            top: 6,
                                            right: 6,
                                            child: GestureDetector(
                                              onTap: () async {
                                                final success =
                                                    await ActivityEvidenceService.deleteEvidence(
                                                      e.id,
                                                    );

                                                if (success) {
                                                  setState(() {
                                                    existingImages.remove(e);
                                                  });
                                                } else {
                                                  _showMessage(
                                                    "ลบรูปไม่สำเร็จ",
                                                  );
                                                }
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
                                );
                              }),

                              /// รูปใหม่
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

                              /// ปุ่มเพิ่ม
                              if (canEditField("image"))
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
                      _submitButton(),
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

  Widget _input(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _descriptionField() {
    return TextField(
      controller: descriptionController,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: "รายละเอียด",
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _imageSection() {
    return SizedBox(
      height: 95,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ...existingImages.map((e) {
            final imageUrl = "http://10.0.2.2:3000/uploads/${e.picture}";
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  imageUrl,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
            );
          }),
          ...images.map(
            (img) => Padding(
              padding: const EdgeInsets.only(right: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(
                  img,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: canEditField("image") ? pickImage : null,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.add),
            ),
          ),
        ],
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
    String hint,
    TextEditingController controller, {
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: readOnly ? Colors.grey.shade200 : const Color(0xFFF1F3F6),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
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

  Widget _submitButton() {
    final canSubmit = !widget.isEdit || isWaiting;

    return GestureDetector(
      onTap: canSubmit ? submit : null,
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
