import 'package:get/get.dart';

class TechPackController extends GetxController {
  var isLoading = true.obs;

  final List<String> generatedImages = [
    'assets/images/grid1.png',
    'assets/images/grid2.png',
    'assets/images/grid3.png',
  ];

  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(seconds: 3), () {
      isLoading.value = false;
    });
  }
}
