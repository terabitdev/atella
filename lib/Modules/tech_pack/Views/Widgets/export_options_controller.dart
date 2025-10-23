import 'package:get/get.dart';

class ExportOptionsController extends GetxController {
  final RxBool pdfWithLogo = true.obs;
  final RxBool neutralPdf = false.obs;

  void selectPdfWithLogo() {
    pdfWithLogo.value = true;
    neutralPdf.value = false;
  }

  void selectNeutralPdf() {
    pdfWithLogo.value = false;
    neutralPdf.value = true;
  }

  bool get shouldExportWithLogo => pdfWithLogo.value;
}
