import 'package:atella/Data/Models/new_manufacturer_model.dart';

/// Extended manufacturer model with translated fields for French locale
class TranslatedManufacturer extends NewManufacturer {
  final String translatedMoq;
  final List<String> translatedProducts;

  TranslatedManufacturer({
    required super.id,
    required super.companyName,
    required super.country,
    super.website,
    super.email,
    super.instagram,
    required super.moq,
    required super.products,
    required super.certifications,
    required this.translatedMoq,
    required this.translatedProducts,
  });

  /// Create from a NewManufacturer with translations
  factory TranslatedManufacturer.fromManufacturer(
    NewManufacturer manufacturer, {
    required String translatedMoq,
    required List<String> translatedProducts,
  }) {
    return TranslatedManufacturer(
      id: manufacturer.id,
      companyName: manufacturer.companyName,
      country: manufacturer.country,
      website: manufacturer.website,
      email: manufacturer.email,
      instagram: manufacturer.instagram,
      moq: manufacturer.moq,
      products: manufacturer.products,
      certifications: manufacturer.certifications,
      translatedMoq: translatedMoq,
      translatedProducts: translatedProducts,
    );
  }

  /// Get the appropriate MOQ based on locale
  String getMoq(String locale) {
    return locale == 'fr' ? translatedMoq : moq;
  }

  /// Get the appropriate products list based on locale
  List<String> getProducts(String locale) {
    return locale == 'fr' ? translatedProducts : products;
  }

  /// Get the appropriate products display based on locale
  String getProductsDisplay(String locale) {
    final productsList = getProducts(locale);
    return productsList.join(', ');
  }
}