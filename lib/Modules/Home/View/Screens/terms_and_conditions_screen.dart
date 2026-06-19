import 'package:atella/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../Widgets/app_header.dart';

import 'package:atella/core/utils/app_snackbar.dart';
class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

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
                title: l10n.termsAndConditions,
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
                      l10n.tcLastUpdated,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Introduction
                    Text(
                      l10n.tcIntroduction,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black87,
                        height: 1.6,
                      ),
                    ),

                    SizedBox(height: 32.h),

                    // Section: Company Information
                    _buildSection(
                      l10n.tcCompanyInformation,
                      l10n.tcCompanyInformationContent,
                    ),

                    // Section: Description of the Service
                    _buildSection(
                      l10n.tcDescriptionOfService,
                      l10n.tcDescriptionOfServiceContent,
                    ),

                    // Section: Eligibility
                    _buildSection(
                      l10n.tcEligibility,
                      l10n.tcEligibilityContent,
                    ),

                    // Section: User Account
                    _buildSection(
                      l10n.tcUserAccount,
                      l10n.tcUserAccountContent,
                    ),

                    // Section: Subscriptions & Payments
                    _buildSection(
                      l10n.tcSubscriptionsAndPayments,
                      l10n.tcSubscriptionsAndPaymentsContent,
                    ),

                    // Section: Usage Limits & Fair Use
                    _buildSection(
                      l10n.tcUsageLimits,
                      l10n.tcUsageLimitsContent,
                    ),

                    // Section: Intellectual Property
                    _buildSection(
                      l10n.tcIntellectualProperty,
                      l10n.tcIntellectualPropertyContent,
                    ),

                    // Section: AI-Generated Content Disclaimer
                    _buildSection(
                      l10n.tcAIContentDisclaimer,
                      l10n.tcAIContentDisclaimerContent,
                    ),

                    // Section: Factory Directory Disclaimer
                    _buildSection(
                      l10n.tcFactoryDirectoryDisclaimer,
                      l10n.tcFactoryDirectoryDisclaimerContent,
                    ),

                    // Section: Limitation of Liability
                    _buildSection(
                      l10n.tcLimitationOfLiability,
                      l10n.tcLimitationOfLiabilityContent,
                    ),

                    // Section: Service Availability
                    _buildSection(
                      l10n.tcServiceAvailability,
                      l10n.tcServiceAvailabilityContent,
                    ),

                    // Section: Termination
                    _buildSection(
                      l10n.tcTermination,
                      l10n.tcTerminationContent,
                    ),

                    // Section: Privacy
                    _buildSection(
                      l10n.tcPrivacy,
                      l10n.tcPrivacyContent,
                    ),

                    // Section: Governing Law
                    _buildSection(
                      l10n.tcGoverningLaw,
                      l10n.tcGoverningLawContent,
                    ),

                    // Section: Changes to Terms
                    _buildSection(
                      l10n.tcChangesToTerms,
                      l10n.tcChangesToTermsContent,
                    ),

                    // Section: Contact
                    _buildSection(
                      l10n.tcContact,
                      l10n.tcContactContent,
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
      showAppSnackbar(
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
