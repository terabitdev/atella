import 'package:atella/Data/Models/translated_manufacturer_model.dart';
import 'package:atella/Modules/tech_pack/Views/Widgets/manufacturer_suggestion_card.dart';
import 'package:atella/Modules/tech_pack/controllers/manufacturer_suggestion_controller.dart';
import 'package:atella/l10n/generated/app_localizations.dart';
import 'package:atella/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// Simple card wrapper for translated manufacturer data
class TranslatedManufacturerCard extends StatelessWidget {
  final TranslatedManufacturer translatedManufacturer;
  final VoidCallback onViewProfile;
  final VoidCallback? onSendEmail;

  const TranslatedManufacturerCard({
    super.key,
    required this.translatedManufacturer,
    required this.onViewProfile,
    this.onSendEmail,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;

    return TranslatedManufacturerSuggestionCard(
      manufacturer: translatedManufacturer,
      translatedManufacturer: translatedManufacturer,
      locale: locale,
      onViewProfile: onViewProfile,
      onSendEmail: onSendEmail,
    );
  }
}

/// Manufacturer card that displays translated data
class TranslatedManufacturerSuggestionCard extends ManufacturerSuggestionCard {
  final TranslatedManufacturer translatedManufacturer;
  final String locale;

  const TranslatedManufacturerSuggestionCard({
    super.key,
    required super.manufacturer,
    required this.translatedManufacturer,
    required this.locale,
    required super.onViewProfile,
    super.onSendEmail,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ManufacturerSuggestionController>();
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main card content
          Padding(
            padding: EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Company name
                Text(
                  manufacturer.companyName,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 8),

                // Location (Country)
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: const Color.fromARGB(199, 5, 1, 1),
                      size: 20,
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        manufacturer.country,
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),

                // Products they make (TRANSLATED)
                if (translatedManufacturer.getProducts(locale).isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 6.h,
                    children: translatedManufacturer
                        .getProducts(locale)
                        .take(4)
                        .map((product) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.buttonColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          product,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.buttonColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                SizedBox(height: 16.h),

                // Action buttons (same as original)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onSendEmail,
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: const BorderSide(color: Colors.black, width: 1),
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          l10n.mfSendViaEmail,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showContactDialog(context, l10n),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: const BorderSide(color: Colors.black, width: 1),
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          l10n.mfContact,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Expandable section
          Obx(() {
            final isExpanded = controller.isCardExpanded(manufacturer.id);
            return Column(
              children: [
                // Expand/Collapse button
                InkWell(
                  onTap: () => controller.toggleCardExpansion(manufacturer.id),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F8F8),
                      border: Border(
                        top: BorderSide(
                          color: const Color(0xFFE0E0E0),
                          width: 1,
                        ),
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(isExpanded ? 0 : 18),
                        bottomRight: Radius.circular(isExpanded ? 0 : 18),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isExpanded ? l10n.mfHideDetails : l10n.mfMoreDetails,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF666666),
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          size: 20,
                          color: const Color(0xFF666666),
                        ),
                      ],
                    ),
                  ),
                ),

                // Expanded content with TRANSLATED data
                if (isExpanded)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(18),
                        bottomRight: Radius.circular(18),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // MOQ (TRANSLATED)
                        _buildDetailRow(
                          icon: Icons.inventory_2_outlined,
                          label: l10n.mfMinimumOrderQuantity,
                          value: translatedManufacturer.getMoq(locale),
                        ),

                        // Certifications (not translated - proper nouns)
                        if (manufacturer.hasCertifications) ...[
                          SizedBox(height: 12),
                          _buildDetailRow(
                            icon: Icons.verified_outlined,
                            label: l10n.mfCertifications,
                            value: manufacturer.certificationsDisplay,
                          ),
                        ],

                        // All Products (TRANSLATED)
                        if (translatedManufacturer.getProducts(locale).isNotEmpty) ...[
                          SizedBox(height: 12),
                          _buildDetailRow(
                            icon: Icons.checkroom_outlined,
                            label: l10n.mfProductsCapabilities,
                            value: translatedManufacturer.getProductsDisplay(locale),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF666666)),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: const Color(0xFF999999),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  color: const Color(0xFF333333),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showContactDialog(BuildContext context, AppLocalizations l10n) {
    // Call the parent's method through a workaround
    // This is a simplified version - you can expand it if needed
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            l10n.mfContactManufacturer(manufacturer.companyName),
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (manufacturer.hasEmail)
                Text('${l10n.mfEmail}: ${manufacturer.email}'),
              if (manufacturer.hasWebsite)
                Text('${l10n.mfWebsite}: ${manufacturer.website}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.mfClose),
            ),
          ],
        );
      },
    );
  }
}