import 'package:flutter/material.dart';
import 'package:myproject/screens/activity_port.dart';
import 'package:myproject/screens/welfare.dart';
import 'scholarship.dart';
import '../widgets/custom_bottom_nav.dart';
import 'home.dart';
import 'calendar.dart';
import 'table.dart';
import 'notification.dart';
import 'profile.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int currentIndex = 0;

  List<Widget> get pages => [
    HomePage(
      onGoScholarship: () {
        setState(() => currentIndex = 5);
      },
      onGoActivity: () {
        setState(() => currentIndex = 6);
      },
      onGoWelfare: () {
        setState(() => currentIndex = 7);
      },
    ),
    CalendarPage(),
    NewsPostPage(),
    NotificationPage(),
    ProfilePage(),
    ScholarshipPage(
      onGoHome: () {
        setState(() => currentIndex = 0);
      },
    ),
    ActivityPage(
      onGoHome: () {
        setState(() => currentIndex = 0);
      },
    ),
    WelfarePage(
      onGoHome: () {
        setState(() => currentIndex = 0);
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: CustomBottomNav(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() => currentIndex = index);
        },
        notificationCount: 0, // ใส่ค่าการแจ้งเตือน
      ),
    );
  }
}
