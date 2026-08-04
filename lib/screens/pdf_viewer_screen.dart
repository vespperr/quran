import 'package:flutter/material.dart';
import 'package:the_open_quran/constants/constants.dart';

import '../widgets/app_bars/primary_app_bar.dart';

/// Shown only when the PDF could not be opened (e.g. no handler). On Android, [PdfNativeViewer] uses Kotlin [PdfViewerActivity]; on desktop, it tries the system PDF app first.
class PdfViewerScreen extends StatelessWidget {
  const PdfViewerScreen({
    super.key,
    required this.assetPath,
    required this.title,
  });

  final String assetPath;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.cardBackground,
      appBar: PrimaryAppBar(
        title: title,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.picture_as_pdf_rounded,
                size: 56,
                color: DesignSystem.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Could not open this PDF. Install a PDF reader or try again.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: DesignSystem.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                assetPath,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: DesignSystem.textForest.withValues(alpha: 0.7),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
