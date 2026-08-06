import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:the_open_quran/constants/constants.dart';

import '../constants/non_quran_style.dart';
import '../widgets/app_bars/primary_app_bar.dart';
import '../widgets/light_sweep_container.dart';

/// Support Us / Donate Screen accepting donations via FIB and SuperQi.
class SupportUsScreen extends StatelessWidget {
  const SupportUsScreen({super.key});

  static const String fibPhoneNumber = '+9647517918001';
  static const String superQiAccountNumber = '910142284272';

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(context.translate.copiedToast(label)),
          ],
        ),
        backgroundColor: const Color(0xFF1B4D3E),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _openFibApp(BuildContext context) async {
    _copyToClipboard(context, fibPhoneNumber, context.translate.fibTitle);
    final uris = [
      Uri.parse('fib://send?phone=%2B9647517918001'),
      Uri.parse('fib://send?phone=+9647517918001'),
      Uri.parse('fib://pay?phone=+9647517918001'),
      Uri.parse('fib://transfer?phone=+9647517918001'),
      Uri.parse('fib://'),
    ];

    bool launched = false;
    for (final uri in uris) {
      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          launched = true;
          break;
        }
      } catch (_) {}
    }

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please open FIB app manually.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openSuperQiApp(BuildContext context) async {
    _copyToClipboard(context, superQiAccountNumber, context.translate.superQiTitle);
    final uris = [
      Uri.parse('superqi://transfer?account=910142284272'),
      Uri.parse('superqi://send?account=910142284272'),
      Uri.parse('superqi://'),
      Uri.parse('qi://'),
    ];

    bool launched = false;
    for (final uri in uris) {
      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          launched = true;
          break;
        }
      } catch (_) {}
    }

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please open SuperQi app manually.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: PrimaryAppBar(
        title: context.translate.supportUsTitle,
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),

            // Hero Intro Header Card with LightSweep
            LightSweepContainer(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF0F382C), const Color(0xFF061A14)]
                        : [const Color(0xFF1B4D3E), const Color(0xFF0E2E25)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1B4D3E).withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: Color(0xFFD4AF37),
                      child: Icon(
                        Icons.favorite_rounded,
                        color: Color(0xFF0E2E25),
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.translate.supportAppDev,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.translate.supportAppDevDesc,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // FIRST IRAQI BANK (FIB) SECTION
            _buildSectionCard(
              context,
              isDark: isDark,
              title: context.translate.fibTitle,
              icon: Icons.account_balance_wallet_rounded,
              badgeColor: const Color(0xFF2E7D6F),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    context.translate.fibPhoneLabel,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFD4AF37),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Prominent Tappable Number Badge with Copy Button
                  InkWell(
                    onTap: () => _copyToClipboard(context, fibPhoneNumber, context.translate.fibTitle),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.phone_iphone_rounded,
                            color: Color(0xFFD4AF37),
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '\u200E$fibPhoneNumber',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.copy_rounded, color: Color(0xFF0E2E25), size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  context.translate.copy,
                                  style: const TextStyle(
                                    color: Color(0xFF0E2E25),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Instructions
                  _buildInstructions([
                    context.translate.fibStep1,
                    context.translate.fibStep2,
                    context.translate.fibStep3,
                  ]),

                  const SizedBox(height: 16),

                  // Direct App Launcher Button
                  ElevatedButton.icon(
                    onPressed: () => _openFibApp(context),
                    icon: const Icon(Icons.launch_rounded, size: 18),
                    label: Text(
                      context.translate.openFibApp,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: const Color(0xFF0E2E25),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // SUPERQI (QI CARD) SECTION
            _buildSectionCard(
              context,
              isDark: isDark,
              title: context.translate.superQiTitle,
              icon: Icons.credit_card_rounded,
              badgeColor: const Color(0xFF1B4D3E),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    context.translate.superQiAccountLabel,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFD4AF37),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Prominent Tappable Account Number Badge with Copy Button
                  InkWell(
                    onTap: () => _copyToClipboard(context, superQiAccountNumber, context.translate.superQiTitle),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.payment_rounded,
                            color: Color(0xFFD4AF37),
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              superQiAccountNumber,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.copy_rounded, color: Color(0xFF0E2E25), size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  context.translate.copy,
                                  style: const TextStyle(
                                    color: Color(0xFF0E2E25),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Instructions specific to Card/Account Transfer
                  _buildInstructions([
                    context.translate.superQiStep1,
                    context.translate.superQiStep2,
                    context.translate.superQiStep3,
                  ]),

                  const SizedBox(height: 16),

                  // Direct App Launcher Button for SuperQi
                  ElevatedButton.icon(
                    onPressed: () => _openSuperQiApp(context),
                    icon: const Icon(Icons.launch_rounded, size: 18),
                    label: Text(
                      context.translate.openSuperQiApp,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: const Color(0xFF0E2E25),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required bool isDark,
    required String title,
    required IconData icon,
    required Color badgeColor,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF0F382C), const Color(0xFF061A14)]
              : [const Color(0xFF1B4D3E), const Color(0xFF0E2E25)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFD4AF37), size: 24),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildInstructions(List<String> steps) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: steps
            .map(
              (step) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  step,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
