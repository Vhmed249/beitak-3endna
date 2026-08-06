import 'dart:io';
import 'package:flutter/material.dart';
import '../models/property_model.dart';
import '../utils/constants.dart';

class PreviewPropertyScreen extends StatefulWidget {
  final Property property;
  final List<File> images;
  final VoidCallback onPublish;

  const PreviewPropertyScreen({
    super.key,
    required this.property,
    required this.images,
    required this.onPublish,
  });

  @override
  State<PreviewPropertyScreen> createState() => _PreviewPropertyScreenState();
}

class _PreviewPropertyScreenState extends State<PreviewPropertyScreen> {
  bool _publishing = false;

  void _publish() {
    if (_publishing) return;

    setState(() {
      _publishing = true;
    });

    Navigator.pop(context);

    widget.onPublish();
  }

  @override
  Widget build(BuildContext context) {
    final property = widget.property;

    return Scaffold(
      appBar: AppBar(
        title: const Text('معاينة العقار'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  SizedBox(
                    height: 220,

                    child: widget.images.isEmpty
                        ? Container(
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Center(
                              child: Icon(Icons.home, size: 70),
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,

                            itemCount: widget.images.length,

                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),

                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),

                                  child: Image.file(
                                    widget.images[index],
                                    width: 220,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    property.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    '${property.price.toStringAsFixed(0)} ج.س',
                    style: TextStyle(
                      fontSize: 20,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  _infoRow(Icons.location_on, property.address),

                  _infoRow(Icons.location_city, property.city),

                  _infoRow(Icons.category, 'نوع العقار: ${property.category}'),

                  _infoRow(
                    Icons.home_work,
                    'نوع الإيجار: ${property.rentType}',
                  ),

                  if (property.neighborhood != null &&
                      property.neighborhood!.isNotEmpty)
                    _infoRow(Icons.map, 'الحي: ${property.neighborhood}'),

                  _infoRow(Icons.phone, 'الهاتف: ${property.phone}'),

                  _infoRow(Icons.chat, 'واتساب: ${property.whatsapp}'),

                  const SizedBox(height: 15),

                  Wrap(
                    spacing: 8,

                    children: [
                      Chip(label: Text('${property.rooms} غرف')),

                      Chip(label: Text('${property.size} م²')),

                      Chip(label: Text('طابق ${property.floor}')),

                      Chip(label: Text(property.furnished)),
                    ],
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    "الوصف",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 5),

                  Text(property.description),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),

            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),

                    onPressed: () {
                      Navigator.pop(context);
                    },

                    child: const Text('رجوع للتعديل'),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),

                    onPressed: _publishing ? null : _publish,

                    child: _publishing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'نشر العقار',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),

      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),

          const SizedBox(width: 8),

          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
