import 'package:flutter/material.dart';
import '../models/welfare.dart';
import '../services/welfare_service.dart';
import 'package:myproject/screens/hospital.dart';

class WelfarePage extends StatefulWidget {
  final VoidCallback onGoHome;

  const WelfarePage({super.key, required this.onGoHome});

  @override
  State<WelfarePage> createState() => _WelfarePageState();
}

class _WelfarePageState extends State<WelfarePage> {
  late Future<List<Welfare>> _future;

  @override
  void initState() {
    super.initState();
    _future = WelfareService.fetchWelfares();
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
                  const _TabButton(title: 'DETAIL', isActive: true),
                  const SizedBox(width: 8),
                  _TabButton(
                    title: 'HOSPITAL',
                    isActive: false,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HospitalPage()),
                      );
                    },
                  ),
                ],
              ),
            ),

            // ===== HOME (อยู่ข้างล่าง) =====
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: GestureDetector(
                onTap: widget.onGoHome,
                child: const Row(
                  children: [
                    Icon(Icons.arrow_back_ios, size: 14, color: Colors.blue),
                    SizedBox(width: 4),
                    Text(
                      'HOME',
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

            const SizedBox(height: 8),

            // ===== CONTENT =====
            Expanded(
              child: FutureBuilder<List<Welfare>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  }

                  final items = snapshot.data!;
                  if (items.isEmpty) {
                    return const Center(child: Text('ไม่มีข้อมูลสวัสดิการ'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final w = items[index];
                      return _WelfareCard(welfare: w);
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

//card
class _WelfareCard extends StatelessWidget {
  final Welfare welfare;
  const _WelfareCard({required this.welfare});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            welfare.title ?? '-',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            welfare.description ?? '-',
            style: const TextStyle(fontSize: 12, height: 1.6),
          ),
        ],
      ),
    );
  }
}

//tab_button

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
