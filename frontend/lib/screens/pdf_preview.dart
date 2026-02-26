import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class FilePreview {
  static void show(BuildContext context, String url) {
    final isPdf = url.toLowerCase().endsWith('.pdf');

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "File Preview",
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
          child: Stack(
            children: [
              /// 🔥 BLUR BACKGROUND
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(color: Colors.black.withOpacity(0.4)),
              ),

              /// 🔥 CENTER CARD
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.85,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Stack(
                    children: [
                      /// CONTENT
                      Positioned.fill(
                        child: isPdf
                            ? SfPdfViewer.network(
                                url,
                                canShowScrollHead: true,
                                canShowScrollStatus: true,
                                enableDoubleTapZooming: true,
                              )
                            : InteractiveViewer(
                                child: Image.network(
                                  url,
                                  fit: BoxFit.contain,
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Text("Unable to load image"),
                                    );
                                  },
                                ),
                              ),
                      ),

                      /// CLOSE BUTTON
                      Positioned(
                        top: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const CircleAvatar(
                            backgroundColor: Colors.black54,
                            child: Icon(Icons.close, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
