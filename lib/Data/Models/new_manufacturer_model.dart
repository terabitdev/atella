class NewManufacturer {
  final String id;
  final String companyName;
  final String country;
  final String? website;
  final String? email;
  final String? instagram;
  final String moq;
  final List<String> products;
  final List<String> certifications;

  NewManufacturer({
    required this.id,
    required this.companyName,
    required this.country,
    this.website,
    this.email,
    this.instagram,
    required this.moq,
    required this.products,
    required this.certifications,
  });

  factory NewManufacturer.fromJson(Map<String, dynamic> json) {
    return NewManufacturer(
      id: json['id'] ?? '',
      companyName: json['companyName'] ?? json['COMPANY NAME'] ?? '',
      country: json['country'] ?? json['COUNTRY'] ?? '',
      website: json['website'] ?? json['WEBSITE'],
      email: json['email'] ?? json['EMAIL'],
      instagram: json['instagram'] ?? json['INSTAGRAM'],
      moq: json['moq'] ?? json['MOQ'] ?? 'Contact manufacturer for MOQ',
      products: _parseStringList(json['products'] ?? json['PRODUCT THEY MAKE & CAPABILITIES']),
      certifications: _parseStringList(json['certifications'] ?? json['CERTIFICATION']),
    );
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    if (value is String) {
      return [value];
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyName': companyName,
      'country': country,
      'website': website,
      'email': email,
      'instagram': instagram,
      'moq': moq,
      'products': products,
      'certifications': certifications,
    };
  }

  // Helper getters for display
  String get productsDisplay => products.join(', ');
  String get certificationsDisplay => certifications.isNotEmpty
      ? certifications.join(', ')
      : 'No certifications';

  bool get hasCertifications => certifications.isNotEmpty;
  bool get hasInstagram => instagram != null && instagram!.isNotEmpty;
  bool get hasWebsite => website != null && website!.isNotEmpty;
  bool get hasEmail => email != null && email!.isNotEmpty;

  // MOQ category helpers
  bool get isLowMOQ => moq.toLowerCase().contains('low') || moq.toLowerCase().contains('less than 100');
  bool get isMediumMOQ => moq.toLowerCase().contains('medium');
  bool get isHighMOQ => moq.toLowerCase().contains('high');
  bool get isContactForMOQ => moq.toLowerCase().contains('contact');
}
