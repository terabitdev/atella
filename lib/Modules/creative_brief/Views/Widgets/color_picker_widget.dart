import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickerWidget extends StatelessWidget {
  final Function(String) onColorSelected;
  final Function(String) onColorRemoved;
  final List<String> selectedColors;

  const ColorPickerWidget({
    Key? key,
    required this.onColorSelected,
    required this.onColorRemoved,
    required this.selectedColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: EdgeInsets.only(bottom: 12.h, top: 8.h),
          child: Text(
            'Solid colors',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF666666),
            ),
          ),
        ),

        // Selected colors display
        if (selectedColors.isNotEmpty) ...[
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: selectedColors.map((hexCode) {
              return _buildSelectedColorChip(hexCode);
            }).toList(),
          ),
          SizedBox(height: 12.h),
        ],

        // Color picker button
        GestureDetector(
          onTap: () => _showColorPicker(context),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_circle_outline,
                  size: 18.sp,
                  color: Colors.black,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Pick a color',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildSelectedColorChip(String hexCode) {
    final color = _hexToColor(hexCode);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Color circle
          Container(
            width: 20.w,
            height: 20.h,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
          ),
          SizedBox(width: 8.w),
          // Hex code
          Text(
            hexCode,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 4.w),
          // Remove icon
          GestureDetector(
            onTap: () => onColorRemoved(hexCode),
            child: Icon(
              Icons.close,
              size: 16.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    Color pickerColor = Colors.blue;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            'Select a Color',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
          ),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: pickerColor,
              onColorChanged: (Color color) {
                pickerColor = color;
              },
              availableColors: [
                // Reds
                Colors.red,
                Colors.redAccent,
                Colors.pink,
                Colors.pinkAccent,

                // Purples
                Colors.purple,
                Colors.purpleAccent,
                Colors.deepPurple,
                Colors.deepPurpleAccent,

                // Blues
                Colors.indigo,
                Colors.indigoAccent,
                Colors.blue,
                Colors.blueAccent,
                Colors.lightBlue,
                Colors.lightBlueAccent,
                Colors.cyan,
                Colors.cyanAccent,

                // Greens
                Colors.teal,
                Colors.tealAccent,
                Colors.green,
                Colors.greenAccent,
                Colors.lightGreen,
                Colors.lightGreenAccent,
                Colors.lime,
                Colors.limeAccent,

                // Yellows/Oranges
                Colors.yellow,
                Colors.yellowAccent,
                Colors.amber,
                Colors.amberAccent,
                Colors.orange,
                Colors.orangeAccent,
                Colors.deepOrange,
                Colors.deepOrangeAccent,

                // Browns/Greys
                Colors.brown,
                Colors.grey,
                Colors.blueGrey,

                // Black/White
                Colors.black,
                Colors.white,
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final hexCode = _colorToHex(pickerColor);
                onColorSelected(hexCode);
                Navigator.of(dialogContext).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Select'),
            ),
          ],
        );
      },
    );
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  Color _hexToColor(String hexCode) {
    final hexString = hexCode.replaceAll('#', '');
    return Color(int.parse('FF$hexString', radix: 16));
  }
}
