import 'package:flutter/material.dart';
import 'package:the_open_quran/constants/constants.dart';
import 'package:the_open_quran/constants/non_quran_style.dart';

import '../services/pdf_native_viewer.dart';
import '../widgets/adhan_learning_links_card.dart';
import '../widgets/app_bars/primary_app_bar.dart';
import '../widgets/cards/pdf_book_card.dart';

/// Tab screen listing PDF books from lib/assets/pdfbooks/.
class PdfBooksScreen extends StatefulWidget {
  const PdfBooksScreen({super.key});

  @override
  State<PdfBooksScreen> createState() => _PdfBooksScreenState();
}

class _PdfBooksScreenState extends State<PdfBooksScreen> {
  Future<void> _openBook(BuildContext context, String assetPath, String title) async {
    final navigator = Navigator.of(context);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );
    try {
      await PdfNativeViewer.open(context, assetPath: assetPath, title: title);
    } finally {
      if (mounted) navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: DesignSystem.gradientLuxuryBackground,
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PrimaryAppBar(title: context.translate.library),
              Expanded(child: _buildBody(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final books = PdfBooksConstants.books;
    final horizontal = NonQuranStyle.screenPaddingH;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              horizontal,
              DesignSystem.space8,
              horizontal,
              DesignSystem.space12,
            ),
            child: const AdhanLearningLinksCard(),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              horizontal,
              DesignSystem.space4,
              horizontal,
              DesignSystem.space8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.translate.yourLibrary,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: DesignSystem.textForest.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${books.length} ${books.length == 1 ? context.translate.book : context.translate.books}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: DesignSystem.textForest.withValues(alpha: 0.6),
                      ),
                ),
              ],
            ),
          ),
        ),
        if (books.isEmpty)
          SliverToBoxAdapter(child: _buildEmptyPdfHint(context))
        else
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: horizontal),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final entry = books[index];
                  final path = entry['path']!;
                  final title = entry['title']!;
                  return PdfBookCard(
                    title: title,
                    subtitle: context.translate.tapToOpen,
                    assetPath: path,
                    onTap: () => _openBook(context, path, title),
                  );
                },
                childCount: books.length,
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  /// Shown under “Your library” when there are no PDF entries (adhan teaching still visible above).
  Widget _buildEmptyPdfHint(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        NonQuranStyle.screenPaddingH,
        DesignSystem.space8,
        NonQuranStyle.screenPaddingH,
        DesignSystem.space24,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(DesignSystem.space24),
            decoration: BoxDecoration(
              color: DesignSystem.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.menu_book_rounded,
              size: 48,
              color: DesignSystem.primary.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: DesignSystem.space16),
          Text(
            context.translate.noPdfBooksYet,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: NonQuranStyle.sectionTitleColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: DesignSystem.space8),
          Text(
            'Add PDFs under lib/assets/pdfbooks/ and list them in lib/constants/pdf_books.dart.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: DesignSystem.textForest.withValues(alpha: 0.65),
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }

}
