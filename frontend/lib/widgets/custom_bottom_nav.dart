import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final int notificationCount;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.notificationCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          navItem(Icons.home_outlined, "HOME", 0),
          navItem(Icons.calendar_today_outlined, "CALENDAR", 1),
          navItem(Icons.table_chart_outlined, "TABLE", 2),
          notificationItem(),
          navItem(Icons.person_outline, "PROFILE", 4),
        ],
      ),
    );
  }

  Widget navItem(IconData icon, String label, int index) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 28,
              color: isSelected ? Colors.blueAccent : Colors.grey.shade500),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isSelected ? Colors.blueAccent : Colors.grey.shade500,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget notificationItem() {
    final isSelected = currentIndex == 3;

    return GestureDetector(
      onTap: () => onTap(3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.notifications_none,
                  size: 28,
                  color: isSelected ? Colors.blueAccent : Colors.grey.shade500),

              if (notificationCount > 0)
                Positioned(
                  right: -6,
                  top: -6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        notificationCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "NOTIFICATION",
            style: TextStyle(
              fontSize: 11,
              color: isSelected ? Colors.blueAccent : Colors.grey.shade500,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
