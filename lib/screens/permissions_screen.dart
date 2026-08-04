import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:the_open_quran/constants/constants.dart';

import '../constants/non_quran_style.dart';
import '../widgets/app_bars/primary_app_bar.dart';
import '../widgets/buttons/secondary_button.dart';

/// Screen for enabling notifications and other permissions.
class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).appBarTheme.iconTheme?.color ??
        Theme.of(context).iconTheme.color ??
        DesignSystem.onSurface;
    return Scaffold(
      appBar: PrimaryAppBar(
        title: context.translate.theOpenQuran,
        leading: IconButton(
          icon: SvgPicture.asset(
            ImageConstants.newBackArrow,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: NonQuranStyle.screenPaddingV,
          horizontal: NonQuranStyle.screenPaddingH,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.translate.permissions,
              style: context.theme.textTheme.displayLarge?.copyWith(
                color: NonQuranStyle.sectionTitleColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: kSizeL),
            _PermissionCard(
              icon: Icons.notifications_outlined,
              title: context.translate.permissionsNotifications,
              description: context.translate.permissionsNotificationsDescription,
              buttonLabel: context.translate.openSettings,
              onPressed: () async {
                final status = await Permission.notification.request();
                if (status.isDenied || status.isPermanentlyDenied) {
                  if (context.mounted) {
                    openAppSettings();
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String description;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.screenPadding),
      decoration: BoxDecoration(
        color: DesignSystem.cardBackground,
        borderRadius: BorderRadius.circular(DesignSystem.cornerRadius),
        boxShadow: DesignSystem.softGlowShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: DesignSystem.iconGreen, size: 28),
              const SizedBox(width: kSizeM),
              Expanded(
                child: Text(
                  title,
                  style: context.theme.textTheme.headlineMedium?.copyWith(
                    color: DesignSystem.textForest,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: kSizeS),
          Text(
            description,
            style: context.theme.textTheme.bodyMedium?.copyWith(
              color: DesignSystem.textForest,
            ),
          ),
          const SizedBox(height: kSizeM),
          SecondaryButton(
            text: buttonLabel,
            onPressed: onPressed,
            icon: Icon(icon, color: AppColors.white, size: 20),
          ),
        ],
      ),
    );
  }
}
