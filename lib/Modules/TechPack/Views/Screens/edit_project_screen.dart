import 'package:atella/Modules/TechPack/Views/Widgets/image_upload_field.dart';
import 'package:atella/Modules/TechPack/Views/Widgets/reusable_dropdown_field.dart';
import 'package:atella/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';

class EditProjectScreen extends StatelessWidget {
  const EditProjectScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        title: Text('Edit Project', style: ESTitleTextTextStyle12400),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Name
            Text('Project Name', style: DDTextTextStyle16500),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: 'Abc',
              decoration: InputDecoration(
                filled: true,
                fillColor: Color.fromRGBO(236, 239, 246, 1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Dropdown Fields
            ReusableDropdownField(
              label: 'What type of clothing are you designing?',
              value: 'T-shirt',
              items: ['T-shirt', 'Shirt', 'Dress'],
              onChanged: (_) {},
              itemLabel: (item) => item,
            ),
            const SizedBox(height: 16),

            ReusableDropdownField(
              label: 'What is the style or vibe?',
              value: 'Casual, Luxury',
              items: ['Casual, Luxury', 'Formal', 'Sporty'],
              onChanged: (_) {},
              itemLabel: (item) => item,
            ),
            const SizedBox(height: 16),

            ReusableDropdownField(
              label: 'Who is your target audience?',
              value: 'Male',
              items: ['Male', 'Female', 'Unisex'],
              onChanged: (_) {},
              itemLabel: (item) => item,
            ),
            const SizedBox(height: 16),

            ReusableDropdownField(
              label: 'Which season is this for?',
              value: 'Spring',
              items: ['Spring', 'Summer', 'Winter', 'Autumn'],
              onChanged: (_) {},
              itemLabel: (item) => item,
            ),
            const SizedBox(height: 16),

            const Text(
              'Upload any inspiration images or moodboards?',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ImageUploadField(
              imageUrl:
                  'https://cdn.pixabay.com/photo/2017/03/27/14/56/fashion-2179283_1280.jpg',
              title: 'New Image',
              subtitle: 'Ready Made And Handmade',
              buttonText: 'Reupload',
              buttonIcon: Icons.refresh,
              onTap: () {},
            ),
            const SizedBox(height: 16),

            ReusableDropdownField(
              label: 'What kind of materials or fabrics do you want to use?"',
              value: 'Organic jersey fabric',
              items: ['Organic jersey fabric', 'Cotton', 'Silk'],
              onChanged: (_) {},
              itemLabel: (item) => item,
            ),
            const SizedBox(height: 16),

            ReusableDropdownField(
              label: 'Any functional elements to include?',
              value: 'Pockets',
              items: ['Pockets', 'Zippers', 'Buttons'],
              onChanged: (_) {},
              itemLabel: (item) => item,
            ),
            const SizedBox(height: 16),

            const Text(
              'Any specific colors or color palette?',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ImageUploadField(
              imageUrl:
                  'https://cdn.pixabay.com/photo/2016/11/29/03/53/beige-1867430_1280.jpg',
              title: 'Neutral',
              subtitle: 'Neutral shades like beige, ivory, and off-white',
              buttonText: 'Reupload',
              buttonIcon: Icons.refresh,
              onTap: () {},
            ),
            const SizedBox(height: 16),

            ReusableDropdownField(
              label: 'What size range do you want to offer?',
              value: 'Small',
              items: ['Small', 'Medium', 'Large'],
              onChanged: (_) {},
              itemLabel: (item) => item,
            ),
            const SizedBox(height: 16),

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
            const SizedBox(height: 16),

            ReusableDropdownField(
              label: 'Do you need labels or tags?',
              value: 'Printed size label only',
              items: ['Printed size label only', 'Brand label', 'Care label'],
              onChanged: (_) {},
              itemLabel: (item) => item,
            ),
            const SizedBox(height: 16),

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
            const SizedBox(height: 16),

            ReusableDropdownField(
              label: 'What’s your estimated quantity (MOQ)?',
              value: '50 pcs',
              items: ['10 pcs', '50 pcs', '100 pcs'],
              onChanged: (_) {},
              itemLabel: (item) => item,
            ),
            const SizedBox(height: 16),

            ReusableDropdownField(
              label: 'Do you have a deadline or preferred delivery time?',
              value: '4 weeks',
              items: ['2 weeks', '4 weeks', '6 weeks'],
              onChanged: (_) {},
              itemLabel: (item) => item,
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Update',
                  style: TextStyle(
                    fontSize: 16,
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
