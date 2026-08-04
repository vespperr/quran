import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:the_open_quran/constants/constants.dart';

/// Displays the surah name from the surahSVG folder (1.svg–114.svg).
/// SVGs are black; [color] tints them to match the design.
/// If the SVG fails to load, [fallbackText] is shown (e.g. Arabic name from model).
class SurahNameSvg extends StatelessWidget {
  const SurahNameSvg({
    super.key,
    required this.surahId,
    this.color,
    this.height = 28,
    this.fit = BoxFit.contain,
    this.fallbackText,
    this.fallbackStyle,
  });

  final int surahId;
  final Color? color;
  final double height;
  final BoxFit fit;
  final String? fallbackText;
  final TextStyle? fallbackStyle;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? DesignSystem.textForest;
    final style = fallbackStyle ?? TextStyle(
      fontSize: height * 0.75,
      fontWeight: FontWeight.w600,
      color: tint,
    );
    return SvgPicture.asset(
      ImageConstants.surahNameSvg(surahId),
      height: height,
      fit: fit,
      colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
      placeholderBuilder: (_) => SizedBox(height: height, width: height * 2),
      errorBuilder: (_, __, ___) {
        if (fallbackText != null && fallbackText!.isNotEmpty) {
          return Text(fallbackText!, style: style, maxLines: 1, overflow: TextOverflow.ellipsis);
        }
        return SizedBox(height: height, width: height * 2);
      },
    );
  }
}
