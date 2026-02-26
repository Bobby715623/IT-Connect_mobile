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
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              /// ===== HEADER =====
              GestureDetector(
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

              const SizedBox(height: 20),

              // ===== SEARCH =====
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearch,
                  decoration: const InputDecoration(
                    hintText: 'Search hospital or province',
                    prefixIcon: Icon(Icons.search, size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
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
                      return const Center(
                        child: Text('ไม่พบโรงพยาบาลที่ค้นหา'),
                      );
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
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            /// Icon Circle
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.local_hospital,
                size: 20,
                color: Colors.redAccent,
              ),
            ),

            const SizedBox(width: 14),

            /// Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),

            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
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
