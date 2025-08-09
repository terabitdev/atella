import 'package:atella/Modules/TechPack/Views/Widgets/image_upload_field.dart';
import 'package:atella/Modules/TechPack/Views/Widgets/reusable_dropdown_field.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditProjectScreen extends StatelessWidget {
  const EditProjectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        title: Text('Edit Project', style: esTitleTextTextStyle12400),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Name
            Text('Project Name', style: ddTextTextStyle16500),
            SizedBox(height: 8.h),
            TextFormField(
              initialValue: 'Abc',
              decoration: InputDecoration(
                filled: true,
                fillColor: Color.fromRGBO(236, 239, 246, 1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 14.h,
                  horizontal: 16.w,
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Dropdown Fields
            ReusableDropdownField(
              label: 'What type of clothing are you designing?',
              value: 'T-shirt',
              items: ['T-shirt', 'Shirt', 'Dress'],
              onChanged: (_) {},
              itemLabel: (item) => item,
            ),
            SizedBox(height: 16.h),

            ReusableDropdownField(
              label: 'What is the style or vibe?',
              value: 'Casual, Luxury',
              items: ['Casual, Luxury', 'Formal', 'Sporty'],
              onChanged: (_) {},
              itemLabel: (item) => item,
            ),
            SizedBox(height: 16.h),

            ReusableDropdownField(
              label: 'Who is your target audience?',
              value: 'Male',
              items: ['Male', 'Female', 'Unisex'],
              onChanged: (_) {},
              itemLabel: (item) => item,
            ),
            SizedBox(height: 16.h),

            ReusableDropdownField(
              label: 'Which season is this for?',
              value: 'Spring',
              items: ['Spring', 'Summer', 'Winter', 'Autumn'],
              onChanged: (_) {},
              itemLabel: (item) => item,
            ),
            SizedBox(height: 16.h),

            Text(
              'Upload any inspiration images or moodboards?',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp),
            ),
            SizedBox(height: 8.h),
            ImageUploadField(
              imageUrl:
                  'https://cdn.pixabay.com/photo/2017/03/27/14/56/fashion-2179283_1280.jpg',
              title: 'New Image',
              subtitle: 'Ready Made And Handmade',
              buttonText: 'Reupload',
              buttonIcon: Icons.refresh,
              onTap: () {},
            ),
            SizedBox(height: 16.h),

            ReusableDropdownField(
              label: 'What kind of materials or fabrics do you want to use?"',
              value: 'Organic jersey fabric',
              items: ['Organic jersey fabric', 'Cotton', 'Silk'],
              onChanged: (_) {},
              itemLabel: (item) => item,
            ),
            SizedBox(height: 16.h),

            ReusableDropdownField(
              label: 'Any functional elements to include?',
              value: 'Pockets',
              items: ['Pockets', 'Zippers', 'Buttons'],
              onChanged: (_) {},
              itemLabel: (item) => item,
            ),
            SizedBox(height: 16.h),

            Text(
              'Any specific colors or color palette?',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp),
            ),
            SizedBox(height: 8.h),
            ImageUploadField(
              imageUrl:
                  'https://cdn.pixabay.com/photo/2016/11/29/03/53/beige-1867430_1280.jpg',
              title: 'Neutral',
              subtitle: 'Neutral shades like beige, ivory, and off-white',
              buttonText: 'Reupload',
              buttonIcon: Icons.refresh,
              onTap: () {},
            ),
            SizedBox(height: 16.h),

            ReusableDropdownField(
              label: 'What size range do you want to offer?',
              value: 'Small',
              items: ['Small', 'Medium', 'Large'],
              onChanged: (_) {},
              itemLabel: (item) => item,
            ),
            SizedBox(height: 16.h),

            ReusableDropdownField(
              label: 'What is your preferred stitching or finish?',
              value: 'Double needle stitching',
              items: [
                'Double needle stitching',
                'Flatlock stitch',
                'Overlock stitch',
              ],
              onChanged: (_) {},
              itemLabel: (item) => item,
            ),
            SizedBox(height: 16.h),

            ReusableDropdownField(
              label: 'Do you need labels or tags?',
              value: 'Printed size label only',
              items: ['Printed size label only', 'Brand label', 'Care label'],
              onChanged: (_) {},
              itemLabel: (item) => item,
            ),
            SizedBox(height: 16.h),

            ReusableDropdownField(
              label: 'How should each item be packed?',
              value: 'Folded with tissue, in polybag',
              items: [
                'Folded with tissue, in polybag',
                'Rolled in tissue',
                'Individually boxed',
              ],
              onChanged: (_) {},
              itemLabel: (item) => item,
            ),
            SizedBox(height: 16.h),

            ReusableDropdownField(
              label: 'What’s your estimated quantity (MOQ)?',
              value: '50 pcs',
              items: ['10 pcs', '50 pcs', '100 pcs'],
              onChanged: (_) {},
              itemLabel: (item) => item,
            ),
            SizedBox(height: 16.h),

            ReusableDropdownField(
              label: 'Do you have a deadline or preferred delivery time?',
              value: '4 weeks',
              items: ['2 weeks', '4 weeks', '6 weeks'],
              onChanged: (_) {},
              itemLabel: (item) => item,
            ),
            SizedBox(height: 24.h),

            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Update',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
