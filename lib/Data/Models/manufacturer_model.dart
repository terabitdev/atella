class Manufacturer {
  final String name;
  final String location;
  final String? phoneNumber;
  final String? email;
  final String? website;
  final String country;

  Manufacturer({
    required this.name,
    required this.location,
    required this.country,
    this.phoneNumber,
    this.email,
    this.website,
  });

  factory Manufacturer.fromJson(Map<String, dynamic> json) {
    return Manufacturer(
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      country: json['country'] ?? '',
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      website: json['website'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'location': location,
      'country': country,
      'phoneNumber': phoneNumber,
      'email': email,
      'website': website,
    };
  }
}