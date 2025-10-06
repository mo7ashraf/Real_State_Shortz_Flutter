class Property {
  final int id;
  final String title;
  final String? description;
  final String propertyType; // apartment, villa, ...
  final String listingType; // sale, rent
  final double? priceSar;
  final double? areaSqm;
  final int? bedrooms;
  final int? bathrooms;
  final String? city;
  final String? district;
  final List<String> images;

  Property({
    required this.id,
    required this.title,
    this.description,
    required this.propertyType,
    required this.listingType,
    this.priceSar,
    this.areaSqm,
    this.bedrooms,
    this.bathrooms,
    this.city,
    this.district,
    this.images = const [],
  });

  factory Property.fromJson(Map<String, dynamic> j) {
    final imgs = (j['images'] as List<dynamic>? ?? [])
        .map((e) => e['image_path'] as String)
        .toList();
    return Property(
      id: j['id'] as int,
      title: j['title'] as String,
      description: j['description'] as String?,
      propertyType: j['property_type'] as String,
      listingType: j['listing_type'] as String,
      priceSar: (j['price_sar'] as num?)?.toDouble(),
      areaSqm: (j['area_sqm'] as num?)?.toDouble(),
      bedrooms: j['bedrooms'] as int?,
      bathrooms: j['bathrooms'] as int?,
      city: j['city'] as String?,
      district: j['district'] as String?,
      images: imgs,
    );
  }
}
