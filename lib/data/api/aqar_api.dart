import 'dart:convert';
import 'package:http/http.dart' as http;

class AqarApi {
  final String baseUrl;
  final String? bearerToken; // optional

  AqarApi({required this.baseUrl, this.bearerToken});

  // Build an API root that tolerates baseUrl with or without trailing '/api'
  String _apiJoin(String segment) {
    final root = baseUrl.replaceAll(RegExp(r'/+$'), '');
    if (root.endsWith('/api')) {
      return '$root$segment';
    }
    return '$root/api$segment';
  }

  Map<String, String> _headers() => {
        'Accept': 'application/json',
        if (bearerToken != null && bearerToken!.isNotEmpty)
          'Authorization': 'Bearer $bearerToken',
      };

  Future<Map<String, dynamic>> createProperty({
    required int userId, // remove if backend uses auth()->id()
    required String title,
    required String propertyType, // apartment|villa|land|shop|office|other
    required String listingType, // sale|rent
    List<String> imagePaths = const [],
    int? bedrooms,
    int? bathrooms,
    double? areaSqm,
    double? priceSar,
    String? city,
    String? district,
    String? address,
    String? description,
  }) async {
    final url = _apiJoin('/properties');
    final uri = Uri.parse(url);
    final req = http.MultipartRequest('POST', uri)..headers.addAll(_headers());

    req.fields.addAll({
      'user_id': '$userId',
      'title': title,
      'property_type': propertyType,
      'listing_type': listingType,
      if (bedrooms != null) 'bedrooms': '$bedrooms',
      if (bathrooms != null) 'bathrooms': '$bathrooms',
      if (areaSqm != null) 'area_sqm': '$areaSqm',
      if (priceSar != null) 'price_sar': '$priceSar',
      if (city != null) 'city': city!,
      if (district != null) 'district': district!,
      if (address != null) 'address': address!,
      if (description != null) 'description': description!,
    });

    for (final p in imagePaths) {
      req.files.add(await http.MultipartFile.fromPath('images[]', p));
    }

    final res = await req.send();
    final body = await res.stream.bytesToString();
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return json.decode(body) as Map<String, dynamic>;
    }
    throw Exception('Create property failed: ${res.statusCode} $body');
  }

  Future<Map<String, dynamic>> createReelForProperty({
    required int userId,
    required int propertyId,
    required String videoPath,
    String? thumbnailPath,
    String? description,
    String? hashtags, // "#villa,#sale"
  }) async {
    final url = _apiJoin('/reels');
    final uri = Uri.parse(url);
    final req = http.MultipartRequest('POST', uri)..headers.addAll(_headers());

    req.fields.addAll({
      'user_id': '$userId',
      'property_id': '$propertyId',
      if (description != null) 'description': description!,
      if (hashtags != null) 'hashtags': hashtags!,
    });

    req.files.add(await http.MultipartFile.fromPath('video', videoPath));
    if (thumbnailPath != null) {
      req.files
          .add(await http.MultipartFile.fromPath('thumbnail', thumbnailPath));
    }

    final res = await req.send();
    final body = await res.stream.bytesToString();
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return json.decode(body) as Map<String, dynamic>;
    }
    throw Exception('Create reel failed: ${res.statusCode} $body');
  }
}
