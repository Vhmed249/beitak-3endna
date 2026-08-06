import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import '../models/property_model.dart';

class PropertyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ============================================================
  // ضغط الصور
  // ============================================================
  Future<File> compressImage(File file) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath =
          '${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 65,
        minWidth: 1000,
        minHeight: 600,
      );
      if (result == null) {
        debugPrint('⚠️ فشل ضغط الصورة، استخدام الصورة الأصلية');
        return file;
      }
      final compressedFile = File(result.path);
      debugPrint('✅ تم ضغط الصورة بنجاح');
      return compressedFile;
    } catch (e) {
      debugPrint('❌ خطأ في ضغط الصورة: $e');
      return file;
    }
  }

  // ============================================================
  // إضافة عقار
  // ============================================================
  Future<void> addProperty(Property property, List<File> imageFiles) async {
    if (imageFiles.isEmpty) {
      throw Exception('يجب إضافة صورة واحدة على الأقل');
    }
    if (imageFiles.length > 10) {
      throw Exception('الحد الأقصى للصور هو 10 صور');
    }
    
    try {
      List<String> urls = [];
      for (int i = 0; i < imageFiles.length; i++) {
        debugPrint('⏳ رفع الصورة ${i + 1}/${imageFiles.length}');
        final compressed = await compressImage(imageFiles[i]);
        final ref = _storage.ref().child(
          'properties/${property.userId}/${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
        );
        await ref.putFile(compressed);
        final url = await ref.getDownloadURL();
        urls.add(url);
        debugPrint('✅ تم رفع الصورة ${i + 1}');
      }
      
      property.imageUrls = urls;
      await _firestore.collection('properties').add({
        ...property.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ تم إضافة العقار بنجاح');
    } catch (e) {
      debugPrint('❌ خطأ في إضافة العقار: $e');
      throw Exception('فشل إضافة العقار: ${e.toString()}');
    }
  }

  // ============================================================
  // جلب جميع العقارات (المقبولة فقط)
  // ============================================================
  Stream<List<Property>> getProperties() {
    try {
      return _firestore
          .collection('properties')
          .where('status', isEqualTo: 'approved')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map(
                  (doc) => Property.fromMap(
                    doc.id,
                    doc.data(),
                  ),
                )
                .toList(),
          );
    } catch (e) {
      debugPrint('❌ خطأ في جلب العقارات: $e');
      return Stream.value([]);
    }
  }

  // ============================================================
  // جلب العقارات المميزة
  // ============================================================
  Stream<List<Property>> getFeaturedProperties() {
    try {
      return _firestore
          .collection('properties')
          .where('status', isEqualTo: 'approved')
          .where('isFeatured', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(5)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map(
                  (doc) => Property.fromMap(
                    doc.id,
                    doc.data(),
                  ),
                )
                .toList(),
          );
    } catch (e) {
      debugPrint('❌ خطأ في جلب العقارات المميزة: $e');
      return Stream.value([]);
    }
  }

  // ============================================================
  // جلب عقارات مستخدم معين
  // ============================================================
  Stream<List<Property>> getUserProperties(String userId) {
    try {
      return _firestore
          .collection('properties')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map(
                  (doc) => Property.fromMap(
                    doc.id,
                    doc.data(),
                  ),
                )
                .toList(),
          );
    } catch (e) {
      debugPrint('❌ خطأ في جلب عقارات المستخدم: $e');
      return Stream.value([]);
    }
  }

  // ============================================================
  // البحث المتقدم (جميع الفلاتر)
  // ============================================================
  Stream<List<Property>> searchProperties({
    String? city,
    String? category,
    String? rentType,
    double? minPrice,
    double? maxPrice,
    int? minRooms,
    int? maxRooms,
    double? minSize,
    double? maxSize,
    bool? isPremium,
    bool? isVerified,
    String? furnished,
    String? neighborhood,
    String? sortBy,
  }) {
    try {
      Query query = _firestore
          .collection('properties')
          .where('status', isEqualTo: 'approved');

      if (city != null && city.isNotEmpty) {
        query = query.where('city', isEqualTo: city);
      }
      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }
      if (rentType != null && rentType.isNotEmpty) {
        query = query.where('rentType', isEqualTo: rentType);
      }
      if (minPrice != null) {
        query = query.where('price', isGreaterThanOrEqualTo: minPrice);
      }
      if (maxPrice != null) {
        query = query.where('price', isLessThanOrEqualTo: maxPrice);
      }
      if (minRooms != null) {
        query = query.where('rooms', isGreaterThanOrEqualTo: minRooms);
      }
      if (maxRooms != null) {
        query = query.where('rooms', isLessThanOrEqualTo: maxRooms);
      }
      if (minSize != null) {
        query = query.where('size', isGreaterThanOrEqualTo: minSize);
      }
      if (maxSize != null) {
        query = query.where('size', isLessThanOrEqualTo: maxSize);
      }
      if (isPremium != null) {
        query = query.where('isPremium', isEqualTo: isPremium);
      }
      if (furnished != null && furnished.isNotEmpty) {
        query = query.where('furnished', isEqualTo: furnished);
      }

      if (neighborhood != null && neighborhood.isNotEmpty) {
        query = query.where('neighborhood', isEqualTo: neighborhood);
      }

      switch (sortBy) {
        case 'price_asc':
          query = query.orderBy('price', descending: false);
          break;
        case 'price_desc':
          query = query.orderBy('price', descending: true);
          break;
        case 'views':
          query = query.orderBy('views', descending: true);
          break;
        case 'favorites':
          query = query.orderBy('favoritesCount', descending: true);
          break;
        default:
          query = query.orderBy('createdAt', descending: true);
      }

      return query.snapshots().map(
        (snapshot) => snapshot.docs
            .map(
              (doc) =>
                  Property.fromMap(
                  doc.id,
                  Map<String, dynamic>.from(
                    doc.data() as Map<String, dynamic>,
                  ),
                ),
            )
            .toList(),
      );
    } catch (e) {
      debugPrint('❌ خطأ في البحث: $e');
      return Stream.value([]);
    }
  }

  // ============================================================
  // جلب عقار واحد بالمعرف
  // ============================================================
  Future<Property?> getPropertyById(String id) async {
    try {
      final doc = await _firestore.collection('properties').doc(id).get();
      if (doc.exists) {
        return Property.fromMap(
                  doc.id,
                  Map<String, dynamic>.from(
                    doc.data() as Map<String, dynamic>,
                  ),
                );
      }
      return null;
    } catch (e) {
      debugPrint('❌ خطأ في جلب العقار: $e');
      return null;
    }
  }

  // ============================================================
  // تحديث عقار
  // ============================================================
  Future<void> updateProperty(Property property) async {
    try {
      if (property.id == null || property.id!.isEmpty) {
        throw Exception('معرف العقار مفقود');
      }
      await _firestore
          .collection('properties')
          .doc(property.id)
          .update(property.toMap());
      debugPrint('✅ تم تحديث العقار بنجاح');
    } catch (e) {
      debugPrint('❌ خطأ في تحديث العقار: $e');
      throw Exception('فشل تحديث العقار');
    }
  }

  // ============================================================
  // حذف عقار
  // ============================================================
  Future<void> deleteProperty(String id) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception('يجب تسجيل الدخول');
      }

      final doc = await _firestore.collection('properties').doc(id).get();

      if (!doc.exists) {
        throw Exception('العقار غير موجود');
      }

      final data = Map<String, dynamic>.from(
                    doc.data() as Map<String, dynamic>,
                  );
      final ownerId = data['userId'];

      // التحقق من الصلاحيات
      if (ownerId != currentUser.uid) {
        // التحقق من كون المستخدم مدير
        final userDoc =
            await _firestore.collection('users').doc(currentUser.uid).get();
        final isAdmin = userDoc.data()?['isAdmin'] ?? false;
        
        if (!isAdmin) {
          throw Exception('لا تملك صلاحية حذف هذا العقار');
        }
      }

      // حذف الصور من Storage
      final imageUrls = List<String>.from(data['imageUrls'] ?? []);
      for (String url in imageUrls) {
        try {
          final ref = _storage.refFromURL(url);
          await ref.delete();
          debugPrint('✅ تم حذف صورة');
        } catch (e) {
          debugPrint('⚠️ فشل حذف صورة: $e');
        }
      }

      // حذف العقار من Firestore
      await _firestore.collection('properties').doc(id).delete();
      debugPrint('✅ تم حذف العقار بنجاح');
    } catch (e) {
      debugPrint('❌ خطأ في حذف العقار: $e');
      rethrow;
    }
  }

  // ============================================================
  // زيادة عدد المشاهدات
  // ============================================================
  Future<void> incrementViews(String id) async {
    try {
      await _firestore.collection('properties').doc(id).update({
        'views': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('⚠️ فشل تحديث المشاهدات: $e');
    }
  }

  // ============================================================
  // زيادة عدد المفضلات
  // ============================================================
  Future<void> incrementFavorites(String id, int value) async {
    try {
      await _firestore.collection('properties').doc(id).update({
        'favoritesCount': FieldValue.increment(value),
      });
    } catch (e) {
      debugPrint('⚠️ فشل تحديث المفضلات: $e');
    }
  }

  // ============================================================
  // تقييم عقار
  // ============================================================
  Future<void> rateProperty(String id, double rating, String? review) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('يجب تسجيل الدخول للتقييم');
    }

    try {
      final doc = _firestore.collection('properties').doc(id);
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(doc);
        if (!snapshot.exists) {
          throw Exception('العقار غير موجود');
        }
        final data = Map<String, dynamic>.from(snapshot.data()!);

        final currentRating = (data['rating'] ?? 0.0) as double;
        final currentCount = (data['ratingCount'] ?? 0) as int;
        final newCount = currentCount + 1;
        final newRating = ((currentRating * currentCount) + rating) / newCount;

        final Map<String, dynamic> updates = {
          'rating': newRating,
          'ratingCount': newCount,
        };

        if (review != null && review.isNotEmpty) {
          final reviews = List<Map<String, dynamic>>.from(
            data['reviews'] ?? [],
          );
          reviews.add({
            'userId': user.uid,
            'rating': rating,
            'review': review,
            'createdAt': FieldValue.serverTimestamp(),
          });
          updates['reviews'] = reviews;
        }

        transaction.update(doc, updates);
      });
      debugPrint('✅ تم إضافة التقييم بنجاح');
    } catch (e) {
      debugPrint('❌ خطأ في التقييم: $e');
      rethrow;
    }
  }

  // ============================================================
  // جلب العقارات المفضلة
  // ============================================================
  Future<List<Property>> getFavorites(List<String> favoriteIds) async {
    if (favoriteIds.isEmpty) return [];
    
    try {
      List<Property> favorites = [];
      for (String id in favoriteIds) {
        try {
          final doc = await _firestore.collection('properties').doc(id).get();
          if (doc.exists) {
            favorites.add(
              Property.fromMap(
                  doc.id,
                  Map<String, dynamic>.from(
                    doc.data() as Map<String, dynamic>,
                  ),
                ),
            );
          }
        } catch (e) {
          debugPrint('⚠️ فشل جلب عقار مفضل: $e');
        }
      }
      return favorites;
    } catch (e) {
      debugPrint('❌ خطأ في جلب المفضلات: $e');
      return [];
    }
  }
}
