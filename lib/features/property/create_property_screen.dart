/*import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/property_api.dart';

class CreatePropertyScreen extends StatefulWidget {
  final PropertyApi api;
  const CreatePropertyScreen({super.key, required this.api});

  @override
  State<CreatePropertyScreen> createState() => _CreatePropertyScreenState();
}

class _CreatePropertyScreenState extends State<CreatePropertyScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _price = TextEditingController();
  final _area = TextEditingController();
  final _beds = TextEditingController();
  final _baths = TextEditingController();
  String _ptype = 'apartment';
  String _ltype = 'sale';
  List<File> _images = [];
  int _coverIndex = 0;

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _price.dispose();
    _area.dispose();
    _beds.dispose();
    _baths.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() {
        _images = picked.map((x) => File(x.path)).toList();
        _coverIndex = 0;
      });
    }
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate() || _images.isEmpty) return;
    final body = {
      'title': _title.text.trim(),
      'description': _desc.text.trim(),
      'property_type': _ptype,
      'listing_type': _ltype,
      'price_sar': _price.text.isEmpty ? null : double.tryParse(_price.text),
      'area_sqm': _area.text.isEmpty ? null : double.tryParse(_area.text),
      'bedrooms': _beds.text.isEmpty ? null : int.tryParse(_beds.text),
      'bathrooms': _baths.text.isEmpty ? null : int.tryParse(_baths.text),
    };
    final id = await widget.api.createProperty(body);
    await widget.api.uploadImages(id, _images, coverIndex: _coverIndex);
    await widget.api
        .publishPost(id, hashtags: '#property,#${_ptype},#${_ltype}');
    if (mounted)
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Property posted!')));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Property Ad')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null),
            TextFormField(
                controller: _desc,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3),
            Row(children: [
              Expanded(
                  child: DropdownButtonFormField(
                      items: const [
                    DropdownMenuItem(
                        value: 'apartment', child: Text('Apartment')),
                    DropdownMenuItem(value: 'villa', child: Text('Villa')),
                    DropdownMenuItem(value: 'land', child: Text('Land')),
                    DropdownMenuItem(value: 'shop', child: Text('Shop')),
                    DropdownMenuItem(value: 'office', child: Text('Office')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                      value: _ptype,
                      onChanged: (v) {
                        setState(() => _ptype = v!);
                      },
                      decoration: const InputDecoration(labelText: 'Type'))),
              const SizedBox(width: 12),
              Expanded(
                  child: DropdownButtonFormField(
                      items: const [
                    DropdownMenuItem(value: 'sale', child: Text('Sale')),
                    DropdownMenuItem(value: 'rent', child: Text('Rent')),
                  ],
                      value: _ltype,
                      onChanged: (v) {
                        setState(() => _ltype = v!);
                      },
                      decoration: const InputDecoration(labelText: 'Listing'))),
            ]),
            Row(children: [
              Expanded(
                  child: TextFormField(
                      controller: _price,
                      decoration:
                          const InputDecoration(labelText: 'Price (SAR)'),
                      keyboardType: TextInputType.number)),
              const SizedBox(width: 12),
              Expanded(
                  child: TextFormField(
                      controller: _area,
                      decoration:
                          const InputDecoration(labelText: 'Area (sqm)'),
                      keyboardType: TextInputType.number)),
            ]),
            Row(children: [
              Expanded(
                  child: TextFormField(
                      controller: _beds,
                      decoration: const InputDecoration(labelText: 'Bedrooms'),
                      keyboardType: TextInputType.number)),
              const SizedBox(width: 12),
              Expanded(
                  child: TextFormField(
                      controller: _baths,
                      decoration: const InputDecoration(labelText: 'Bathrooms'),
                      keyboardType: TextInputType.number)),
            ]),
            const SizedBox(height: 16),
            ElevatedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.photo),
                label: const Text('Select Images')),
            if (_images.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(
                    _images.length,
                    (i) => GestureDetector(
                          onTap: () => setState(() => _coverIndex = i),
                          child: Stack(children: [
                            Image.file(_images[i],
                                width: 100, height: 100, fit: BoxFit.cover),
                            if (_coverIndex == i)
                              const Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Icon(Icons.check_circle)),
                          ]),
                        )),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
                onPressed: _submit, child: const Text('Publish Post')),
          ],
        ),
      ),
    );
  }
}*/
import 'package:flutter/material.dart';
import '../../data/api/aqar_api.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart'; // for pickers (or import your utils)
import 'dart:io';

class CreatePropertyScreen extends StatefulWidget {
  final int userId; // pass logged-in user's id
  final String baseUrl; // e.g. http://10.0.2.2:8000 (Android emulator)
  final String? token; // Bearer token if your API is protected

  const CreatePropertyScreen({
    super.key,
    required this.userId,
    required this.baseUrl,
    this.token,
  });

  @override
  State<CreatePropertyScreen> createState() => _CreatePropertyScreenState();
}

class _CreatePropertyScreenState extends State<CreatePropertyScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _price = TextEditingController();
  final _area = TextEditingController();
  final _bed = TextEditingController();
  final _bath = TextEditingController();
  final _city = TextEditingController();
  final _district = TextEditingController();
  final _address = TextEditingController();
  final _desc = TextEditingController();

  String _propertyType = 'apartment';
  String _listingType = 'sale';

  List<String> _images = [];
  String? _video;
  bool _busy = false;

  @override
  void dispose() {
    _title.dispose();
    _price.dispose();
    _area.dispose();
    _bed.dispose();
    _bath.dispose();
    _city.dispose();
    _district.dispose();
    _address.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<List<String>> _pickImages() async {
    final picker = ImagePicker();
    final imgs = await picker.pickMultiImage(imageQuality: 85);
    return imgs.map((x) => x.path).toList();
  }

  Future<String?> _pickVideo() async {
    final res = await FilePicker.platform
        .pickFiles(type: FileType.video, allowMultiple: false);
    return res?.files.single.path;
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;

    setState(() => _busy = true);
    final api = AqarApi(baseUrl: widget.baseUrl, bearerToken: widget.token);

    try {
      // 1) Create property
      final prop = await api.createProperty(
        userId: widget.userId,
        title: _title.text.trim(),
        propertyType: _propertyType,
        listingType: _listingType,
        imagePaths: _images,
        bedrooms: _bed.text.isEmpty ? null : int.tryParse(_bed.text),
        bathrooms: _bath.text.isEmpty ? null : int.tryParse(_bath.text),
        areaSqm: _area.text.isEmpty ? null : double.tryParse(_area.text),
        priceSar: _price.text.isEmpty ? null : double.tryParse(_price.text),
        city: _city.text.trim().isEmpty ? null : _city.text.trim(),
        district: _district.text.trim().isEmpty ? null : _district.text.trim(),
        address: _address.text.trim().isEmpty ? null : _address.text.trim(),
        description: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
      );

      final propId = (prop['property'] as Map)['id'] as int;

      // 2) Create reel linked to this property (optional but recommended)
      if (_video != null) {
        await api.createReelForProperty(
          userId: widget.userId,
          propertyId: propId,
          videoPath: _video!,
          thumbnailPath: _images.isNotEmpty ? _images.first : null,
          description: 'Walkthrough • ${_title.text}',
          hashtags: '#${_propertyType},#${_listingType},#${_city.text}',
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Property published!')),
        );
        Navigator.pop(context, true); // return success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Property')),
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Title *'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: DropdownButtonFormField(
                    value: _propertyType,
                    decoration:
                        const InputDecoration(labelText: 'Property type *'),
                    items: const [
                      DropdownMenuItem(
                          value: 'apartment', child: Text('Apartment')),
                      DropdownMenuItem(value: 'villa', child: Text('Villa')),
                      DropdownMenuItem(value: 'land', child: Text('Land')),
                      DropdownMenuItem(value: 'shop', child: Text('Shop')),
                      DropdownMenuItem(value: 'office', child: Text('Office')),
                      DropdownMenuItem(value: 'other', child: Text('Other')),
                    ],
                    onChanged: (v) =>
                        setState(() => _propertyType = v as String),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField(
                    value: _listingType,
                    decoration:
                        const InputDecoration(labelText: 'Listing type *'),
                    items: const [
                      DropdownMenuItem(value: 'sale', child: Text('Sale')),
                      DropdownMenuItem(value: 'rent', child: Text('Rent')),
                    ],
                    onChanged: (v) =>
                        setState(() => _listingType = v as String),
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _price,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Price (SAR)'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _area,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Area (sqm)'),
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _bed,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Bedrooms'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _bath,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Bathrooms'),
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                    child: TextFormField(
                        controller: _city,
                        decoration: const InputDecoration(labelText: 'City'))),
                const SizedBox(width: 12),
                Expanded(
                    child: TextFormField(
                        controller: _district,
                        decoration:
                            const InputDecoration(labelText: 'District'))),
              ]),
              const SizedBox(height: 8),
              TextFormField(
                  controller: _address,
                  decoration: const InputDecoration(labelText: 'Address')),
              const SizedBox(height: 8),
              TextFormField(
                controller: _desc,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: () async {
                      final picked = await _pickImages();
                      if (!mounted) return;
                      setState(() => _images = picked);
                    },
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Pick Images'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final v = await _pickVideo();
                      if (!mounted) return;
                      setState(() => _video = v);
                    },
                    icon: const Icon(Icons.video_library_outlined),
                    label: Text(_video == null
                        ? 'Pick Video (optional)'
                        : 'Video selected'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_images.isNotEmpty)
                SizedBox(
                  height: 96,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (_, i) => ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        // ignore: deprecated_member_use
                        // You can swap to FileImage(File(_images[i])) as needed
                        // using dart:io in mobile builds.
                        // For brevity in snippet:
                        // use Image.asset placeholder if needed.
                        // Here:
                        // File display omitted to keep it short.
                        // Replace with your own preview widget.
                        // This thumbnail row is optional.
                        // Keep if you like.
                        // Placeholder:
                        // (no-op)
                        // —
                        // simplify: show a container
                        // (remove this whole block if you want)
                        // This line intentionally left minimal.
                        //
                        // In production, use Image.file(File(_images[i]), fit: BoxFit.cover)
                        File(_images[i]),
                        fit: BoxFit.cover,
                      ),
                    ),
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemCount: _images.length,
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: _busy ? null : _submit,
                  child: _busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Publish'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
