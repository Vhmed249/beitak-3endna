# 📱 دليل الإعداد والتشغيل - مشروع "بيتك عندنا"

## ⚠️ **المتطلبات الأساسية**

قبل البدء، تأكد من تثبيت:
1. ✅ **Flutter SDK** (الإصدار 3.0 أو أحدث)
2. ✅ **Android Studio** أو **VS Code** مع ملحقات Flutter/Dart
3. ✅ **Firebase CLI** (لنشر القواعد)
4. ✅ **Git** (اختياري)

---

## 📥 **المرحلة 1: تثبيت Flutter**

### **Windows:**

#### **الطريقة 1: تثبيت يدوي (مُوصى به)**

1. **تحميل Flutter SDK:**
   - اذهب إلى: https://docs.flutter.dev/get-started/install/windows
   - حمّل ملف ZIP الأحدث
   - استخرجه في: `C:\src\flutter` (أو أي مسار تفضله)

2. **إضافة Flutter إلى PATH:**
   - افتح "بحث Windows" → اكتب "Environment Variables"
   - اختر "Edit the system environment variables"
   - اضغط "Environment Variables..."
   - في "System Variables" → اختر "Path" → Edit
   - اضغط "New" → أضف: `C:\src\flutter\bin`
   - اضغط OK على جميع النوافذ

3. **أعد تشغيل PowerShell/CMD**

4. **تحقق من التثبيت:**
   ```powershell
   flutter --version
   flutter doctor
   ```

#### **الطريقة 2: باستخدام Chocolatey (أسرع)**

```powershell
# افتح PowerShell كـ Administrator
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# ثم ثبّت Flutter
choco install flutter
```

---

## 🔥 **المرحلة 2: تثبيت Firebase CLI**

### **Windows:**

#### **الطريقة 1: باستخدام npm (مُوصى به)**

```powershell
# تثبيت Node.js أولاً من: https://nodejs.org/

# ثم ثبّت Firebase CLI
npm install -g firebase-tools

# تحقق من التثبيت
firebase --version
```

#### **الطريقة 2: باستخدام Standalone Binary**

1. حمّل من: https://firebase.tools/bin/win/instant/latest
2. أعد تسمية الملف إلى `firebase.exe`
3. ضعه في مجلد (مثل `C:\firebase`)
4. أضف المجلد إلى PATH (نفس خطوات Flutter)

---

## 🚀 **المرحلة 3: إعداد المشروع**

### **1. التحقق من التثبيت:**

```powershell
# تحقق من Flutter
flutter --version
flutter doctor

# تحقق من Firebase CLI
firebase --version
```

### **2. الانتقال إلى مجلد المشروع:**

```powershell
cd "C:\Users\Ahmed\Desktop\beitak-3endna-main (1)\beitak-3endna-main"
```

### **3. تنظيف وتحديث المشروع:**

```powershell
# تنظيف الـ build القديم
flutter clean

# تحميل الحزم
flutter pub get

# تحقق من عدم وجود مشاكل
flutter doctor
```

---

## 🗑️ **المرحلة 4: حذف الملفات القديمة**

### **Windows PowerShell:**

```powershell
# احذف ملفات Shell Scripts القديمة
Remove-Item *.sh -Force

# احذف ملفات الـ Backup
Remove-Item *.backup -Force
Remove-Item *.bak -Force

# احذف ملفات أخرى
Remove-Item Get, Process, Run, analyze_result.txt, project_dump.txt -Force -ErrorAction SilentlyContinue
```

### **أو يدوياً:**
افتح المجلد واحذف:
- جميع ملفات `.sh`
- `firestore.rules.backup`
- `storage.rules.backup`
- `pubspec.yaml.bak`
- `Get`, `Process`, `Run`
- `analyze_result.txt`, `project_dump.txt`

---

## 🔥 **المرحلة 5: إعداد Firebase**

### **1. تسجيل الدخول:**

```powershell
firebase login
```

### **2. تهيئة المشروع (إذا لم يكن مُهيأ):**

```powershell
firebase init

# اختر:
# - Firestore
# - Storage
# - (اختياري) Hosting, Functions
```

### **3. نشر قواعد Firestore الجديدة:**

```powershell
firebase deploy --only firestore:rules
```

### **4. (اختياري) نشر قواعد Storage:**

```powershell
firebase deploy --only storage:rules
```

---

## 📱 **المرحلة 6: تشغيل التطبيق**

### **1. توصيل جهاز أو تشغيل emulator:**

#### **جهاز حقيقي (Android):**
- فعّل "Developer Options" على الجهاز
- فعّل "USB Debugging"
- وصّل الجهاز بالكمبيوتر

#### **Emulator:**
```powershell
# افتح Android Studio → AVD Manager → Start Emulator
# أو من الـ terminal:
flutter emulators --launch <emulator_name>
```

### **2. التحقق من الأجهزة المتصلة:**

```powershell
flutter devices
```

### **3. تشغيل التطبيق:**

```powershell
# Debug Mode
flutter run

# أو Release Mode
flutter run --release

# أو لجهاز محدد
flutter run -d <device_id>
```

---

## 🏗️ **المرحلة 7: بناء APK للإنتاج**

### **Android APK:**

```powershell
# بناء APK (حجم أكبر لكن متوافق مع جميع الأجهزة)
flutter build apk --release

# الملف سيكون في:
# build\app\outputs\flutter-apk\app-release.apk
```

### **Android App Bundle (مُوصى به لـ Play Store):**

```powershell
# بناء AAB (حجم أصغر وأفضل)
flutter build appbundle --release

# الملف سيكون في:
# build\app\outputs\bundle\release\app-release.aab
```

---

## 🧪 **المرحلة 8: الاختبار**

### **1. اختبارات أساسية:**

```powershell
# اختبار تسجيل الدخول
# - سجل دخول برقم هاتف جديد
# - تأكد من استلام OTP

# اختبار إضافة عقار
# - أضف عقار جديد
# - تأكد من ظهوره كـ "pending"

# اختبار البحث
# - ابحث عن عقار بالمدينة
# - تأكد من عمل الفلاتر

# اختبار الملف الشخصي
# - افتح الملف الشخصي
# - تأكد من ظهور جميع الخيارات
```

### **2. اختبار الأمان (مهم!):**

```powershell
# افتح Firebase Console
# - اذهب إلى Firestore
# - جرب تعديل status لعقار من "pending" إلى "approved"
# - يجب أن يفشل إذا لم تكن مشرفاً

# جرب تعديل isAdmin لمستخدم
# - يجب أن يفشل
```

---

## 🐛 **حل المشاكل الشائعة**

### **1. "flutter: command not found"**
- تأكد من إضافة Flutter إلى PATH
- أعد تشغيل Terminal/PowerShell

### **2. "firebase: command not found"**
- تأكد من تثبيت Firebase CLI
- أعد تشغيل Terminal/PowerShell

### **3. "Waiting for another flutter command to release the startup lock"**
```powershell
# احذف ملف القفل
Remove-Item "$env:LOCALAPPDATA\flutter\.flutter_tool_state" -Force
```

### **4. "Android licenses not accepted"**
```powershell
flutter doctor --android-licenses
# اقبل جميع الرخص بالضغط على 'y'
```

### **5. مشاكل Gradle**
```powershell
cd android
.\gradlew clean
cd ..
flutter clean
flutter pub get
```

### **6. "Could not find package"**
```powershell
flutter pub cache repair
flutter pub get
```

---

## 📚 **موارد مفيدة**

### **Documentation:**
- Flutter: https://docs.flutter.dev
- Firebase: https://firebase.google.com/docs
- Dart: https://dart.dev/guides

### **Community:**
- Flutter Discord: https://discord.gg/flutter
- Stack Overflow: https://stackoverflow.com/questions/tagged/flutter

### **Tutorials:**
- Flutter YouTube: https://www.youtube.com/flutterdev
- Firebase YouTube: https://www.youtube.com/firebase

---

## 📞 **الدعم**

إذا واجهت مشاكل:
1. راجع `SECURITY_AUDIT_REPORT.md` للتفاصيل الكاملة
2. افحص logs: `flutter run --verbose`
3. تحقق من Firebase Console للأخطاء
4. تأكد من صحة firebase_options.dart

---

## ✅ **Checklist قبل النشر**

- [ ] تم اختبار تسجيل الدخول
- [ ] تم اختبار إضافة عقار
- [ ] تم اختبار البحث والفلاتر
- [ ] تم اختبار المفضلة
- [ ] تم اختبار الملف الشخصي
- [ ] تم اختبار لوحة التحكم (للمشرف)
- [ ] تم نشر firestore.rules الجديدة
- [ ] تم حذف الملفات القديمة
- [ ] تم اختبار الأمان (محاولة التلاعب)
- [ ] تم بناء APK نهائي
- [ ] تم اختبار APK على أجهزة مختلفة

---

**حظاً موفقاً! 🚀**
