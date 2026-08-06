import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:the_open_quran/constants/constants.dart';
import 'package:the_open_quran/routes/app_routes.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/non_quran_style.dart';
import '../widgets/app_bars/primary_app_bar.dart';
import 'developer_profile_screen.dart';
import 'language_screen.dart';
import 'memorization_screen.dart';
import 'support_us_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Scaffold(
          backgroundColor: DesignSystem.cardBackground,
          appBar: PrimaryAppBar(
            title: context.translate.theOpenQuran,
          ),
          body: buildBody,
        ),
        buildAppInfo,
      ],
    );
  }

  Widget get buildBody {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: NonQuranStyle.screenPaddingH,
            vertical: NonQuranStyle.screenPaddingV,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                context.translate.settings,
                style: context.theme.textTheme.headlineMedium?.copyWith(
                  color: NonQuranStyle.sectionTitleColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.translate.settingsDescription,
                style: context.theme.textTheme.bodyMedium?.copyWith(
                  color: DesignSystem.textForest.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 24),
              SettingsMenuCard(
                iconPath: ImageConstants.languageIcon,
                title: context.translate.language,
                subTitle: context.translate.changeAppLanguage,
                onTap: () {
                  Navigator.push(
                    context,
                    AppRoutes.fadeSlideRoute(builder: (context) => const LanguageScreen()),
                  );
                },
              ),
              SettingsMenuCard(
                iconData: Icons.calendar_month,
                iconPath: '',
                title: context.translate.memorizationProgram,
                subTitle: context.translate.viewManageMemorizationPlans,
                onTap: () {
                  Navigator.push(
                    context,
                    AppRoutes.fadeSlideRoute(
                        builder: (context) => const MemorizationScreen()),
                  );
                },
              ),
              SettingsMenuCard(
                iconPath: ImageConstants.introductionIcon,
                title: context.translate.privacyPolicy,
                subTitle: context.translate.readPrivacyPolicy,
                onTap: () async {
                  const url = 'https://t.me/akademyay_bangbezhy';
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url),
                        mode: LaunchMode.externalApplication);
                  }
                },
              ),
              SettingsMenuCard(
                iconData: Icons.favorite_rounded,
                iconPath: '',
                title: context.translate.supportUsTitle,
                subTitle: context.translate.donateViaFibSuperQi,
                onTap: () {
                  Navigator.push(
                    context,
                    AppRoutes.fadeSlideRoute(
                      builder: (context) => const SupportUsScreen(),
                    ),
                  );
                },
              ),
              SettingsMenuCard(
                iconData: Icons.person_pin_rounded,
                iconPath: '',
                title: 'Developer Profile',
                subTitle: 'AbdulrahmanMh',
                onTap: () {
                  Navigator.push(
                    context,
                    AppRoutes.fadeSlideRoute(
                      builder: (context) => const DeveloperProfileScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget get buildAppInfo {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              AppRoutes.fadeSlideRoute(
                builder: (context) => const DeveloperProfileScreen(),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Text(
              "${context.translate.openSourceDevelopedByFabrikod} ${context.translate.version} ${snapshot.data?.version ?? ""}",
              style: context.theme.textTheme.headlineSmall,
            ),
          ),
        );
      },
    );
  }
}

/// Menu card for settings — icon, title, subtitle, trailing arrow (profile style).
class SettingsMenuCard extends StatelessWidget {
  const SettingsMenuCard({
    super.key,
    required this.iconPath,
    required this.title,
    required this.subTitle,
    this.iconData,
    this.onTap,
  });

  final String iconPath;
  final String title;
  final String subTitle;
  final IconData? iconData;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor =
        DesignSystem.textForest.withValues(alpha: 0.64);
    final subtitleColor =
        DesignSystem.textForest.withValues(alpha: 0.54);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              if (iconData != null)
                Icon(iconData, size: 24, color: iconColor)
              else
                SvgPicture.asset(
                  iconPath,
                  height: 24,
                  width: 24,
                  colorFilter: ColorFilter.mode(
                    iconColor,
                    BlendMode.srcIn,
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.theme.textTheme.labelLarge?.copyWith(
                        color: DesignSystem.textForest,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_outlined,
                size: 16,
                color: iconColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
