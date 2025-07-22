import 'package:atella/core/constants/app_images.dart';
import 'package:atella/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/themes/app_fonts.dart';

class SearchWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final VoidCallback? onClear;

  const SearchWidget({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onClear,
  });

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final FocusNode _focusNode = FocusNode();
  bool isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.h,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(236, 239, 246, 1),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(
          color: isFocused ? AppColors.buttonColor : Colors.transparent,
          width: 2.w,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        onChanged: widget.onChanged,
        style: OSTextStyle165002,
        decoration: InputDecoration(
          hintText: 'Search Product',
          hintStyle: OSTextStyle165002,
          prefixIcon: Padding(
            padding: EdgeInsets.all(12.w),
            child: Image.asset(
              searchIcon, // Your image asset
              height: 20.h,
              width: 20.w,
              fit: BoxFit.contain,
            ),
          ),
          suffixIcon: widget.controller.text.isNotEmpty
              ? GestureDetector(
                  onTap: widget.onClear,
                  child: Icon(Icons.clear, size: 20.sp, color: Colors.grey),
                )
              : const SizedBox.shrink(),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
        ),
      ),
    );
  }
}
