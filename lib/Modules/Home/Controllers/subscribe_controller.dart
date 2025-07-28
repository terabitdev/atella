import 'package:get/get.dart';

class SubscribeController extends GetxController {
  RxString selectedPlan = 'annual'.obs;

  void selectPlan(String plan) {
    selectedPlan.value = plan;
  }
}
