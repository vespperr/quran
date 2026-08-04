import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:the_open_quran/constants/constants.dart';

/// Callbacks and data for PDF viewer controls (prev/next/jump to page).
class PdfViewerControlsData {
  const PdfViewerControlsData({
    required this.currentPage,
    required this.totalPages,
    required this.onPreviousPage,
    required this.onNextPage,
    required this.onFirstPage,
    required this.onLastPage,
    required this.onJumpToPage,
  });

  final int currentPage;
  final int totalPages;
  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;
  final VoidCallback onFirstPage;
  final VoidCallback onLastPage;
  final void Function(int page) onJumpToPage;
}

/// Bottom bar with page navigation: First | Prev | Page X of Y | Next | Last, plus "Go to page".
class PdfViewerControls extends StatelessWidget {
  const PdfViewerControls({
    super.key,
    required this.data,
  });

  final PdfViewerControlsData data;

  void _goToPageDialog(BuildContext context) {
    final total = data.totalPages;
    final controller = TextEditingController(text: '${data.currentPage}');
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.translate.goToPage),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '1 - $total',
            border: const OutlineInputBorder(),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          onSubmitted: (value) {
            final p = int.tryParse(value);
            if (p != null && p >= 1 && p <= total) {
              data.onJumpToPage(p);
              Navigator.of(ctx).pop();
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.translate.cancel),
          ),
          FilledButton(
            onPressed: () {
              final p = int.tryParse(controller.text);
              if (p != null && p >= 1 && p <= total) {
                data.onJumpToPage(p);
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Go'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = data;
    final canPrev = d.currentPage > 1;
    final canNext = d.currentPage < d.totalPages;

    return Material(
      elevation: 8,
      color: DesignSystem.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignSystem.space12,
            vertical: DesignSystem.space8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ControlIcon(
                icon: Icons.first_page,
                onPressed: canPrev ? d.onFirstPage : null,
              ),
              const SizedBox(width: 4),
              _ControlIcon(
                icon: Icons.chevron_left,
                onPressed: canPrev ? d.onPreviousPage : null,
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _goToPageDialog(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignSystem.space12,
                    vertical: DesignSystem.space8,
                  ),
                  decoration: BoxDecoration(
                    color: DesignSystem.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DesignSystem.radiusPill),
                  ),
                  child: Text(
                    '${d.currentPage} / ${d.totalPages}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: DesignSystem.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _ControlIcon(
                icon: Icons.chevron_right,
                onPressed: canNext ? d.onNextPage : null,
              ),
              const SizedBox(width: 4),
              _ControlIcon(
                icon: Icons.last_page,
                onPressed: canNext ? d.onLastPage : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlIcon extends StatelessWidget {
  const _ControlIcon({required this.icon, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed == null
          ? null
          : () {
              HapticFeedback.lightImpact();
              onPressed!();
            },
      icon: Icon(
        icon,
        color: onPressed != null
            ? DesignSystem.primary
            : DesignSystem.onSurface.withValues(alpha: 0.4),
      ),
      style: IconButton.styleFrom(
        foregroundColor: DesignSystem.primary,
      ),
    );
  }
}

// NOTE: PdfViewerControlsDataBuilder was removed because it depends on
// `pdfx` controllers (PdfController / PdfControllerPinch).
