# 🏠 بيتك عندنا - تطبيق إدارة الإيجارات

## 📱 عن التطبيق

**بيتك عندنا** هو تطبيق Flutter لإدارة إيجار العقارات في السودان. يتيح للمستخدمين:
- 🔍 البحث عن عقارات للإيجار
- ➕ إضافة إعلانات جديدة
- ⭐ حفظ العقارات المفضلة
- 💬 التواصل مع الملاك
- 🔔 استقبال إشعارات

---

## ⚡ **بدء سريع**

### إذا كان Flutter مثبتاً:

```bash
# 1. تنظيف المشروع
flutter clean
flutter pub get

# 2. نشر Firebase Rules
firebase login
firebase deploy --only firestore:rules

# 3. تشغيل التطبيق
flutter run
```

### إذا لم يكن Flutter مثبتاً:
👉 **راجع `SETUP_GUIDE.md` لدليل التثبيت الكامل**

---

## 🗑️ **تنظيف الملفات القديمة**

### Windows PowerShell:
```powershell
.\cleanup.ps1
```

### أو يدوياً:
احذف جميع ملفات:
- `*.sh` (46 ملف)
- `*.backup`, `*.bak` (3 ملفات)
- `Get`, `Process`, `Run`
- `analyze_result.txt`, `project_dump.txt`

---

## 🔒 **التحديثات الأمنية الأخيرة**

✅ تم إصلاح 3 ثغرات أمنية حرجة في Firestore Rules  
✅ تم إصلاح 5 أخطاء وظيفية  
✅ تم تطبيق 12+ تحسين على الكود  

👉 **راجع `SECURITY_AUDIT_REPORT.md` للتفاصيل الكاملة**

---

## 🛠️ **التقنيات المستخدمة**

- **Flutter** - فريموورك UI
- **Firebase** - Backend (Auth, Firestore, Storage, Messaging)
- **Provider** - State Management
- **Google Maps** - عرض المواقع
- **Phone Auth** - تسجيل الدخول

---

## 📂 **هيكل المشروع**

```
lib/
├── models/          # نماذج البيانات
│   ├── property_model.dart
│   └── user_model.dart
├── providers/       # إدارة الحالة
│   └── app_provider.dart
├── screens/         # الشاشات
│   ├── home_screen.dart
│   ├── login_screen.dart
│   ├── search_screen.dart
│   ├── profile_screen.dart
│   └── ...
├── services/        # الخدمات
│   ├── auth_service.dart
│   ├── property_service.dart
│   └── notification_service.dart
├── widgets/         # مكونات قابلة لإعادة الاستخدام
│   └── property_card.dart
├── utils/           # أدوات مساعدة
│   └── constants.dart
└── main.dart        # نقطة البداية
```

---

## 🧪 **الاختبار**

### اختبارات أساسية:
1. ✅ تسجيل الدخول بـ OTP
2. ✅ إضافة عقار جديد
3. ✅ البحث والفلاتر
4. ✅ المفضلة
5. ✅ الملف الشخصي

### اختبار الأمان:
- جرب تعديل `status` لعقار من Firestore Console → يجب أن يفشل
- جرب تعديل `isAdmin` لمستخدم → يجب أن يفشل

---

## 📱 **بناء APK**

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle (Play Store)
flutter build appbundle --release
```

الملف سيكون في:
- APK: `build/app/outputs/flutter-apk/`
- AAB: `build/app/outputs/bundle/release/`

---

## 🐛 **حل المشاكل**

### "flutter: command not found"
- تأكد من تثبيت Flutter وإضافته إلى PATH
- راجع `SETUP_GUIDE.md`

### "firebase: command not found"
- ثبّت Firebase CLI: `npm install -g firebase-tools`

### مشاكل أخرى؟
- راجع `SETUP_GUIDE.md` → قسم "حل المشاكل الشائعة"

---

## 📄 **الملفات المهمة**

- `SETUP_GUIDE.md` - دليل التثبيت والإعداد الكامل
- `SECURITY_AUDIT_REPORT.md` - تقرير المراجعة الأمنية
- `cleanup.ps1` - سكريبت لحذف الملفات القديمة
- `firestore.rules` - قواعد الأمان (تم تحديثها)
- `storage.rules` - قواعد Storage

---

## 📞 **الدعم**

واجهت مشكلة؟
1. راجع `SETUP_GUIDE.md`
2. راجع `SECURITY_AUDIT_REPORT.md`
3. افحص logs: `flutter run --verbose`

---

## ⚖️ **الترخيص**

هذا المشروع للاستخدام الشخصي أو التعليمي.

---

**بيتك... أقرب مما تتخيل 🏠**
