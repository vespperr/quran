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
    _tabController = TabController(length: 3, vsync: this);
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
      height: MediaQuery.sizeOf(context).height * 0.88,
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
                    'ڕێبەری نوێژ و سوننەتەکان',
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
            margin: const EdgeInsets.symmetric(horizontal: 16),
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
                fontSize: 12.5,
                fontFamily: 'Inter',
              ),
              tabs: const [
                Tab(text: 'شێوازی نوێژکردن'),
                Tab(text: 'نوێژە سوننەتەکان'),
                Tab(text: 'کاتەکانی نەهی'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildHowToPrayTab(theme, isDark),
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

  Widget _buildHowToPrayTab(ThemeData theme, bool isDark) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      physics: const BouncingScrollPhysics(),
      children: [
        // Prophetic Hadith banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E88E5).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF1E88E5).withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.menu_book_rounded,
                      color: Color(0xFF1E88E5), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'فەرموودەی پێغەمبەری خوا ﷺ',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E88E5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '«صَلُّوا كَمَا رَأَيْتُمُونِي أُصَلِّي»',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  height: 1.6,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 6),
              Text(
                '«نوێژ بکەن بەو شێوازەی کە بینیتان من نوێژم پێکرد.» (صحيح البخاري)',
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

        // Prerequisites
        Text(
          'مەرجەکانی پێش دەستپێکردنی نوێژ',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF43A047),
          ),
        ),
        const SizedBox(height: 8),
        _buildPrerequisiteCard(
          isDark: isDark,
          items: const [
            '١. پاکوخاوێنی: دەستنوێژگرتن یان خۆشۆردن لە لەشگرانی.',
            '٢. پاکیی لەش و جلوبەرگ و شوێنی نوێژ لە هەموو ناپاکیەک.',
            '٣. داپۆشینی عەورەت (بۆ پیاو لە ناوکەوە تا ئەژنۆ، بۆ ئافرەت هەموو لەش جگە لە دەموچاو و دەستەکان).',
            '٤. دڵنیابوون لە هاتنی کاتی نوێژەکە.',
            '٥. ڕووکردنە قیبلەی پیرۆز (کەعبەی پیرۆز).',
            '٦. نیەت: شوێنەکەی دڵە و بە دەم وتنی نەهاتووە و بیدعەیە.',
          ],
        ),
        const SizedBox(height: 20),

        // Steps Title
        Text(
          'شێوازی نوێژکردن هەنگاو بە هەنگاو',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF43A047),
          ),
        ),
        const SizedBox(height: 10),

        // Step 1: Takbeerat al-Ihram
        _buildStepCard(
          stepNumber: '١',
          title: 'تەكبیرەی ئیحرام (دەستپێکردن)',
          arabicText: 'اللَّهُ أَكْبَرُ',
          explanation:
              'ڕاوەستان بە ڕێکی و سەیرکردنی جێگای سوجدە. هەردوو دەست تا ئاستی شانەکان یان نەرمەی گوێچکەکان بەرز دەکرێنەوە بە شێوەیەک پەنجەکان لێک کراوە نەبن و ڕوو لە قیبلە بن، لەگەڵ وتنی «اللَّهُ أَكْبَرُ».',
          note: 'ئەم تەكبیرەیە فەرزە (ڕوکنە) و بەبێ ئەمە نوێژ دانامەزرێت.',
          isDark: isDark,
        ),

        // Step 2: Istiftah
        _buildStepCard(
          stepNumber: '٢',
          title: 'دانانی دەستەکان و دەعای دەستپێکردن (الاستفتاح)',
          arabicText:
              '«سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ، وَتَبَارَكَ اسْمُكَ، وَتَعَالَى جَدُّكَ، وَلاَ إِلَهَ غَيْرُكَ»',
          explanation:
              'دەستی ڕاست لەسەر پشتی دەستی چەپ و مەچەک لەسەر سنگ دادەنرێت. پاشان ئەم دوعایە  بە بێدەنگی لە دڵ یان بە چرپە لە ڕکاتی یەکەمدا دەخوێندرێت.',
          note: 'سوننەتە لە ڕکاتی یەکەمدا لە دوای تەكبیرەی ئیحرام بخوێندرێت.',
          isDark: isDark,
        ),

        // Step 3: Fatihah & Surah
        _buildStepCard(
          stepNumber: '٣',
          title: 'پەناگرتن و خوێندنی سورەتی (الفاتحة)',
          arabicText:
              '«أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ • بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ»',
          explanation:
              'پاش پەناگرتن بە پەروەردگار و بەسمەلە، سورەتی پیرۆزی فاتیحە بە تەواوی دەخوێندرێت. لە کۆتایی فاتیحەدا دەوترێت: «آمين». خوێندنی فاتیحە ڕوکنە لە هەموو ڕکاتێکدا بۆ ئیمام و تەنیاخوێن. پاش فاتیحە لە ڕکاتی یەکەم و دووەمدا سورەتێک یان چەند ئایەتێک لە قورئان دەخوێندرێت.',
          note:
              '«لاَ صَلاَةَ لِمَنْ لَمْ يَقْرَأْ بِفَاتِحَةِ الْكِتَابِ» (صحيح البخاري).',
          isDark: isDark,
        ),

        // Step 4: Ruku
        _buildStepCard(
          stepNumber: '٤',
          title: 'چوون بۆ ڕکوع (چەمینەوە)',
          arabicText: '«سُبْحَانَ رَبِّيَ الْعَظِيمِ» (٣ جار)',
          explanation:
              'وتنی «اللَّهُ أَكْبَرُ» و چەمینەوە بۆ ڕکوع. دەستەکان دەخرێنە سەر ئەژنۆکان و پەنجەکان لێک جیا دەکرێنەوە وەک ئەوەی دەست بە ئەژنۆوە گیرابێت. پشت تەواو ڕێک دەبێت بە ئاستی سەر، بەبێ دانەواندن یان بەرزکردنەوەی سەر.',
          note:
              'ئارامگرتن لە ڕکوعدا ڕوکنە، نابێت پەلە بکرێت تا جومگەکان جێگیر دەبن.',
          isDark: isDark,
        ),

        // Step 5: Rising from Ruku
        _buildStepCard(
          stepNumber: '٥',
          title: 'هەستانەوە لە ڕکوع بە هێمنی',
          arabicText:
              '«سَمِعَ اللَّهُ لِمَنْ حَمِدَهُ»\n«رَبَّنَا وَلَكَ الْحَمْدُ، حَمْداً كَثِيراً طَيِّباً مُبَارَكاً فِيهِ»',
          explanation:
              'بەرزبوونەوە لە ڕکوع بە تەواوی تا قیت ڕادەوەستیت. لە کاتی هەستانەوە دەوترێت «سَمِعَ اللَّهُ لِمَنْ حَمِدَهُ» (بۆ ئیمام و تەنیاخوێن)، لە کاتی ڕاوەستان بە ڕێکی دەوترێت «رَبَّنَا وَلَكَ الْحَمْدُ...».',
          note:
              'پێویستە بە تەواوی پشت ڕێک بوەستێت و هەموو جومگەیەک بگەڕێتەوە شوێنی خۆی.',
          isDark: isDark,
        ),

        // Step 6: First Sujud
        _buildStepCard(
          stepNumber: '٦',
          title: 'سوجدەی یەکەم',
          arabicText: '«سُبْحَانَ رَبِّيَ الأَعْلَى» (٣ جار)',
          explanation:
              'وتنی «اللَّهُ أَكْبَرُ» و دابەزین بۆ سوجدە. سوجدە بردن لەسەر ٧ ئەندام: نێوچەوان لەگەڵ لوت، هەردوو لەپی دەست، هەردوو ئەژنۆ، و سەرپەنجەکانی هەردوو پێ کە ڕوو لە قیبلە بن. باڵەکان لە تەنیشت دوور دەخرێنەوە و ئەنیشک لەسەر زەوی دانانرێت.',
          note:
              'نزیکترین کات کە بەندە لە پەروەردگاری نزیک بێت کاتی سوجدەیە، بۆیە دەعای تێدا زۆر بکەن.',
          isDark: isDark,
        ),

        // Step 7: Sitting Between Sujuds
        _buildStepCard(
          stepNumber: '٧',
          title: 'دانیشتنی نێوان دوو سوجدەدا',
          arabicText: '«رَبِّ اغْفِرْ لِي، رَبِّ اغْفِرْ لِي»',
          explanation:
              'هەستانەوە لە سوجدە بە وتنی «اللَّهُ أَكْبَرُ» و دانیشتن بە ئارامی. سوننەتە پێی چەپ ڕابخرێت و لەسەری دابنیشێت (افتراش) و پێی ڕاست ڕابگیرێت بە پەنجەکانی ڕوو لە قیبلە. دەستەکان لەسەر ڕان دادەنرێن.',
          note:
              'هێمنی و دڵنیابوون لە دانیشتنەکە ڕوکنە و ناکرێت بە خێرایی سوجدەی دووەم ببرێت.',
          isDark: isDark,
        ),

        // Step 8: Second Sujud & 2nd Rakat
        _buildStepCard(
          stepNumber: '٨',
          title: 'سوجدەی دووەم و هەستانەوە بۆ ڕکاتی دووەم',
          arabicText: '«سُبْحَانَ رَبِّيَ الأَعْلَى» (٣ جار)',
          explanation:
              'سوجدەی دووەم دەبرێتەوە بە هەمان شێوازی سوجدەی یەکەم. پاشان بە وتنی «اللَّهُ أَكْبَرُ» هەڵدەستیتەوە بۆ ئەنجامدانی ڕکاتی دووەم بە هەمان هەنگاوەکان، جگە لە تەكبیرەی ئیحرام و دەعای دەستپێکردن کە تەنها لە ڕکاتی یەکەمدا هەن.',
          note: 'بە ئەنجامدانی سوجدەی دووەم ڕکاتی یەکەم تەواو دەبێت.',
          isDark: isDark,
        ),

        // Step 9: First Tashahhud
        _buildStepCard(
          stepNumber: '٩',
          title: 'تەشەهودی یەکەم (دوای ڕکاتی دووەم)',
          arabicText:
              '«التَّحِيَّاتُ لِلَّهِ، وَالصَّلَوَاتُ وَالطَّيِّبَاتُ، السَّلاَمُ عَلَيْكَ أَيُّهَا النَّبِيُّ وَرَحْمَةُ اللَّهِ وَبَرَكَاتُهُ، السَّلاَمُ عَلَيْنَا وَعَلَى عِبَادِ اللَّهِ الصَّالِحِينَ، أَشْهَدُ أَنْ لاَ إِلَهَ إِلاَّ اللَّهُ، وَأَشْهَدُ أَنَّ مُحَمَّداً عَبْدُهُ وَرَسُولُهُ»',
          explanation:
              'دوای ڕکاتی دووەم دادەنیشیت، دەستی چەپ لەسەر ئەژنۆی چەپ و دەستی ڕاست لەسەر ئەژنۆی ڕاست دادەنرێت. پەنجەکانی دەستی ڕاست گرێ دەدرێن جگە لە پەنجەی شایەتمان کە ڕوو لە قیبلە ئاماژەی پێدەکرێت لەگەڵ خوێندنی تەشەهود.',
          note:
              'لە نوێژەکانی نیوەڕۆ، عەسر، مەغریب و عیشادا دوای ئەم تەشەهودە بە وتنی «اللَّهُ أَكْبَرُ» هەڵدەستیتەوە بۆ ڕکاتەکانی تر.',
          isDark: isDark,
        ),

        // Step 10: Final Tashahhud & Salawat & Refuge
        _buildStepCard(
          stepNumber: '١٠',
          title: 'تەشەهودی کۆتایی، سەڵاواتی ئیبراهیمی، و پەناگرتن',
          arabicText:
              '«اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ، كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ، إِنَّكَ حَمِيدٌ مَجِيدٌ، اللَّهُمَّ بَارِكْ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ، كَمَا بَارَكْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ، إِنَّكَ حَمِيدٌ مَجِيدٌ»\n\n«اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ عَذَابِ جَهَنَّمَ، وَمِنْ عَذَابِ الْقَبْرِ، وَمِنْ فِتْنَةِ الْمَحْيَا وَالْمَمَاتِ، وَمِنْ شَرِّ فِتْنَةِ الْمَسِيحِ الدَّجَّالِ»',
          explanation:
              'لە کۆتا ڕکاتی نوێژەکەدا دادەنیشیت، تەشەهود دەخوێنیت و پاشان سەڵاواتی ئیبراهیمی دەخوێنیت. سوننەتی پێغەمبەرە ﷺ کە لە دوای سەڵاوات و پێش سەلامدانەوە پەنا بە خوا بگریت لە چوار شتی مەترسیدار.',
          note: 'دەعاکردن لەم کاتەدا پێش سەلامدانەوە زۆر وەڵامدراوەیە.',
          isDark: isDark,
        ),

        // Step 11: Tasleem
        _buildStepCard(
          stepNumber: '١١',
          title: 'سەلامدانەوە (کۆتایی نوێژ)',
          arabicText:
              'لای ڕاست: «السَّلاَمُ عَلَيْكُمْ وَرَحْمَةُ اللَّهِ»\nلای چەپ: «السَّلاَمُ عَلَيْكُمْ وَرَحْمَةُ اللَّهِ»',
          explanation:
              'سەرت دەسوڕێنیت بۆ لای ڕاست بە شێوەیەک سپیایی گۆنات لە دواوە ببینرێت و سەلام دەدەیتەوە، پاشان بە هەمان شێوە سەرت دەسوڕێنیت بۆ لای چەپ و سەلام دەدەیتەوە.',
          note: 'بە سەلامدانەوە بۆ لای ڕاست نوێژەکە بە تەواوی کۆتایی دێت.',
          isDark: isDark,
        ),
        const SizedBox(height: 16),

        // Tumaneenah Note
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFE53935).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
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
                      color: Color(0xFFE53935), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'ئاگادارییەکی زۆر گرنگ: هێمنی و ئارامی (الطمأنينة)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                      color: Color(0xFFE53935),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'هێمنی لە ڕاوەستان، ڕکوع، هەستانەوە، و سوجدەدا یەکێکە لە پایە (ڕوکنە) هەرە سەرەکییەکانی نوێژ. کەسێک نوێژ بە پەلە و بەبێ جێگیربوونی ئێسکەکانی بکات، نوێژەکەی قبوڵ نابێت وەکو چۆن پێغەمبەری خوا ﷺ بەو پیاوەی فەرموو کە پەلەی کرد لە نوێژەکەیدا: «ارْجِعْ فَصَلِّ فَإِنَّكَ لَمْ تُصَلِّ» (بگەڕێرەوە نوێژ بکەوە چونکە تۆ نوێژت نەکردووە).',
                style: theme.textTheme.bodySmall?.copyWith(
                  height: 1.5,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Rakat count table
        Text(
          'ژمارەی ڕکاتەکانی ٥ نوێژە فەرزەکە',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF43A047),
          ),
        ),
        const SizedBox(height: 8),
        _buildPrayerRakatCountItem(
            'نوێژی بەیانی (الفجر)', '٢ ڕکات', 'بە دەنگ', isDark),
        _buildPrayerRakatCountItem(
            'نوێژی نیوەڕۆ (الظهر)', '٤ ڕکات', 'بە بێدەنگ (نهێنی)', isDark),
        _buildPrayerRakatCountItem(
            'نوێژی عەسر (العصر)', '٤ ڕکات', 'بە بێدەنگ (نهێنی)', isDark),
        _buildPrayerRakatCountItem(
            'نوێژی ئێوارە (المغرب)', '٣ ڕکات', '٢ بە دەنگ + ١ بێدەنگ', isDark),
        _buildPrayerRakatCountItem(
            'نوێژی عیشا (العشاء)', '٤ ڕکات', '٢ بە دەنگ + ٢ بێدەنگ', isDark),
        const SizedBox(height: 20),

        // Common Mistakes in Congregational Prayer
        Text(
          'هەڵە باوەکانی ناو نوێژی جەماعەت',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFFE53935),
          ),
        ),
        const SizedBox(height: 8),
        _buildMistakeCard(
          title: '١. دەنگ دەرکردن و فسکە فسک لە خوێندنەوەدا',
          problem:
              'لە نوێژە نهێنییەکاندا (نیوەڕۆ و عەسر یان لە دوای ئیمام)، هەندێک کەس دەنگی فسکە فسک یان فیکە فیک لە دەمیان دێت کە دەبێتە هۆی بێزارکردن و تێکدانی خشوعی ئەو کەسانەی لە تەنیشتیەوە نوێژ دەکەن.',
          correction:
              'خوێندنەوەی دروست بە تەنها جووڵاندنی زمان و لێوەکان دەبێت بەبێ دەرکردنی دەنگ و فسکە فسک، وەکو پێغەمبەری خوا ﷺ فەرموویەتی: «إِنَّ كُلَّكُمْ يُنَاجِي رَبَّهُ، فَلاَ يُؤْذِيَنَّ بَعْضُكُمْ بَعْضاً» (هەمووتان رازونیاز لەگەڵ پەروەردگارتان دەکەن، با هیچتان یەکتری بێزار نەکات).',
          isDark: isDark,
        ),
        _buildMistakeCard(
          title: '٢. شێوازی هەڵەی دانانی قاچەکان و ناڕێکی ڕیز',
          problem:
              'یان زۆر کردنەوەی قاچەکان بە شێوەیەکی ناپێویست و سەرنجڕاکێش کە دەبێتە هۆی تێکدانی ڕاوەستانی کەسانی تەنیشت، یان بە پێچەوانەوە زۆر نووساندنی قاچەکان بە یەکەوە و بەجێهێشتنی بۆشایی گەورە لە نێوان شانی نوێژخوێناندا.',
          correction:
              'سوننەت ئەوەیە هەر کەسێک قاچەکانی بە ئەندازەی بەرینی شانەکانی خۆی بکاتەوە و پەنجەکانی ڕوو لە قیبلە بن، و ڕیزەکە بە تەریبکردنی پاژنەی پێ و شانەکان پڕ بکرێتەوە بەبێ پاڵنان و زیادەڕەوی.',
          isDark: isDark,
        ),
        _buildMistakeCard(
          title: '٣. پێشکەوتن بەسەر پێشنوێژدا (مسابقة الإمام)',
          problem:
              'چوون بۆ ڕکوع یان سوجدە یان بەرزبوونەوە پێش پێشنوێژ (ئیمام)، یان سەلامدانەوە پێش ئەوەی ئیمام سەلام بداتەوە.',
          correction:
              'ئیمام دانراوە بۆ ئەوەی شوێنی بکەویت، فەرزە لەسەر نوێژخوێن تەنها دوای دەنگی ئیمام کردارەکە ئەنجام بدات نەک پێشتر.',
          isDark: isDark,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMistakeCard({
    required String title,
    required String problem,
    required String correction,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF261D1D) : const Color(0xFFFFF8F8),
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
              const Icon(
                Icons.cancel_rounded,
                color: Color(0xFFE53935),
                size: 18,
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
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:
                  isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.grey.shade200,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('⚠️ ', style: TextStyle(fontSize: 12)),
                    Expanded(
                      child: Text(
                        'هەڵەکە: $problem',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.45,
                          color: isDark
                              ? Colors.grey.shade300
                              : Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 15,
                      color: Color(0xFF43A047),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'دروست و سوننەت: $correction',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.45,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFF81C784)
                              : const Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrerequisiteCard({
    required bool isDark,
    required List<String> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2A22) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: items
            .map((it) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          size: 16, color: Color(0xFF43A047)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          it,
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.45,
                            color: isDark
                                ? Colors.grey.shade300
                                : Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildStepCard({
    required String stepNumber,
    required String title,
    required String arabicText,
    required String explanation,
    required String note,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2A22) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: const Color(0xFF43A047),
                child: Text(
                  stepNumber,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    color: Color(0xFF43A047),
                  ),
                ),
              ),
            ],
          ),
          if (arabicText.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF43A047).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                arabicText,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  height: 1.6,
                ),
                textDirection: TextDirection.rtl,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            explanation,
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
            ),
          ),
          if (note.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline,
                    size: 13, color: Color(0xFFD4AF37)),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    note,
                    style: TextStyle(
                      fontSize: 11,
                      color:
                          isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPrayerRakatCountItem(
    String prayer,
    String rakats,
    String voiceType,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2A22) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              prayer,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF43A047).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              rakats,
              style: const TextStyle(
                color: Color(0xFF43A047),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            voiceType,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
