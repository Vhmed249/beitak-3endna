import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../models/property_model.dart';
import '../utils/constants.dart';
import '../providers/app_provider.dart';
import 'preview_property_screen.dart';

class AddPropertyScreen extends StatefulWidget {
  final Property? property;
  const AddPropertyScreen({super.key, this.property});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController();
  final _roomsController = TextEditingController();
  final _sizeController = TextEditingController();
  final _floorController = TextEditingController();
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();

  String? _selectedState;
  String? _selectedCity;
  String? _selectedNeighborhood;
  String? _selectedCategory;
  String? _selectedRentType;
  String? _selectedFurnished;
  List<File> _selectedImages = [];
  bool _isLoading = false;

  double _latitude = 0.0;
  double _longitude = 0.0;
  String _locationStatus = 'لم يتم تحديد الموقع';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    if (widget.property != null) {
      _titleController.text = widget.property!.title;
      _descController.text = widget.property!.description;
      _addressController.text = widget.property!.address;
      _priceController.text = widget.property!.price.toString();
      _roomsController.text = widget.property!.rooms.toString();
      _sizeController.text = widget.property!.size.toString();
      _floorController.text = widget.property!.floor.toString();
      _phoneController.text = widget.property!.phone;
      _whatsappController.text = widget.property!.whatsapp;
      _selectedCategory = widget.property!.category;
      _selectedCity = widget.property!.city;
      _selectedRentType = widget.property!.rentType;
      _selectedFurnished = widget.property!.furnished;
      _latitude = widget.property!.latitude;
      _longitude = widget.property!.longitude;
      _locationStatus = '✅ تم تحديد موقع العقار';
    }
  }

  Future<void> _getCurrentLocation() async {
    if (widget.property != null) return;
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _locationStatus = 'الخدمات الموقعية مغلقة');
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _locationStatus =
            '✅ تم تحديد موقعك (${_latitude.toStringAsFixed(4)}, ${_longitude.toStringAsFixed(4)})';
      });
    } else {
      setState(() => _locationStatus = '❌ تم رفض صلاحية الموقع');
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final List<XFile>? picked = await picker.pickMultiImage();
    if (picked != null) {
      if (picked.length > 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يمكنك اختيار 10 صور كحد أقصى')),
        );
        return;
      }
      setState(() {
        _selectedImages = picked.map((e) => File(e.path)).toList();
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedState == null ||
        _selectedCity == null ||
        _selectedCategory == null ||
        _selectedRentType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار جميع القوائم المنسدلة')),
      );
      return;
    }
    if (_selectedImages.isEmpty && widget.property == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار صورة واحدة على الأقل')),
      );
      return;
    }

    if (_phoneController.text.isEmpty || _whatsappController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال رقم الهاتف ورقم واتساب')),
      );
      return;
    }

    final fullAddress = _selectedNeighborhood != null
        ? '${_selectedNeighborhood!}، ${_selectedCity!}، ${_selectedState!}'
        : '${_selectedCity!}، ${_selectedState!}';

    final property = Property(
      userId: FirebaseAuth.instance.currentUser?.uid ?? '',
      title: _titleController.text,
      description: _descController.text,
      address: _addressController.text.isNotEmpty
          ? _addressController.text
          : fullAddress,
      price: double.parse(_priceController.text),
      rentType: _selectedRentType ?? 'شهري',
      category: _selectedCategory ?? 'شقة',
      city: _selectedCity!,
      latitude: _latitude,
      longitude: _longitude,
      imageUrls: widget.property?.imageUrls ?? [],
      phone: _phoneController.text.replaceAll(RegExp(r'\s+'), '').trim(),
      whatsapp: _whatsappController.text.replaceAll(RegExp(r'\s+'), '').trim(),
      rooms: int.tryParse(_roomsController.text) ?? 1,
      size: double.tryParse(_sizeController.text) ?? 0,
      floor: int.tryParse(_floorController.text) ?? 0,
      furnished: _selectedFurnished ?? 'غير مفروش',
      status: 'pending',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PreviewPropertyScreen(
          property: property,
          images: _selectedImages,
          onPublish: () async {
            setState(() => _isLoading = true);
            try {
              final service = Provider.of<AppProvider>(
                context,
                listen: false,
              ).propertyService;
              if (widget.property != null) {
                await service.deleteProperty(widget.property!.id!);
              }
              await service.addProperty(property, _selectedImages);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ تم النشر بنجاح!'),
                    backgroundColor: AppColors.secondary,
                  ),
                );
                Navigator.pop(context);
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('❌ فشل النشر: $e')),
                );
              }
            }
            setState(() => _isLoading = false);
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _roomsController.dispose();
    _sizeController.dispose();
    _floorController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cities = _selectedState != null
        ? AppConstants.getCities(_selectedState!)
        : [];
    final neighborhoods = (_selectedState != null && _selectedCity != null)
        ? AppConstants.getNeighborhoods(_selectedState!, _selectedCity!)
        : [];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.property != null ? 'تعديل الإعلان' : 'إضافة إعلان جديد',
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                maxLength: 100,
                decoration: const InputDecoration(labelText: 'عنوان العقار *'),
                validator: (v) => v!.isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                maxLength: 500,
                decoration: const InputDecoration(labelText: 'الوصف *'),
                validator: (v) => v!.isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _addressController,
                maxLength: 200,
                decoration: const InputDecoration(
                  labelText: 'العنوان التفصيلي (اختياري)',
                  prefixIcon: Icon(
                    Icons.location_city,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'السعر (جنيه) *'),
                validator: (v) => v!.isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _roomsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'عدد الغرف'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _sizeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'المساحة (م²)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _floorController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'الطابق'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'المفروشات'),
                      value: _selectedFurnished,
                      items: ['مفروش', 'غير مفروش', 'نصف مفروش']
                          .map(
                            (f) => DropdownMenuItem<String>(
                              value: f,
                              child: Text(f),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedFurnished = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // حقول التواصل
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'رقم الهاتف *'),
                      validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _whatsappController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'رقم واتساب *'),
                      validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'الولاية *'),
                value: _selectedState,
                items: AppConstants.states
.map(
                      (s) => DropdownMenuItem<String>(value: s, child: Text(s)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedState = value;
                    _selectedCity = null;
                    _selectedNeighborhood = null;
                  });
                },
                validator: (v) => v == null ? 'اختر ولاية' : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'المدينة *'),
                value: _selectedCity,
                items: cities
                    .map(
                      (c) => DropdownMenuItem<String>(value: c, child: Text(c)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCity = value;
                    _selectedNeighborhood = null;
                  });
                },
                validator: (v) => v == null ? 'اختر مدينة' : null,
              ),
              const SizedBox(height: 10),
              if (neighborhoods.isNotEmpty)
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'الحي (اختياري)'),
                  value: _selectedNeighborhood,
                  items: neighborhoods
                      .map(
                        (n) =>
                            DropdownMenuItem<String>(value: n, child: Text(n)),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedNeighborhood = value),
                ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'نوع العقار *'),
                value: _selectedCategory,
                items: AppConstants.categories
                    .map(
                      (c) => DropdownMenuItem<String>(value: c, child: Text(c)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v),
                validator: (v) => v == null ? 'اختر نوعاً' : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'نوع الإيجار *'),
                value: _selectedRentType,
                items: AppConstants.rentTypes
                    .map(
                      (r) => DropdownMenuItem<String>(value: r, child: Text(r)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedRentType = v),
                validator: (v) => v == null ? 'اختر نوعاً' : null,
              ),
              const SizedBox(height: 20),
              if (widget.property == null)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: _pickImages,
                  icon: const Icon(Icons.photo_library, color: AppColors.white),
                  label: Text(
                    _selectedImages.isEmpty
                        ? 'اختر الصور (حتى 10)'
                        : '✅ ${_selectedImages.length} صورة',
                    style: const TextStyle(color: AppColors.white, fontSize: 16),
                  ),
                ),
              if (_selectedImages.isNotEmpty)
                Container(
                  height: 80,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length,
                    itemBuilder: (ctx, i) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Image.file(
                        _selectedImages[i],
                        width: 70,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.gps_fixed, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(child: Text(_locationStatus)),
                    if (widget.property == null)
                      IconButton(
                        icon: const Icon(Icons.refresh, color: AppColors.primary),
                        onPressed: _getCurrentLocation,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const CircularProgressIndicator(color: AppColors.white)
                    : Text(
                        widget.property != null
                            ? 'تعديل الإعلان'
                            : 'إضافة الإعلان',
                        style: const TextStyle(color: AppColors.white, fontSize: 20),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
