import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  /// تسجيل الخروج
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('❌ خطأ في تسجيل الخروج: $e');
      throw Exception('فشل تسجيل الخروج');
    }
  }

  /// إرسال رمز OTP إلى رقم الهاتف
  Future<void> sendOTP(String phoneNumber, Function(String) onCodeSent) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('❌ فشل التحقق: ${e.message}');
          throw Exception(e.message ?? 'حدث خطأ في التحقق من رقم الهاتف');
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      debugPrint('❌ خطأ في إرسال OTP: $e');
      rethrow;
    }
  }

  /// التحقق من رمز OTP وتسجيل الدخول
  Future<UserCredential> verifyOTP(
    String verificationId,
    String smsCode,
  ) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final result = await _auth.signInWithCredential(credential);

      final user = result.user;

      if (user == null) {
        throw Exception('فشل تسجيل الدخول');
      }

      // حفظ بيانات المستخدم في Firestore
      await saveUserData(user.uid, {
        'uid': user.uid,
        'phone': user.phoneNumber ?? '',
        'name': '',
        'isAdmin': false,
        'isVerified': false,
        'favorites': [],
      });

      return result;
    } catch (e) {
      debugPrint('❌ خطأ في التحقق من OTP: $e');
      if (e is FirebaseAuthException) {
        if (e.code == 'invalid-verification-code') {
          throw Exception('رمز التحقق غير صحيح');
        } else if (e.code == 'session-expired') {
          throw Exception('انتهت صلاحية الرمز، يرجى المحاولة مرة أخرى');
        }
      }
      throw Exception('فشل التحقق من الرمز');
    }
  }

  /// جلب بيانات المستخدم من Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        return null;
      }

      return doc.data();
    } catch (e) {
      debugPrint('❌ خطأ في جلب بيانات المستخدم: $e');
      return null;
    }
  }

  /// حفظ أو تحديث بيانات المستخدم
  Future<void> saveUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .set(data, SetOptions(merge: true));
    } catch (e) {
      debugPrint('❌ خطأ في حفظ بيانات المستخدم: $e');
      throw Exception('فشل حفظ البيانات');
    }
  }
}
