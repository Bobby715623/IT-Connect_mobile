import 'package:flutter/material.dart';
import 'package:myproject/screens/login.dart';
import 'screens/navigation_bar.dart';
import 'screens/scholarship.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: LoginPage());
  }
}
