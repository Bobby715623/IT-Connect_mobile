import 'package:flutter/material.dart';
import '../widgets/feature_card.dart';

class HomePage extends StatelessWidget {
  final VoidCallback onGoScholarship;
  final VoidCallback onGoActivity;
  final VoidCallback onGoWelfare;

  const HomePage({
    super.key,
    required this.onGoScholarship,
    required this.onGoActivity,
    required this.onGoWelfare,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1,
                children: [
                  // Scholarship
                  FeatureCard(
                    color: const Color(0xFF2CB6B0),
                    icon: const Icon(
                      Icons.school,
                      size: 90,
                      color: Colors.white70,
                    ),
                    title: 'Scholarship',
                    showStar: true,
                    onTap: onGoScholarship,
                  ),

                  // Activity (push ได้ เพราะไม่อยู่ใน bottom nav)
                  FeatureCard(
                    color: const Color(0xFF2F61D6),
                    icon: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 90,
                          height: 90,
                          child: CircularProgressIndicator(
                            value: 0.7,
                            strokeWidth: 12,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.greenAccent,
                            ),
                            backgroundColor: Colors.white24,
                          ),
                        ),
                        const Text(
                          '11',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 36,
                          ),
                        ),
                      ],
                    ),
                    title: 'Activity',
                    showStar: true,
                    onTap: onGoActivity,
                  ),

                  // Welfare
                  FeatureCard(
                    color: const Color(0xFFD2B63B),
                    icon: const Icon(
                      Icons.favorite,
                      size: 90,
                      color: Colors.white70,
                    ),
                    title: 'Welfare',
                    onTap: onGoWelfare,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
