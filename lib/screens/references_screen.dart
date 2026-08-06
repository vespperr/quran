import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:the_open_quran/constants/constants.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/non_quran_style.dart';
import '../widgets/app_bars/primary_app_bar.dart';

import '../routes/app_routes.dart';
import 'developer_profile_screen.dart';

class ReferencesScreen extends StatefulWidget {
  const ReferencesScreen({super.key});

  @override
  State<ReferencesScreen> createState() => _ReferencesScreenState();
}

class _ReferencesScreenState extends State<ReferencesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar,
      body: buildBody,
    );
  }

  PreferredSizeWidget get buildAppBar {
    return PrimaryAppBar(
      title: context.translate.references,
      leading: IconButton(
        icon: SvgPicture.asset(ImageConstants.newBackArrow),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget get buildBody {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: NonQuranStyle.screenPaddingH,
        vertical: NonQuranStyle.screenPaddingV,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 100,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(ImageConstants.appLogo),
              const SizedBox(
                width: 30,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.translate.theOpenQuran,
                    style: context.theme.textTheme.displayLarge,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    "Version 1.0.2",
                    style: context.theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        AppRoutes.fadeSlideRoute(
                          builder: (context) => const DeveloperProfileScreen(),
                        ),
                      );
                    },
                    child: Text(
                      context.translate.fabrikodTwoThree,
                      style: context.theme.textTheme.headlineMedium?.copyWith(
                        color: DesignSystem.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(
            height: kSizeXL,
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  style: context.theme.textTheme.headlineMedium,
                  text: context.translate.referencesDescription,
                ),
                TextSpan(
                  style: context.theme.textTheme.headlineMedium!
                      .copyWith(color: DesignSystem.primary),
                  text: "GitHub repository.",
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      const url = 'https://github.com/fabrikod/the-open-quran';
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(
                          Uri.parse(url),
                        );
                      }
                    },
                ),
                TextSpan(
                  text: context.translate.referencesDescription2,
                  style: context.theme.textTheme.headlineMedium,
                ),
                TextSpan(
                  text: "\n \n${context.translate.referencesDescription3}",
                  style: context.theme.textTheme.headlineMedium,
                ),
                TextSpan(
                  style: context.theme.textTheme.headlineMedium!
                      .copyWith(color: DesignSystem.primary),
                  text: " Quran.com api V4",
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      const url = 'https://quran.api-docs.io/';
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(
                          Uri.parse(url),
                        );
                      }
                    },
                ),
                TextSpan(
                    text: "\n \n${context.translate.contactUs}",
                    style: context.theme.textTheme.headlineMedium),
                TextSpan(
                    text: "\n \n${context.translate.privacyPolicy}",
                    style: context.theme.textTheme.headlineMedium),
                TextSpan(
                  style: context.theme.textTheme.headlineMedium!
                      .copyWith(color: DesignSystem.primary),
                  text: " (see app settings).",
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      const url = 'https://t.me/akademyay_bangbezhy';
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(
                          Uri.parse(url),
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
