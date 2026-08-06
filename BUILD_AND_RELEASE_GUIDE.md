# دليل البناء والنشر - بيتك عندنا

## 📋 المتطلبات الأساسية

### 1. تثبيت Flutter
```bash
# تحقق من تثبيت Flutter
flutter --version

# يجب أن يكون الإصدار 3.4.0 أو أحدث
```

### 2. تثبيت Android SDK
- Android Studio
- Android SDK Platform 35
- Android SDK Build-Tools
- NDK Version 25.1.8937393

---

## 🔑 إعداد التوقيع (Release Signing)

### الخطوة 1: إنشاء Keystore
```bash
# في مجلد android/ قم بتنفيذ:
keytool -genkey -v -keystore beitak-3endna-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias beitak3endna
```

### الخطوة 2: إنشاء ملف key.properties
قم بإنشاء ملف `android/key.properties` بالمحتوى التالي:

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=beitak3endna
storeFile=beitak-3endna-keystore.jks
```

**⚠️ هام:** لا تضف هذا الملف إلى Git! تأكد من وجوده في `.gitignore`

---

## 🧪 الاختبار والتحقق

### 1. تنظيف المشروع
```bash
flutter clean
flutter pub get
```

### 2. تحليل الكود
```bash
flutter analyze
```

**النتيجة المتوقعة:** 0 issues found

### 3. تنسيق الكود
```bash
dart format lib/
```

### 4. اختبار البناء (Debug)
```bash
flutter build apk --debug
```

---

## 🚀 بناء النسخة النهائية

### بناء APK
```bash
flutter build apk --release
```

الملف الناتج: `build/app/outputs/flutter-apk/app-release.apk`

### بناء App Bundle (موصى به لـ Google Play)
```bash
flutter build appbundle --release
```

الملف الناتج: `build/app/outputs/bundle/release/app-release.aab`

---

## 📱 التثبيت والاختبار

### تثبيت APK على الجهاز
```bash
flutter install --release
```

### أو يدوياً:
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## ✅ قائمة التحقق قبل النشر

### التحقق من الكود
- [x] لا توجد أخطاء في `flutter analyze`
- [x] تم تنسيق الكود بـ `dart format`
- [x] تم اختبار جميع الميزات الأساسية
- [x] تم اختبار تسجيل الدخول
- [x] تم اختبار إضافة عقار
- [x] تم اختبار البحث
- [x] تم اختبار المفضلة

### التحقق من Firebase
- [x] Firestore Rules محدثة ومنشورة
- [x] Storage Rules محدثة ومنشورة
- [x] Firebase Authentication مفعّل
- [x] تم اختبار جميع عمليات Firebase

### التحقق من Android
- [x] تم إعداد التوقيع (Signing)
- [x] تم تحديث versionCode في pubspec.yaml
- [x] تم تحديث versionName في pubspec.yaml
- [x] تم اختبار البناء Release
- [x] تم اختبار التطبيق على أجهزة مختلفة

### التحقق من الصلاحيات
- [x] INTERNET - للاتصال بالإنترنت
- [x] ACCESS_FINE_LOCATION - لتحديد الموقع
- [x] ACCESS_COARSE_LOCATION - لتحديد الموقع التقريبي
- [x] READ_MEDIA_IMAGES - لاختيار الصور

---

## 🌐 نشر Firebase Rules

### Firestore Rules
```bash
firebase deploy --only firestore:rules
```

### Storage Rules
```bash
firebase deploy --only storage
```

---

## 📤 النشر على Google Play Console

### 1. تجهيز الملفات المطلوبة
- App Bundle (AAB): `app-release.aab`
- لقطات الشاشة (Screenshots): 4-8 صور
- أيقونة التطبيق: 512x512 PNG
- صورة المميزة: 1024x500 PNG
- وصف التطبيق (عربي/إنجليزي)
- سياسة الخصوصية

### 2. رفع التطبيق
1. افتح Google Play Console
2. اختر التطبيق
3. انتقل إلى Production > Create new release
4. ارفع ملف AAB
5. أضف Release notes
6. اضغط Review release
7. اضغط Start rollout to Production

---

## 🔧 استكشاف الأخطاء

### مشكلة: Keystore not found
**الحل:** تأكد من وجود ملف `key.properties` و keystore في المكان الصحيح

### مشكلة: Gradle build failed
**الحل:**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### مشكلة: Firebase configuration
**الحل:** تأكد من وجود `google-services.json` في `android/app/`

---

## 📊 معلومات البناء

### الإصدار الحالي
- Version: 4.0.0
- Build Number: 1

### حجم التطبيق (تقريبي)
- APK: ~40-50 MB
- App Bundle: ~35-45 MB

### الأجهزة المدعومة
- Min SDK: 21 (Android 5.0)
- Target SDK: 35 (Android 15)

---

## 📝 ملاحظات مهمة

1. **احتفظ بنسخة احتياطية من Keystore** - إذا فقدته لن تستطيع تحديث التطبيق!
2. **لا تشارك key.properties** - هذا الملف يحتوي على معلومات سرية
3. **اختبر Release Build** دائماً قبل النشر - قد تختلف عن Debug
4. **تحديث versionCode** - يجب زيادته مع كل نشر جديد
5. **مراجعة Firebase Rules** - تأكد من أمان البيانات

---

## 🆘 الدعم والمساعدة

للمزيد من المعلومات:
- [Flutter Documentation](https://docs.flutter.dev)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Google Play Console Help](https://support.google.com/googleplay/android-developer)

---

## ✨ التحسينات المطبقة

### الكود
- ✅ معالجة شاملة للأخطاء
- ✅ تسجيل Debug بالعربية
- ✅ منع Memory Leaks
- ✅ Null Safety كامل

### الأداء
- ✅ ضغط الصور (65% جودة)
- ✅ استخدام CachedNetworkImage
- ✅ Debouncing في البحث (500ms)
- ✅ RepaintBoundary في PropertyCard

### الأمان
- ✅ Firestore Rules محكمة
- ✅ Storage Rules محكمة
- ✅ التحقق من الصلاحيات
- ✅ تنظيف أرقام الهواتف

### Android
- ✅ ProGuard Rules
- ✅ Signing Configuration
- ✅ MultiDex مفعّل
- ✅ Minify و Shrink مفعّل

---

**تم بنجاح! المشروع جاهز للنشر على Google Play Store 🎉**
