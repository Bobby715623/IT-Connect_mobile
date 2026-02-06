import 'package:flutter/material.dart';
import '../models/hospital.dart';
import '../services/hospital_service.dart';
import '../utils/map_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

class HospitalPage extends StatefulWidget {
  const HospitalPage({super.key});

  @override
  State<HospitalPage> createState() => _HospitalPageState();
}

class _HospitalPageState extends State<HospitalPage> {
  late Future<List<Hospital>> _future;
  List<Hospital> _allHospitals = [];
  List<Hospital> _filteredHospitals = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _future = HospitalService.fetchHospitals();
  }

  void _onSearch(String keyword) {
    setState(() {
      _filteredHospitals = _allHospitals.where((h) {
        final name = h.name.toLowerCase();
        final province = (h.province ?? '').toLowerCase();
        final key = keyword.toLowerCase();
        return name.contains(key) || province.contains(key);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== TABS =====
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _TabButton(
                    title: 'DETAIL',
                    isActive: false,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const _TabButton(title: 'HOSPITAL', isActive: true),
                ],
              ),
            ),

            // ===== BACK =====
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Row(
                  children: [
                    Icon(Icons.arrow_back_ios, size: 14, color: Colors.blue),
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

            const SizedBox(height: 12),

            // ===== SEARCH =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F1F1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearch,
                  decoration: InputDecoration(
                    hintText: 'Search Hospital',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              _onSearch('');
                              setState(() {});
                            },
                            child: const Icon(Icons.close),
                          )
                        : null,
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ===== LIST =====
            Expanded(
              child: FutureBuilder<List<Hospital>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  }

                  if (_allHospitals.isEmpty) {
                    _allHospitals = snapshot.data!;
                    _filteredHospitals = _allHospitals;
                  }

                  if (_filteredHospitals.isEmpty) {
                    return const Center(child: Text('ไม่พบโรงพยาบาลที่ค้นหา'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredHospitals.length,
                    itemBuilder: (context, index) {
                      final h = _filteredHospitals[index];

                      return HospitalCard(
                        name: h.name,
                        subtitle: h.province ?? '-',
                        onTap: () {
                          if (h.placeId != null && h.placeId!.isNotEmpty) {
                            openGoogleMapsWithPlaceId(h.placeId!);
                          } else if (h.latitude != null &&
                              h.longitude != null) {
                            openGoogleMaps(
                              h.latitude!,
                              h.longitude!,
                            ); // fallback
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('ไม่มีข้อมูลสถานที่'),
                              ),
                            );
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= TAB BUTTON =================
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

// ================= HOSPITAL CARD =================
class HospitalCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final VoidCallback? onTap;

  const HospitalCard({
    super.key,
    required this.name,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.location_on_outlined, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}

Future<void> openGoogleMapsWithPlaceId(String placeId) async {
  final uri = Uri.parse('geo:0,0?q=place_id:$placeId');

  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
