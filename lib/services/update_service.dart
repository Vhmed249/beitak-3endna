import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UpdateService {
  /// الحصول على رقم إصدار التطبيق الحالي
  Future<String> currentVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return info.version;
    } catch (e) {
      debugPrint('❌ خطأ في الحصول على رقم الإصدار: $e');
      return '1.0.0';
    }
  }

  /// الحصول على معلومات التطبيق الكاملة
  Future<Map<String, String>> getAppInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return {
        'appName': info.appName,
        'packageName': info.packageName,
        'version': info.version,
        'buildNumber': info.buildNumber,
      };
    } catch (e) {
      debugPrint('❌ خطأ في الحصول على معلومات التطبيق: $e');
      return {
        'appName': 'بيتك عندنا',
        'packageName': 'com.beitak3endna.app',
        'version': '1.0.0',
        'buildNumber': '1',
      };
    }
  }
}
