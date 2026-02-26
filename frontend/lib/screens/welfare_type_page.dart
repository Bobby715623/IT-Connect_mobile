import 'package:flutter/material.dart';
import '../services/welfare_service.dart';
import '../models/welfare.dart';
import 'welfare_detail_page.dart';
import 'hospital.dart';

class WelfareTypePage extends StatefulWidget {
  final String type;

  const WelfareTypePage({super.key, required this.type});

  @override
  State<WelfareTypePage> createState() => _WelfareTypePageState();
}

class _WelfareTypePageState extends State<WelfareTypePage> {
  List<Welfare> welfareList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final data = await WelfareService.getByType(widget.type);
    setState(() {
      welfareList = data;
      isLoading = false;
    });
  }

  String _formatTitle(String type) {
    switch (type) {
      case "scholarship":
        return "SCHOLARSHIP";
      case "healthcare":
        return "HEALTHCARE";
      case "petition":
        return "PETITION";
      case "registercourse":
        return "REGISTER COURSE";
      default:
        return type.toUpperCase();
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case "healthcare":
        return Icons.add_box_outlined;
      case "scholarship":
        return Icons.school_outlined;
      case "registercourse":
        return Icons.assignment_outlined;
      case "petition":
        return Icons.description_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isHealthcare = widget.type == "healthcare";

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              /// BACK
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Row(
                  children: [
                    Icon(
                      Icons.arrow_back_ios,
                      size: 14,
                      color: Colors.blueAccent,
                    ),
                    SizedBox(width: 6),
                    Text(
                      "BACK",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// HEADER (TITLE)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatTitle(widget.type),
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 36),

              /// CONTENT
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : welfareList.isEmpty
                    ? const Center(
                        child: Text(
                          "No data available",
                          style: TextStyle(color: Colors.black54),
                        ),
                      )
                    : ListView(
                        children: [
                          ...welfareList.map((item) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        WelfareDetailPage(welfare: item),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 18),
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// ICON
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.blueAccent.withOpacity(
                                          0.08,
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Icon(
                                        _getTypeIcon(widget.type),
                                        color: Colors.blueAccent,
                                        size: 20,
                                      ),
                                    ),

                                    const SizedBox(width: 16),

                                    /// TEXT
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.title,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.blueAccent,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          if (item.description != null)
                                            Text(
                                              item.description!,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black87,
                                                height: 1.5,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),

                          /// HEALTHCARE SECTION
                          if (isHealthcare) _buildHospitalSection(context),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHospitalSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        const Divider(),
        const SizedBox(height: 20),
        const Text(
          "PARTNER HOSPITAL",
          style: TextStyle(
            fontSize: 13,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HospitalPage()),
            );
          },
          child: Row(
            children: const [
              Icon(Icons.local_hospital, size: 20, color: Colors.redAccent),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  "โรงพยาบาลคู่สัญญา",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ],
    );
  }
}
