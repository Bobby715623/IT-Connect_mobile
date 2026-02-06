import 'package:flutter/material.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.white,
        alignment: Alignment.center,
        child: const Text('Activity Page', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
