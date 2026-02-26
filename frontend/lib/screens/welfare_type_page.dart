import 'package:flutter/material.dart';
import '../models/welfare.dart';
import 'hospital.dart';
import 'pdf_preview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'hospital.dart';
import 'pdf_preview.dart';

class WelfareTypePage extends StatelessWidget {
  final Welfare welfare;

  const WelfareTypePage({super.key, required this.welfare});

  @override
  Widget build(BuildContext context) {
    final isHealthcare = welfare.type == "healthcare";

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              /// BACK BUTTON
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Row(
                  children: [
                    Icon(
                      Icons.arrow_back_ios,
                      size: 14,
                      color: Colors.blueAccent,
                    ),
                    SizedBox(width: 6),
                    Text(
                      "BACK",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              /// COVER IMAGE
              if (welfare.coverImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    welfare.coverImage!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

              const SizedBox(height: 8),

              /// TITLE
              Text(
                welfare.title,
                style: const TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 16),

              /// DESCRIPTION
              if (welfare.description != null)
                Text(
                  welfare.description!,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.8,
                    color: Colors.black87,
                  ),
                ),

              const SizedBox(height: 40),

              /// FILE SECTION TITLE
              if (welfare.files.isNotEmpty)
                const Text(
                  "DOCUMENTS",
                  style: TextStyle(
                    fontSize: 13,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),

              const SizedBox(height: 20),

              /// FILE LIST
              Column(
                children: welfare.files.map((file) {
                  return Column(children: [_buildDocumentRow(context, file)]);
                }).toList(),
              ),

              /// HOSPITAL SECTION (เฉพาะ healthcare)
              if (isHealthcare) _buildHospitalSection(context),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentRow(BuildContext context, file) {
    final String url = file.fileUrl;
    final String name = file.fileName;
    final bool isPdf = url.toLowerCase().endsWith('.pdf');

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          /// FILE ICON CONTAINER
          Container(
            padding: const EdgeInsets.all(10),

            child: Icon(
              isPdf ? Icons.picture_as_pdf : Icons.image,
              color: Colors.blueAccent,
            ),
          ),

          const SizedBox(width: 14),

          /// FILE NAME
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),

          /// PREVIEW BUTTON
          IconButton(
            icon: const Icon(Icons.visibility),
            onPressed: () {
              FilePreview.show(context, file.fileUrl);
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              await launchUrl(Uri.parse(url));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Divider(thickness: 0.8),
        const SizedBox(height: 20),

        const Text(
          "PARTNER HOSPITAL",
          style: TextStyle(
            fontSize: 13,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),

        const SizedBox(height: 16),

        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HospitalPage()),
            );
          },
          child: Row(
            children: const [
              Icon(Icons.local_hospital, size: 20, color: Colors.redAccent),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  "โรงพยาบาลคู่สัญญา",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ],
    );
  }
}
