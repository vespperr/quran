import 'package:flutter/material.dart';

import '../../constants/design_system.dart';
import '../../constants/extensions.dart';
import '../../constants/fonts.dart';

/// Modal bottom sheet presenting the comprehensive guide for:
/// 1. Step-by-step How to Pray (صفة الصلاة / شێوازی نوێژکردن) & Congregational mistakes.
/// 2. The 12 Confirmed Sunnah Prayers (السنن الرواتب), Duha, Witr, and Tahajjud.
/// 3. The Prohibited Times for voluntary prayer (أوقات النهي / کاتەکانی نەهی).
///
/// Fully localized in Kurdish, Arabic, and English.
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
    final lang = Localizations.localeOf(context).languageCode;

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
                    context.translate.worshipGuideTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
              labelPadding: const EdgeInsets.symmetric(horizontal: 4),
              indicator: BoxDecoration(
                color: const Color(0xFF43A047),
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: Colors.white,
              unselectedLabelColor:
                  theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              tabs: [
                Tab(text: context.translate.howToPray),
                Tab(text: context.translate.sunnahPrayers),
                Tab(text: context.translate.prohibitedTimes),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildHowToPrayTab(theme, isDark, lang),
                _buildSunnahTab(theme, isDark, lang),
                _buildProhibitedTab(theme, isDark, lang),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // TAB 1: HOW TO PRAY (صفة الصلاة / شێوازی نوێژکردن)
  // --------------------------------------------------------------------------
  Widget _buildHowToPrayTab(ThemeData theme, bool isDark, String lang) {
    final isAr = lang == 'ar';
    final isEn = lang == 'en';

    final String hadithHeader = isEn
        ? 'Prophetic Hadith'
        : (isAr ? 'حديث نبوي شريف' : 'فەرموودەی پێغەمبەری خوا ﷺ');

    final String hadithSub = isEn
        ? '«Pray as you have seen me praying.» (Sahih al-Bukhari)'
        : (isAr
            ? '«صَلُّوا كَمَا رَأَيْتُمُونِي أُصَلِّي» (صحيح البخاري)'
            : '«نوێژ بکەن بەو شێوازەی کە بینیتان من نوێژم پێکرد.» (صحيح البخاري)');

    final String prereqTitle = isEn
        ? 'Prerequisites Before Beginning Prayer'
        : (isAr
            ? 'شروط صحة الصلاة قبل البدء فيها'
            : 'مەرجەکانی پێش دەستپێکردنی نوێژ');

    final List<String> prereqItems = isEn
        ? const [
            '1. Purification: Wudu (ablution) or Ghusl from major impurity.',
            '2. Purity of body, clothing, and prayer place from impurities.',
            '3. Covering the Awrah (men: navel to knee; women: entire body except face & hands).',
            '4. Ensuring the prescribed prayer time has arrived.',
            '5. Facing the Holy Qiblah (the Kaaba in Makkah).',
            '6. Intention (Niyyah): Located in the heart; uttering it verbally is an unfounded innovation.',
          ]
        : (isAr
            ? const [
                '١. الطهارة: الوضوء من الحدث الأصغر أو الغسل من الجنابة.',
                '٢. طهارة البدن والثياب والمكان من النجاسات.',
                '٣. ستر العورة (للرجل من السرة إلى الركبة، وللمرأة كامل البدن عدا الوجه والكفين).',
                '٤. دخول وقت الصلاة بيقين أو غلبة ظن.',
                '٥. استقبال القبلة المشرفة (الكعبة).',
                '٦. النية: ومحلها القلب، والتلفظ بها بدعة لم تثبت عن النبي ﷺ.',
              ]
            : const [
                '١. پاکوخاوێنی: دەستنوێژگرتن یان خۆشۆردن لە لەشگرانی.',
                '٢. پاکیی لەش و جلوبەرگ و شوێنی نوێژ لە هەموو ناپاکیەک.',
                '٣. داپۆشینی عەورەت (بۆ پیاو لە ناوکەوە تا ئەژنۆ، بۆ ئافرەت هەموو لەش جگە لە دەموچاو و دەستەکان).',
                '٤. دڵنیابوون لە هاتنی کاتی نوێژەکە.',
                '٥. ڕووکردنە قیبلەی پیرۆز (کەعبەی پیرۆز).',
                '٦. نیەت: شوێنەکەی دڵە و بە دەم وتنی نەهاتووە و بیدعەیە.',
              ]);

    final String stepsTitle = isEn
        ? 'Step-by-Step Prayer Method'
        : (isAr ? 'صفة الصلاة خطوة بخطوة' : 'شێوازی نوێژکردن هەنگاو بە هەنگاو');

    final String rakatCountTitle = isEn
        ? 'Number of Rak\'ahs in the 5 Obligatory Prayers'
        : (isAr
            ? 'عدد ركعات الصلوات الخمس المفروضة'
            : 'ژمارەی ڕکاتەکانی ٥ نوێژە فەرزەکە');

    final String mistakesTitle = isEn
        ? 'Common Mistakes in Congregational Prayer'
        : (isAr
            ? 'أخطاء شائعة في صلاة الجماعة'
            : 'هەڵە باوەکانی ناو نوێژی جەماعەت');

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
                  Expanded(
                    child: Text(
                      hadithHeader,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E88E5),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '«صَلُّوا كَمَا رَأَيْتُمُونِي أُصَلِّي»',
                style: TextStyle(
                  fontFamily: Fonts.naskh,
                  fontFamilyFallback: [Fonts.uthmanic],
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  height: 1.8,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 6),
              Text(
                hadithSub,
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
          prereqTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF43A047),
          ),
        ),
        const SizedBox(height: 8),
        _buildPrerequisiteCard(
          isDark: isDark,
          items: prereqItems,
        ),
        const SizedBox(height: 20),

        // Steps Title
        Text(
          stepsTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF43A047),
          ),
        ),
        const SizedBox(height: 10),

        // Steps 1 to 11
        ..._buildPrayerSteps(isDark, lang),
        const SizedBox(height: 16),

        // Rakat count table
        Text(
          rakatCountTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF43A047),
          ),
        ),
        const SizedBox(height: 8),
        ..._buildRakatItems(isDark, lang),
        const SizedBox(height: 20),

        // Common Mistakes in Congregational Prayer
        Text(
          mistakesTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFFE53935),
          ),
        ),
        const SizedBox(height: 8),
        ..._buildMistakeCards(isDark, lang),
        const SizedBox(height: 24),
      ],
    );
  }

  List<Widget> _buildPrayerSteps(bool isDark, String lang) {
    final isAr = lang == 'ar';
    final isEn = lang == 'en';

    if (isEn) {
      return [
        _buildStepCard(
          stepNumber: '1',
          title: 'Takbeerat al-Ihram (Opening Takbeer)',
          arabicText: 'اللَّهُ أَكْبَرُ',
          explanation:
              'Stand upright facing the Qiblah, looking at the place of prostration. Raise both hands level with shoulders or earlobes with fingers pointing toward Qiblah, saying: «Allahu Akbar».',
          note:
              'This Takbeer is an essential pillar (Rukn); the prayer does not begin without it.',
          isDark: isDark,
        ),
        _buildStepCard(
          stepNumber: '2',
          title: 'Placing Hands & Opening Supplication (Istiftah)',
          arabicText:
              '«سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ، وَتَبَارَكَ اسْمُكَ، وَتَعَالَى جَدُّكَ، وَلاَ إِلَهَ غَيْرُكَ»',
          explanation:
              'Place the right hand over the back of the left hand, wrist, and forearm on the chest. Recite this opening supplication silently in the first Rak\'ah.',
          note:
              'A recommended Sunnah in the first Rak\'ah after Takbeerat al-Ihram.',
          isDark: isDark,
        ),
        _buildStepCard(
          stepNumber: '3',
          title: 'Recitation of Surah Al-Fatihah & Surah',
          arabicText:
              'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ... ﴿اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ﴾... «آمِين»',
          explanation:
              'Seek refuge with Allah, recite Basmala silently, then recite Surah Al-Fatihah followed by «Ameen». Then recite an additional portion of the Quran in the first two Rak\'ahs.',
          note:
              'Reciting Al-Fatihah is an essential pillar in every Rak\'ah (Sahih al-Bukhari).',
          isDark: isDark,
        ),
        _buildStepCard(
          stepNumber: '4',
          title: 'Bowing (Ruku\') and Glorifying Allah',
          arabicText: '«سُبْحَانَ رَبِّيَ الْعَظِيمِ» (3 times)',
          explanation:
              'Say «Allahu Akbar» while raising hands, bow with a straight back and grasp knees with fingers spread, maintaining complete tranquility (Tuma\'ninah).',
          note: 'Tranquility in Ruku\' is an obligatory pillar of prayer.',
          isDark: isDark,
        ),
        _buildStepCard(
          stepNumber: '5',
          title: 'Rising from Bowing & Standing Upright',
          arabicText:
              '«سَمِعَ اللَّهُ لِمَنْ حَمِدَهُ» ... «رَبَّنَا وَلَكَ الْحَمْدُ، حَمْداً كَثِيراً طَيِّباً مُبَارَكاً فِيهِ»',
          explanation:
              'Rise from bowing until standing completely straight with every joint at ease, saying «Sami\' Allahu liman hamidah» then «Rabbana wa lakal-hamd».',
          note:
              'Standing fully upright with tranquility is an essential pillar.',
          isDark: isDark,
        ),
        _buildStepCard(
          stepNumber: '6',
          title: 'First Prostration (Sujud) on Seven Limbs',
          arabicText: '«سُبْحَانَ رَبِّيَ الأَعْلَى» (3 times)',
          explanation:
              'Say «Allahu Akbar» and prostrate on 7 limbs: forehead with nose, both palms, both knees, and toes curled pointing toward Qiblah.',
          note: 'The closest a servant is to his Lord is while in prostration.',
          isDark: isDark,
        ),
        _buildStepCard(
          stepNumber: '7',
          title: 'Sitting Between the Two Prostrations',
          arabicText: '«رَبِّ اغْفِرْ لِي، رَبِّ اغْفِرْ لِي، وَارْحَمْنِي»',
          explanation:
              'Say «Allahu Akbar», sit calmly on your left foot with the right foot upright, hands resting on thighs, and ask for forgiveness.',
          note: 'Tranquility in this sitting is an essential pillar.',
          isDark: isDark,
        ),
        _buildStepCard(
          stepNumber: '8',
          title: 'Second Prostration (Sujud)',
          arabicText: '«سُبْحَانَ رَبِّيَ الأَعْلَى» (3 times)',
          explanation:
              'Say «Allahu Akbar» and perform the second prostration exactly like the first. This completes the first Rak\'ah.',
          note:
              'Rise with Takbeer to stand upright and begin the second Rak\'ah.',
          isDark: isDark,
        ),
        _buildStepCard(
          stepNumber: '9',
          title: 'Second Rak\'ah & First Tashahhud',
          arabicText:
              '«التَّحِيَّاتُ لِلَّهِ وَالصَّلَوَاتُ وَالطَّيِّبَاتُ... أَشْهَدُ أَنْ لاَ إِلَهَ إِلاَّ اللَّهُ وَأَشْهَدُ أَنَّ مُحَمَّداً عَبْدُهُ وَرَسُولُهُ»',
          explanation:
              'Perform the second Rak\'ah, then sit for the first Tashahhud in 3- and 4-Rak\'ah prayers, pointing with the index finger.',
          note: 'An obligatory duty (Wajib) compensated by Sajdat al-Sahw.',
          isDark: isDark,
        ),
        _buildStepCard(
          stepNumber: '10',
          title: 'Final Tashahhud & Abrahamic Blessings',
          arabicText:
              '«اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ... اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ عَذَابِ جَهَنَّمَ، وَمِنْ عَذَابِ الْقَبْرِ...»',
          explanation:
              'Sit in the final Rak\'ah with Tawarruk (if 3 or 4 Rak\'ahs), recite the full Tashahhud, send blessings on the Prophet ﷺ, and seek refuge from the four evils.',
          note:
              'The final Tashahhud and sending blessings on the Prophet ﷺ are pillars.',
          isDark: isDark,
        ),
        _buildStepCard(
          stepNumber: '11',
          title: 'Tasleem (Ending the Prayer)',
          arabicText: '«السَّلاَمُ عَلَيْكُمْ وَرَحْمَةُ اللَّهِ»',
          explanation:
              'Turn your head to the right saying «As-salamu alaykum wa rahmatullah», then to the left likewise.',
          note:
              'The first Tasleem is the concluding pillar that exits the prayer.',
          isDark: isDark,
        ),
      ];
    }

    if (isAr) {
      return [
        _buildStepCard(
          stepNumber: '١',
          title: 'تكبيرة الإحرام',
          arabicText: 'اللَّهُ أَكْبَرُ',
          explanation:
              'القيام معتدلاً والنظر إلى موضع السجود، ورفع اليدين حذو المنكبين أو فروع الأذنين مبسوطتي الأصابع مستقبلاً بهما القبلة، قائلاً: «اللَّهُ أَكْبَرُ».',
          note: 'هذه التكبيرة ركن لا تصح الصلاة إلا بها.',
          isDark: isDark,
        ),
        _buildStepCard(
          stepNumber: '٢',
          title: 'وضع اليدين ودعاء الاستفتاح',
          arabicText:
              '«سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ، وَتَبَارَكَ اسْمُكَ، وَتَعَالَى جَدُّكَ، وَلاَ إِلَهَ غَيْرُكَ»',
          explanation:
              'وضع اليد اليمنى على ظهر كف اليسرى والرسغ والساعد على الصدر، وقراءة دعاء الاستفتاح سراً في الركعة الأولى.',
          note: 'سنة مستحبة في الركعة الأولى بعد تكبيرة الإحرام.',
          isDark: isDark,
        ),
        _buildStepCard(
          stepNumber: '٣',
          title: 'قراءة سورة الفاتحة وما تيسر من القرآن',
          arabicText:
              'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ... ﴿اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ﴾... «آمِين»',
          explanation:
              'الاستعاذة بالله والبسملة سراً، ثم قراءة الفاتحة وهي ركن في كل ركعة، والتأمين بعدها، ثم قراءة ما تيسر من القرآن في الركعتين الأوليين.',
          note:
              'قراءة الفاتحة ركن أساسي، لقوله ﷺ: «لا صلاة لمن لم يقرأ بفاتحة الكتاب».',
          isDark: isDark,
        ),
        _buildStepCard(
          stepNumber: '٤',
          title: 'الركوع وتعظيم الرب',
          arabicText: '«سُبْحَانَ رَبِّيَ الْعَظِيمِ» (٣ مرات)',
          explanation:
              'التكبير مع رفع اليدين والركوع حتى يستوي الظهر مستوياً وتلقم اليدان الركبتين مفرجتي الأصابع، مع الطمأنينة التامة.',
          note: 'الطمأنينة في الركوع ركن لا تسقط أبداً.',
          isDark: isDark,
        ),
        _buildStepCard(
          stepNumber: '٥',
          title: 'الرفع من الركوع والاعتدال',
          arabicText:
              '«سَمِعَ اللَّهُ لِمَنْ حَمِدَهُ» ثم «رَبَّنَا وَلَكَ الْحَمْدُ، حَمْداً كَثِيراً طَيِّباً مُبَارَكاً فِيهِ»',
          explanation:
              'الرفع من الركوع حتى يستوي الظهر قائماً وتطمئن المفاصل، قائلاً الإمام والمنفرد «سمع الله لمن حمده»، والمأموم «ربنا ولك الحمد».',
          note: 'الاعتدال والطمأنينة فيه ركن أساسي.',
          isDark: isDark,
        ),
        _buildStepCard(
          stepNumber: '٦',
          title: 'السجود الأول على الأعضاء السبعة',
          arabicText: '«سُبْحَانَ رَبِّيَ الأَعْلَى» (٣ مرات)',
          explanation:
              'الهوي للسجود مكبراً والسجود على ٧ أعضاء: الجبهة مع الأنف، والكفين، والركبتين، وأطراف أصابع القدمين متجهة للقبلة.',
          note: 'أقرب ما يكون العبد من ربه وهو ساجد.',
          isDark: isDark,
        ),
        _buildStepCard(
          stepNumber: '٧',
          title: 'الجلوس بين السجدتين',
          arabicText:
              '«رَبِّ اغْفِرْ لِي، رَبِّ اغْفِرْ لِي، وَارْحَمْنِي، وَاجْبُرْنِي»',
          explanation:
              'الرفع من السجود مكبراً والجلوس مفترشاً رجله اليسرى وناصباً اليمنى، مع وضع اليدين على الفخذين والطمأنينة التامة.',
          note: 'الطمأنينة في هذا الجلوس ركن واجب.',
          isDark: isDark,
        ),
        _buildStepCard(
          stepNumber: '٨',
          title: 'السجود الثاني',
          arabicText: '«سُبْحَانَ رَبِّيَ الأَعْلَى» (٣ مرات)',
          explanation:
              'التكبير والسجود مرة ثانية كالأولى تماماً بالطمأنينة والدعاء.',
          note:
              'بانتهاء السجدة الثانية تكتمل الركعة الأولى، ثم ينهض مكبراً للركعة الثانية.',
          isDark: isDark,
        ),
        _buildStepCard(
          stepNumber: '٩',
          title: 'الركعة الثانية والتشهد الأول',
          arabicText:
              '«التَّحِيَّاتُ لِلَّهِ وَالصَّلَوَاتُ وَالطَّيِّبَاتُ... أَشْهَدُ أَنْ لاَ إِلَهَ إِلاَّ اللَّهُ وَأَشْهَدُ أَنَّ مُحَمَّداً عَبْدُهُ وَرَسُولُهُ»',
          explanation:
              'أداء الركعة الثانية كالأولى، ثم الجلوس للتشهد الأول مع الإشارة بالسبابة في الصلاة الثلاثية والرباعية.',
          note: 'واجب يُجبر بسجود السهو إذا نُسي.',
          isDark: isDark,
        ),
        _buildStepCard(
          stepNumber: '١٠',
          title: 'التشهد الأخير والصلاة الإبراهيمية',
          arabicText:
              '«اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ... اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ عَذَابِ جَهَنَّمَ، وَمِنْ عَذَابِ الْقَبْرِ...»',
          explanation:
              'الجلوس في الركعة الأخيرة متوركاً وقراءة التشهد كاملاً مع الصلاة الإبراهيمية والتعوذ من أربع.',
          note: 'التشهد الأخير والصلاة على النبي ﷺ ركن في الصلاة.',
          isDark: isDark,
        ),
        _buildStepCard(
          stepNumber: '١١',
          title: 'التسليم وإنهاء الصلاة',
          arabicText: '«السَّلاَمُ عَلَيْكُمْ وَرَحْمَةُ اللَّهِ»',
          explanation:
              'الالتفات إلى اليمين حتى يُرى بياض الخد قائلاً «السلام عليكم ورحمة الله»، ثم إلى اليسار كذلك.',
          note: 'التسليمة الأولى ركن يخرج به المصلي من الصلاة.',
          isDark: isDark,
        ),
      ];
    }

    // Default: Kurdish
    return [
      _buildStepCard(
        stepNumber: '١',
        title: 'تەكبیرەی ئیحرام (دەستپێکردن)',
        arabicText: 'اللَّهُ أَكْبَرُ',
        explanation:
            'ڕاوەستان بە ڕێکی و سەیرکردنی جێگای سوجدە. هەردوو دەست تا ئاستی شانەکان یان نەرمەی گوێچکەکان بەرز دەکرێنەوە بە شێوەیەک پەنجەکان لێک کراوە نەبن و ڕوو لە قیبلە بن، لەگەڵ وتنی «اللَّهُ أَكْبَرُ».',
        note: 'ئەم تەكبیرەیە فەرزە (ڕوکنە) و بەبێ ئەمە نوێژ دانامەزرێت.',
        isDark: isDark,
      ),
      _buildStepCard(
        stepNumber: '٢',
        title: 'دانانی دەستەکان و دەعای دەستپێکردن (الاستفتاح)',
        arabicText:
            '«سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ، وَتَبَارَكَ اسْمُكَ، وَتَعَالَى جَدُّكَ، وَلاَ إِلَهَ غَيْرُكَ»',
        explanation:
            'دەستی ڕاست لەسەر پشتی دەستی چەپ و مەچەک لەسەر سنگ دادەنرێت. پاشان ئەم دوعایە بە بێدەنگی لە دڵ یان بە چرپە لە ڕکاتی یەکەمدا دەخوێندرێت.',
        note: 'سوننەتە لە ڕکاتی یەکەمدا لە دوای تەكبیرەی ئیحرام بخوێندرێت.',
        isDark: isDark,
      ),
      _buildStepCard(
        stepNumber: '٣',
        title: 'خوێندنی سورەتی الفاتحة و سورەتێکی تر',
        arabicText:
            'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ... ﴿اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ﴾... «آمِين»',
        explanation:
            'پەناگرتن بە خوا (الاستعاذة) و وتنی (بسم الله)، پاشان خوێندنی سورەتی فاتیحە بە تەواوی کە ڕوکنە لە هەموو ڕکاتێکدا، و وتنی (ئامین). پاشان خوێندنی چەند ئایەتێک یان سورەتێکی تر لە هەردوو ڕکاتی یەکەم و دووەمدا.',
        note:
            'خوێندنی فاتیحە ڕوکنە، پێغەمبەر ﷺ فەرموویەتی: «هیچ نوێژێک نییە بۆ کەسێک فاتیحە نەخوێنێت».',
        isDark: isDark,
      ),
      _buildStepCard(
        stepNumber: '٤',
        title: 'ڕکوع بردن و بەگەورەگرتنی پەروەردگار',
        arabicText: '«سُبْحَانَ رَبِّيَ الْعَظِيمِ» (٣ جار)',
        explanation:
            'وتنی (الله أكبر) لەگەڵ بەرزکردنەوەی دەستەکان، پاشان چەمانەوە بە شێوەیەک پشت تەخت بێت و هەردوو دەست لەسەر ئەژنۆکان جێگیر بکرێن و پەنجەکان لێک کراوە بن، لەگەڵ هێمنی (الطمأنينة).',
        note: 'هێمنی و جێگیربوون لە ڕکوعدا یەکێکە لە فەرزە سەرەکییەکان.',
        isDark: isDark,
      ),
      _buildStepCard(
        stepNumber: '٥',
        title: 'هەستانەوە لە ڕکوع و ڕێکوەستان',
        arabicText:
            '«سَمِعَ اللَّهُ لِمَنْ حَمِدَهُ» پاشان «رَبَّنَا وَلَكَ الْحَمْدُ، حَمْداً كَثِيراً طَيِّباً مُبَارَكاً فِيهِ»',
        explanation:
            'بەرزبوونەوە لە ڕکوع هەتا پشت بە تەواوی ڕێک دەبێتەوە، پێشنوێژ و تەنیا دەڵێن: (سمع الله لمن حمده)، و لە دوای ئیمام دەوترێت: (ربنا ولك الحمد).',
        note: 'ڕێکوەستان و ئارامگرتن هەتا هەموو جومگەکان جێگیر دەبن فەرزە.',
        isDark: isDark,
      ),
      _buildStepCard(
        stepNumber: '٦',
        title: 'سوجدەی یەکەم لەسەر ٧ ئەندام',
        arabicText: '«سُبْحَانَ رَبِّيَ الأَعْلَى» (٣ جار)',
        explanation:
            'ڕۆشتن بۆ سوجدە بە وتنی (الله أكبر) بەبێ بەرزکردنەوەی دەست. دەبێت ٧ ئەندام لەسەر زەوی بن: (تەوێڵ لەگەڵ لوت، هەردوو لەپی دەست، هەردوو ئەژنۆ، و سەرپەنجەکانی هەردوو پێ بە ڕووی قیبلە).',
        note:
            'نزیکترین کات کە بەندە لە پەروەردگاریەوە نزیک بێت لە کاتی سوجدەدایە.',
        isDark: isDark,
      ),
      _buildStepCard(
        stepNumber: '٧',
        title: 'دانیشتنی نێوان دوو سوجدەکە',
        arabicText:
            '«رَبِّ اغْفِرْ لِي، رَبِّ اغْفِرْ لِي، وَارْحَمْنِي، وَاجْبُرْنِي، وَارْزُقْنِي، وَاهْدِنِي»',
        explanation:
            'هەستانەوە لە سوجدە بە وتنی (الله أكبر) و دانیشتن لەسەر پێی چەپ و ڕاگرتنی پێی ڕاست، لەگەڵ دانانی دەستەکان لەسەر ڕانەکان و هێمنی تەواو.',
        note:
            'هێمنی لەم دانیشتنەدا فەرزە و پەلەکردن تێیدا نوێژ بەتاڵ دەکاتەوە.',
        isDark: isDark,
      ),
      _buildStepCard(
        stepNumber: '٨',
        title: 'سوجدەی دووەم',
        arabicText: '«سُبْحَانَ رَبِّيَ الأَعْلَى» (٣ جار)',
        explanation:
            'وتنی (الله أكبر) و ڕۆشتنەوە بۆ سوجدەی دووەم بە هەمان شێوازی سوجدەی یەکەم بە هێمنی و دوعاکردنەوە. بەمەش ڕکاتی یەکەم کۆتایی دێت.',
        note:
            'پاش ئەم سوجدەیە بە وتنی (الله أكبر) هەڵدەستێتەوە بۆ ڕکاتی دووەم.',
        isDark: isDark,
      ),
      _buildStepCard(
        stepNumber: '٩',
        title: 'ڕکاتی دووەم و تەحیاتی یەکەم (التشهد الأول)',
        arabicText:
            '«التَّحِيَّاتُ لِلَّهِ وَالصَّلَوَاتُ وَالطَّيِّبَاتُ، السَّلاَمُ عَلَيْكَ أَيُّهَا النَّبِيُّ وَرَحْمَةُ اللَّهِ وَبَرَكَاتُهُ، السَّلاَمُ عَلَيْنَا وَعَلَى عِبَادِ اللَّهِ الصَّالِحِينَ، أَشْهَدُ أَنْ لاَ إِلَهَ إِلاَّ اللَّهُ وَأَشْهَدُ أَنَّ مُحَمَّداً عَبْدُهُ وَرَسُولُهُ»',
        explanation:
            'ڕکاتی دووەم هاوشێوەی ڕکاتی یەکەم ئەنجام دەدرێت. پاش سوجدەی دووەم دادەنیشێت بۆ تەحیاتی یەکەم لە نوێژە ٣ و ٤ ڕکاتییەکاندا، لەگەڵ ئاماژەکردن بە پەنجەی شایەتمان.',
        note:
            'ئەم تەحیاتە واجبە و لە کاتی لەبیرچووندا بە سوجدەی سەهو قەرەبوو دەکرێتەوە.',
        isDark: isDark,
      ),
      _buildStepCard(
        stepNumber: '١٠',
        title: 'تەحیاتی کۆتایی و سڵاوات (التشهد الأخير والصلاة الإبراهيمية)',
        arabicText:
            '«اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ... اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ عَذَابِ جَهَنَّمَ، وَمِنْ عَذَابِ الْقَبْرِ، وَمِنْ فِتْنَةِ الْمَحْيَا وَالْمَمَاتِ، وَمِنْ شَرِّ فِتْنَةِ الْمَسِيحِ الدَّجَّالِ»',
        explanation:
            'لە ڕکاتی کۆتاییدا دادەنیشێت و تەحیات بە تەواوی لەگەڵ سڵاواتی ئیبراهیمی دەخوێنێت و پەنا دەگرێت بە خوا لە چوار شت.',
        note: 'تەحیاتی کۆتایی و سڵاواتدان لەسەر پێغەمبەر ﷺ فەرزە لە نوێژدا.',
        isDark: isDark,
      ),
      _buildStepCard(
        stepNumber: '١١',
        title: 'سەلامدانەوە و کۆتاییهێنان بە نوێژ (التسليم)',
        arabicText:
            '«السَّلاَمُ عَلَيْكُمْ وَرَحْمَةُ اللَّهِ» (دەستە ڕاست و دەستە چەپ)',
        explanation:
            'سەلامدانەوە بۆ لای ڕاست بە شێوەیەک سپیایی گۆنا ببینرێت قائلاً: (السلام عليكم ورحمة الله)، پاشان بۆ لای چەپیش بە هەمان شێوە.',
        note: 'سەلامی یەکەم فەرزە (ڕوکنە) و نوێژی پێ تەواو دەبێت.',
        isDark: isDark,
      ),
    ];
  }

  List<Widget> _buildRakatItems(bool isDark, String lang) {
    final isAr = lang == 'ar';
    final isEn = lang == 'en';

    if (isEn) {
      return [
        _buildPrayerRakatCountItem(
            'Fajr Prayer', '2 Rak\'ahs', 'Aloud', isDark),
        _buildPrayerRakatCountItem(
            'Dhuhr Prayer', '4 Rak\'ahs', 'Silent', isDark),
        _buildPrayerRakatCountItem(
            'Asr Prayer', '4 Rak\'ahs', 'Silent', isDark),
        _buildPrayerRakatCountItem(
            'Maghrib Prayer', '3 Rak\'ahs', '2 Aloud + 1 Silent', isDark),
        _buildPrayerRakatCountItem(
            'Isha Prayer', '4 Rak\'ahs', '2 Aloud + 2 Silent', isDark),
      ];
    }

    if (isAr) {
      return [
        _buildPrayerRakatCountItem('صلاة الفجر', 'ركعتان', 'جهراً', isDark),
        _buildPrayerRakatCountItem('صلاة الظهر', '٤ ركعات', 'سراً', isDark),
        _buildPrayerRakatCountItem('صلاة العصر', '٤ ركعات', 'سراً', isDark),
        _buildPrayerRakatCountItem(
            'صلاة المغرب', '٣ ركعات', '٢ جهراً + ١ سراً', isDark),
        _buildPrayerRakatCountItem(
            'صلاة العشاء', '٤ ركعات', '٢ جهراً + ٢ سراً', isDark),
      ];
    }

    return [
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
    ];
  }

  List<Widget> _buildMistakeCards(bool isDark, String lang) {
    final isAr = lang == 'ar';
    final isEn = lang == 'en';

    if (isEn) {
      return [
        _buildMistakeCard(
          title: '1. Whispering and making noise during silent prayers',
          problem:
              'In silent prayers (Dhuhr, Asr, or behind the Imam), some worshippers whisper or make whistling sounds with their lips, disturbing those next to them.',
          correction:
              'Silent recitation is done by moving the tongue and lips without vocalizing, as the Prophet ﷺ said: «Each of you is conversing with his Lord, so do not harm or disturb one another».',
          isDark: isDark,
          lang: lang,
        ),
        _buildMistakeCard(
          title: '2. Improper foot spacing and gaps between worshippers',
          problem:
              'Either spreading legs excessively wide causing discomfort to neighbors, or keeping feet glued tightly together leaving wide gaps between shoulders where Satan enters.',
          correction:
              'The Sunnah is to keep feet shoulder-width apart pointing towards Qiblah, aligning shoulders and heels straight without pushing.',
          isDark: isDark,
          lang: lang,
        ),
        _buildMistakeCard(
          title: '3. Preceding the Imam (Musabaqat al-Imam)',
          problem:
              'Bowing, prostrating, rising, or saying Salam before the Imam does.',
          correction:
              'The Imam is appointed to be followed. Follow each movement only after the Imam finishes saying Takbeer, not before or simultaneously.',
          isDark: isDark,
          lang: lang,
        ),
      ];
    }

    if (isAr) {
      return [
        _buildMistakeCard(
          title: '١. الهمس والتشويش في القراءة السرية',
          problem:
              'في الصلوات السرية (كالظهر والعصر وخلف الإمام)، يُصدر بعض المصلين فحيحاً أو صوتاً مسموعاً أثناء القراءة يشوش على من بجواره ويفقدهم الخشوع.',
          correction:
              'القراءة السرية الصحيحة تكون بتحريك اللسان والشفتين فقط دون إخراج صوت، لقول النبي ﷺ: «إِنَّ كُلَّكُمْ يُنَاجِي رَبَّهُ، فَلاَ يُؤْذِيَنَّ بَعْضُكُمْ بَعْضاً».',
          isDark: isDark,
          lang: lang,
        ),
        _buildMistakeCard(
          title: '٢. الخلل في تسوية الصفوف ومواضع الأقدام',
          problem:
              'المباعدة المفرطة بين القدمين مما يضيق على الجيران، أو العكس بضم القدمين بشدة وترك فُرج واسعة بين المناكب تفتح للشيطان مدخلاً.',
          correction:
              'السنة أن يفتح المصلي قدميه بقدر عرض منكبيه موجهتين للقبلة، وتسوية الصف بمحاذاة المناكب والأعقاب دون مدافعة ولا إفراط.',
          isDark: isDark,
          lang: lang,
        ),
        _buildMistakeCard(
          title: '٣. مسابقة الإمام في الركوع والسجود',
          problem: 'الركوع أو السجود أو الرفع أو السلام قبل الإمام أو مقارنته.',
          correction:
              'إنما جُعل الإمام ليؤتم به، فيجب متابعته بعد انقطاع صوته بالتكبير لا قبله ولا معه، لقوله ﷺ: «إِذَا رَكَعَ فَارْكَعُوا، وَإِذَا سَجَدَ فَاسْجُدُوا».',
          isDark: isDark,
          lang: lang,
        ),
      ];
    }

    return [
      _buildMistakeCard(
        title: '١. دەنگ دەرکردن و فسکە فسک لە خوێندنەوەدا',
        problem:
            'لە نوێژە نهێنییەکاندا (نیوەڕۆ و عەسر یان لە دوای ئیمام)، هەندێک کەس دەنگی فسکە فسک یان فیکە فیک لە دەمیان دێت کە دەبێتە هۆی بێزارکردن و تێکدانی خشوعی ئەو کەسانەی لە تەنیشتیەوە نوێژ دەکەن.',
        correction:
            'خوێندنەوەی دروست بە تەنها جووڵاندنی زمان و لێوەکان دەبێت بەبێ دەرکردنی دەنگ و فسکە فسک، وەکو پێغەمبەری خوا ﷺ فەرموویەتی: «إِنَّ كُلَّكُمْ يُنَاجِي رَبَّهُ، فَلاَ يُؤْذِيَنَّ بَعْضُكُمْ بَعْضاً» (هەمووتان رازونیاز لەگەڵ پەروەردگارتان دەکەن، با هیچتان یەکتری بێزار نەکات).',
        isDark: isDark,
        lang: lang,
      ),
      _buildMistakeCard(
        title: '٢. شێوازی هەڵەی دانانی قاچەکان و ناڕێکی ڕیز',
        problem:
            'یان زۆر کردنەوەی قاچەکان بە شێوەیەکی ناپێویست و سەرنجڕاکێش کە دەبێتە هۆی تێکدانی ڕاوەستانی کەسانی تەنیشت، یان بە پێچەوانەوە زۆر نووساندنی قاچەکان بە یەکەوە و بەجێهێشتنی بۆشایی گەورە لە نێوان شانی نوێژخوێناندا.',
        correction:
            'سوننەت ئەوەیە هەر کەسێک قاچەکانی بە ئەندازەی بەرینی شانەکانی خۆی بکاتەوە و پەنجەکانی ڕوو لە قیبلە بن، و ڕیزەکە بە تەریبکردنی پاژنەی پێ و شانەکان پڕ بکرێتەوە بەبێ پاڵنان و زیادەڕەوی.',
        isDark: isDark,
        lang: lang,
      ),
      _buildMistakeCard(
        title: '٣. پێشکەوتن بەسەر پێشنوێژدا (مسابقة الإمام)',
        problem:
            'چوون بۆ ڕکوع یان سوجدە یان بەرزبوونەوە پێش پێشنوێژ (ئیمام)، یان سەلامدانەوە پێش ئەوەی ئیمام سەلام بداتەوە.',
        correction:
            'ئیمام دانراوە بۆ ئەوەی شوێنی بکەویت، فەرزە لەسەر نوێژخوێن تەنها دوای دەنگی ئیمام کردارەکە ئەنجام بدات نەک پێشتر.',
        isDark: isDark,
        lang: lang,
      ),
    ];
  }

  // --------------------------------------------------------------------------
  // TAB 2: SUNNAH PRAYERS (السنن والنوافل / نوێژە سوننەتەکان)
  // --------------------------------------------------------------------------
  Widget _buildSunnahTab(ThemeData theme, bool isDark, String lang) {
    final isAr = lang == 'ar';
    final isEn = lang == 'en';

    final String hadithHeader = isEn
        ? 'Virtue of Sunnah Prayers'
        : (isAr ? 'فضل السنن الرواتب' : 'فەزڵی نوێژە سوننەتەکان');

    final String hadithSub = isEn
        ? '«Whoever prays twelve Rak\'ahs in a day and night, a house will be built for him in Paradise.» (Sahih Muslim)'
        : (isAr
            ? '«من صلى في يوم وليلة ثنتي عشرة ركعة بُني له بيت في الجنة: أربعاً قبل الظهر، وركعتين بعدها، وركعتين بعد المغرب، وركعتين بعد العشاء، وركعتين قبل صلاة الغداة.» (رواه مسلم)'
            : '«هەرکەسێک لە شەو و ڕۆژێکدا دوازدە ڕکعەت نوێژی سوننەت بکات، خوای گەورە ماڵێکی لە بەهەشتدا بۆ دروست دەکات.» (صحيح مسلم)');

    final String rawatibTitle = isEn
        ? '1. Confirmed Sunnah Prayers (12 Daily Rak\'ahs)'
        : (isAr
            ? '١. السنن الرواتب المؤكدة (١٢ ركعة في اليوم والليلة)'
            : '١. سوننەتە موئەکەدەکان (١٢ ڕکعەتی ڕۆژانە)');

    final String otherSunnahTitle = isEn
        ? '2. Other Highly Recommended Sunnahs'
        : (isAr ? '٢. سنن ونوافل أخرى عظيمة' : '٢. نوێژە سوننەتە گرنگەکانی تر');

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
                  Expanded(
                    child: Text(
                      hadithHeader,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF43A047),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '«مَنْ صَلَّى فِي يَوْمٍ وَلَيْلَةٍ ثِنْتَيْ عَشْرَةَ رَكْعَةً بُنِيَ لَهُ بَيْتٌ فِي الْجَنَّةِ»',
                style: TextStyle(
                  fontFamily: Fonts.naskh,
                  fontFamilyFallback: [Fonts.uthmanic],
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  height: 1.8,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 6),
              Text(
                hadithSub,
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
          rawatibTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF43A047),
          ),
        ),
        const SizedBox(height: 8),
        ..._buildRawatibItems(isDark, lang),
        const SizedBox(height: 20),

        // Other Sunnahs
        Text(
          otherSunnahTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFFD4AF37),
          ),
        ),
        const SizedBox(height: 10),
        ..._buildOtherSunnahCards(isDark, lang),
        const SizedBox(height: 24),
      ],
    );
  }

  List<Widget> _buildRawatibItems(bool isDark, String lang) {
    final isAr = lang == 'ar';
    final isEn = lang == 'en';

    if (isEn) {
      return [
        _buildPrayerSunnahItem(
          prayer: 'Fajr Prayer (Al-Fajr)',
          before: '2 Rak\'ahs before obligatory prayer',
          after: '—',
          note:
              'Most emphasized Sunnah; recommended to recite Al-Kafirun and Al-Ikhlas.',
          isDark: isDark,
          lang: lang,
        ),
        _buildPrayerSunnahItem(
          prayer: 'Dhuhr Prayer (Al-Dhuhr)',
          before: '4 Rak\'ahs before (in pairs of 2)',
          after: '2 Rak\'ahs after obligatory prayer',
          note: 'Recommended to pray 2 more after Dhuhr to make it 4 Rak\'ahs.',
          isDark: isDark,
          lang: lang,
        ),
        _buildPrayerSunnahItem(
          prayer: 'Asr Prayer (Al-Asr)',
          before: '4 Rak\'ahs (Non-confirmed Sunnah)',
          after: '— (Prohibited time after Asr)',
          note:
              'Prophet ﷺ said: «May Allah have mercy on a person who prays four Rak\'ahs before Asr».',
          isDark: isDark,
          lang: lang,
        ),
        _buildPrayerSunnahItem(
          prayer: 'Maghrib Prayer (Al-Maghrib)',
          before: '—',
          after: '2 Rak\'ahs after obligatory prayer',
          note: 'Performed immediately after the obligatory Maghrib prayer.',
          isDark: isDark,
          lang: lang,
        ),
        _buildPrayerSunnahItem(
          prayer: 'Isha Prayer (Al-Isha)',
          before: '—',
          after: '2 Rak\'ahs after obligatory prayer',
          note: 'Followed by the Witr prayer.',
          isDark: isDark,
          lang: lang,
        ),
      ];
    }

    if (isAr) {
      return [
        _buildPrayerSunnahItem(
          prayer: 'صلاة الفجر',
          before: 'ركعتان قبل الفريضة',
          after: '—',
          note: 'آكد السنن الرواتب، يُسن فيها قراءة سورتي الكافرون والإخلاص.',
          isDark: isDark,
          lang: lang,
        ),
        _buildPrayerSunnahItem(
          prayer: 'صلاة الظهر',
          before: '٤ ركعات قبل الفريضة (مثنى مثنى)',
          after: 'ركعتان بعد الفريضة',
          note: 'يستحب أيضاً زيادة ركعتين بعد الظهر ليصبح المجموع ٤ ركعات.',
          isDark: isDark,
          lang: lang,
        ),
        _buildPrayerSunnahItem(
          prayer: 'صلاة العصر',
          before: '٤ ركعات (سنة غير مؤكدة)',
          after: '— (وقت نهي بعد الفريضة)',
          note: 'قال ﷺ: «رحم الله امرأً صلى قبل العصر أربعاً».',
          isDark: isDark,
          lang: lang,
        ),
        _buildPrayerSunnahItem(
          prayer: 'صلاة المغرب',
          before: '—',
          after: 'ركعتان بعد الفريضة',
          note: 'تُصلى بعد صلاة المغرب مباشرة.',
          isDark: isDark,
          lang: lang,
        ),
        _buildPrayerSunnahItem(
          prayer: 'صلاة العشاء',
          before: '—',
          after: 'ركعتان بعد الفريضة',
          note: 'يُسن بعدها صلاة الوتر.',
          isDark: isDark,
          lang: lang,
        ),
      ];
    }

    return [
      _buildPrayerSunnahItem(
        prayer: 'نوێژی بەیانی (الفجر)',
        before: '٢ ڕکعەتی پێش فەرز',
        after: '—',
        note:
            'گرنگترین سوننەتە، سوننەتە سورەتی (الكافرون و الإخلاص) تێیدا بخوێندرێت.',
        isDark: isDark,
        lang: lang,
      ),
      _buildPrayerSunnahItem(
        prayer: 'نوێژی نیوەڕۆ (الظهر)',
        before: '٤ ڕکعەتی پێش فەرز (دوو بە دوو)',
        after: '٢ ڕکعەتی پاش فەرز',
        note:
            'دەتوانرێت ٢ ڕکعەتی تریش پاش نیوەڕۆ زیاد بکرێت بۆ تەواوکردنی ٤ ڕکعەت.',
        isDark: isDark,
        lang: lang,
      ),
      _buildPrayerSunnahItem(
        prayer: 'نوێژی عەسر (العصر)',
        before: '٤ ڕکعەت (سوننەتی غەیرە موئەکەدە)',
        after: '— (کاتی نەهیە پاش فەرز)',
        note: '«ڕەحمەتی خوای لێبێت کەسێک پێش عەسر چوار ڕکعەت نوێژ بکات».',
        isDark: isDark,
        lang: lang,
      ),
      _buildPrayerSunnahItem(
        prayer: 'نوێژی ئێوارە (المغرب)',
        before: '—',
        after: '٢ ڕکعەتی پاش فەرز',
        note: 'پاش فەرز بە خێرایی ئەنجام دەدرێت.',
        isDark: isDark,
        lang: lang,
      ),
      _buildPrayerSunnahItem(
        prayer: 'نوێژی عیشا (العشاء)',
        before: '—',
        after: '٢ ڕکعەتی پاش فەرز',
        note: 'پاش ئەم ٢ ڕکعەتە نوێژی ویتر دەکرێت.',
        isDark: isDark,
        lang: lang,
      ),
    ];
  }

  List<Widget> _buildOtherSunnahCards(bool isDark, String lang) {
    final isAr = lang == 'ar';
    final isEn = lang == 'en';

    if (isEn) {
      return [
        _buildCardItem(
          title: 'Duha Prayer (Salat al-Duha)',
          content:
              '• Time: From ~15-20 min after sunrise until ~15 min before Dhuhr adhan.\n• Rak\'ahs: Minimum 2 Rak\'ahs, up to 4 or 8 Rak\'ahs.\n• Virtue: Counts as charity for all 360 joints of the human body.',
          icon: Icons.wb_sunny_outlined,
          iconColor: const Color(0xFFD4AF37),
          isDark: isDark,
        ),
        const SizedBox(height: 10),
        _buildCardItem(
          title: 'Witr Prayer (Salat al-Witr)',
          content:
              '• Time: From after Isha prayer until the Fajr adhan.\n• Rak\'ahs: Odd number (1, 3, or 5 Rak\'ahs).\n• Recommended to recite Du\'a al-Qunut in the final Rak\'ah.',
          icon: Icons.nightlight_round,
          iconColor: const Color(0xFF673AB7),
          isDark: isDark,
        ),
        const SizedBox(height: 10),
        _buildCardItem(
          title: 'Night Prayer (Tahajjud / Qiyam al-Layl)',
          content:
              '• Time: Throughout the night, especially in the last third before Fajr.\n• Rak\'ahs: In pairs of 2 Rak\'ahs, concluded with Witr.',
          icon: Icons.bedtime_outlined,
          iconColor: const Color(0xFF2E7D32),
          isDark: isDark,
        ),
      ];
    }

    if (isAr) {
      return [
        _buildCardItem(
          title: 'صلاة الضحى',
          content:
              '• وقتها: من بعد شروق الشمس بـ ١٥-٢٠ دقيقة إلى قبل أذان الظهر بـ ١٥ دقيقة.\n• ركعاتها: أقلها ركعتان، وتصلى ٤ أو ٨ ركعات.\n• فضلها: تجزئ عن صدقة ٣٦٠ مفصلاً في جسد الإنسان.',
          icon: Icons.wb_sunny_outlined,
          iconColor: const Color(0xFFD4AF37),
          isDark: isDark,
        ),
        const SizedBox(height: 10),
        _buildCardItem(
          title: 'صلاة الوتر',
          content:
              '• وقتها: من بعد صلاة العشاء إلى طلوع الفجر.\n• ركعاتها: وتر (ركعة، أو ثلاث ركعات، أو خمس).\n• يُستحب القنوت والدعاء في الركعة الأخيرة منها.',
          icon: Icons.nightlight_round,
          iconColor: const Color(0xFF673AB7),
          isDark: isDark,
        ),
        const SizedBox(height: 10),
        _buildCardItem(
          title: 'قيام الليل والتهجد',
          content:
              '• وقتها: جوف الليل كله، وأفضلها الثلث الأخير من الليل قبل الفجر.\n• ركعاتها: مثنى مثنى، وتُختم بصلاة الوتر.',
          icon: Icons.bedtime_outlined,
          iconColor: const Color(0xFF2E7D32),
          isDark: isDark,
        ),
      ];
    }

    return [
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
    ];
  }

  // --------------------------------------------------------------------------
  // TAB 3: PROHIBITED TIMES (أوقات النهي / کاتەکانی نەهی)
  // --------------------------------------------------------------------------
  Widget _buildProhibitedTab(ThemeData theme, bool isDark, String lang) {
    final isAr = lang == 'ar';
    final isEn = lang == 'en';

    final String bannerTitle = isEn
        ? 'Prohibited Times for Voluntary Prayers'
        : (isAr
            ? 'أوقات النهي عن صلاة النوافل'
            : 'کاتەکانی نەهی (قەدەغەکراوی نوێژ)');

    final String bannerDesc = isEn
        ? 'The Prophet ﷺ strictly prohibited voluntary non-cause prayers during 3 specific times:'
        : (isAr
            ? 'نهى رسول الله ﷺ عن صلاة النوافل المطلقة في ثلاثة أوقات:'
            : 'پێغەمبەری خوا ﷺ بەتوندی نەهی فەرمووە لە ئەنجامدانی نوێژی سوننەتی ڕەها (نەفلی بێ هۆکار) لە ٣ کاتی سەرەکیدا:');

    final String noteTitle = isEn
        ? 'Important Fiqh Note (Permissible Prayers):'
        : (isAr
            ? 'تنبيه فقهي هام (الصلوات المستثناة):'
            : 'تێبینی گرنگی فیقهی (نوێژە ڕێگەپێدراوەکان):');

    final String noteBody = isEn
        ? 'Prayers with a specific reason (such as missed obligatory prayers, funeral prayer, eclipse prayer, and Tahiyyat al-Masjid) are permissible during these times; the prohibition applies only to general voluntary prayers without a specific cause.'
        : (isAr
            ? 'الصلوات ذوات الأسباب (مثل قضاء الفوائت، صلاة الجنازة، صلاة الكسوف، وتحية المسجد عند الشافعية) تجوز في هذه الأوقات؛ والنهي خاص بالنوافل المطلقة التي لا سبب لها.'
            : 'ئەو نوێژانەی کە هۆکارێکی تایبەتیان هەیە (وەک قەزاکردنەوەی نوێژی فەرز، نوێژی جەنازە، نوێژی خۆرگیران، سڵاوی مزگەوت لەسەر ڕای ئیمامی شافعی) دروستن لەم کاتانەشدا ئەنجام بدرێن؛ تەنها نوێژی سوننەتی ڕەها (نەفلی بێ هۆکار) مەکرووهـ یان حەرامە.');

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
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Color(0xFFE53935), size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      bannerTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.5,
                        color: Color(0xFFE53935),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                bannerDesc,
                style: theme.textTheme.bodySmall?.copyWith(
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ..._buildProhibitedCards(isDark, lang),
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
                noteTitle,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                noteBody,
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

  List<Widget> _buildProhibitedCards(bool isDark, String lang) {
    final isAr = lang == 'ar';
    final isEn = lang == 'en';

    if (isEn) {
      return [
        _buildProhibitedCard(
          number: '1',
          title: 'From After Fajr until Sunrise has Fully Risen',
          duration: 'From Fajr prayer until ~15-20 min after sunrise',
          reason:
              'Because the sun rises between the two horns of Satan and disbelievers prostrate to it at that time.',
          isDark: isDark,
          lang: lang,
        ),
        const SizedBox(height: 12),
        _buildProhibitedCard(
          number: '2',
          title: 'Sun at its Zenith (Midday Before Dhuhr)',
          duration: 'Approximately 5 to 15 minutes before Dhuhr adhan',
          reason:
              'Because Hellfire is stoked and heated up at this moment until the sun moves past the meridian.',
          isDark: isDark,
          lang: lang,
        ),
        const SizedBox(height: 12),
        _buildProhibitedCard(
          number: '3',
          title: 'From After Asr until the Sun Fully Sets',
          duration: 'From completing obligatory Asr prayer until Maghrib adhan',
          reason:
              'Because the sun sets between the two horns of Satan and disbelievers prostrate to it at sunset.',
          isDark: isDark,
          lang: lang,
        ),
      ];
    }

    if (isAr) {
      return [
        _buildProhibitedCard(
          number: '١',
          title: 'من بعد صلاة الفجر حتى ترتفع الشمس قيد رمح',
          duration: 'من صلاة الفجر إلى حوالي ١٥-٢٠ دقيقة بعد شروق الشمس',
          reason: 'لأن الشمس تطلع بين قرني شيطان وحينئذ يسجد لها الكفار.',
          isDark: isDark,
          lang: lang,
        ),
        const SizedBox(height: 12),
        _buildProhibitedCard(
          number: '٢',
          title: 'عند استواء الشمس في كبد السماء (قبل الظهر)',
          duration: 'حوالي ٥ إلى ١٥ دقيقة قبل أذان الظهر',
          reason: 'لأن جهنم تُسجر وتوقد في هذا الوقت حتى تزول الشمس نحو الغرب.',
          isDark: isDark,
          lang: lang,
        ),
        const SizedBox(height: 12),
        _buildProhibitedCard(
          number: '٣',
          title: 'من بعد صلاة العصر حتى تغرب الشمس تماماً',
          duration: 'من بعد أداء فريضة العصر حتى أذان المغرب',
          reason: 'لأن الشمس تغرب بين قرني شيطان وحينئذ يسجد لها الكفار.',
          isDark: isDark,
          lang: lang,
        ),
      ];
    }

    return [
      _buildProhibitedCard(
        number: '١',
        title: 'لە دوای نوێژی بەیانی تا بەرزبوونەوەی تەواوی خۆر',
        duration: 'لە پاش بەیانی تا نزیکەی ١٥ بۆ ٢٠ خولەک پاش خۆرهەڵاتن',
        reason:
            'لەبەر ئەوەی خۆر لە نێوان دوو شاخی شەیتاندا هەڵدێت و کافرەکان لەم کاتەدا سوجدەی بۆ دەبەن.',
        isDark: isDark,
        lang: lang,
      ),
      const SizedBox(height: 12),
      _buildProhibitedCard(
        number: '٢',
        title: 'کاتی وەستانی خۆر لە ناوەڕاستی ئاسمان (پێش نیوەڕۆ)',
        duration: 'نزیکەی ٥ بۆ ١٥ خولەک پێش بانگی نیوەڕۆ',
        reason:
            'لەبەر ئەوەی لەم کاتەدا ئاگری دۆزەخ دادەگیرسێندرێت و گەرم دەکرێت هەتا خۆر لە ناوەڕاست لا دەدات بەلای ڕۆژئاوادا.',
        isDark: isDark,
        lang: lang,
      ),
      const SizedBox(height: 12),
      _buildProhibitedCard(
        number: '٣',
        title: 'لە دوای نوێژی عەسر تا ئاوابوونی تەواوی خۆر',
        duration: 'لە پاش ئەنجامدانی فەرزی عەسر هەتا بانگی ئێوارە',
        reason: 'لەبەر ئەوەی خۆر لە نێوان دوو شاخی شەیتاندا ئاوا دەبێت.',
        isDark: isDark,
        lang: lang,
      ),
    ];
  }

  // --------------------------------------------------------------------------
  // REUSABLE CARD WIDGETS
  // --------------------------------------------------------------------------
  Widget _buildPrayerSunnahItem({
    required String prayer,
    required String before,
    required String after,
    required String note,
    required bool isDark,
    required String lang,
  }) {
    final String beforeLabel = lang == 'en'
        ? 'Before: '
        : (lang == 'ar' ? 'قبل الفريضة: ' : 'پێش فەرز: ');
    final String afterLabel = lang == 'en'
        ? 'After: '
        : (lang == 'ar' ? 'بعد الفريضة: ' : 'پاش فەرز: ');
    final String badgeLabel =
        lang == 'en' ? 'Sunnah' : (lang == 'ar' ? 'سنة' : 'سوننەت');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  prayer,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF43A047).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badgeLabel,
                  style: const TextStyle(
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
              Text(
                beforeLabel,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5),
              ),
              Expanded(
                child: Text(
                  before,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.arrow_forward, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                afterLabel,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5),
              ),
              Expanded(
                child: Text(
                  after,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
              ),
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
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
    required String lang,
  }) {
    final String reasonLabel = lang == 'en'
        ? 'Reason: '
        : (lang == 'ar' ? 'العلة والسبب: ' : 'هۆکار: ');

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
            '$reasonLabel$reason',
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
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF43A047).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: const Color(0xFF43A047).withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  stepNumber,
                  style: const TextStyle(
                    color: Color(0xFF43A047),
                    fontSize: 12,
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
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
              ),
            ),
            child: Text(
              arabicText,
              style: const TextStyle(
                fontFamily: Fonts.naskh,
                fontFamilyFallback: [Fonts.uthmanic],
                fontWeight: FontWeight.bold,
                fontSize: 16,
                height: 1.8,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
          Flexible(
            child: Text(
              voiceType,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMistakeCard({
    required String title,
    required String problem,
    required String correction,
    required bool isDark,
    required String lang,
  }) {
    final String problemLabel = lang == 'en'
        ? 'The Mistake: '
        : (lang == 'ar' ? 'الخطأ: ' : 'هەڵەکە: ');
    final String correctLabel = lang == 'en'
        ? 'Sunnah / Correct: '
        : (lang == 'ar' ? 'الصحيح والسنة: ' : 'دروست و سوننەت: ');

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
                        '$problemLabel$problem',
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
                        '$correctLabel$correction',
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
}
