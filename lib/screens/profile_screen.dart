import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/app_provider.dart';
import '../utils/constants.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import 'notifications_screen.dart';
import '../admin/admin_dashboard.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final uid = user.uid;
        final userMap = await Provider.of<AppProvider>(
          context,
          listen: false,
        ).authService.getUserData(uid);

        if (mounted) {
          setState(() {
            _userData = userMap != null ? UserModel.fromMap(userMap) : null;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Profile Error: $e");

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userData == null
              ? const Center(child: Text('لا توجد بيانات'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // الصورة الشخصية
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primary,
                        backgroundImage: _userData!.profileImage != null
                            ? NetworkImage(_userData!.profileImage!)
                            : null,
                        child: _userData!.profileImage == null
                            ? Text(
                                _userData!.name.isNotEmpty
                                    ? _userData!.name[0].toUpperCase()
                                    : '؟',
                                style: const TextStyle(
                                  fontSize: 40,
                                  color: AppColors.white,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _userData!.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _userData!.phone,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_userData!.isVerified)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.verified,
                              color: AppColors.secondary,
                              size: 20,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'حساب موثق',
                              style: TextStyle(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 24),
                      const Divider(),

                      // القائمة
                      ListTile(
                        leading: const Icon(
                          Icons.edit,
                          color: AppColors.primary,
                        ),
                        title: const Text('تعديل الملف الشخصي'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfileScreen(),
                            ),
                          );
                          if (result == true) {
                            _loadUserData();
                          }
                        },
                      ),

                      ListTile(
                        leading: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                        ),
                        title: const Text('المفضلة'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // الانتقال إلى شاشة المفضلة (موجودة بالفعل في bottom navigation)
                          Navigator.pop(context);
                        },
                      ),

                      ListTile(
                        leading: const Icon(
                          Icons.home,
                          color: AppColors.primary,
                        ),
                        title: const Text('عقاراتي'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // يمكنك إضافة شاشة لعرض عقارات المستخدم
                          debugPrint("Navigate to My Properties");
                        },
                      ),

                      if (_userData!.isAdmin)
                        ListTile(
                          leading: const Icon(
                            Icons.admin_panel_settings,
                            color: AppColors.warning,
                          ),
                          title: const Text('لوحة التحكم - المشرف'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AdminDashboard(),
                              ),
                            );
                          },
                        ),

                      ListTile(
                        leading: const Icon(
                          Icons.settings,
                          color: AppColors.primary,
                        ),
                        title: const Text('الإعدادات'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),

                      const Divider(),

                      ListTile(
                        leading: const Icon(
                          Icons.logout,
                          color: Colors.red,
                        ),
                        title: const Text(
                          'تسجيل الخروج',
                          style: TextStyle(color: Colors.red),
                        ),
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('تسجيل الخروج'),
                              content: const Text(
                                'هل أنت متأكد من تسجيل الخروج؟',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('إلغاء'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text(
                                    'تسجيل الخروج',
                                    style: TextStyle(color: AppColors.white),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await Provider.of<AppProvider>(
                              context,
                              listen: false,
                            ).logout();

                            if (mounted) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                                (route) => false,
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
    );
  }
}
