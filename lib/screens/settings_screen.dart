import 'verification_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/app_provider.dart';
import '../utils/constants.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    // هنا يمكنك تحميل تفضيل الإشعارات من SharedPreferences أو Firestore
    // حالياً سنفترض أنه مفعل
  }

  Future<void> _saveNotificationPreference(bool value) async {
    // حفظ التفضيل في SharedPreferences أو Firestore
    setState(() {
      _notificationsEnabled = value;
    });
    // مثال: حفظ في SharedPreferences
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setBool('notifications', value);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('الإعدادات'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: ListView(
        children: [
          // ===== الوضع الليلي =====
          SwitchListTile(
            title: Text('الوضع الليلي'),
            subtitle: Text('تفعيل المظهر الداكن للتطبيق'),
            value: provider.isDarkMode,
            onChanged: (_) => provider.toggleDarkMode(),
            secondary: Icon(
              provider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
          ),

          // ===== الإشعارات =====
          SwitchListTile(
            title: Text('الإشعارات'),
            subtitle: Text('تلقي إشعارات عند الرسائل والتحديثات'),
            value: _notificationsEnabled,
            onChanged: (value) => _saveNotificationPreference(value),
            secondary: Icon(Icons.notifications),
          ),

          const Divider(),

          // ===== معلومات المستخدم =====
          ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              child: Text(user?.displayName?.substring(0, 1) ?? 'U'),
            ),
            title: Text(user?.displayName ?? 'مستخدم'),
            subtitle: Text(user?.phoneNumber ?? ''),
          ),

          const Divider(),

          // ===== التحقق من الهوية =====
          ListTile(
            leading: Icon(Icons.verified, color: AppColors.primary),
            title: Text('التحقق من الهوية'),
            subtitle: Text('رفع المستندات للتحقق من حسابك'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => VerificationScreen()),
              );
            },
          ),

          // ===== سياسة الخصوصية =====
          ListTile(
            leading: Icon(Icons.privacy_tip, color: AppColors.primary),
            title: Text('سياسة الخصوصية'),
            onTap: () {
              // عرض سياسة الخصوصية (يمكنك وضع رابط أو نص)
            },
          ),

          // ===== الإصدار =====
          ListTile(
            leading: Icon(Icons.info, color: AppColors.primary),
            title: Text('الإصدار'),
            trailing: Text('1.0.0', style: TextStyle(color: Colors.grey[600])),
          ),

          const Divider(),

          // ===== تسجيل الخروج =====
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await Provider.of<AppProvider>(
                context,
                listen: false,
              ).authService.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
