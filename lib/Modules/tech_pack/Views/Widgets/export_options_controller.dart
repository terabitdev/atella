import 'package:get/get.dart';

enum ExportType { pdfWithLogo, neutralPdf, word }

class ExportOptionsController extends GetxController {
  final Rx<ExportType> selectedExportType = ExportType.pdfWithLogo.obs;

  void selectPdfWithLogo() {
    selectedExportType.value = ExportType.pdfWithLogo;
  }

  void selectNeutralPdf() {
    selectedExportType.value = ExportType.neutralPdf;
  }

  void selectWord() {
    selectedExportType.value = ExportType.word;
  }

  bool get isPdfWithLogo => selectedExportType.value == ExportType.pdfWithLogo;
  bool get isNeutralPdf => selectedExportType.value == ExportType.neutralPdf;
  bool get isWord => selectedExportType.value == ExportType.word;

  bool get shouldExportWithLogo => isPdfWithLogo;
}
