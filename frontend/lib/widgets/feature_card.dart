import 'package:flutter/material.dart';

class FeatureCard extends StatelessWidget {
  final Color color;
  final Widget icon; // ใช้ Icon หรือ Image.asset
  final String title;
  final VoidCallback onTap;
  final bool showStar;

  const FeatureCard({
    super.key,
    required this.color,
    required this.icon,
    required this.title,
    required this.onTap,
    this.showStar = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(21),
        child: Ink(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(21),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // เนื้อหาไอคอน + ข้อความ
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ไอคอน ถ้าต้องการขนาดใหญ่ปรับ Container
                    SizedBox(
                      height: 84,
                      child: Center(child: icon),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              
            ],
          ),
        ),
      ),
    );
  }
}
