import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:the_open_quran/constants/constants.dart';
import 'package:the_open_quran/constants/non_quran_style.dart';
import 'package:the_open_quran/services/pdf_thumbnail_service.dart';

/// Course-style PDF book card: large top cover, rounded content area, title, info chips, and primary action button.
class PdfBookCard extends StatefulWidget {
  const PdfBookCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.assetPath,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String? assetPath;
  final VoidCallback? onTap;

  @override
  State<PdfBookCard> createState() => _PdfBookCardState();
}

class _PdfBookCardState extends State<PdfBookCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  Uint8List? _thumbnailBytes;
  /// True while loading a native thumbnail (Android).
  bool _thumbnailLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastOutSlowIn,
      ),
    );
    _animationController.forward();
    final path = widget.assetPath;
    if (path != null && path.isNotEmpty) {
      _thumbnailLoading = true;
      PdfThumbnailService.firstPagePng(path).then((bytes) {
        if (!mounted) return;
        setState(() {
          _thumbnailBytes = bytes;
          _thumbnailLoading = false;
        });
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  static const double _cardRadius = 16;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignSystem.space8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap == null
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  widget.onTap!();
                },
          borderRadius: BorderRadius.circular(_cardRadius),
          child: Container(
            decoration: BoxDecoration(
              color: DesignSystem.surface,
              borderRadius: BorderRadius.circular(_cardRadius),
              boxShadow: [
                BoxShadow(
                  color: DesignSystem.textForest.withValues(alpha: 0.12),
                  offset: const Offset(0, 3),
                  blurRadius: 10,
                ),
                BoxShadow(
                  color: DesignSystem.textForest.withValues(alpha: 0.06),
                  offset: const Offset(1, 1),
                  blurRadius: 8,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_cardRadius),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final cardWidth = constraints.maxWidth;
                  final coverHeight = cardWidth / 2.4;
                  return Stack(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildCover(context),
                          _buildContent(context),
                        ],
                      ),
                      _buildFloatingBadge(context, coverHeight),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCover(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2.4,
      child: _thumbnailBytes != null
          ? Image.memory(
              _thumbnailBytes!,
              fit: BoxFit.cover,
              gaplessPlayback: true,
            )
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    DesignSystem.primary.withValues(alpha: 0.25),
                    DesignSystem.primary.withValues(alpha: 0.12),
                    DesignSystem.primary.withValues(alpha: 0.06),
                  ],
                ),
              ),
              child: Center(
                child: _thumbnailLoading
                    ? SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: DesignSystem.primary.withValues(alpha: 0.85),
                        ),
                      )
                    : Icon(
                        Icons.picture_as_pdf_rounded,
                        color: DesignSystem.primary.withValues(alpha: 0.9),
                        size: 32,
                      ),
              ),
            ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: 12,
        right: 12,
        top: 10,
        bottom: 10,
      ),
      decoration: BoxDecoration(
        color: DesignSystem.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(_cardRadius),
          topRight: Radius.circular(_cardRadius),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            textAlign: TextAlign.left,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  letterSpacing: 0.2,
                  color: NonQuranStyle.sectionTitleColor,
                ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 0, right: 4, top: 4, bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'PDF',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    letterSpacing: 0.2,
                    color: DesignSystem.primary,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 11,
                        color: DesignSystem.textForest.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(width: 3),
                    Icon(
                      Icons.menu_book_rounded,
                      color: DesignSystem.primary,
                      size: 14,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                _buildInfoChip(context, context.translate.pdf, context.translate.format),
                _buildInfoChip(context, context.translate.book, context.translate.type),
                _buildInfoChip(context, context.translate.read, context.translate.openBook),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 34,
            decoration: BoxDecoration(
              color: DesignSystem.primary,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: DesignSystem.primary.withValues(alpha: 0.35),
                  offset: const Offset(1, 1),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(10),
                child: Center(
                  child: Text(
                    context.translate.openBook,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      letterSpacing: 0,
                      color: DesignSystem.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String value, String label) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Container(
          decoration: BoxDecoration(
            color: DesignSystem.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: DesignSystem.outlineVariant.withValues(alpha: 0.4),
            ),
            boxShadow: [
              BoxShadow(
                color: DesignSystem.textForest.withValues(alpha: 0.06),
                offset: const Offset(1, 1),
                blurRadius: 4,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 9,
                  letterSpacing: 0.15,
                  color: DesignSystem.primary,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 8,
                  letterSpacing: 0.15,
                  color: DesignSystem.textForest.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingBadge(BuildContext context, double coverHeight) {
    const badgeSize = 32.0;
    return Positioned(
      top: coverHeight - 12 - badgeSize,
      right: 12,
      child: ScaleTransition(
        alignment: Alignment.center,
        scale: _scaleAnimation,
        child: Container(
          width: badgeSize,
          height: badgeSize,
          decoration: BoxDecoration(
            color: DesignSystem.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: DesignSystem.primary.withValues(alpha: 0.4),
                offset: const Offset(0, 2),
                blurRadius: 6,
              ),
            ],
          ),
          child: Icon(
            Icons.auto_stories_rounded,
            color: DesignSystem.onPrimary,
            size: 16,
          ),
        ),
      ),
    );
  }
}
