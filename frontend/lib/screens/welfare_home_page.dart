import 'package:flutter/material.dart';
import '../services/welfare_service.dart';
import '../models/welfare.dart';
import 'welfare_type_page.dart';

class WelfareHomePage extends StatefulWidget {
  final VoidCallback onGoHome;
  const WelfareHomePage({super.key, required this.onGoHome});

  @override
  State<WelfareHomePage> createState() => _WelfareHomePageState();
}

class _WelfareHomePageState extends State<WelfareHomePage> {
  late Future<List<Welfare>> _future;

  @override
  void initState() {
    super.initState();
    _future = WelfareService.fetchWelfares();
  }

  final List<String> _types = [
    'healthcare',
    'scholarship',
    'registercourse',
    'petition',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<List<Welfare>>(
          future: _future,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data!;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  ///Button home
                  GestureDetector(
                    onTap: widget.onGoHome,
                    child: const Row(
                      children: [
                        Icon(
                          Icons.arrow_back_ios,
                          size: 14,
                          color: Colors.blueAccent,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'HOME',
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// TITLE
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "WELFARE",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Student Support & Benefits",
                        style: TextStyle(fontSize: 14, color: Colors.black45),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  /// CATEGORY LIST
                  Expanded(
                    child: ListView.separated(
                      itemCount: _types.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 40, thickness: 0.6),
                      itemBuilder: (context, index) {
                        final type = _types[index];

                        final welfare = data
                            .where((w) => w.type == type)
                            .firstOrNull;

                        return _buildCategoryRow(context, type, welfare);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryRow(
    BuildContext context,
    String type,
    Welfare? welfare,
  ) {
    final hasData = welfare != null;
    final docCount = welfare?.files.length ?? 0;

    return GestureDetector(
      onTap: hasData
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WelfareTypePage(welfare: welfare!),
                ),
              );
            }
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ICON
          Icon(
            _getIcon(type),
            size: 22,
            color: hasData ? Colors.blueAccent : Colors.black26,
          ),

          const SizedBox(width: 16),

          /// TEXT AREA
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatTitle(type),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: hasData ? Colors.black87 : Colors.black26,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  hasData ? "$docCount Documents" : "Coming Soon",
                  style: TextStyle(
                    fontSize: 13,
                    color: hasData ? Colors.black45 : Colors.black26,
                  ),
                ),
              ],
            ),
          ),

          /// ARROW
          if (hasData)
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.black38,
            ),
        ],
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'healthcare':
        return Icons.local_hospital_outlined;
      case 'scholarship':
        return Icons.school_outlined;
      case 'registercourse':
        return Icons.assignment_outlined;
      case 'petition':
        return Icons.description_outlined;
      default:
        return Icons.info_outline;
    }
  }

  String _formatTitle(String type) {
    switch (type) {
      case 'healthcare':
        return "Healthcare";
      case 'scholarship':
        return "Scholarship";
      case 'registercourse':
        return "Register Course";
      case 'petition':
        return "Petition";
      default:
        return type;
    }
  }
}
