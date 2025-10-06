import 'dart:io';
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
}
