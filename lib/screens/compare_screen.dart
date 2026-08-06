import 'package:flutter/material.dart';
import '../models/property_model.dart';
import '../utils/constants.dart';

class CompareScreen extends StatelessWidget {
  final Property property1;
  final Property property2;

  const CompareScreen({
    super.key,
    required this.property1,
    required this.property2,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مقارنة العقارات'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // الصور
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: property1.imageUrls.isNotEmpty
                        ? Image.network(
                            property1.imageUrls.first,
                            height: 150,
                            fit: BoxFit.cover,
                          )
                        : Container(height: 150, color: Colors.grey[300]),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: property2.imageUrls.isNotEmpty
                        ? Image.network(
                            property2.imageUrls.first,
                            height: 150,
                            fit: BoxFit.cover,
                          )
                        : Container(height: 150, color: Colors.grey[300]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // جدول المقارنة
            _compareRow(
              'السعر',
              '${property1.price} ج.س',
              '${property2.price} ج.س',
            ),
            _compareRow('العنوان', property1.title, property2.title),
            _compareRow('المدينة', property1.city, property2.city),
            _compareRow('نوع العقار', property1.category, property2.category),
            _compareRow('نوع الإيجار', property1.rentType, property2.rentType),
            _compareRow(
              'عدد الغرف',
              property1.rooms.toString(),
              property2.rooms.toString(),
            ),
            _compareRow(
              'المساحة',
              '${property1.size} م²',
              '${property2.size} م²',
            ),
            _compareRow(
              'الطابق',
              property1.floor.toString(),
              property2.floor.toString(),
            ),
            _compareRow('المفروشات', property1.furnished, property2.furnished),
            _compareRow(
              'التقييم',
              property1.rating?.toStringAsFixed(1) ?? 'لا يوجد',
              property2.rating?.toStringAsFixed(1) ?? 'لا يوجد',
            ),
            _compareRow(
              'المشاهدات',
              property1.views.toString(),
              property2.views.toString(),
            ),
            const SizedBox(height: 16),
            // وصف العقارين
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'وصف ${property1.title}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(property1.description),
                  const SizedBox(height: 8),
                  Text(
                    'وصف ${property2.title}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(property2.description),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _compareRow(String label, String value1, String value2) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value1,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.primary),
            ),
          ),
          Expanded(
            child: Text(
              value2,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.secondary),
            ),
          ),
        ],
      ),
    );
  }
}
