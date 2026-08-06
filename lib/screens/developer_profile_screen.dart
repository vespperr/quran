import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:the_open_quran/constants/constants.dart';

import '../constants/non_quran_style.dart';
import '../routes/app_routes.dart';
import '../widgets/app_bars/primary_app_bar.dart';
import '../widgets/light_sweep_container.dart';
import 'support_us_screen.dart';

/// Developer CV / Profile Screen for AbdulrahmanMh.
class DeveloperProfileScreen extends StatelessWidget {
  const DeveloperProfileScreen({super.key});

  static const String facebookUrl = 'https://www.facebook.com/AbdurahmanMH0';
  static const String whatsappUrl = 'https://wa.me/qr/Q3TBVBQLRF2AK1';
  static const String telegramUrl = 'https://t.me/AbdurahmanMH';

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: PrimaryAppBar(
        title: 'Developer Profile',
        leading: IconButton(
          icon: SvgPicture.asset(ImageConstants.newBackArrow),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: NonQuranStyle.screenPaddingH,
          vertical: NonQuranStyle.screenPaddingV,
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Header Profile Card
            LightSweepContainer(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF1B4D3E), const Color(0xFF0F2E25)]
                        : [const Color(0xFF2E7D6F), const Color(0xFF1B4D3E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: const Color(0xFFD4AF37),
                    child: const CircleAvatar(
                      radius: 37,
                      backgroundColor: Color(0xFF0F2E25),
                      child: Icon(
                        Icons.code_rounded,
                        color: Color(0xFFD4AF37),
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'AbdulrahmanMh',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Open Source Developer',
                    style: TextStyle(
                      color: const Color(0xFFD4AF37),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Developed & Maintained by AbdulrahmanMh',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

            const SizedBox(height: 24),

            // Social Media Buttons Grid
            Row(
              children: [
                Expanded(
                  child: _SocialButton(
                    label: 'Facebook',
                    icon: Icons.facebook,
                    color: const Color(0xFF1877F2),
                    onTap: () => _launch(facebookUrl),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SocialButton(
                    label: 'WhatsApp',
                    icon: Icons.chat_bubble_outline_rounded,
                    color: const Color(0xFF25D366),
                    onTap: () => _launch(whatsappUrl),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SocialButton(
                    label: 'Telegram',
                    icon: Icons.send_rounded,
                    color: const Color(0xFF229ED9),
                    onTap: () => _launch(telegramUrl),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Support Us / Donate Card
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  AppRoutes.fadeSlideRoute(
                    builder: (context) => const SupportUsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.favorite_rounded, color: Color(0xFF0E2E25)),
              label: Text(
                '${context.translate.supportUsTitle} (FIB & SuperQi)',
                style: const TextStyle(
                  color: Color(0xFF0E2E25),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // WhatsApp QR Code Card
            GestureDetector(
              onTap: () => _launch(whatsappUrl),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2623) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.qr_code_scanner_rounded,
                          color: Color(0xFFD4AF37),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Scan or Tap QR to Chat on WhatsApp',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // High-contrast container for QR code
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        ImageConstants.whatsappQrCode,
                        width: 220,
                        height: 220,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'https://wa.me/qr/Q3TBVBQLRF2AK1',
                      style: TextStyle(
                        fontSize: 11,
                        color: DesignSystem.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
