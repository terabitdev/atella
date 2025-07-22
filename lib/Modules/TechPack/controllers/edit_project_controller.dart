import 'package:get/get.dart';
import 'package:flutter/material.dart';

class EditProjectController extends GetxController {
  // Mock data for dropdowns
  final clothingTypes = ['T-shirt', 'Shirt', 'Pants', 'Dress', 'Jacket'];
  final styles = ['Casual', 'Luxury', 'Sport', 'Formal'];
  final audiences = ['Male', 'Female', 'Unisex', 'Kids'];
  final seasons = ['Spring', 'Summer', 'Autumn', 'Winter'];
  final materials = ['Organic jersey fabric', 'Cotton', 'Polyester', 'Wool'];
  final sizeRanges = ['Small', 'Medium', 'Large', 'XL', 'XXL'];
  final stitching = ['Double needle stitching', 'Single needle', 'Overlock'];
  final labels = ['Printed size label only', 'Woven label', 'No label'];
  final packing = ['Folded with tissue, in polybag', 'Boxed', 'Hanger'];
  final moqs = ['50 pcs', '100 pcs', '200 pcs', '500 pcs'];
  final deadlines = ['4 weeks', '6 weeks', '8 weeks'];
  final functionals = ['Pockets', 'Zippers', 'Buttons', 'None'];

  // State
  final projectNameController = TextEditingController(text: 'Abc');
  final RxString clothingType = 'T-shirt'.obs;
  final RxString style = 'Casual'.obs; // ✅ FIXED: Removed extra comma
  final RxString audience = 'Male'.obs;
  final RxString season = 'Spring'.obs;
  final RxString material = 'Organic jersey fabric'.obs;
  final RxString functional = 'Pockets'.obs;
  final RxString color = 'Neutral'.obs;
  final RxString sizeRange = 'Small'.obs;
  final RxString stitchingType = 'Double needle stitching'.obs;
  final RxString label = 'Printed size label only'.obs;
  final RxString packingType = 'Folded with tissue, in polybag'.obs;
  final RxString moq = '50 pcs'.obs;
  final RxString deadline = '4 weeks'.obs;

  // Image paths (mock)
  final RxString inspirationImageUrl =
      'https://images.unsplash.com/photo-1512436991641-6745cdb1723f?auto=format&fit=crop&w=400&q=80'
          .obs;
  final RxString colorImageUrl =
      'https://images.unsplash.com/photo-1512436991641-6745cdb1723f?auto=format&fit=crop&w=400&q=80'
          .obs;

  @override
  void onClose() {
    projectNameController.dispose();
    super.onClose();
  }
}
