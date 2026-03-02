import 'package:atella/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../Widgets/app_header.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: GlobalHeader(
                title: l10n.privacyPolicy,
              ),
            ),

            SizedBox(height: 20.h),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Last Updated
                    Text(
                      l10n.ppLastUpdated,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Introduction
                    _buildRichText(l10n.ppIntroduction),

                    SizedBox(height: 32.h),

                    // Section: Information We Collect
                    _buildSection(
                      l10n.ppInformationWeCollect,
                      l10n.ppInformationWeCollectContent,
                    ),

                    // Section: How We Use Your Information
                    _buildSection(
                      l10n.ppHowWeUseYourInformation,
                      l10n.ppHowWeUseYourInformationContent,
                    ),

                    // Section: AI & Third-Party Services
                    _buildSection(
                      l10n.ppAIAndThirdPartyServices,
                      l10n.ppAIAndThirdPartyServicesContent,
                    ),

                    // Section: Data Retention
                    _buildSection(
                      l10n.ppDataRetention,
                      l10n.ppDataRetentionContent,
                    ),

                    // Section: Data Sharing & Disclosure
                    _buildSection(
                      l10n.ppDataSharingAndDisclosure,
                      l10n.ppDataSharingAndDisclosureContent,
                    ),

                    // Section: Security
                    _buildSection(
                      l10n.ppSecurity,
                      l10n.ppSecurityContent,
                    ),

                    // Section: Your Rights
                    _buildSection(
                      l10n.ppYourRights,
                      l10n.ppYourRightsContent,
                    ),

                    // Section: Children's Privacy
                    _buildSection(
                      l10n.ppChildrensPrivacy,
                      l10n.ppChildrensPrivacyContent,
                    ),

                    // Section: International Data Transfers
                    _buildSection(
                      l10n.ppInternationalDataTransfers,
                      l10n.ppInternationalDataTransfersContent,
                    ),

                    // Section: Changes to This Privacy Policy
                    _buildSection(
                      l10n.ppChangesToThisPrivacyPolicy,
                      l10n.ppChangesToThisPrivacyPolicyContent,
                    ),

                    // Section: Contact Us
                    _buildSection(
                      l10n.ppContactUs,
                      l10n.ppContactUsContent,
                    ),

                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 28.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),

          SizedBox(height: 12.h),

          // Section Content with clickable links
          _buildRichText(content),
        ],
      ),
    );
  }

  Widget _buildRichText(String content) {
    final List<TextSpan> spans = [];
    final RegExp linkRegex = RegExp(
      r'(https?://[^\s]+)|([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})',
      caseSensitive: false,
    );

    int lastIndex = 0;
    for (final match in linkRegex.allMatches(content)) {
      // Add text before the link
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: content.substring(lastIndex, match.start),
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black87,
              height: 1.6,
            ),
          ),
        );
      }

      // Add the clickable link
      final link = match.group(0)!;
      spans.add(
        TextSpan(
          text: link,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.blue,
            height: 1.6,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () => _launchUrl(link),
        ),
      );

      lastIndex = match.end;
    }

    // Add remaining text after the last link
    if (lastIndex < content.length) {
      spans.add(
        TextSpan(
          text: content.substring(lastIndex),
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.black87,
            height: 1.6,
          ),
        ),
      );
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final l10n = AppLocalizations.of(Get.context!)!;
    // Add mailto: prefix for email addresses
    if (!urlString.startsWith('http') && urlString.contains('@')) {
      urlString = 'mailto:$urlString';
    }

    final Uri uri = Uri.parse(urlString);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // Optionally show an error message
      Get.snackbar(
        l10n.error,
        l10n.couldNotOpenLink,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(milliseconds: 1500),
      );
    }
  }
}
