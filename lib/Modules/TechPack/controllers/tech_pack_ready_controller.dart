import 'package:get/get.dart';
import 'tech_pack_details_controller.dart';

class TechPackReadyController extends GetxController {
  final TechPackDetailsController _detailsController = Get.find<TechPackDetailsController>();
  
  List<String> get generatedImages => _detailsController.generatedTechPackImages;
  
  String get selectedDesignImage => _detailsController.selectedDesignImagePath.value;
  
  bool get isGenerating => _detailsController.isGeneratingTechPack.value;
  
  RxInt selectedImageIndex = 0.obs;
  
  void selectImage(int index) {
    selectedImageIndex.value = index;
  }
  
  bool get hasGeneratedImages => generatedImages.isNotEmpty;
  
  String? get currentSelectedImage {
    if (hasGeneratedImages && selectedImageIndex.value < generatedImages.length) {
      return generatedImages[selectedImageIndex.value];
    }
    return null;
  }
  
  String get techPackSummary {
    return '''
Materials: ${_detailsController.mainFabricController.text}
Colors: ${_detailsController.primaryColorController.text}
Sizes: ${_detailsController.sizeRangeController.text}
Quantity: ${_detailsController.quantityController.text}
Target Cost: ${_detailsController.costPerPieceController.text}
Delivery: ${_detailsController.deliveryDateController.text}
    ''';
  }
}