import 'package:flutter/material.dart';
import 'package:myproject/screens/login.dart';
import 'screens/navigation_bar.dart';
import 'screens/scholarship.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('th_TH', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //locale: const Locale('th', 'TH'),
      //supportedLocales: const [Locale('th', 'TH')],
      home: LoginPage(),
    );
  }
}
