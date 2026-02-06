import 'package:flutter/material.dart';

class TablePage extends StatelessWidget {
  const TablePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: Text('Table Page', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}
