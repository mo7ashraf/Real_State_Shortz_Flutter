import 'dart:io';
import 'package:http/http.dart' as http;

class PropertyApi {
  final String baseUrl;
  final String token;
  PropertyApi(this.baseUrl, this.token);

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  Future<int> createProperty(Map<String, dynamic> body) async {
    final r = await http.post(
      Uri.parse('$baseUrl/api/properties'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: body..removeWhere((k, v) => v == null),
    );
    if (r.statusCode != 201) throw Exception(r.body);
    final id = (r.body.contains('"property"'))
        ? int.parse(RegExp(r'"id":\\s*(\\d+)').firstMatch(r.body)!.group(1)!)
        : throw Exception('No id returned');
    return id;
  }

  Future<void> uploadImages(int propertyId, List<File> images,
      {int coverIndex = 0}) async {
    final req = http.MultipartRequest(
        'POST', Uri.parse('$baseUrl/api/properties/$propertyId/images'));
    req.headers.addAll(_headers);
    for (var i = 0; i < images.length; i++) {
      req.files
          .add(await http.MultipartFile.fromPath('images[$i]', images[i].path));
    }
    req.fields['cover_index'] = coverIndex.toString();
    final res = await req.send();
    if (res.statusCode != 200)
      throw Exception('Upload failed: ${res.statusCode}');
  }

  Future<void> publishPost(int propertyId, {String? hashtags}) async {
    final req = await http.post(
        Uri.parse('$baseUrl/api/properties/$propertyId/publish-post'),
        headers: _headers,
        body: hashtags != null ? {'hashtags': hashtags} : null);
    if (req.statusCode != 201) {
      throw Exception(req.body);
    }
  }

  Future<void> addReel(int propertyId, File video,
      {File? thumbnail, String? description, String? hashtags}) async {
    final req = http.MultipartRequest(
        'POST', Uri.parse('$baseUrl/api/properties/$propertyId/reels'));
    req.headers.addAll(_headers);
    req.files.add(await http.MultipartFile.fromPath('video', video.path));
    if (thumbnail != null) {
      req.files
          .add(await http.MultipartFile.fromPath('thumbnail', thumbnail.path));
    }
    if (description != null) req.fields['description'] = description;
    if (hashtags != null) req.fields['hashtags'] = hashtags;
    final res = await req.send();
    if (res.statusCode != 201)
      throw Exception('Reel failed: ${res.statusCode}');
  }
}
