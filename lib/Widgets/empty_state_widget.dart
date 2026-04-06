import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:atella/Widgets/custom_roundbutton.dart';
import 'package:atella/core/themes/app_colors.dart';

import 'package:atella/l10n/generated/app_localizations.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String buttonText;
  final VoidCallback onButtonPressed;
  final String? imagePath;

  const EmptyStateWidget({
    super.key,
    required this.title,
    this.subtitle,
    required this.buttonText,
    required this.onButtonPressed,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Empty state image
          if (imagePath != null)
            Image.asset(
              imagePath!,
              height: 170.h,
              width: 155.w,
              fit: BoxFit.contain,
            ),

          SizedBox(height: 24.h),

          // Title text
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Color(0xFF666666),
              height: 1.4,
            ),
          ),

          // Subtitle text (optional)
          if (subtitle != null) ...[
            SizedBox(height: 12.h),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Color(0xFF999999),
                height: 1.3,
              ),
            ),
          ],

          SizedBox(height: 40.h),

          RoundButton(
            title: buttonText,
            onTap: onButtonPressed,
            color: AppColors.buttonColor,
            isloading: false,
          ),
        ],
      ),
    );
  }
}

// Predefined empty states for common scenarios
class HomeEmptyState extends StatelessWidget {
  final VoidCallback onCreateProject;

  const HomeEmptyState({super.key, required this.onCreateProject});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: AppLocalizations.of(context)!.homeEmptyStateTitle,
      buttonText: AppLocalizations.of(context)!.createNewProject,
      onButtonPressed: onCreateProject,
      imagePath: "assets/images/empty.png",
    );
  }
}

class FavoritesEmptyState extends StatelessWidget {
  final VoidCallback onCreateProject;

  const FavoritesEmptyState({super.key, required this.onCreateProject});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: AppLocalizations.of(context)!.noFavoritesYet,
      subtitle: AppLocalizations.of(context)!.noFavoritesSubtitle,
      buttonText: AppLocalizations.of(context)!.createNewProject,
      onButtonPressed: onCreateProject,
      imagePath: "assets/images/empty.png",
    );
  }
}

class SearchEmptyState extends StatelessWidget {
  final String searchQuery;
  final VoidCallback? onClearSearch;

  const SearchEmptyState({
    super.key,
    required this.searchQuery,
    this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 40.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80.w, color: Color(0xFFCCCCCC)),

          SizedBox(height: 24.h),

          Text(
            AppLocalizations.of(context)!.noResultsFor(searchQuery),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Color(0xFF666666),
            ),
          ),

          SizedBox(height: 8.h),

          Text(
            AppLocalizations.of(context)!.tryAdjustingSearch,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, color: Color(0xFF999999)),
          ),

          if (onClearSearch != null) ...[
            SizedBox(height: 24.h),
            TextButton(
              onPressed: onClearSearch,
              child: Text(
                AppLocalizations.of(context)!.clearSearch,
                style: TextStyle(fontSize: 14.sp, color: AppColors.buttonColor),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
