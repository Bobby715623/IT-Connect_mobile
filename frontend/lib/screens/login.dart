import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:myproject/services/auth_service.dart';

import 'package:myproject/services/google_auth_service.dart';
import 'package:myproject/screens/navigation_bar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoading = false;

  // 🔴 เปลี่ยน URL ตาม platform ที่ใช้
  String get backendUrl {
    // Android Emulator
    return 'http://10.0.2.2:3000/auth/google';

    // Flutter Web
    // return 'http://localhost:3000/auth/google';
  }

  // ===============================
  // Login handler
  Future<void> _handleLogin() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      debugPrint('BUTTON PRESSED');

      // 1️⃣ Google Login
      final googleUser = await GoogleAuthService().signInWithGoogle();

      if (googleUser == null) {
        debugPrint('Login cancelled');
        return;
      }

      // 2️⃣ Get Google idToken
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        debugPrint('No idToken');
        return;
      }

      // 3️⃣ Send idToken to backend
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );

      if (response.statusCode != 200) {
        debugPrint('Backend error: ${response.body}');
        return;
      }

      // 4️⃣ Receive JWT
      final data = jsonDecode(response.body);

      final jwt = data['token'];
      final userId = data['user']['UserID'];

      await AuthService.saveToken(jwt);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainNavigation(userId: userId)),
      );
    } catch (e) {
      debugPrint('Login error: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ===============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ===== LOGO =====
              Image.asset('assets/images/it_connect_logo.png', width: 250),

              const SizedBox(height: 20),

              // ===== TITLE =====
              const Text(
                'เข้าสู่ระบบ',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 24),

              // ===== GOOGLE BUTTON =====
              SizedBox(
                width: 260,
                height: 48,
                child: OutlinedButton(
                  onPressed: isLoading ? null : _handleLogin,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    side: const BorderSide(color: Colors.grey),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/google_icon.jpg',
                              width: 20,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Sign in with Google',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
