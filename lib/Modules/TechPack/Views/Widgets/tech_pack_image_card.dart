import 'package:atella/core/constants/app_iamges.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';

class TechPackImageCard extends StatelessWidget {
  final bool isLoading;
  final String? imagePath;
  final VoidCallback? onTap;
  const TechPackImageCard({
    Key? key,
    this.isLoading = false,
    this.imagePath,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE3E1FB),
        borderRadius: BorderRadius.circular(24),
      ),
      width: double.infinity,
      height: 180,
      child: isLoading
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(generateTechPackIcon, height: 50, width: 50),
                const SizedBox(height: 12),
                Text('Generating..', style: GSTextStyle17400),
              ],
            )
          : imagePath != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                imagePath!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 180,
              ),
            )
          : SizedBox.shrink(),
    );
    if (onTap != null && !isLoading && imagePath != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}
