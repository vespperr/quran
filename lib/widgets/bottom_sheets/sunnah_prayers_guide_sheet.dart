import 'package:flutter/material.dart';
import '../../constants/design_system.dart';

/// Modal bottom sheet presenting the comprehensive guide for:
/// 1. The 12 Confirmed Sunnah Prayers (السنن الرواتب), Duha, Witr, and Tahajjud.
/// 2. The Prohibited Times for voluntary prayer (أوقات النهي / کاتەکانی نەهی).
class SunnahPrayersGuideSheet extends StatefulWidget {
  const SunnahPrayersGuideSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SunnahPrayersGuideSheet(),
    );
  }

  @override
  State<SunnahPrayersGuideSheet> createState() =>
      _SunnahPrayersGuideSheetState();
}

class _SunnahPrayersGuideSheetState extends State<SunnahPrayersGuideSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: MediaQuery.sizeOf(context).height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161F1A) : DesignSystem.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(DesignSystem.cornerRadius),
        ),
        boxShadow: DesignSystem.shadowSoft,
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: DesignSystem.outline.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: Color(0xFFD4AF37),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'ڕێبەری نوێژە سوننەتەکان و کاتەکانی نەهی',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Tab bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: const Color(0xFF43A047),
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: Colors.white,
              unselectedLabelColor:
                  theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                fontFamily: 'Inter',
              ),
              tabs: const [
                Tab(text: 'نوێژە سوننەتەکان'),
                Tab(text: 'کاتەکانی نەهی (قەدەغەکراو)'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSunnahTab(theme, isDark),
                _buildProhibitedTab(theme, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSunnahTab(ThemeData theme, bool isDark) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      physics: const BouncingScrollPhysics(),
      children: [
        // Hadith Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF43A047).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF43A047).withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.star_rounded,
                      color: Color(0xFF43A047), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'فەرموودەی پێغەمبەری خوا ﷺ',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF43A047),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '«مَنْ صَلَّى فِي يَوْمٍ وَلَيْلَةٍ ثِنْتَيْ عَشْرَةَ رَكْعَةً بُنِيَ لَهُ بَيْتٌ فِي الْجَنَّةِ»',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  height: 1.6,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 6),
              Text(
                '«هەرکەسێک لە شەو و ڕۆژێکدا ١٢ ڕکعەت نوێژی سوننەت بکات، کۆشکێکی لە بەهەشتدا بۆ دروست دەکرێت.» (صحيح مسلم)',
                style: theme.textTheme.bodySmall?.copyWith(
                  height: 1.5,
                  color:
                      theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // 12 Rawatib Section
        Text(
          '١. سوننەتە موئەکەدەکان (١٢ ڕکعەتی ڕۆژانە)',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF43A047),
          ),
        ),
        const SizedBox(height: 8),
        _buildPrayerSunnahItem(
          prayer: 'نوێژی بەیانی (الفجر)',
          before: '٢ ڕکعەتی پێش فەرز',
          after: '—',
          note:
              'گرنگترین سوننەتە، سوننەتە سورەتی (الكافرون و الإخلاص) تێیدا بخوێندرێت.',
          isDark: isDark,
        ),
        _buildPrayerSunnahItem(
          prayer: 'نوێژی نیوەڕۆ (الظهر)',
          before: '٤ ڕکعەتی پێش فەرز (دوو بە دوو)',
          after: '٢ ڕکعەتی پاش فەرز',
          note:
              'دەتوانرێت ٢ ڕکعەتی تریش پاش نیوەڕۆ زیاد بکرێت بۆ تەواوکردنی ٤ ڕکعەت.',
          isDark: isDark,
        ),
        _buildPrayerSunnahItem(
          prayer: 'نوێژی عەسر (العصر)',
          before: '٤ ڕکعەت (سوننەتی غەیرە موئەکەدە)',
          after: '— (کاتی نەهیە پاش فەرز)',
          note: '«ڕەحمەتی خوای لێبێت کەسێک پێش عەسر چوار ڕکعەت نوێژ بکات».',
          isDark: isDark,
        ),
        _buildPrayerSunnahItem(
          prayer: 'نوێژی ئێوارە (المغرب)',
          before: '—',
          after: '٢ ڕکعەتی پاش فەرز',
          note: 'پاش فەرز بە خێرایی ئەنجام دەدرێت.',
          isDark: isDark,
        ),
        _buildPrayerSunnahItem(
          prayer: 'نوێژی عیشا (العشاء)',
          before: '—',
          after: '٢ ڕکعەتی پاش فەرز',
          note: 'پاش ئەم ٢ ڕکعەتە نوێژی ویتر دەکرێت.',
          isDark: isDark,
        ),
        const SizedBox(height: 20),
        // Other Sunnahs
        Text(
          '٢. نوێژە سوننەتە گرنگەکانی تر',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFFD4AF37),
          ),
        ),
        const SizedBox(height: 10),
        _buildCardItem(
          title: 'نوێژی چێشتەنگاو (صلاة الضحى)',
          content:
              '• کاتەکەی: نزیکەی ١٥ بۆ ٢٠ خولەک دوای خۆرهەڵاتن دەستپێدەکات هەتا ١٥ خولەک پێش بانگی نیوەڕۆ.\n• ڕکعەتەکان: کەمترینی ٢ ڕکعەتە، تا ٤ یان ٨ ڕکعەت.\n• فەزڵەکەی: خێر و سەدەقەی ٣٦٠ جومگەی لەشی مرۆڤ دەدات.',
          icon: Icons.wb_sunny_outlined,
          iconColor: const Color(0xFFD4AF37),
          isDark: isDark,
        ),
        const SizedBox(height: 10),
        _buildCardItem(
          title: 'نوێژی ویتر (صلاة الوتر)',
          content:
              '• کاتەکەی: لە دوای نوێژی عیشا هەتا کاتی بانگی بەیانی.\n• ڕکعەتەکان: تاکە (١ ڕکعەت، یان ٣ ڕکعەت: ٢ ڕکعەت پاشان سەلام دەداتەوە و ١ ڕکعەتی ویتر دەکات).\n• سوننەتە لە دوایین ڕکعەتدا دوعای قنوت بخوێندرێت.',
          icon: Icons.nightlight_round,
          iconColor: const Color(0xFF673AB7),
          isDark: isDark,
        ),
        const SizedBox(height: 10),
        _buildCardItem(
          title: 'شەونوێژ (قیام اللیل / التهجد)',
          content:
              '• کاتەکەی: تەواوی شەو، بەتایبەت لە سێیەکی کۆتایی شەودا پێش بانگی بەیانی.\n• ڕکعەتەکان: دوو بە دوو، هەتا ویتر دەکرێتە کۆتا نوێژ.',
          icon: Icons.bedtime_outlined,
          iconColor: const Color(0xFF2E7D32),
          isDark: isDark,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildProhibitedTab(ThemeData theme, bool isDark) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      physics: const BouncingScrollPhysics(),
      children: [
        // Warning Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE53935).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE53935).withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Color(0xFFE53935), size: 22),
                  SizedBox(width: 8),
                  Text(
                    'کاتەکانی نەهی (قەدەغەکراوی نوێژ)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFFE53935),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'پێغەمبەری خوا ﷺ بەتوندی نەهی فەرمووە لە ئەنجامدانی نوێژی سوننەتی ڕەها (نەفلی بێ هۆکار) لە ٣ کاتی سەرەکیدا:',
                style: theme.textTheme.bodySmall?.copyWith(
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildProhibitedCard(
          number: '١',
          title: 'لە دوای نوێژی بەیانی تا بەرزبوونەوەی تەواوی خۆر',
          duration: 'لە پاش بەیانی تا نزیکەی ١٥ بۆ ٢٠ خولەک پاش خۆرهەڵاتن',
          reason:
              'لەبەر ئەوەی خۆر لە نێوان دوو شاخی شەیتاندا هەڵدێت و کافرەکان لەم کاتەدا سوجدەی بۆ دەبەن.',
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildProhibitedCard(
          number: '٢',
          title: 'کاتی وەستانی خۆر لە ناوەڕاستی ئاسمان (پێش نیوەڕۆ)',
          duration: 'نزیکەی ٥ بۆ ١٥ خولەک پێش بانگی نیوەڕۆ',
          reason:
              'لەبەر ئەوەی لەم کاتەدا ئاگری دۆزەخ دادەگیرسێندرێت و گەرم دەکرێت هەتا خۆر لە ناوەڕاست لا دەدات بەلای ڕۆژئاوادا.',
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildProhibitedCard(
          number: '٣',
          title: 'لە دوای نوێژی عەسر تا ئاوابوونی تەواوی خۆر',
          duration: 'لە پاش ئەنجامدانی فەرزی عەسر هەتا بانگی ئێوارە',
          reason: 'لەبەر ئەوەی خۆر لە نێوان دوو شاخی شەیتاندا ئاوا دەبێت.',
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        // Fiqh Exception Note
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تێبینی گرنگی فیقهی (نوێژە ڕێگەپێدراوەکان):',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'ئەو نوێژانەی کە هۆکارێکی تایبەتیان هەیە (وەک قەزاکردنەوەی نوێژی فەرز، نوێژی جەنازە، نوێژی خۆرگیران، سڵاوی مزگەوت لەسەر ڕای ئیمامی شافعی) دروستن لەم کاتانەشدا ئەنجام بدرێن؛ تەنها نوێژی سوننەتی ڕەها (نەفلی بێ هۆکار) مەکرووهـ یان حەرامە.',
                style: theme.textTheme.bodySmall?.copyWith(
                  height: 1.55,
                  color:
                      theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPrayerSunnahItem({
    required String prayer,
    required String before,
    required String after,
    required String note,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: DesignSystem.outline.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                prayer,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF43A047).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'سوننەت',
                  style: TextStyle(
                    color: Color(0xFF43A047),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.arrow_back, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text('پێش فەرز: ',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              Text(before,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.arrow_forward, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text('پاش فەرز: ',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              Text(after,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            note,
            style: TextStyle(
              fontSize: 11.5,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardItem({
    required String title,
    required String content,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: DesignSystem.outline.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 12.5, height: 1.55),
          ),
        ],
      ),
    );
  }

  Widget _buildProhibitedCard({
    required String number,
    required String title,
    required String duration,
    required String reason,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE53935).withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE53935).withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 11,
                backgroundColor: const Color(0xFFE53935),
                child: Text(
                  number,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    color: Color(0xFFE53935),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.schedule, size: 14, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  duration,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'هۆکار: $reason',
            style: TextStyle(
              fontSize: 11.5,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
