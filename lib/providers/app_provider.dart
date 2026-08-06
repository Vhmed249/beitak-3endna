import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/property_service.dart';
import '../models/user_model.dart';

class AppProvider extends ChangeNotifier {
  final AuthService authService = AuthService();
  final PropertyService propertyService = PropertyService();

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  List<String> _favorites = [];
  List<String> get favorites => _favorites;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isDisposed = false;

  // ============================================================
  // المُنشئ
  // ============================================================
  AppProvider() {
    Future.microtask(() async {
      await _loadTheme();

      FirebaseAuth.instance.authStateChanges().listen((user) {
        if (_isDisposed) return;
        
        if (user != null) {
          loadUserData();
        } else {
          _currentUser = null;
          _favorites = [];
          if (!_isDisposed) {
            notifyListeners();
          }
        }
      });
    });
  }

  // ============================================================
  // تحميل بيانات المستخدم
  // ============================================================
  Future<void> loadUserData() async {
    if (_isDisposed) return;
    
    _errorMessage = null;
    _isLoading = true;
    if (!_isDisposed) {
      notifyListeners();
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists && !_isDisposed) {
          _currentUser = UserModel.fromMap(doc.data()!);
          _favorites = _currentUser?.favorites ?? [];
          _errorMessage = null;
          debugPrint('✅ تم تحميل بيانات المستخدم: ${_currentUser!.name}');
        }
      }
    } catch (e) {
      _errorMessage = "تعذر تحميل بيانات المستخدم";
      debugPrint("❌ خطأ في تحميل بيانات المستخدم: $e");
    } finally {
      _isLoading = false;
      if (!_isDisposed) {
        notifyListeners();
      }
    }
  }

  // ============================================================
  // تحديث بيانات المستخدم
  // ============================================================
  Future<void> updateUserData(UserModel user) async {
    if (_isDisposed) return;
    
    try {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
      await userDoc.set(user.toMap(), SetOptions(merge: true));
      _currentUser = user;
      if (!_isDisposed) {
        notifyListeners();
      }
      debugPrint('✅ تم تحديث بيانات المستخدم');
    } catch (e) {
      debugPrint("❌ خطأ في تحديث بيانات المستخدم: $e");
      rethrow;
    }
  }

  // ============================================================
  // المفضلة
  // ============================================================
  Future<void> _syncFavoritesToCloud() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || _currentUser == null) return;

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'favorites': _favorites},
      );

      // تحديث القائمة المحلية
      _currentUser = _currentUser!.copyWith(favorites: List.from(_favorites));
      debugPrint('✅ تم مزامنة المفضلات مع السحابة');
    } catch (e) {
      debugPrint("❌ خطأ في مزامنة المفضلات: $e");
    }
  }

  Future<void> toggleFavorite(String propertyId) async {
    if (_isDisposed) return;
    
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      debugPrint("⚠️ يجب تسجيل الدخول لإضافة المفضلة");
      return;
    }

    final bool adding = !_favorites.contains(propertyId);

    // التحديث المحلي الفوري
    if (adding) {
      if (!_favorites.contains(propertyId)) {
        _favorites.add(propertyId);
      }
    } else {
      _favorites.remove(propertyId);
    }

    if (!_isDisposed) {
      notifyListeners();
    }

    // المزامنة مع السحابة
    try {
      await _syncFavoritesToCloud();

      // تحديث عداد المفضلات في العقار
      await FirebaseFirestore.instance
          .collection('properties')
          .doc(propertyId)
          .update({'favoritesCount': FieldValue.increment(adding ? 1 : -1)});
      
      debugPrint('✅ ${adding ? "تمت إضافة" : "تمت إزالة"} العقار ${adding ? "إلى" : "من"} المفضلة');
    } catch (e) {
      debugPrint("❌ خطأ في تحديث المفضلة: $e");
      
      // التراجع عن التغيير المحلي في حالة الفشل
      if (adding) {
        _favorites.remove(propertyId);
      } else {
        if (!_favorites.contains(propertyId)) {
          _favorites.add(propertyId);
        }
      }
      
      if (!_isDisposed) {
        notifyListeners();
      }
    }
  }

  bool isFavorite(String propertyId) => _favorites.contains(propertyId);

  // ============================================================
  // الوضع الليلي
  // ============================================================
  void toggleDarkMode() {
    if (_isDisposed) return;
    
    _isDarkMode = !_isDarkMode;
    _saveTheme();
    if (!_isDisposed) {
      notifyListeners();
    }
    debugPrint('🌙 تم تغيير الوضع ${_isDarkMode ? "الليلي" : "النهاري"}');
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool('darkMode') ?? false;
      if (!_isDisposed) {
        notifyListeners();
      }
      debugPrint('✅ تم تحميل إعدادات الثيم');
    } catch (e) {
      debugPrint("⚠️ خطأ في تحميل الثيم: $e");
    }
  }

  Future<void> _saveTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('darkMode', _isDarkMode);
      debugPrint('✅ تم حفظ إعدادات الثيم');
    } catch (e) {
      debugPrint("⚠️ خطأ في حفظ الثيم: $e");
    }
  }

  bool get isLoggedIn => FirebaseAuth.instance.currentUser != null;

  // ============================================================
  // تسجيل الخروج
  // ============================================================
  Future<void> logout() async {
    if (_isDisposed) return;
    
    try {
      await authService.logout();
      _currentUser = null;
      _favorites = [];
      _isLoading = false;
      _errorMessage = null;
      if (!_isDisposed) {
        notifyListeners();
      }
      debugPrint('✅ تم تسجيل الخروج بنجاح');
    } catch (e) {
      debugPrint("❌ خطأ في تسجيل الخروج: $e");
      rethrow;
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    debugPrint('🗑️ تم التخلص من AppProvider');
    super.dispose();
  }
}
